import Foundation
import Observation

@MainActor
@Observable
final class AssetStore {
    var assets: [Asset] = []
    var settings: Settings = .default
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
        } catch {
            assets = []
            settings = .default
        }
        isLoaded = true
    }

    func save() {
        do {
            try persistence.save(state: PersistedState(assets: assets, settings: settings))
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
        save()
    }

    func delete(_ asset: Asset) {
        assets.removeAll { $0.id == asset.id }
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
        save()
    }

    func growthRate(for category: AssetCategory) -> Double {
        settings.growthRates[category.rawValue] ?? category.definition.growthRateDefault
    }

    func setGrowthRate(_ value: Double, for category: AssetCategory) {
        settings.growthRates[category.rawValue] = value
        save()
    }
}
