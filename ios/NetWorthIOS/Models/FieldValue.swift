import Foundation

enum FieldValue: Codable, Hashable {
    case number(Double)
    case text(String)
    case date(Date)

    enum CodingKeys: String, CodingKey {
        case type
        case number
        case text
        case date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "number":
            self = .number(try container.decode(Double.self, forKey: .number))
        case "text":
            self = .text(try container.decode(String.self, forKey: .text))
        case "date":
            self = .date(try container.decode(Date.self, forKey: .date))
        default:
            self = .text("")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .number(let value):
            try container.encode("number", forKey: .type)
            try container.encode(value, forKey: .number)
        case .text(let value):
            try container.encode("text", forKey: .type)
            try container.encode(value, forKey: .text)
        case .date(let value):
            try container.encode("date", forKey: .type)
            try container.encode(value, forKey: .date)
        }
    }
}
