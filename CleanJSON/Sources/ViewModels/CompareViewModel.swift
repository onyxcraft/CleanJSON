import Foundation
import SwiftUI
import AppKit

class CompareViewModel: ObservableObject {
    @Published var leftJSON: String = ""
    @Published var rightJSON: String = ""
    @Published var leftDocument: JSONDocument = JSONDocument()
    @Published var rightDocument: JSONDocument = JSONDocument()
    @Published var diffs: [JSONDiff] = []
    @Published var showingDiff: Bool = false

    func loadLeftJSON(_ text: String) {
        leftJSON = text
        validateLeft()
    }

    func loadRightJSON(_ text: String) {
        rightJSON = text
        validateRight()
    }

    func validateLeft() {
        let result = JSONValidator.validate(leftJSON)
        leftDocument.rawText = leftJSON
        leftDocument.isValid = result.isValid
        leftDocument.errorMessage = result.errorMessage
        leftDocument.errorLine = result.errorLine
        leftDocument.parsedJSON = result.parsedJSON
    }

    func validateRight() {
        let result = JSONValidator.validate(rightJSON)
        rightDocument.rawText = rightJSON
        rightDocument.isValid = result.isValid
        rightDocument.errorMessage = result.errorMessage
        rightDocument.errorLine = result.errorLine
        rightDocument.parsedJSON = result.parsedJSON
    }

    func compare() {
        guard leftDocument.isValid, rightDocument.isValid else {
            diffs = []
            return
        }

        diffs = JSONDiffer.diff(leftDocument.parsedJSON, rightDocument.parsedJSON)
        showingDiff = true
    }

    func clear() {
        leftJSON = ""
        rightJSON = ""
        leftDocument = JSONDocument()
        rightDocument = JSONDocument()
        diffs = []
        showingDiff = false
    }

    func openLeftFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                loadLeftJSON(content)
            } catch {
                leftDocument.errorMessage = "Failed to open file: \(error.localizedDescription)"
            }
        }
    }

    func openRightFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                loadRightJSON(content)
            } catch {
                rightDocument.errorMessage = "Failed to open file: \(error.localizedDescription)"
            }
        }
    }
}
