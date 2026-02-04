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

    private var categorySummaries: [CategorySummary] {
        CalculationsService.categorySummaries(assets: store.assets, includeInNetWorth: true, isLiability: false)
    }

    private var topCategories: [CategorySummary] {
        Array(categorySummaries.prefix(3))
    }

    private var topAssets: [Asset] {
        store.assets.sorted { CalculationsService.assetValue($0) > CalculationsService.assetValue($1) }.prefix(3).map { $0 }
    }

    private var projectionSeries: [ProjectionSeriesPoint] {
        CalculationsService.projectionSeries(assets: store.assets, settings: store.settings, months: 12)
    }

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    StaggeredCard(isVisible: showCards, delay: 0.0) {
                        HeroHeaderView(
                            currentValue: currentNetWorth,
                            projectionValue: projectionValue,
                            percentGrowth: percentGrowth,
                            lastUpdated: lastUpdated
                        )
                    }

                    StaggeredCard(isVisible: showCards, delay: 0.06) {
                        PrimaryActionCard {
                            tabSelection = .assets
                        }
                    }

                    StaggeredCard(isVisible: showCards, delay: 0.12) {
                        InsightsCard(delta: deltaSinceLast)
                    }

                    StaggeredCard(isVisible: showCards, delay: 0.20) {
                        CategoryPreviewCard(
                            categories: topCategories,
                            onSeeAll: { tabSelection = .assets }
                        )
                    }

                    StaggeredCard(isVisible: showCards, delay: 0.28) {
                        TrendCard(snapshots: trendPoints)
                    }

                    StaggeredCard(isVisible: showCards, delay: 0.36) {
                        ProjectionCard(
                            series: projectionSeries,
                            currentValue: currentNetWorth,
                            projectionValue: projectionValue,
                            percentGrowth: percentGrowth
                        )
                    }

                    StaggeredCard(isVisible: showCards, delay: 0.44) {
                        TopAssetsCard(assets: topAssets)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, Theme.Spacing.screenVertical)
            }
        }
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

    private var trendPoints: [NetWorthSnapshot] {
        Array(store.snapshots.suffix(12))
    }
}

private struct StaggeredCard<Content: View>: View {
    let isVisible: Bool
    let delay: Double
    @ViewBuilder var content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            content
        } else {
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 18)
                .animation(.spring(response: 0.7, dampingFraction: 0.9).delay(delay), value: isVisible)
        }
    }
}

private struct NetWorthDelta: Hashable {
    let amount: Double
    let percent: Double
}

private struct CardHeader<Trailing: View, Subtitle: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing
    @ViewBuilder var subtitle: Subtitle

    init(_ title: String, @ViewBuilder trailing: () -> Trailing = { EmptyView() }, @ViewBuilder subtitle: () -> Subtitle = { EmptyView() }) {
        self.title = title
        self.trailing = trailing()
        self.subtitle = subtitle()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            HStack {
                Text(title)
                    .font(AppFont.font(.headline, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer()
                trailing
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            subtitle
        }
    }
}

private struct InsightRow: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.font(.subheadline))
                .foregroundStyle(Theme.secondaryText)
            Spacer()
            Text(value)
                .font(AppFont.font(.subheadline, weight: .semibold))
                .foregroundStyle(valueColor)
        }
    }
}

private struct PrimaryActionCard: View {
    let onTap: () -> Void

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                CardHeader("Quick update")

                Text("Update a value to keep your net worth current.")
                    .font(AppFont.font(.subheadline))
                    .foregroundStyle(Theme.secondaryText)

                Button(action: onTap) {
                    Label("Update assets", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accentAlt)
            }
        }
    }
}

private struct HeroHeaderView: View {
    let currentValue: Double
    let projectionValue: Double
    let percentGrowth: Double
    let lastUpdated: Date?

    var body: some View {
        ZStack {
            Theme.card
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("Current net worth")
                    .font(AppFont.font(.subheadline, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)

                Text(Formatters.formatINR(currentValue))
                    .font(Theme.Typography.heroValue)
                    .foregroundStyle(Theme.primaryText)
                    .contentTransition(.numericText())

                if let lastUpdated {
                    Text("Updated \(lastUpdated, style: .date)")
                        .font(AppFont.font(.caption2))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.xxLarge)
        }
        .frame(height: Theme.Size.heroHeight)
        .clipShape(.rect(cornerRadius: Theme.Radius.hero))
        .shadow(
            color: Theme.Elevation.heroShadowColor,
            radius: Theme.Elevation.heroShadowRadius,
            x: 0,
            y: Theme.Elevation.heroShadowY
        )
    }

}

private struct ProjectionCard: View {
    let series: [ProjectionSeriesPoint]
    let currentValue: Double
    let projectionValue: Double
    let percentGrowth: Double

    private var delta: Double {
        projectionValue - currentValue
    }

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                CardHeader("Projection") {
                    Text("1Y")
                        .font(AppFont.font(.caption, weight: .bold))
                        .foregroundStyle(Theme.accentAlt)
                        .padding(.horizontal, Theme.Spacing.small)
                        .padding(.vertical, Theme.Spacing.xSmall)
                        .background(Theme.accentAlt.opacity(0.15), in: Capsule())
                }

                Text(Formatters.formatINR(projectionValue))
                    .font(AppFont.font(.title2, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .contentTransition(.numericText())

                HStack(spacing: Theme.Spacing.small) {
                    Label("Projected change", systemImage: "chart.line.uptrend.xyaxis")
                        .font(AppFont.font(.caption))
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    GrowthPill(percent: percentGrowth, delta: delta)
                }

                if #available(iOS 16, *) {
                    if series.isEmpty {
                        Text("Add assets to see projections.")
                            .font(AppFont.font(.subheadline))
                            .foregroundStyle(Theme.secondaryText)
                    } else {
                        Chart(series) { point in
                            LineMark(
                                x: .value("Month", point.month),
                                y: .value("Change", point.percent)
                            )
                            .foregroundStyle(by: .value("Series", point.series.rawValue))
                            .interpolationMethod(.catmullRom)
                        }
                        .chartForegroundStyleScale([
                            ProjectionSeries.growth.rawValue: Theme.positive,
                            ProjectionSeries.decline.rawValue: Theme.negative
                        ])
                        .chartLegend(position: .bottom, alignment: .leading)
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                                AxisTick()
                                    .foregroundStyle(Theme.divider.opacity(0.4))
                                AxisValueLabel()
                                    .font(AppFont.font(.caption2))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 3)) { value in
                                AxisGridLine()
                                    .foregroundStyle(Theme.divider.opacity(0.2))
                                AxisTick()
                                    .foregroundStyle(Theme.divider.opacity(0.4))
                                AxisValueLabel {
                                    if let yValue = value.as(Double.self) {
                                        Text(yValue, format: .percent.precision(.fractionLength(0)))
                                    }
                                }
                                .font(AppFont.font(.caption2))
                                .foregroundStyle(Theme.secondaryText)
                            }
                        }
                        .frame(height: Theme.Size.chartSmall)
                    }
                } else {
                    Text("Projection chart requires iOS 16+")
                        .font(AppFont.font(.footnote))
                        .foregroundStyle(Theme.secondaryText)
                }

                Text("Assumptions only. Actuals can vary.")
                    .font(AppFont.font(.caption2))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

private struct GrowthPill: View {
    let percent: Double
    let delta: Double

    var body: some View {
        HStack(spacing: Theme.Spacing.tight) {
            Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(AppFont.font(.caption2, weight: .bold))
            Text(percent, format: .percent.precision(.fractionLength(1)))
                .font(AppFont.font(.caption, weight: .bold))
        }
        .foregroundStyle(delta >= 0 ? Theme.positive : Theme.negative)
        .padding(.horizontal, Theme.Spacing.small)
        .padding(.vertical, Theme.Spacing.xSmall)
        .background((delta >= 0 ? Theme.positive : Theme.negative).opacity(0.12), in: Capsule())
    }
}

private struct InsightsCard: View {
    let delta: NetWorthDelta?

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                CardHeader("Latest change")

                if let delta {
                    InsightRow(
                        title: "Net worth change",
                        value: Formatters.formatINR(delta.amount),
                        valueColor: delta.amount >= 0 ? Theme.positive : Theme.negative
                    )
                    InsightRow(
                        title: "Percent change",
                        value: delta.percent.formatted(.percent.precision(.fractionLength(1))),
                        valueColor: Theme.primaryText
                    )

                    Text("Compared to your previous update.")
                        .font(AppFont.font(.caption))
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    Text("No changes yet.")
                        .font(AppFont.font(.subheadline))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
    }
}

private struct TrendCard: View {
    let snapshots: [NetWorthSnapshot]

    private struct TrendPoint: Identifiable {
        let index: Int
        let display: Double
        let isPercent: Bool
        var id: Int { index }
    }

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                CardHeader("Net Worth Trend")

                if snapshots.count < 2 {
                    Text("Update again to see trends.")
                        .font(AppFont.font(.subheadline))
                        .foregroundStyle(Theme.secondaryText)
                } else if #available(iOS 16, *) {
                    let ordered = snapshots.sorted { $0.date < $1.date }
                    let base = ordered.first?.netWorth ?? 0
                    let usePercent = base > 0
                    let points = ordered.enumerated().map { index, snapshot in
                        let value = usePercent ? (snapshot.netWorth - base) / base : snapshot.netWorth
                        return TrendPoint(index: index + 1, display: value, isPercent: usePercent)
                    }

                    Chart(points) { point in
                        LineMark(
                            x: .value("Update", point.index),
                            y: .value("Change", point.display)
                        )
                        .foregroundStyle(Theme.accentAlt)
                        .interpolationMethod(.catmullRom)
                        AreaMark(
                            x: .value("Update", point.index),
                            y: .value("Change", point.display)
                        )
                        .foregroundStyle(Theme.accentAlt)
                        .opacity(0.12)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { value in
                            AxisTick()
                                .foregroundStyle(Theme.divider.opacity(0.4))
                            AxisValueLabel {
                                if let index = value.as(Int.self) {
                                    Text("\(index)")
                                }
                            }
                            .font(AppFont.font(.caption2))
                            .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { value in
                            AxisGridLine()
                                .foregroundStyle(Theme.divider.opacity(0.2))
                            AxisTick()
                                .foregroundStyle(Theme.divider.opacity(0.4))
                            AxisValueLabel {
                                if let yValue = value.as(Double.self) {
                                    if usePercent {
                                        Text(yValue, format: .percent.precision(.fractionLength(0)))
                                    } else {
                                        Text(Formatters.formatINRCompact(yValue))
                                    }
                                }
                            }
                            .font(AppFont.font(.caption2))
                            .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    .frame(height: Theme.Size.chartMedium)
                } else {
                    Text("Trend chart requires iOS 16+")
                        .font(AppFont.font(.footnote))
                        .foregroundStyle(Theme.secondaryText)
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
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                CardHeader("Categories") {
                    Button("See all") {
                        onSeeAll()
                    }
                    .font(AppFont.font(.subheadline))
                    .foregroundStyle(Theme.accentAlt)
                }

                if categories.isEmpty {
                    Text("Add assets to see category totals.")
                        .font(AppFont.font(.subheadline))
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
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                CardHeader("Top Assets")

                if assets.isEmpty {
                    Text("Add your first asset to get started.")
                        .font(AppFont.font(.subheadline))
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
