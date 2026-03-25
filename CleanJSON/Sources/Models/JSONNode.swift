import Foundation

class JSONNode: Identifiable, ObservableObject {
    let id = UUID()
    let key: String?
    let value: Any
    let path: String
    @Published var isExpanded: Bool
    var children: [JSONNode]

    var displayValue: String {
        if let dict = value as? [String: Any] {
            return "{\(dict.count) \(dict.count == 1 ? "item" : "items")}"
        } else if let array = value as? [Any] {
            return "[\(array.count) \(array.count == 1 ? "item" : "items")]"
        } else if let string = value as? String {
            return "\"\(string)\""
        } else if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            return "\(number)"
        } else if value is NSNull {
            return "null"
        }
        return "\(value)"
    }

    var typeDescription: String {
        if value is [String: Any] {
            return "Object"
        } else if value is [Any] {
            return "Array"
        } else if value is String {
            return "String"
        } else if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return "Boolean"
            }
            return "Number"
        } else if value is NSNull {
            return "Null"
        }
        return "Unknown"
    }

    var hasChildren: Bool {
        return value is [String: Any] || value is [Any]
    }

    init(key: String? = nil, value: Any, path: String, isExpanded: Bool = false) {
        self.key = key
        self.value = value
        self.path = path
        self.isExpanded = isExpanded
        self.children = []
        self.buildChildren()
    }

    private func buildChildren() {
        if let dict = value as? [String: Any] {
            children = dict.sorted { $0.key < $1.key }.map { key, value in
                let childPath = path.isEmpty ? key : "\(path).\(key)"
                return JSONNode(key: key, value: value, path: childPath)
            }
        } else if let array = value as? [Any] {
            children = array.enumerated().map { index, value in
                let childPath = "\(path)[\(index)]"
                return JSONNode(key: "[\(index)]", value: value, path: childPath)
            }
        }
    }

    func toggleExpansion() {
        isExpanded.toggle()
    }
}

extension JSONNode {
    static func buildTree(from json: Any) -> JSONNode {
        return JSONNode(value: json, path: "$")
    }
}
