import Foundation

struct YAMLConverter {
    static func jsonToYAML(_ json: Any, indent: Int = 0) -> String {
        let indentString = String(repeating: "  ", count: indent)

        if let dict = json as? [String: Any] {
            if dict.isEmpty {
                return "{}"
            }

            var lines: [String] = []
            let sortedKeys = dict.keys.sorted()

            for key in sortedKeys {
                let value = dict[key]!
                let yamlValue = jsonToYAML(value, indent: indent + 1)

                if value is [String: Any] {
                    lines.append("\(indentString)\(key):")
                    lines.append(yamlValue)
                } else if value is [Any] {
                    lines.append("\(indentString)\(key):")
                    lines.append(yamlValue)
                } else {
                    lines.append("\(indentString)\(key): \(yamlValue)")
                }
            }

            return lines.joined(separator: "\n")
        } else if let array = json as? [Any] {
            if array.isEmpty {
                return "[]"
            }

            var lines: [String] = []

            for item in array {
                let yamlValue = jsonToYAML(item, indent: indent + 1)

                if item is [String: Any] || item is [Any] {
                    lines.append("\(indentString)-")
                    let itemLines = yamlValue.components(separatedBy: "\n")
                    for (index, line) in itemLines.enumerated() {
                        if index == 0 {
                            lines.append("  \(line)")
                        } else {
                            lines.append("  \(line)")
                        }
                    }
                } else {
                    lines.append("\(indentString)- \(yamlValue)")
                }
            }

            return lines.joined(separator: "\n")
        } else if let string = json as? String {
            if string.contains("\n") || string.contains(":") || string.contains("#") {
                return "\"\(string.replacingOccurrences(of: "\"", with: "\\\""))\""
            }
            return string
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

    static func yamlToJSON(_ yamlString: String) -> String? {
        let lines = yamlString.components(separatedBy: .newlines)
        var result: [String: Any] = [:]
        var currentPath: [String] = []
        var currentIndent = 0

        for line in lines {
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty,
                  !line.trimmingCharacters(in: .whitespaces).hasPrefix("#") else {
                continue
            }

            let indent = line.prefix(while: { $0 == " " }).count

            if line.trimmingCharacters(in: .whitespaces).hasPrefix("-") {
                continue
            }

            if let colonRange = line.range(of: ":") {
                let key = line[..<colonRange.lowerBound].trimmingCharacters(in: .whitespaces)
                let value = line[colonRange.upperBound...].trimmingCharacters(in: .whitespaces)

                if value.isEmpty {
                    result[key] = [:]
                } else {
                    result[key] = parseYAMLValue(value)
                }
            }
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }

    private static func parseYAMLValue(_ value: String) -> Any {
        let trimmed = value.trimmingCharacters(in: .whitespaces)

        if trimmed == "true" {
            return true
        } else if trimmed == "false" {
            return false
        } else if trimmed == "null" {
            return NSNull()
        } else if let number = Double(trimmed) {
            return number
        } else if trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"") {
            let unquoted = String(trimmed.dropFirst().dropLast())
            return unquoted.replacingOccurrences(of: "\\\"", with: "\"")
        }

        return trimmed
    }
}
