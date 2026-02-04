import SwiftUI

struct AssetsListView: View {
    let store: AssetStore

    @State private var activeSheet: AssetSheet?
    @State private var selectedCategory: AssetCategory?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    splitList
                } detail: {
                    NavigationStack {
                        if let selectedCategory {
                            CategoryDetailView(store: store, category: selectedCategory)
                        } else {
                            ContentUnavailableView(
                                "Select a category",
                                systemImage: "tray.full",
                                description: Text("Choose a category to see its assets.")
                            )
                        }
                    }
                }
            } else {
                NavigationStack {
                    compactList
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            AssetFormView(store: store, asset: sheet.asset, initialCategory: sheet.initialCategory)
        }
    }

    private var compactList: some View {
        List {
            if wealthSummaries.isEmpty && liabilitySummaries.isEmpty && coverageSummaries.isEmpty {
                ContentUnavailableView {
                    Label("No assets yet", systemImage: "tray")
                } description: {
                    Text("Add your first asset to see category totals.")
                } actions: {
                    Button("Add asset") {
                        activeSheet = AssetSheet(asset: nil, initialCategory: nil)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentAlt)
                }
            } else {
                wealthSection
                liabilitySection
                protectionSection
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
    }

    private var splitList: some View {
        List(selection: $selectedCategory) {
            if wealthSummaries.isEmpty && liabilitySummaries.isEmpty && coverageSummaries.isEmpty {
                ContentUnavailableView {
                    Label("No assets yet", systemImage: "tray")
                } description: {
                    Text("Add your first asset to see category totals.")
                } actions: {
                    Button("Add asset") {
                        activeSheet = AssetSheet(asset: nil, initialCategory: nil)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentAlt)
                }
            } else {
                wealthSection(selectionEnabled: true)
                liabilitySection(selectionEnabled: true)
                protectionSection(selectionEnabled: true)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Assets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    activeSheet = AssetSheet(asset: nil, initialCategory: nil)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    @ViewBuilder
    private var wealthSection: some View {
        wealthSection(selectionEnabled: false)
    }

    @ViewBuilder
    private var liabilitySection: some View {
        liabilitySection(selectionEnabled: false)
    }

    @ViewBuilder
    private var protectionSection: some View {
        protectionSection(selectionEnabled: false)
    }

    @ViewBuilder
    private func wealthSection(selectionEnabled: Bool) -> some View {
        if !wealthSummaries.isEmpty {
            Section {
                ForEach(wealthSummaries) { summary in
                    if selectionEnabled {
                        CategoryRowView(summary: summary)
                            .tag(summary.category)
                            .contentShape(Rectangle())
                    } else {
                        NavigationLink(value: summary.category) {
                            CategoryRowView(summary: summary)
                        }
                    }
                }
            } header: {
                Text("Wealth")
            } footer: {
                Text("Assets that add to your net worth.")
            }
        }
    }

    @ViewBuilder
    private func liabilitySection(selectionEnabled: Bool) -> some View {
        if !liabilitySummaries.isEmpty {
            Section {
                ForEach(liabilitySummaries) { summary in
                    if selectionEnabled {
                        CategoryRowView(summary: summary)
                            .tag(summary.category)
                            .contentShape(Rectangle())
                    } else {
                        NavigationLink(value: summary.category) {
                            CategoryRowView(summary: summary)
                        }
                    }
                }
            } header: {
                Text("Liabilities")
            } footer: {
                Text("Debts that reduce your net worth.")
            }
        }
    }

    @ViewBuilder
    private func protectionSection(selectionEnabled: Bool) -> some View {
        if !coverageSummaries.isEmpty {
            Section {
                ForEach(coverageSummaries) { summary in
                    if selectionEnabled {
                        CategoryRowView(summary: summary)
                            .tag(summary.category)
                            .contentShape(Rectangle())
                    } else {
                        NavigationLink(value: summary.category) {
                            CategoryRowView(summary: summary)
                        }
                    }
                }
            } header: {
                Text("Protection")
            } footer: {
                Text("Coverage only, not included in net worth.")
            }
        }
    }
}

private struct AssetSheet: Identifiable {
    let id = UUID()
    let asset: Asset?
    let initialCategory: AssetCategory?
}
