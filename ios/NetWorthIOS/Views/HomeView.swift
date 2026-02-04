import SwiftUI
import Charts

struct HomeView: View {
    let store: AssetStore
    @Binding var tabSelection: RootTab
    @State private var showCards = false

    private var currentNetWorth: Double {
        CalculationsService.netWorth(store.assets)
    }

    private var projectionValue: Double {
        CalculationsService.oneYearProjection(assets: store.assets, settings: store.settings)
    }

    private var projectionPoints: [ProjectionPoint] {
        CalculationsService.projection(assets: store.assets, settings: store.settings, months: 12)
    }

    private var categorySummaries: [CategorySummary] {
        CalculationsService.categorySummaries(assets: store.assets, includeInNetWorth: true, isLiability: false)
    }

    private var topCategories: [CategorySummary] {
        Array(categorySummaries.prefix(3))
    }

    private var topAssets: [Asset] {
        store.assets.sorted { CalculationsService.assetValue($0) > CalculationsService.assetValue($1) }.prefix(3).map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                StaggeredCard(isVisible: showCards, delay: 0.0) {
                    HeroHeaderView(
                        currentValue: currentNetWorth,
                        projectionValue: projectionValue,
                        percentGrowth: percentGrowth,
                        lastUpdated: lastUpdated
                    )
                }

                StaggeredCard(isVisible: showCards, delay: 0.08) {
                    CategoryPreviewCard(
                        categories: topCategories,
                        onSeeAll: { tabSelection = .assets }
                    )
                }

                StaggeredCard(isVisible: showCards, delay: 0.16) {
                    InsightsCard(delta: deltaSinceLast, topShare: topShare)
                }

                StaggeredCard(isVisible: showCards, delay: 0.24) {
                    TrendCard(snapshots: trendPoints)
                }

                StaggeredCard(isVisible: showCards, delay: 0.32) {
                    DriversCard(changes: driverChanges)
                }

                StaggeredCard(isVisible: showCards, delay: 0.40) {
                    ProjectionCard(
                        points: projectionPoints,
                        currentValue: currentNetWorth,
                        projectionValue: projectionValue,
                        percentGrowth: percentGrowth
                    )
                }

                StaggeredCard(isVisible: showCards, delay: 0.48) {
                    TopAssetsCard(assets: topAssets)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Theme.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("Net Worth")
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                showCards = true
            }
        }
    }

    private var percentGrowth: Double {
        guard currentNetWorth > 0 else { return 0 }
        return (projectionValue - currentNetWorth) / currentNetWorth
    }

    private var lastUpdated: Date? {
        store.assets.map(\.updatedAt).max()
    }

    private var deltaSinceLast: NetWorthDelta? {
        guard store.snapshots.count >= 2 else { return nil }
        let last = store.snapshots.last!
        let previous = store.snapshots.dropLast().last!
        let amount = last.netWorth - previous.netWorth
        let percent = previous.netWorth > 0 ? amount / previous.netWorth : 0
        return NetWorthDelta(amount: amount, percent: percent)
    }

    private var topShare: Double? {
        guard currentNetWorth > 0 else { return nil }
        let sum = topCategories.reduce(0) { $0 + $1.total }
        return sum / currentNetWorth
    }

    private var trendPoints: [NetWorthSnapshot] {
        Array(store.snapshots.suffix(12))
    }

    private var driverChanges: [DriverChange] {
        guard store.snapshots.count >= 2 else { return [] }
        let last = store.snapshots.last!
        let previous = store.snapshots.dropLast().last!
        let keys = Set(last.categoryTotals.keys).union(previous.categoryTotals.keys)
        let changes = keys.compactMap { key -> DriverChange? in
            let newValue = last.categoryTotals[key] ?? 0
            let oldValue = previous.categoryTotals[key] ?? 0
            let delta = newValue - oldValue
            guard delta != 0, let category = AssetCategory(rawValue: key) else { return nil }
            return DriverChange(category: category, delta: delta)
        }
        return changes.sorted { abs($0.delta) > abs($1.delta) }
    }
}

private struct StaggeredCard<Content: View>: View {
    let isVisible: Bool
    let delay: Double
    @ViewBuilder var content: Content

    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 18)
            .animation(.spring(response: 0.7, dampingFraction: 0.9).delay(delay), value: isVisible)
    }
}

private struct NetWorthDelta: Hashable {
    let amount: Double
    let percent: Double
}

private struct DriverChange: Identifiable, Hashable {
    let category: AssetCategory
    let delta: Double
    var id: AssetCategory { category }
}

private struct HeroHeaderView: View {
    let currentValue: Double
    let projectionValue: Double
    let percentGrowth: Double
    let lastUpdated: Date?

    private var delta: Double {
        projectionValue - currentValue
    }

    var body: some View {
        ZStack {
            headerGradient
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Net Worth")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Text(Formatters.formatINR(currentValue))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                if let lastUpdated {
                    Text("Updated \(lastUpdated, style: .date)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(24)
        }
        .frame(height: 220)
        .clipShape(.rect(cornerRadius: 28))
        .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
    }

    @ViewBuilder
    private var headerGradient: some View {
        if #available(iOS 17, *) {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ],
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.15),
                    Color(red: 0.08, green: 0.28, blue: 0.20),
                    Color(red: 0.10, green: 0.40, blue: 0.28),
                    Color(red: 0.12, green: 0.36, blue: 0.30),
                    Color(red: 0.18, green: 0.52, blue: 0.36),
                    Color(red: 0.30, green: 0.64, blue: 0.48),
                    Color(red: 0.40, green: 0.72, blue: 0.58),
                    Color(red: 0.58, green: 0.82, blue: 0.70),
                    Color(red: 0.78, green: 0.92, blue: 0.84)
                ]
            )
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.15),
                    Color(red: 0.14, green: 0.45, blue: 0.34),
                    Color(red: 0.55, green: 0.82, blue: 0.68)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct ProjectionCard: View {
    let points: [ProjectionPoint]
    let currentValue: Double
    let projectionValue: Double
    let percentGrowth: Double

    private var delta: Double {
        projectionValue - currentValue
    }

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Projection")
                        .font(.headline)
                        .foregroundStyle(Theme.primaryText)
                    Spacer()
                    Text("1Y")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.accentAlt)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accentAlt.opacity(0.15), in: Capsule())
                }

                Text(Formatters.formatINR(projectionValue))
                    .font(.title2.bold())
                    .foregroundStyle(Theme.primaryText)
                    .contentTransition(.numericText())

                HStack(spacing: 12) {
                    Label("Projected change", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    GrowthPill(percent: percentGrowth, delta: delta)
                }

                if #available(iOS 16, *) {
                    Chart(points) { point in
                        LineMark(
                            x: .value("Month", point.month),
                            y: .value("Value", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        AreaMark(
                            x: .value("Month", point.month),
                            y: .value("Value", point.value)
                        )
                        .opacity(0.12)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                                .foregroundStyle(.clear)
                            AxisTick()
                                .foregroundStyle(.clear)
                            AxisValueLabel()
                                .foregroundStyle(.clear)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                                .foregroundStyle(.clear)
                            AxisTick()
                                .foregroundStyle(.clear)
                            AxisValueLabel()
                                .foregroundStyle(.clear)
                        }
                    }
                    .frame(height: 110)
                } else {
                    Text("Projection chart requires iOS 16+")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                }

                Text("Assumptions only. Actuals can vary.")
                    .font(.caption2)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

private struct GrowthPill: View {
    let percent: Double
    let delta: Double

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption2.bold())
            Text(percent, format: .percent.precision(.fractionLength(1)))
                .font(.caption.bold())
        }
        .foregroundStyle(delta >= 0 ? Theme.positive : Theme.negative)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background((delta >= 0 ? Theme.positive : Theme.negative).opacity(0.12), in: Capsule())
    }
}

private struct InsightsCard: View {
    let delta: NetWorthDelta?
    let topShare: Double?

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Insights")
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)

                HStack {
                    Text("Since last update")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    if let delta {
                        Text(Formatters.formatINR(delta.amount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(delta.amount >= 0 ? Theme.positive : Theme.negative)
                    } else {
                        Text("—")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }

                HStack {
                    Text("Top 3 categories share")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    if let topShare {
                        Text(topShare, format: .percent.precision(.fractionLength(0)))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.primaryText)
                    } else {
                        Text("—")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
    }
}

private struct TrendCard: View {
    let snapshots: [NetWorthSnapshot]

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Net Worth Trend")
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)

                if snapshots.count < 2 {
                    Text("Make another update to see trends.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                } else if #available(iOS 16, *) {
                    Chart(snapshots) { snapshot in
                        LineMark(
                            x: .value("Date", snapshot.date),
                            y: .value("Net Worth", snapshot.netWorth)
                        )
                        .interpolationMethod(.catmullRom)
                        AreaMark(
                            x: .value("Date", snapshot.date),
                            y: .value("Net Worth", snapshot.netWorth)
                        )
                        .opacity(0.12)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                                .foregroundStyle(.clear)
                            AxisTick()
                                .foregroundStyle(.clear)
                            AxisValueLabel()
                                .foregroundStyle(.clear)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                                .foregroundStyle(.clear)
                            AxisTick()
                                .foregroundStyle(.clear)
                            AxisValueLabel()
                                .foregroundStyle(.clear)
                        }
                    }
                    .frame(height: 120)
                } else {
                    Text("Trend chart requires iOS 16+")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
    }
}

private struct DriversCard: View {
    let changes: [DriverChange]

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Drivers")
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)

                if changes.isEmpty {
                    Text("No changes yet.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    ForEach(Array(changes.prefix(3))) { change in
                        HStack {
                            Text(change.category.definition.name)
                                .font(.subheadline)
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Text(Formatters.formatINR(change.delta))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(change.delta >= 0 ? Theme.positive : Theme.negative)
                        }
                    }
                }
            }
        }
    }
}

private struct CategoryPreviewCard: View {
    let categories: [CategorySummary]
    let onSeeAll: () -> Void

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Categories")
                        .font(.headline)
                        .foregroundStyle(Theme.primaryText)
                    Spacer()
                    Button("See all") {
                        onSeeAll()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Theme.accentAlt)
                }

                if categories.isEmpty {
                    Text("Add assets to see category totals.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    ForEach(categories) { summary in
                        CategoryRowView(summary: summary)
                    }
                }
            }
        }
    }
}

private struct TopAssetsCard: View {
    let assets: [Asset]

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Assets")
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)

                if assets.isEmpty {
                    Text("Add your first asset to get started.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    ForEach(assets) { asset in
                        let value = CalculationsService.assetValue(asset)
                        AssetRowView(asset: asset, value: value)
                    }
                }
            }
        }
    }
}
