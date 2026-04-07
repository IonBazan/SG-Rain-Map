// MARK: - RadarViewModel

import Foundation
import AppKit
import Observation

@Observable
@MainActor
final class RadarViewModel {

    // MARK: State

    var currentRadarImage: NSImage?
    var isLoading: Bool = false
    var errorMessage: String?
    var lastUpdated: Date?

    var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            if let cached = imageCache[selectedIndex] {
                currentRadarImage = cached
            } else {
                Task { await downloadFrame(at: selectedIndex) }
            }
        }
    }

    // MARK: Private

    private var frames: [RadarFrame] = []
    private var imageCache: [Int: NSImage] = [:]
    private var refreshTask: Task<Void, Never>?

    // MARK: Computed

    var timestamps: [String] { frames.map(\.timestamp) }

    var selectedTimestamp: String {
        frames.indices.contains(selectedIndex) ? frames[selectedIndex].timestamp : ""
    }

    var selectedTimeLabel: String {
        frames.indices.contains(selectedIndex) ? frames[selectedIndex].displayTime : ""
    }

    var lastUpdatedText: String {
        guard let lastUpdated else { return "Not yet loaded" }
        let mins = Int(-lastUpdated.timeIntervalSinceNow / 60)
        return mins < 1 ? "Updated just now" : "Updated \(mins) min ago"
    }

    var isShowingLive: Bool { selectedIndex == 0 }

    /// Display time of the oldest available frame — shown on the left edge of the slider.
    var oldestTimeLabel: String { frames.last?.displayTime ?? "" }

    // MARK: - Public API

    func loadLatest() async {
        frames = RadarService.shared.generateFrames()
        imageCache.removeAll()
        selectedIndex = 0

        // Download frame 0 first so the map shows immediately, then preload the rest.
        await downloadFrame(at: 0)
        Task { await preloadAllFrames() }
    }

    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(RadarConstants.refreshInterval))
                guard !Task.isCancelled else { break }
                await loadLatest()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    // MARK: - Private

    /// Downloads a single frame and stores it in the cache.
    private func downloadFrame(at index: Int) async {
        guard frames.indices.contains(index) else { return }
        let frame = frames[index]

        // Already cached — just display it.
        if let cached = imageCache[index] {
            if index == selectedIndex { currentRadarImage = cached }
            return
        }

        if index == selectedIndex { isLoading = true }

        do {
            let image = try await RadarService.shared.fetchRadarImage(from: frame.imageURL)
            imageCache[index] = image
            if index == selectedIndex {
                currentRadarImage = image
                errorMessage = nil
                if isShowingLive { lastUpdated = Date() }
            }
        } catch {
            if index == selectedIndex && currentRadarImage == nil {
                errorMessage = "Could not load radar: \(error.localizedDescription)"
            }
        }

        if index == selectedIndex { isLoading = false }
    }

    /// Concurrently downloads all frames not already in the cache.
    private func preloadAllFrames() async {
        let indicesToFetch = frames.indices.filter { imageCache[$0] == nil }
        guard !indicesToFetch.isEmpty else { return }

        // Collect results concurrently, then write to cache on MainActor at the end.
        let results = await withTaskGroup(of: (Int, NSImage?).self) { group in
            for i in indicesToFetch {
                let url = frames[i].imageURL
                group.addTask {
                    let image = try? await RadarService.shared.fetchRadarImage(from: url)
                    return (i, image)
                }
            }
            var out: [Int: NSImage] = [:]
            for await (i, image) in group {
                if let image { out[i] = image }
            }
            return out
        }

        // Merge into cache; update display if the selected frame just arrived.
        for (i, image) in results {
            imageCache[i] = image
        }
        if let display = imageCache[selectedIndex], currentRadarImage == nil {
            currentRadarImage = display
        }
    }
}
