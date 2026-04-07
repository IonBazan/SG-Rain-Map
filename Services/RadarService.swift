// MARK: - RadarService
// Generates radar frame list locally using the same timestamp floor logic as
// weather.gov.sg's GenerateTimeStamp, then fetches images from weather.gov.sg.

import Foundation
import AppKit

// MARK: - RadarFrame

struct RadarFrame: Sendable {
    let sortingTime: Date
    let imageURL: URL

    /// "YYYYMMDDHHmm" in SGT — used as cache key
    var timestamp: String { Self.timestampFormatter.string(from: sortingTime) }

    /// Human-readable label, e.g. "22:35 SGT"
    var displayTime: String { Self.displayFormatter.string(from: sortingTime) + " SGT" }

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMddHHmm"
        f.timeZone = TimeZone(identifier: "Asia/Singapore")
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone(identifier: "Asia/Singapore")
        return f
    }()
}

// MARK: - RadarService

actor RadarService {
    static let shared = RadarService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: nil
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }

    // MARK: - Frame list

    /// Generates `count` frames newest-first using the same floor logic as
    /// weather.gov.sg's GenerateTimeStamp:
    ///   n = floor(unixMs / 60000)   → whole minutes
    ///   s = floor(n / 5) * 5        → nearest 5-min boundary
    ///   o = s * 60                  → back to seconds
    nonisolated func generateFrames(count: Int = RadarConstants.frameCount) -> [RadarFrame] {
        let now     = Date()
        let minutes = Int(now.timeIntervalSince1970) / 60
        let unix    = (minutes / 5) * 5 * 60
        let base    = Date(timeIntervalSince1970: Double(unix))

        print("[RadarService] generateFrames — now: \(Self.debugFormatter.string(from: now)) | floored to: \(Self.debugFormatter.string(from: base))")

        let frames = (0..<count).compactMap { i -> RadarFrame? in
            let date      = base.addingTimeInterval(Double(-i * 5 * 60))
            let timestamp = Self.timestampFormatter.string(from: date)
            let urlString = "\(RadarConstants.radarBaseURL)dpsri_70km_\(timestamp)0000dBR.dpsri.png"
            guard let url = URL(string: urlString) else { return nil }
            return RadarFrame(sortingTime: date, imageURL: url)
        }

        let oldest = frames.last?.displayTime ?? "–"
        let newest = frames.first?.displayTime ?? "–"
        print("[RadarService] generateFrames — \(frames.count) frames: \(oldest) → \(newest)")
        frames.forEach { print("[RadarService]   \($0.displayTime) → \($0.imageURL)") }

        return frames
    }

    // MARK: - Image fetch

    func fetchRadarImage(from url: URL) async throws -> NSImage {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        let (data, response) = try await session.data(for: request)

        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard status == 200 else {
            print("[RadarService] fetchRadarImage — HTTP \(status) for \(url)")
            throw URLError(.badServerResponse)
        }
        guard let image = NSImage(data: data) else {
            print("[RadarService] fetchRadarImage — failed to decode image data (\(data.count) bytes) for \(url)")
            throw URLError(.cannotDecodeRawData)
        }
        print("[RadarService] fetchRadarImage — OK \(url) (\(data.count / 1024) KB)")
        return image
    }

    // MARK: - Private

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMddHHmm"
        f.timeZone = TimeZone(identifier: "Asia/Singapore")
        return f
    }()

    private static let debugFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss 'SGT'"
        f.timeZone = TimeZone(identifier: "Asia/Singapore")
        return f
    }()
}
