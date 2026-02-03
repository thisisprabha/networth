import Foundation

enum CSVService {
    static let headers = [
        "id",
        "category",
        "name",
        "icon",
        "color",
        "values",
        "createdAt",
        "updatedAt"
    ]

    static func exportCSV(assets: [Asset]) throws -> String {
        var rows: [String] = []
        rows.append(headers.joined(separator: ","))

        for asset in assets {
            let valuesJSON = try jsonString(from: asset.values)
            let fields = [
                asset.id,
                asset.category.rawValue,
                asset.name,
                asset.category.definition.symbolName,
                asset.category.definition.color.description,
                valuesJSON,
                isoString(asset.createdAt),
                isoString(asset.updatedAt)
            ]
            rows.append(fields.map(csvEscape).joined(separator: ","))
        }

        return rows.joined(separator: "\n")
    }

    static func importCSV(_ content: String) throws -> [Asset] {
        let lines = content.split(whereSeparator: \.isNewline).map(String.init)
        guard let headerLine = lines.first else { return [] }
        let headerFields = parseCSVLine(headerLine)
        guard headerFields == headers else { return [] }

        var assets: [Asset] = []

        for line in lines.dropFirst() {
            let fields = parseCSVLine(line)
            if fields.count < headers.count { continue }

            let id = fields[0]
            let categoryRaw = fields[1]
            let name = fields[2]
            let valuesString = fields[5]
            let createdAt = parseDate(fields[6]) ?? Date()
            let updatedAt = parseDate(fields[7]) ?? Date()

            guard let category = AssetCategory(rawValue: categoryRaw) else { continue }
            let values = parseValues(valuesString)

            let asset = Asset(
                id: id.isEmpty ? UUID().uuidString : id,
                category: category,
                name: name.isEmpty ? category.definition.name : name,
                values: values,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            assets.append(asset)
        }

        return assets
    }

    private static func jsonString(from values: [String: FieldValue]) throws -> String {
        var json: [String: Any] = [:]
        for (key, value) in values {
            switch value {
            case .number(let number):
                json[key] = number
            case .text(let text):
                json[key] = text
            case .date(let date):
                json[key] = isoString(date)
            }
        }
        let data = try JSONSerialization.data(withJSONObject: json)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private static func parseValues(_ jsonString: String) -> [String: FieldValue] {
        guard let data = jsonString.data(using: .utf8) else { return [:] }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        var values: [String: FieldValue] = [:]
        for (key, value) in json {
            if let number = value as? NSNumber {
                values[key] = .number(number.doubleValue)
            } else if let string = value as? String {
                if let date = parseDate(string) {
                    values[key] = .date(date)
                } else {
                    values[key] = .text(string)
                }
            }
        }
        return values
    }

    private static func parseDate(_ string: String) -> Date? {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: string) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }

    private static func isoString(_ date: Date) -> String {
        let iso = ISO8601DateFormatter()
        return iso.string(from: date)
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var index = line.startIndex

        while index < line.endIndex {
            let char = line[index]
            if char == "\"" {
                let nextIndex = line.index(after: index)
                if inQuotes, nextIndex < line.endIndex, line[nextIndex] == "\"" {
                    current.append("\"")
                    index = nextIndex
                } else {
                    inQuotes.toggle()
                }
            } else if char == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
            index = line.index(after: index)
        }
        fields.append(current)
        return fields
    }

    private static func csvEscape(_ value: String) -> String {
        let needsQuotes = value.contains(",") || value.contains("\"") || value.contains("\n")
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return needsQuotes ? "\"\(escaped)\"" : escaped
    }
}
