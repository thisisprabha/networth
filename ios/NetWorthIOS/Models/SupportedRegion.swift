import Foundation

struct SupportedRegion: Identifiable, Hashable {
    let name: String
    let currencyCode: String
    let regionCode: String

    var id: String { "\(regionCode)-\(currencyCode)" }

    var displayName: String { "\(name) (\(currencyCode))" }

    static let all: [SupportedRegion] = [
        SupportedRegion(name: "United States", currencyCode: "USD", regionCode: "US"),
        SupportedRegion(name: "India", currencyCode: "INR", regionCode: "IN"),
        SupportedRegion(name: "United Kingdom", currencyCode: "GBP", regionCode: "GB"),
        SupportedRegion(name: "Eurozone", currencyCode: "EUR", regionCode: "DE"),
        SupportedRegion(name: "Canada", currencyCode: "CAD", regionCode: "CA"),
        SupportedRegion(name: "Australia", currencyCode: "AUD", regionCode: "AU"),
        SupportedRegion(name: "Singapore", currencyCode: "SGD", regionCode: "SG"),
        SupportedRegion(name: "United Arab Emirates", currencyCode: "AED", regionCode: "AE"),
        SupportedRegion(name: "Saudi Arabia", currencyCode: "SAR", regionCode: "SA"),
        SupportedRegion(name: "Japan", currencyCode: "JPY", regionCode: "JP"),
        SupportedRegion(name: "China", currencyCode: "CNY", regionCode: "CN"),
        SupportedRegion(name: "Hong Kong", currencyCode: "HKD", regionCode: "HK"),
        SupportedRegion(name: "Switzerland", currencyCode: "CHF", regionCode: "CH"),
        SupportedRegion(name: "South Korea", currencyCode: "KRW", regionCode: "KR"),
        SupportedRegion(name: "Brazil", currencyCode: "BRL", regionCode: "BR")
    ]

    static func match(currencyCode: String, regionCode: String) -> SupportedRegion? {
        all.first { $0.currencyCode == currencyCode && $0.regionCode == regionCode }
    }

    static func bestMatch(forRegionCode regionCode: String) -> SupportedRegion? {
        all.first { $0.regionCode == regionCode }
    }

    static func defaultRegionCode(forCurrencyCode currencyCode: String) -> String {
        all.first { $0.currencyCode == currencyCode }?.regionCode ?? "IN"
    }
}

