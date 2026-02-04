import SwiftUI
import WidgetKit

struct NetWorthWidgetView: View {
    let entry: NetWorthEntry

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    backgroundGradient
                }
        } else {
            content
                .background(backgroundGradient)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Net Worth")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            Text(formatINR(entry.state.netWorth))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            if let delta = entry.state.deltaPercent {
                Text(delta, format: .percent.precision(.fractionLength(1)))
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            } else {
                Text("Update to see change")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Text(entry.state.lastUpdated, style: .date)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.18, blue: 0.15),
                Color(red: 0.18, green: 0.52, blue: 0.36),
                Color(red: 0.78, green: 0.92, blue: 0.84)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func formatINR(_ value: Double) -> String {
        if value >= 10_000_000 {
            return "₹" + formattedDecimal(value / 10_000_000) + "Cr"
        }
        if value >= 100_000 {
            return "₹" + formattedDecimal(value / 100_000) + "L"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "₹0"
    }

    private func formattedDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
