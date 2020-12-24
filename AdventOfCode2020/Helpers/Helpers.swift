import Foundation

public func getInputString(atPath path: String) -> String {
    guard
        let data = FileManager.default.contents(atPath: path)
    else {
        return ""
    }

    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

