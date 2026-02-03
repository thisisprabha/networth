import Foundation

enum Formatters {
    static func formatINR(_ value: Double) -> String {
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

    static func formatINRCompact(_ value: Double) -> String {
        if value >= 10_000_000 {
            return formattedDecimal(value / 10_000_000) + "Cr"
        }
        if value >= 100_000 {
            return formattedDecimal(value / 100_000) + "L"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private static func formattedDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
