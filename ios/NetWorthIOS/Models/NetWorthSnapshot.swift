import Foundation

struct NetWorthSnapshot: Identifiable, Codable, Hashable {
    let id: String
    let date: Date
    let netWorth: Double
    let assetCount: Int
    let categoryTotals: [String: Double]

    init(date: Date, netWorth: Double, assetCount: Int, categoryTotals: [String: Double]) {
        self.id = UUID().uuidString
        self.date = date
        self.netWorth = netWorth
        self.assetCount = assetCount
        self.categoryTotals = categoryTotals
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        netWorth = try container.decode(Double.self, forKey: .netWorth)
        assetCount = try container.decode(Int.self, forKey: .assetCount)
        categoryTotals = try container.decodeIfPresent([String: Double].self, forKey: .categoryTotals) ?? [:]
    }
}
