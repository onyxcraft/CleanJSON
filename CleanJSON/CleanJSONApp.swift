import SwiftUI

@main
struct CleanJSONApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 500)
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
