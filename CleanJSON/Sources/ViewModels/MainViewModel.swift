import Foundation
import SwiftUI
import AppKit

class MainViewModel: ObservableObject {
    @Published var document: JSONDocument
    @Published var formattedText: String = ""
    @Published var searchQuery: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var selectedPath: String = ""
    @Published var yamlPreview: String = ""
    @Published var showingYAML: Bool = false

    let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
        self.document = JSONDocument()
    }

    func loadJSON(_ text: String) {
        document.rawText = text
        validateAndFormat()
    }

    func validateAndFormat() {
        let result = JSONValidator.validate(document.rawText)
        document.isValid = result.isValid
        document.errorMessage = result.errorMessage
        document.errorLine = result.errorLine
        document.parsedJSON = result.parsedJSON

        if result.isValid, let json = result.parsedJSON {
            if let formatted = JSONFormatter.format(document.rawText, indent: settings.indentStyle) {
                formattedText = formatted
            } else {
                formattedText = JSONFormatter.beautify(json, indent: settings.indentStyle)
            }
            document.rawText = formattedText
        } else {
            formattedText = document.rawText
        }
    }

    func formatJSON() {
        guard document.isValid, !document.rawText.isEmpty else { return }

        if let formatted = JSONFormatter.format(document.rawText, indent: settings.indentStyle) {
            formattedText = formatted
            document.rawText = formatted
        }
    }

    func minifyJSON() {
        guard document.isValid, !document.rawText.isEmpty else { return }

        if let minified = JSONFormatter.minify(document.rawText) {
            formattedText = minified
            document.rawText = minified
        }
    }

    func search() {
        guard !searchQuery.isEmpty, let json = document.parsedJSON else {
            searchResults = []
            return
        }

        searchResults = JSONSearcher.search(searchQuery, in: json)
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }

    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                loadJSON(content)
            } catch {
                document.errorMessage = "Failed to open file: \(error.localizedDescription)"
            }
        }
    }

    func saveFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "formatted.json"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try formattedText.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                document.errorMessage = "Failed to save file: \(error.localizedDescription)"
            }
        }
    }

    func generateYAMLPreview() {
        guard let json = document.parsedJSON else {
            yamlPreview = ""
            return
        }

        yamlPreview = YAMLConverter.jsonToYAML(json)
    }

    func toggleYAMLView() {
        showingYAML.toggle()
        if showingYAML {
            generateYAMLPreview()
        }
    }

    func pasteFromClipboard() {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            loadJSON(text)
        }
    }
}
