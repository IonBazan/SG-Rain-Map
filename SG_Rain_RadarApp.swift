// MARK: - SG_Rain_RadarApp
// macOS 14+ SwiftUI app entry point

import SwiftUI

@main
struct SG_Rain_RadarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 900, height: 700)
        .commands {
            // Keep standard Edit/Window menus, remove unused items
            CommandGroup(replacing: .newItem) {}
        }
    }
}
