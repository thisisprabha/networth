import Foundation
import Observation

@MainActor
@Observable
final class AssetStore {
    var assets: [Asset] = []
    var settings: Settings = .default
    var snapshots: [NetWorthSnapshot] = []
    var isLoaded = false

    private let persistence: PersistenceStore

    init(persistence: PersistenceStore = .default) {
        self.persistence = persistence
    }

    func load() {
        guard !isLoaded else { return }
        do {
            let state = try persistence.load()
            assets = state.assets
            settings = state.settings
            snapshots = state.snapshots
        } catch {
            assets = []
            settings = .default
            snapshots = []
        }
        isLoaded = true
    }

    func save() {
        do {
            try persistence.save(state: PersistedState(assets: assets, settings: settings, snapshots: snapshots))
        } catch {
            return
        }
    }

    func upsert(_ asset: Asset) {
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
        } else {
            assets.append(asset)
        }
        recordSnapshot()
        save()
    }

    func delete(_ asset: Asset) {
        assets.removeAll { $0.id == asset.id }
        recordSnapshot()
        save()
    }

    func merge(_ newAssets: [Asset]) {
        var merged = assets
        for asset in newAssets {
            if let index = merged.firstIndex(where: { $0.id == asset.id }) {
                if merged[index].updatedAt < asset.updatedAt {
                    merged[index] = asset
                }
            } else {
                merged.append(asset)
            }
        }
        assets = merged
        recordSnapshot()
        save()
    }

    func growthRate(for category: AssetCategory) -> Double {
        settings.growthRates[category.rawValue] ?? category.definition.growthRateDefault
    }

    func setGrowthRate(_ value: Double, for category: AssetCategory) {
        settings.growthRates[category.rawValue] = value
        save()
    }

    private func recordSnapshot() {
        let now = Date()
        let total = CalculationsService.netWorth(assets)
        let count = assets.count
        let categoryTotals = CalculationsService.netWorthComponents(assets: assets)
            .reduce(into: [String: Double]()) { result, entry in
                result[entry.key.rawValue] = entry.value
            }
        var newSnapshot: NetWorthSnapshot?
        let updated = NetWorthSnapshot(date: now, netWorth: total, assetCount: count, categoryTotals: categoryTotals)
        if let last = snapshots.last {
            let totalsChanged = last.categoryTotals != categoryTotals
            let netWorthChanged = last.netWorth != total
            let countChanged = last.assetCount != count
            guard totalsChanged || netWorthChanged || countChanged else { return }
            snapshots.append(updated)
            newSnapshot = updated
        } else {
            snapshots.append(updated)
            newSnapshot = updated
        }

        if snapshots.count > 120 {
            snapshots = Array(snapshots.suffix(120))
        }

        if let snapshot = newSnapshot {
            let previous = snapshots.dropLast().last
            let deltaPercent: Double?
            if let previous, previous.netWorth > 0 {
                deltaPercent = (snapshot.netWorth - previous.netWorth) / previous.netWorth
            } else {
                deltaPercent = nil
            }
            WidgetDataService.save(
                state: WidgetState(
                    netWorth: snapshot.netWorth,
                    lastUpdated: snapshot.date,
                    deltaPercent: deltaPercent
                )
            )
        }
    }
}
