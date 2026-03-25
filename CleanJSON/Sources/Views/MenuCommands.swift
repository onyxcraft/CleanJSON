import SwiftUI

struct MenuCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window") {
                NSApp.sendAction(#selector(NSDocumentController.newDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
        }

        CommandGroup(after: .newItem) {
            Button("Open JSON File...") {
                NotificationCenter.default.post(name: .openFile, object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)

            Button("Paste JSON") {
                NotificationCenter.default.post(name: .pasteJSON, object: nil)
            }
            .keyboardShortcut("v", modifiers: [.command, .shift])
        }

        CommandGroup(replacing: .saveItem) {
            Button("Save JSON...") {
                NotificationCenter.default.post(name: .saveFile, object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)
        }

        CommandMenu("Format") {
            Button("Format JSON") {
                NotificationCenter.default.post(name: .formatJSON, object: nil)
            }
            .keyboardShortcut("f", modifiers: .command)

            Button("Minify JSON") {
                NotificationCenter.default.post(name: .minifyJSON, object: nil)
            }
            .keyboardShortcut("m", modifiers: .command)

            Divider()

            Button("Validate JSON") {
                NotificationCenter.default.post(name: .validateJSON, object: nil)
            }
            .keyboardShortcut("r", modifiers: .command)

            Divider()

            Button("Copy Formatted") {
                NotificationCenter.default.post(name: .copyFormatted, object: nil)
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button("Show Tree View") {
                NotificationCenter.default.post(name: .showTreeView, object: nil)
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("Show Compare View") {
                NotificationCenter.default.post(name: .showCompareView, object: nil)
            }
            .keyboardShortcut("2", modifiers: .command)

            Divider()

            Button("Toggle YAML Preview") {
                NotificationCenter.default.post(name: .toggleYAML, object: nil)
            }
            .keyboardShortcut("y", modifiers: .command)
        }
    }
}

extension Notification.Name {
    static let openFile = Notification.Name("openFile")
    static let pasteJSON = Notification.Name("pasteJSON")
    static let saveFile = Notification.Name("saveFile")
    static let formatJSON = Notification.Name("formatJSON")
    static let minifyJSON = Notification.Name("minifyJSON")
    static let validateJSON = Notification.Name("validateJSON")
    static let copyFormatted = Notification.Name("copyFormatted")
    static let showTreeView = Notification.Name("showTreeView")
    static let showCompareView = Notification.Name("showCompareView")
    static let toggleYAML = Notification.Name("toggleYAML")
}
