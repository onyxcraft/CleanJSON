import Foundation

struct JSONValidator {
    static func validate(_ jsonString: String) -> ValidationResult {
        guard !jsonString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ValidationResult(
                isValid: false,
                errorMessage: "Empty JSON",
                errorLine: nil,
                parsedJSON: nil
            )
        }

        guard let data = jsonString.data(using: .utf8) else {
            return ValidationResult(
                isValid: false,
                errorMessage: "Invalid string encoding",
                errorLine: nil,
                parsedJSON: nil
            )
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            return ValidationResult(
                isValid: true,
                errorMessage: nil,
                errorLine: nil,
                parsedJSON: json
            )
        } catch let error as NSError {
            let errorMessage = parseError(error, jsonString: jsonString)
            let errorLine = findErrorLine(from: error, in: jsonString)

            return ValidationResult(
                isValid: false,
                errorMessage: errorMessage,
                errorLine: errorLine,
                parsedJSON: nil
            )
        }
    }

    private static func parseError(_ error: NSError, jsonString: String) -> String {
        if let debugDescription = error.userInfo["NSDebugDescription"] as? String {
            if debugDescription.contains("after") {
                return "Unexpected character in JSON structure"
            } else if debugDescription.contains("token") {
                return "Invalid token in JSON"
            } else if debugDescription.contains("end") {
                return "Unexpected end of JSON"
            } else if debugDescription.contains("string") {
                return "Malformed string in JSON"
            }
            return debugDescription
        }

        return error.localizedDescription
    }

    private static func findErrorLine(from error: NSError, in jsonString: String) -> Int? {
        if let debugDescription = error.userInfo["NSDebugDescription"] as? String {
            let pattern = #"character (\d+)"#
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: debugDescription, range: NSRange(debugDescription.startIndex..., in: debugDescription)),
               let range = Range(match.range(at: 1), in: debugDescription),
               let characterPosition = Int(debugDescription[range]) {

                let lines = jsonString.components(separatedBy: .newlines)
                var currentPosition = 0

                for (lineIndex, line) in lines.enumerated() {
                    let lineLength = line.count + 1
                    if currentPosition + lineLength > characterPosition {
                        return lineIndex + 1
                    }
                    currentPosition += lineLength
                }
            }
        }

        return nil
    }

    static func isValidJSONStructure(_ value: Any) -> Bool {
        if value is [String: Any] || value is [Any] {
            return true
        }
        return false
    }
}
