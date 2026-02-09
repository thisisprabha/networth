import Foundation

struct MoneyFormatConfig: Codable, Hashable {
    var currencyCode: String
    var regionCode: String

    init(currencyCode: String, regionCode: String) {
        self.currencyCode = currencyCode
        self.regionCode = regionCode
    }
}

enum Formatters {
    static func formatMoney(_ value: Double, config: MoneyFormatConfig) -> String {
        if config.currencyCode.uppercased() == "INR", config.regionCode.uppercased() == "IN" {
            return formatINR(value)
        }

        let locale = moneyLocale(config: config)
        return value.formatted(
            .currency(code: config.currencyCode)
                .locale(locale)
                .precision(.fractionLength(0))
        )
    }

    static func formatMoneyCompact(_ value: Double, config: MoneyFormatConfig) -> String {
        if config.currencyCode.uppercased() == "INR", config.regionCode.uppercased() == "IN" {
            return formatINRCompact(value)
        }

        let locale = moneyLocale(config: config)
        let absValue = abs(value)
        let formatted = absValue.formatted(
            .number
                .notation(.compactName)
                .locale(locale)
                .precision(.fractionLength(0...1))
        )
        return value < 0 ? "-\(formatted)" : formatted
    }

    static func currencySymbol(config: MoneyFormatConfig) -> String {
        if config.currencyCode.uppercased() == "INR", config.regionCode.uppercased() == "IN" {
            return "₹"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = config.currencyCode
        formatter.locale = moneyLocale(config: config)
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.currencySymbol
    }

    static func currencyDisplay(config: MoneyFormatConfig) -> String {
        let symbol = currencySymbol(config: config)
        if symbol == config.currencyCode {
            return config.currencyCode
        }
        return "\(config.currencyCode) (\(symbol))"
    }

    private static func moneyLocale(config: MoneyFormatConfig) -> Locale {
        let languageCode = deviceLanguageCode()
        let identifier = "\(languageCode)_\(config.regionCode)"
        return Locale(identifier: identifier)
    }

    private static func deviceLanguageCode() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        let separatorSet = CharacterSet(charactersIn: "-_")
        let components = preferred.components(separatedBy: separatorSet).filter { !$0.isEmpty }
        return components.first ?? "en"
    }

    private static func formatINR(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        let absValue = abs(value)
        if absValue >= 10_000_000 {
            return "\(sign)₹" + formattedDecimal(absValue / 10_000_000) + "Cr"
        }
        if absValue >= 100_000 {
            return "\(sign)₹" + formattedDecimal(absValue / 100_000) + "L"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: absValue)) ?? "₹0"
        return sign + formatted.replacingOccurrences(of: "-", with: "")
    }

    private static func formatINRCompact(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        let absValue = abs(value)
        if absValue >= 10_000_000 {
            return sign + formattedDecimal(absValue / 10_000_000) + "Cr"
        }
        if absValue >= 100_000 {
            return sign + formattedDecimal(absValue / 100_000) + "L"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return sign + (formatter.string(from: NSNumber(value: absValue)) ?? "0")
    }

    private static func formattedDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
