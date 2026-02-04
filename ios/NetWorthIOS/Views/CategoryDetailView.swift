import SwiftUI

struct CategoryDetailView: View {
    let store: AssetStore
    let category: AssetCategory

    @State private var activeSheet: AssetSheet?

    private var assets: [Asset] {
        store.assets
            .filter { $0.category == category }
            .sorted { CalculationsService.assetValue($0) > CalculationsService.assetValue($1) }
    }

    private var totalValue: Double {
        assets.reduce(0) { $0 + CalculationsService.assetValue($1) }
    }

    private var totalDisplay: String {
        let value = Formatters.formatINR(totalValue)
        return category.definition.isLiability ? "-" + value : value
    }

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                        Text("Total")
                            .font(AppFont.font(.caption))
                            .foregroundStyle(Theme.secondaryText)
                        Text(totalDisplay)
                            .font(AppFont.font(.title3, weight: .bold))
                            .foregroundStyle(category.definition.isLiability ? Theme.negative : Theme.primaryText)
                            .contentTransition(.numericText())
                        if category.definition.isLiability {
                            Text("Debt reduces net worth")
                                .font(AppFont.font(.caption2))
                                .foregroundStyle(Theme.secondaryText)
                        } else if !category.definition.includesInNetWorth {
                            Text("Coverage only (not part of net worth)")
                                .font(AppFont.font(.caption2))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, Theme.Spacing.xSmall)
            }

            Section("Assets") {
                if assets.isEmpty {
                    ContentUnavailableView {
                        Label("No assets yet", systemImage: "tray")
                    } description: {
                        Text("Add assets in this category.")
                    } actions: {
                        Button("Add asset") {
                            activeSheet = AssetSheet(asset: nil, initialCategory: category)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accentAlt)
                    }
                } else {
                    ForEach(assets) { asset in
                        Button {
                            activeSheet = AssetSheet(asset: asset, initialCategory: category)
                        } label: {
                            AssetRowView(asset: asset, value: CalculationsService.assetValue(asset))
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                Haptics.warning()
                                store.delete(asset)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle(category.definition.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    activeSheet = AssetSheet(asset: nil, initialCategory: category)
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
