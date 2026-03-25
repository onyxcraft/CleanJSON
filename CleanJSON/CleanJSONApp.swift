import SwiftUI

@main
struct CleanJSONApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .commands {
            MenuCommands()
        }

        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}
