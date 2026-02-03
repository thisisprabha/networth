import SwiftUI
import Charts

struct HomeView: View {
    let store: AssetStore
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
                        percentGrowth: percentGrowth
                    )
                }

                StaggeredCard(isVisible: showCards, delay: 0.08) {
                    ProjectionCard(points: projectionPoints)
                }

                StaggeredCard(isVisible: showCards, delay: 0.16) {
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

private struct HeroHeaderView: View {
    let currentValue: Double
    let projectionValue: Double
    let percentGrowth: Double

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

                HStack(spacing: 12) {
                    Label("Projection", systemImage: "sparkles")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.2), in: Capsule())

                    Text(Formatters.formatINR(projectionValue))
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }

                HStack {
                    Text("1‑Year Growth")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text(percentGrowth, format: .percent.precision(.fractionLength(1)))
                        .font(.caption.bold())
                        .foregroundStyle(delta >= 0 ? .white : .white.opacity(0.7))
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
                    Color(red: 0.10, green: 0.05, blue: 0.35),
                    Color(red: 0.20, green: 0.10, blue: 0.55),
                    Color(red: 0.30, green: 0.20, blue: 0.70),
                    Color(red: 0.30, green: 0.10, blue: 0.60),
                    Color(red: 0.45, green: 0.20, blue: 0.75),
                    Color(red: 0.55, green: 0.35, blue: 0.85),
                    Color(red: 0.55, green: 0.30, blue: 0.80),
                    Color(red: 0.65, green: 0.45, blue: 0.90),
                    Color(red: 0.75, green: 0.55, blue: 0.95)
                ]
            )
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.05, blue: 0.35),
                    Color(red: 0.30, green: 0.15, blue: 0.65),
                    Color(red: 0.55, green: 0.40, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct ProjectionCard: View {
    let points: [ProjectionPoint]

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Projection")
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)
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
                    .frame(height: 120)
                } else {
                    Text("Projection chart requires iOS 16+")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
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
