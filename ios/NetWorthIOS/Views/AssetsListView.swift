import SwiftUI

struct AssetsListView: View {
    let store: AssetStore

    @State private var activeSheet: AssetSheet?

    private var sortedAssets: [Asset] {
        store.assets.sorted { CalculationsService.assetValue($0) > CalculationsService.assetValue($1) }
    }

    var body: some View {
        List {
            Section {
                ForEach(sortedAssets) { asset in
                    Button {
                        activeSheet = AssetSheet(asset: asset)
                    } label: {
                        AssetRowView(asset: asset, value: CalculationsService.assetValue(asset))
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            store.delete(asset)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("All Assets")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Assets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    activeSheet = AssetSheet(asset: nil)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            AssetFormView(store: store, asset: sheet.asset)
        }
    }
}

private struct AssetSheet: Identifiable {
    let id = UUID()
    let asset: Asset?
}
