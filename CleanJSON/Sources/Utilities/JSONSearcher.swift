import Foundation

struct JSONSearcher {
    static func search(_ query: String, in json: Any, path: String = "$") -> [SearchResult] {
        var results: [SearchResult] = []
        let lowercasedQuery = query.lowercased()

        searchRecursive(query: lowercasedQuery, json: json, path: path, results: &results)

        return results
    }

    private static func searchRecursive(query: String, json: Any, path: String, results: inout [SearchResult], line: Int = 1) {
        if let dict = json as? [String: Any] {
            for (key, value) in dict {
                let newPath = path == "$" ? "$.\(key)" : "\(path).\(key)"

                if key.lowercased().contains(query) {
                    results.append(SearchResult(
                        path: newPath,
                        key: key,
                        value: formatValue(value),
                        line: line
                    ))
                }

                if let stringValue = value as? String, stringValue.lowercased().contains(query) {
                    results.append(SearchResult(
                        path: newPath,
                        key: key,
                        value: stringValue,
                        line: line
                    ))
                } else if let numberValue = value as? NSNumber {
                    let numberString = "\(numberValue)"
                    if numberString.lowercased().contains(query) {
                        results.append(SearchResult(
                            path: newPath,
                            key: key,
                            value: numberString,
                            line: line
                        ))
                    }
                }

                searchRecursive(query: query, json: value, path: newPath, results: &results, line: line + 1)
            }
        } else if let array = json as? [Any] {
            for (index, item) in array.enumerated() {
                let newPath = "\(path)[\(index)]"

                if let stringValue = item as? String, stringValue.lowercased().contains(query) {
                    results.append(SearchResult(
                        path: newPath,
                        key: nil,
                        value: stringValue,
                        line: line
                    ))
                } else if let numberValue = item as? NSNumber {
                    let numberString = "\(numberValue)"
                    if numberString.lowercased().contains(query) {
                        results.append(SearchResult(
                            path: newPath,
                            key: nil,
                            value: numberString,
                            line: line
                        ))
                    }
                }

                searchRecursive(query: query, json: item, path: newPath, results: &results, line: line + 1)
            }
        }
    }

    private static func formatValue(_ value: Any) -> String {
        if let string = value as? String {
            return string
        } else if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            return "\(number)"
        } else if value is NSNull {
            return "null"
        } else if value is [String: Any] {
            return "{...}"
        } else if value is [Any] {
            return "[...]"
        }
        return "\(value)"
    }
}
