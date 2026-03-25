import Foundation

struct JSONDiff: Identifiable {
    let id = UUID()
    let path: String
    let type: DiffType
    let leftValue: String?
    let rightValue: String?

    enum DiffType {
        case added
        case removed
        case modified
        case equal
    }
}

struct JSONDiffer {
    static func diff(_ left: Any?, _ right: Any?, path: String = "$") -> [JSONDiff] {
        var diffs: [JSONDiff] = []

        if left == nil && right == nil {
            return diffs
        }

        if left == nil {
            diffs.append(JSONDiff(
                path: path,
                type: .added,
                leftValue: nil,
                rightValue: formatValue(right)
            ))
            return diffs
        }

        if right == nil {
            diffs.append(JSONDiff(
                path: path,
                type: .removed,
                leftValue: formatValue(left),
                rightValue: nil
            ))
            return diffs
        }

        if let leftDict = left as? [String: Any], let rightDict = right as? [String: Any] {
            diffDictionaries(leftDict, rightDict, path: path, diffs: &diffs)
        } else if let leftArray = left as? [Any], let rightArray = right as? [Any] {
            diffArrays(leftArray, rightArray, path: path, diffs: &diffs)
        } else {
            let leftStr = formatValue(left)
            let rightStr = formatValue(right)

            if leftStr == rightStr {
                diffs.append(JSONDiff(
                    path: path,
                    type: .equal,
                    leftValue: leftStr,
                    rightValue: rightStr
                ))
            } else {
                diffs.append(JSONDiff(
                    path: path,
                    type: .modified,
                    leftValue: leftStr,
                    rightValue: rightStr
                ))
            }
        }

        return diffs
    }

    private static func diffDictionaries(_ left: [String: Any], _ right: [String: Any], path: String, diffs: inout [JSONDiff]) {
        let allKeys = Set(left.keys).union(Set(right.keys))

        for key in allKeys.sorted() {
            let newPath = path == "$" ? "$.\(key)" : "\(path).\(key)"
            let leftValue = left[key]
            let rightValue = right[key]

            diffs.append(contentsOf: diff(leftValue, rightValue, path: newPath))
        }
    }

    private static func diffArrays(_ left: [Any], _ right: [Any], path: String, diffs: inout [JSONDiff]) {
        let maxCount = max(left.count, right.count)

        for index in 0..<maxCount {
            let newPath = "\(path)[\(index)]"
            let leftValue = index < left.count ? left[index] : nil
            let rightValue = index < right.count ? right[index] : nil

            diffs.append(contentsOf: diff(leftValue, rightValue, path: newPath))
        }
    }

    private static func formatValue(_ value: Any?) -> String {
        guard let value = value else {
            return ""
        }

        if let string = value as? String {
            return "\"\(string)\""
        } else if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            return "\(number)"
        } else if value is NSNull {
            return "null"
        } else if let dict = value as? [String: Any] {
            return "{\(dict.count) \(dict.count == 1 ? "item" : "items")}"
        } else if let array = value as? [Any] {
            return "[\(array.count) \(array.count == 1 ? "item" : "items")]"
        }

        return "\(value)"
    }
}
