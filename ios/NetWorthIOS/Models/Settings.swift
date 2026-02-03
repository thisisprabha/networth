import Foundation

struct Settings: Codable, Hashable {
    var currencyCode: String
    var growthRates: [String: Double]
    var appLockEnabled: Bool

    static var `default`: Settings {
        var rates: [String: Double] = [:]
        for category in AssetCategory.allCases {
            rates[category.rawValue] = category.definition.growthRateDefault
        }
        return Settings(
            currencyCode: "INR",
            growthRates: rates,
            appLockEnabled: true
        )
    }
}
