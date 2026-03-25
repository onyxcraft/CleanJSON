import Foundation

struct JSONDocument: Identifiable, Equatable {
    let id = UUID()
    var rawText: String
    var parsedJSON: Any?
    var isValid: Bool
    var errorMessage: String?
    var errorLine: Int?

    init(rawText: String = "") {
        self.rawText = rawText
        self.isValid = false
        self.parsedJSON = nil
        self.errorMessage = nil
        self.errorLine = nil
    }

    static func == (lhs: JSONDocument, rhs: JSONDocument) -> Bool {
        lhs.id == rhs.id && lhs.rawText == rhs.rawText
    }
}

struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    let errorLine: Int?
    let parsedJSON: Any?
}

struct SearchResult: Identifiable, Equatable {
    let id = UUID()
    let path: String
    let key: String?
    let value: String
    let line: Int

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

enum IndentStyle: String, CaseIterable, Identifiable {
    case twoSpaces = "2 Spaces"
    case fourSpaces = "4 Spaces"
    case tab = "Tab"

    var id: String { rawValue }

    var value: String {
        switch self {
        case .twoSpaces: return "  "
        case .fourSpaces: return "    "
        case .tab: return "\t"
        }
    }
}
