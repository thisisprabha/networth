import Foundation

struct Asset: Identifiable, Codable, Hashable {
    var id: String
    var category: AssetCategory
    var name: String
    var values: [String: FieldValue]
    var createdAt: Date
    var updatedAt: Date
}

extension Asset {
    func numberValue(_ key: String) -> Double {
        if case let .number(value)? = values[key] {
            return value
        }
        if case let .text(text)? = values[key], let number = Double(text) {
            return number
        }
        return 0
    }

    func textValue(_ key: String) -> String? {
        if case let .text(value)? = values[key] {
            return value
        }
        if case let .number(value)? = values[key] {
            return String(value)
        }
        return nil
    }

    func dateValue(_ key: String) -> Date? {
        if case let .date(value)? = values[key] {
            return value
        }
        return nil
    }
}
