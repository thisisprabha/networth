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
        case .homeLoan, .carLoan, .personalLoan, .creditCard, .otherDebt:
            return asset.numberValue("debtBalance")
        case .lifeInsurance, .healthInsurance, .vehicleInsurance:
            return asset.numberValue("coverageAmount")
        }
    }

    static func netWorth(_ assets: [Asset]) -> Double {
        assets
            .filter { $0.category.definition.includesInNetWorth }
            .reduce(0) { $0 + netWorthContribution(for: $1) }
    }

    static func netWorthContribution(for asset: Asset) -> Double {
        let sign: Double = asset.category.definition.isLiability ? -1 : 1
        return assetValue(asset) * sign
    }

    static func netWorthComponents(assets: [Asset]) -> [AssetCategory: Double] {
        let filteredAssets = assets.filter { $0.category.definition.includesInNetWorth }
        var totals: [AssetCategory: Double] = [:]
        for asset in filteredAssets {
            totals[asset.category, default: 0] += netWorthContribution(for: asset)
        }
        return totals
    }

    static func categorySummaries(assets: [Asset], includeInNetWorth: Bool, isLiability: Bool? = nil) -> [CategorySummary] {
        let filteredAssets = assets.filter {
            $0.category.definition.includesInNetWorth == includeInNetWorth &&
            (isLiability == nil || $0.category.definition.isLiability == isLiability)
        }
        let total = includeInNetWorth && isLiability != true ? netWorth(filteredAssets) : 0
        var buckets: [AssetCategory: Double] = [:]
        for asset in filteredAssets {
            buckets[asset.category, default: 0] += assetValue(asset)
        }
        let summaries = buckets.map { category, value in
            CategorySummary(
                category: category,
                total: value,
                percentage: includeInNetWorth && isLiability != true && total > 0 ? value / total : nil
            )
        }
        return summaries.sorted { $0.total > $1.total }
    }

    static func projection(assets: [Asset], settings: Settings, months: Int = 12) -> [ProjectionPoint] {
        let projectedAssets = assets.filter { $0.category.definition.includesInNetWorth }
        let current = netWorth(projectedAssets)
        var points: [ProjectionPoint] = [ProjectionPoint(month: 0, value: current)]
        for month in 1...months {
            var total: Double = 0
            for asset in projectedAssets {
                let currentValue = assetValue(asset)
                let rate = growthRate(for: asset.category, settings: settings)
                let monthly = rate / 12 / 100
                let projected = currentValue * pow(1 + monthly, Double(month))
                let sign: Double = asset.category.definition.isLiability ? -1 : 1
                total += projected * sign
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
