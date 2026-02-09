import SwiftUI

private struct MoneyFormatConfigKey: EnvironmentKey {
    static let defaultValue = MoneyFormatConfig(currencyCode: "INR", regionCode: "IN")
}

extension EnvironmentValues {
    var moneyConfig: MoneyFormatConfig {
        get { self[MoneyFormatConfigKey.self] }
        set { self[MoneyFormatConfigKey.self] = newValue }
    }
}

