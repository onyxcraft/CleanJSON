import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @Published var indentStyle: IndentStyle {
        didSet {
            UserDefaults.standard.set(indentStyle.rawValue, forKey: "indentStyle")
        }
    }

    @Published var autoFormat: Bool {
        didSet {
            UserDefaults.standard.set(autoFormat, forKey: "autoFormat")
        }
    }

    @Published var validateOnPaste: Bool {
        didSet {
            UserDefaults.standard.set(validateOnPaste, forKey: "validateOnPaste")
        }
    }

    init() {
        self.indentStyle = IndentStyle(rawValue: UserDefaults.standard.string(forKey: "indentStyle") ?? IndentStyle.twoSpaces.rawValue) ?? .twoSpaces
        self.autoFormat = UserDefaults.standard.bool(forKey: "autoFormat")
        self.validateOnPaste = UserDefaults.standard.bool(forKey: "validateOnPaste")
    }
}
