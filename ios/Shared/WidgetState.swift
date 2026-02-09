import Foundation

struct WidgetState: Codable, Hashable {
    let netWorth: Double
    let lastUpdated: Date
    let deltaPercent: Double?
    let currencyCode: String
    let regionCode: String

    enum CodingKeys: String, CodingKey {
        case netWorth
        case lastUpdated
        case deltaPercent
        case currencyCode
        case regionCode
    }

    init(netWorth: Double, lastUpdated: Date, deltaPercent: Double?, currencyCode: String, regionCode: String) {
        self.netWorth = netWorth
        self.lastUpdated = lastUpdated
        self.deltaPercent = deltaPercent
        self.currencyCode = currencyCode
        self.regionCode = regionCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        netWorth = try container.decode(Double.self, forKey: .netWorth)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        deltaPercent = try container.decodeIfPresent(Double.self, forKey: .deltaPercent)

        let currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode) ?? "INR"
        self.currencyCode = currencyCode
        regionCode = try container.decodeIfPresent(String.self, forKey: .regionCode) ?? Self.defaultRegionCode(forCurrencyCode: currencyCode)
    }

    private static func defaultRegionCode(forCurrencyCode currencyCode: String) -> String {
        switch currencyCode.uppercased() {
        case "USD": return "US"
        case "INR": return "IN"
        case "GBP": return "GB"
        case "EUR": return "DE"
        case "CAD": return "CA"
        case "AUD": return "AU"
        case "SGD": return "SG"
        case "AED": return "AE"
        case "SAR": return "SA"
        case "JPY": return "JP"
        case "CNY": return "CN"
        case "HKD": return "HK"
        case "CHF": return "CH"
        case "KRW": return "KR"
        case "BRL": return "BR"
        default: return "IN"
        }
    }
}

