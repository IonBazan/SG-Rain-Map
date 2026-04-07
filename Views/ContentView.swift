// MARK: - ContentView
// Main window: full-bleed map, toolbar controls, time-scrub slider, status bar

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var viewModel = RadarViewModel()
    @State private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: RadarConstants.defaultCenter,
        span: RadarConstants.defaultSpan
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Map (full-bleed)
            MapView(
                radarImage: $viewModel.currentRadarImage,
                region: $region,
                centerOnUserTrigger: locationManager.centerOnUserTrigger,
                userLocation: locationManager.userLocation
            )
            .ignoresSafeArea()

            // MARK: Loading shimmer
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.7)
                    .padding(8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding([.top, .trailing], 12)
            }

            // MARK: Bottom overlay (slider + legend + status)
            VStack(spacing: 0) {
                // Time-scrub slider
                if !viewModel.timestamps.isEmpty {
                    VStack(spacing: 4) {
                        HStack {
                            Text(viewModel.oldestTimeLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: 4) {
                                if viewModel.isShowingLive {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 6, height: 6)
                                }
                                Text(viewModel.selectedTimeLabel)
                                    .font(.caption.bold())
                                    .foregroundStyle(viewModel.isShowingLive ? .red : .primary)
                            }
                            Spacer()
                            Text("Now")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(viewModel.timestamps.count - 1 - viewModel.selectedIndex) },
                                set: { viewModel.selectedIndex = viewModel.timestamps.count - 1 - Int($0) }
                            ),
                            in: 0...Double(max(viewModel.timestamps.count - 1, 1)),
                            step: 1
                        )
                        .tint(.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                // Legend + status bar
                HStack {
                    RainLegendView()

                    Spacer()

                    Text(viewModel.lastUpdatedText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let error = viewModel.errorMessage {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                            .help(error)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .padding(.top, 4)
            }
            .background(.regularMaterial)
        }

        // MARK: Toolbar
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    Task { await viewModel.loadLatest() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .help("Refresh (⌘R)")
                .keyboardShortcut("r", modifiers: .command)

                Button {
                    locationManager.centerOnUser()
                } label: {
                    Label("My Location", systemImage: "location.fill")
                }
                .help("My Location (⌘L)")
                .keyboardShortcut("l", modifiers: .command)
            }
        }

        // MARK: Lifecycle
        .task {
            await viewModel.loadLatest()
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }

        // MARK: Error alert — only shown when there is nothing to display at all
        .alert("Radar Unavailable", isPresented: Binding(
            get: { viewModel.errorMessage != nil && viewModel.currentRadarImage == nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Retry") { Task { await viewModel.loadLatest() } }
            Button("Dismiss", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }

}
