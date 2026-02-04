import SwiftUI

struct AssetsListView: View {
    let store: AssetStore

    @State private var activeSheet: AssetSheet?

    private var wealthSummaries: [CategorySummary] {
        CalculationsService.categorySummaries(assets: store.assets, includeInNetWorth: true, isLiability: false)
    }

    private var liabilitySummaries: [CategorySummary] {
        CalculationsService.categorySummaries(assets: store.assets, includeInNetWorth: true, isLiability: true)
    }

    private var coverageSummaries: [CategorySummary] {
        CalculationsService.categorySummaries(assets: store.assets, includeInNetWorth: false)
    }

    var body: some View {
        List {
            if wealthSummaries.isEmpty && liabilitySummaries.isEmpty && coverageSummaries.isEmpty {
                ContentUnavailableView(
                    "No assets yet",
                    systemImage: "tray",
                    description: Text("Add your first asset to see category totals.")
                )
            } else {
                if !wealthSummaries.isEmpty {
                    Section("Wealth") {
                        ForEach(wealthSummaries) { summary in
                            NavigationLink(value: summary.category) {
                                CategoryRowView(summary: summary)
                            }
                        }
                    }
                }
                if !liabilitySummaries.isEmpty {
                    Section("Liabilities") {
                        ForEach(liabilitySummaries) { summary in
                            NavigationLink(value: summary.category) {
                                CategoryRowView(summary: summary)
                            }
                        }
                    }
                }
                if !coverageSummaries.isEmpty {
                    Section("Protection") {
                        ForEach(coverageSummaries) { summary in
                            NavigationLink(value: summary.category) {
                                CategoryRowView(summary: summary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Assets")
        .navigationDestination(for: AssetCategory.self) { category in
            CategoryDetailView(store: store, category: category)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    activeSheet = AssetSheet(asset: nil, initialCategory: nil)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            AssetFormView(store: store, asset: sheet.asset, initialCategory: sheet.initialCategory)
        }
    }
}

private struct AssetSheet: Identifiable {
    let id = UUID()
    let asset: Asset?
    let initialCategory: AssetCategory?
}
