import Foundation

struct JSONFormatter {
    static func format(_ jsonString: String, indent: IndentStyle) -> String? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        let options: JSONSerialization.WritingOptions = indent == .tab ? [.prettyPrinted] : [.prettyPrinted, .sortedKeys]
        guard let formattedData = try? JSONSerialization.data(withJSONObject: json, options: options) else {
            return nil
        }

        var formattedString = String(data: formattedData, encoding: .utf8) ?? ""

        if indent != .fourSpaces {
            formattedString = formattedString.replacingOccurrences(of: "    ", with: indent.value)
        }

        return formattedString
    }

    static func minify(_ jsonString: String) -> String? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        guard let minifiedData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }

        return String(data: minifiedData, encoding: .utf8)
    }

    static func beautify(_ json: Any, indent: IndentStyle = .twoSpaces, level: Int = 0) -> String {
        let indentString = String(repeating: indent.value, count: level)
        let nextIndentString = String(repeating: indent.value, count: level + 1)

        if let dict = json as? [String: Any] {
            if dict.isEmpty {
                return "{}"
            }
            var lines = ["{"]
            let sortedKeys = dict.keys.sorted()
            for (index, key) in sortedKeys.enumerated() {
                let value = dict[key]!
                let formattedValue = beautify(value, indent: indent, level: level + 1)
                let comma = index < sortedKeys.count - 1 ? "," : ""
                lines.append("\(nextIndentString)\"\(key)\": \(formattedValue)\(comma)")
            }
            lines.append("\(indentString)}")
            return lines.joined(separator: "\n")
        } else if let array = json as? [Any] {
            if array.isEmpty {
                return "[]"
            }
            var lines = ["["]
            for (index, item) in array.enumerated() {
                let formattedValue = beautify(item, indent: indent, level: level + 1)
                let comma = index < array.count - 1 ? "," : ""
                lines.append("\(nextIndentString)\(formattedValue)\(comma)")
            }
            lines.append("\(indentString)]")
            return lines.joined(separator: "\n")
        } else if let string = json as? String {
            let escaped = string
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
            return "\"\(escaped)\""
        } else if let number = json as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            return "\(number)"
        } else if json is NSNull {
            return "null"
        }

        return "\(json)"
    }
}
