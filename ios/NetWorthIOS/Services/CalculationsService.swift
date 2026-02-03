import Foundation

enum CalculationsService {
    static func assetValue(_ asset: Asset) -> Double {
        switch asset.category {
        case .stocks:
            return asset.numberValue("stockValue")
        case .mutualFunds:
            return asset.numberValue("fundValue")
        case .gold:
            return asset.numberValue("goldQuantity") * asset.numberValue("goldRate")
        case .fixedDeposits:
            return asset.numberValue("principalAmount")
        case .personalAssets:
            let quantity = asset.numberValue("quantity")
            let value = asset.numberValue("assetValue")
            return value * max(quantity, 1)
        case .bonds:
            return asset.numberValue("bondValue")
        case .land:
            return asset.numberValue("landValue")
        case .home:
            return asset.numberValue("homeValue")
        case .savings:
            return asset.numberValue("savingsBalance")
        case .emergencySavings:
            return asset.numberValue("emergencyBalance")
        case .esop:
            return asset.numberValue("esopCurrentValue") * asset.numberValue("esopShares")
        case .privateEquity:
            return asset.numberValue("peValue")
        case .vpfPpf:
            return asset.numberValue("vpfAmount")
        case .silver:
            return asset.numberValue("silverGrams") * asset.numberValue("silverRate")
        }
    }

    static func netWorth(_ assets: [Asset]) -> Double {
        assets.reduce(0) { $0 + assetValue($1) }
    }

    static func projection(assets: [Asset], settings: Settings, months: Int = 12) -> [ProjectionPoint] {
        let current = netWorth(assets)
        var points: [ProjectionPoint] = [ProjectionPoint(month: 0, value: current)]

        for month in 1...months {
            var total: Double = 0
            for asset in assets {
                let currentValue = assetValue(asset)
                let rate = growthRate(for: asset.category, settings: settings)
                let monthly = rate / 12 / 100
                let projected = currentValue * pow(1 + monthly, Double(month))
                total += projected
            }
            points.append(ProjectionPoint(month: month, value: total))
        }
        return points
    }

    static func oneYearProjection(assets: [Asset], settings: Settings) -> Double {
        projection(assets: assets, settings: settings, months: 12).last?.value ?? 0
    }

    static func growthRate(for category: AssetCategory, settings: Settings) -> Double {
        settings.growthRates[category.rawValue] ?? category.definition.growthRateDefault
    }
}
