import SwiftUI

struct AssetCategoryDefinition {
    let category: AssetCategory
    let name: String
    let symbolName: String
    let color: Color
    let fields: [AssetFieldDefinition]
    let growthRateDefault: Double
    let growthRateRange: ClosedRange<Double>?
    let includesInNetWorth: Bool
    let isLiability: Bool

    init(
        category: AssetCategory,
        name: String,
        symbolName: String,
        color: Color,
        fields: [AssetFieldDefinition],
        growthRateDefault: Double,
        growthRateRange: ClosedRange<Double>?,
        includesInNetWorth: Bool = true,
        isLiability: Bool = false
    ) {
        self.category = category
        self.name = name
        self.symbolName = symbolName
        self.color = color
        self.fields = fields
        self.growthRateDefault = growthRateDefault
        self.growthRateRange = growthRateRange
        self.includesInNetWorth = includesInNetWorth
        self.isLiability = isLiability
    }
}

extension AssetCategoryDefinition {
    static let ordered: [AssetCategory] = [
        .stocks,
        .mutualFunds,
        .gold,
        .silver,
        .fixedDeposits,
        .bonds,
        .land,
        .home,
        .savings,
        .emergencySavings,
        .esop,
        .privateEquity,
        .vpfPpf,
        .personalAssets,
        .homeLoan,
        .carLoan,
        .personalLoan,
        .creditCard,
        .otherDebt,
        .lifeInsurance,
        .healthInsurance,
        .vehicleInsurance
    ]

    static let all: [AssetCategory: AssetCategoryDefinition] = {
        let personalAssetOptions: [AssetFieldOption] = [
            .init(value: "bike", label: "Bike", defaultNumber: 100000),
            .init(value: "car", label: "Car", defaultNumber: 800000),
            .init(value: "cycle", label: "Cycle", defaultNumber: 10000),
            .init(value: "phone", label: "iPhone/Smartphone", defaultNumber: 80000),
            .init(value: "laptop", label: "Laptop", defaultNumber: 90000),
            .init(value: "pc", label: "PC", defaultNumber: 100000),
            .init(value: "watch", label: "Smart Watch", defaultNumber: 30000),
            .init(value: "console", label: "Gaming Console", defaultNumber: 50000),
            .init(value: "shoes", label: "Luxury Shoes", defaultNumber: 15000),
            .init(value: "watch_luxury", label: "Luxury Watch", defaultNumber: 100000),
            .init(value: "other", label: "Other", defaultNumber: 10000)
        ]

        return [
            .stocks: AssetCategoryDefinition(
                category: .stocks,
                name: "Stock Investments",
                symbolName: "chart.line.uptrend.xyaxis",
                color: .green,
                fields: [
                    .init(
                        id: "stockValue",
                        label: "Approximate Total Value",
                        kind: .slider,
                        min: 0,
                        max: 10_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: 17.5,
                growthRateRange: 15...20,
                includesInNetWorth: true
            ),
            .mutualFunds: AssetCategoryDefinition(
                category: .mutualFunds,
                name: "Mutual Fund Investments",
                symbolName: "chart.bar",
                color: .blue,
                fields: [
                    .init(
                        id: "fundValue",
                        label: "Approximate Total Value",
                        kind: .slider,
                        min: 0,
                        max: 10_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: 11.5,
                growthRateRange: 10...13,
                includesInNetWorth: true
            ),
            .gold: AssetCategoryDefinition(
                category: .gold,
                name: "Gold",
                symbolName: "circle.fill",
                color: .yellow,
                fields: [
                    .init(
                        id: "goldQuantity",
                        label: "Quantity (grams)",
                        kind: .number,
                        min: 0,
                        step: 0.1,
                        defaultValue: .number(0)
                    ),
                    .init(
                        id: "goldRate",
                        label: "Current Rate (₹ per gram)",
                        kind: .number,
                        min: 0,
                        step: 100,
                        defaultValue: .number(5000)
                    )
                ],
                growthRateDefault: 9.5,
                growthRateRange: 9...10,
                includesInNetWorth: true
            ),
            .silver: AssetCategoryDefinition(
                category: .silver,
                name: "Silver",
                symbolName: "circle.dashed",
                color: .gray,
                fields: [
                    .init(
                        id: "silverGrams",
                        label: "Quantity (grams)",
                        kind: .number,
                        min: 0,
                        step: 1,
                        defaultValue: .number(0)
                    ),
                    .init(
                        id: "silverRate",
                        label: "Current Rate (₹ per gram)",
                        kind: .number,
                        min: 0,
                        step: 1,
                        defaultValue: .number(85)
                    )
                ],
                growthRateDefault: 9.5,
                growthRateRange: 9...10,
                includesInNetWorth: true
            ),
            .fixedDeposits: AssetCategoryDefinition(
                category: .fixedDeposits,
                name: "Fixed Deposits",
                symbolName: "tray",
                color: .gray,
                fields: [
                    .init(
                        id: "principalAmount",
                        label: "Principal Amount",
                        kind: .slider,
                        min: 0,
                        max: 5_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "interestRate",
                        label: "Interest Rate (%)",
                        kind: .number,
                        min: 0,
                        max: 12,
                        step: 0.1,
                        defaultValue: .number(7)
                    ),
                    .init(
                        id: "maturityDate",
                        label: "Maturity Date (optional)",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 7,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .personalAssets: AssetCategoryDefinition(
                category: .personalAssets,
                name: "My Belongings",
                symbolName: "shippingbox",
                color: .purple,
                fields: [
                    .init(
                        id: "assetType",
                        label: "Asset Type",
                        kind: .select,
                        defaultValue: .text(personalAssetOptions.first?.value ?? "other"),
                        options: personalAssetOptions
                    ),
                    .init(
                        id: "assetName",
                        label: "Description (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "quantity",
                        label: "Quantity",
                        kind: .number,
                        min: 1,
                        step: 1,
                        defaultValue: .number(1)
                    ),
                    .init(
                        id: "assetValue",
                        label: "Current Value",
                        kind: .slider,
                        min: 0,
                        max: 2_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: -7.5,
                growthRateRange: -10...(-5),
                includesInNetWorth: true
            ),
            .bonds: AssetCategoryDefinition(
                category: .bonds,
                name: "Bonds",
                symbolName: "doc.text",
                color: .blue,
                fields: [
                    .init(
                        id: "bondValue",
                        label: "Approximate Total Value",
                        kind: .slider,
                        min: 0,
                        max: 5_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: 8,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .land: AssetCategoryDefinition(
                category: .land,
                name: "Land",
                symbolName: "map",
                color: .green,
                fields: [
                    .init(
                        id: "landValue",
                        label: "Estimated Current Value",
                        kind: .slider,
                        min: 100_000,
                        max: 50_000_000,
                        step: 100_000,
                        defaultValue: .number(1_000_000),
                        format: .currency
                    )
                ],
                growthRateDefault: 9,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .home: AssetCategoryDefinition(
                category: .home,
                name: "Home (Real Estate)",
                symbolName: "house",
                color: .red,
                fields: [
                    .init(
                        id: "homeValue",
                        label: "Estimated Current Value",
                        kind: .slider,
                        min: 500_000,
                        max: 50_000_000,
                        step: 100_000,
                        defaultValue: .number(5_000_000),
                        format: .currency
                    )
                ],
                growthRateDefault: 9,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .savings: AssetCategoryDefinition(
                category: .savings,
                name: "Savings",
                symbolName: "dollarsign.circle",
                color: .green,
                fields: [
                    .init(
                        id: "savingsBalance",
                        label: "Current Balance",
                        kind: .slider,
                        min: 0,
                        max: 5_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: 4,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .emergencySavings: AssetCategoryDefinition(
                category: .emergencySavings,
                name: "Emergency Savings",
                symbolName: "shield",
                color: .yellow,
                fields: [
                    .init(
                        id: "emergencyBalance",
                        label: "Current Balance",
                        kind: .slider,
                        min: 0,
                        max: 1_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: 4,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .esop: AssetCategoryDefinition(
                category: .esop,
                name: "ESOP",
                symbolName: "briefcase",
                color: .indigo,
                fields: [
                    .init(
                        id: "esopCurrentValue",
                        label: "Approximate Current Value per Share",
                        kind: .number,
                        min: 0,
                        step: 1,
                        defaultValue: .number(1)
                    ),
                    .init(
                        id: "esopShares",
                        label: "Number of Vested Shares",
                        kind: .number,
                        min: 0,
                        step: 1,
                        defaultValue: .number(0)
                    )
                ],
                growthRateDefault: 15,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .privateEquity: AssetCategoryDefinition(
                category: .privateEquity,
                name: "Private Equity",
                symbolName: "chart.line.uptrend.xyaxis",
                color: .teal,
                fields: [
                    .init(
                        id: "peValue",
                        label: "Estimated Current Value",
                        kind: .slider,
                        min: 0,
                        max: 50_000_000,
                        step: 10_000,
                        defaultValue: .number(100_000),
                        format: .currency
                    ),
                    .init(
                        id: "peUnits",
                        label: "Number of Units/Shares (Optional)",
                        kind: .number,
                        min: 0,
                        step: 1,
                        defaultValue: .number(1)
                    )
                ],
                growthRateDefault: 20,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .vpfPpf: AssetCategoryDefinition(
                category: .vpfPpf,
                name: "VPF/PPF",
                symbolName: "lock",
                color: .orange,
                fields: [
                    .init(
                        id: "vpfAmount",
                        label: "Current Balance",
                        kind: .slider,
                        min: 0,
                        max: 10_000_000,
                        step: 1_000,
                        defaultValue: .number(0),
                        format: .currency
                    )
                ],
                growthRateDefault: 8.5,
                growthRateRange: nil,
                includesInNetWorth: true
            ),
            .homeLoan: AssetCategoryDefinition(
                category: .homeLoan,
                name: "Home Loan",
                symbolName: "house",
                color: .red,
                fields: [
                    .init(
                        id: "debtBalance",
                        label: "Outstanding Balance",
                        kind: .slider,
                        min: 0,
                        max: 100_000_000,
                        step: 100_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "interestRate",
                        label: "Interest Rate (%)",
                        kind: .number,
                        min: 0,
                        max: 20,
                        step: 0.1,
                        defaultValue: .number(8)
                    ),
                    .init(
                        id: "lender",
                        label: "Lender (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "nextPaymentDate",
                        label: "Next Payment Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: true,
                isLiability: true
            ),
            .carLoan: AssetCategoryDefinition(
                category: .carLoan,
                name: "Car Loan",
                symbolName: "car",
                color: .orange,
                fields: [
                    .init(
                        id: "debtBalance",
                        label: "Outstanding Balance",
                        kind: .slider,
                        min: 0,
                        max: 10_000_000,
                        step: 50_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "interestRate",
                        label: "Interest Rate (%)",
                        kind: .number,
                        min: 0,
                        max: 20,
                        step: 0.1,
                        defaultValue: .number(9)
                    ),
                    .init(
                        id: "lender",
                        label: "Lender (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "nextPaymentDate",
                        label: "Next Payment Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: true,
                isLiability: true
            ),
            .personalLoan: AssetCategoryDefinition(
                category: .personalLoan,
                name: "Personal Loan",
                symbolName: "person.text.rectangle",
                color: .purple,
                fields: [
                    .init(
                        id: "debtBalance",
                        label: "Outstanding Balance",
                        kind: .slider,
                        min: 0,
                        max: 10_000_000,
                        step: 50_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "interestRate",
                        label: "Interest Rate (%)",
                        kind: .number,
                        min: 0,
                        max: 30,
                        step: 0.1,
                        defaultValue: .number(12)
                    ),
                    .init(
                        id: "lender",
                        label: "Lender (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "nextPaymentDate",
                        label: "Next Payment Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: true,
                isLiability: true
            ),
            .creditCard: AssetCategoryDefinition(
                category: .creditCard,
                name: "Credit Card",
                symbolName: "creditcard",
                color: .pink,
                fields: [
                    .init(
                        id: "debtBalance",
                        label: "Current Balance",
                        kind: .slider,
                        min: 0,
                        max: 2_000_000,
                        step: 10_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "interestRate",
                        label: "Interest Rate (%)",
                        kind: .number,
                        min: 0,
                        max: 50,
                        step: 0.1,
                        defaultValue: .number(30)
                    ),
                    .init(
                        id: "issuer",
                        label: "Issuer (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "paymentDueDate",
                        label: "Payment Due Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: true,
                isLiability: true
            ),
            .otherDebt: AssetCategoryDefinition(
                category: .otherDebt,
                name: "Other Debt",
                symbolName: "exclamationmark.triangle",
                color: .gray,
                fields: [
                    .init(
                        id: "debtBalance",
                        label: "Outstanding Balance",
                        kind: .slider,
                        min: 0,
                        max: 5_000_000,
                        step: 25_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "interestRate",
                        label: "Interest Rate (%)",
                        kind: .number,
                        min: 0,
                        max: 40,
                        step: 0.1,
                        defaultValue: .number(0)
                    ),
                    .init(
                        id: "notes",
                        label: "Notes (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: true,
                isLiability: true
            ),
            .lifeInsurance: AssetCategoryDefinition(
                category: .lifeInsurance,
                name: "Life Insurance",
                symbolName: "heart.text.square",
                color: .pink,
                fields: [
                    .init(
                        id: "coverageAmount",
                        label: "Coverage Amount",
                        kind: .slider,
                        min: 0,
                        max: 50_000_000,
                        step: 50_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "annualPremium",
                        label: "Annual Premium",
                        kind: .number,
                        min: 0,
                        step: 500,
                        defaultValue: .number(0)
                    ),
                    .init(
                        id: "provider",
                        label: "Provider (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "renewalDate",
                        label: "Renewal Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: false,
                isLiability: false
            ),
            .healthInsurance: AssetCategoryDefinition(
                category: .healthInsurance,
                name: "Health Insurance",
                symbolName: "cross.case",
                color: .mint,
                fields: [
                    .init(
                        id: "coverageAmount",
                        label: "Coverage Amount",
                        kind: .slider,
                        min: 0,
                        max: 10_000_000,
                        step: 50_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "annualPremium",
                        label: "Annual Premium",
                        kind: .number,
                        min: 0,
                        step: 500,
                        defaultValue: .number(0)
                    ),
                    .init(
                        id: "provider",
                        label: "Provider (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "renewalDate",
                        label: "Renewal Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: false,
                isLiability: false
            ),
            .vehicleInsurance: AssetCategoryDefinition(
                category: .vehicleInsurance,
                name: "Vehicle Insurance",
                symbolName: "car",
                color: .orange,
                fields: [
                    .init(
                        id: "coverageAmount",
                        label: "Coverage Amount",
                        kind: .slider,
                        min: 0,
                        max: 5_000_000,
                        step: 25_000,
                        defaultValue: .number(0),
                        format: .currency
                    ),
                    .init(
                        id: "annualPremium",
                        label: "Annual Premium",
                        kind: .number,
                        min: 0,
                        step: 500,
                        defaultValue: .number(0)
                    ),
                    .init(
                        id: "provider",
                        label: "Provider (optional)",
                        kind: .text,
                        defaultValue: .text("")
                    ),
                    .init(
                        id: "renewalDate",
                        label: "Renewal Date",
                        kind: .date,
                        defaultValue: .date(.now)
                    )
                ],
                growthRateDefault: 0,
                growthRateRange: nil,
                includesInNetWorth: false,
                isLiability: false
            )
        ]
    }()

    static func definition(for category: AssetCategory) -> AssetCategoryDefinition {
        all[category] ?? all[.stocks]!
    }
}

extension AssetCategory {
    var definition: AssetCategoryDefinition {
        AssetCategoryDefinition.definition(for: self)
    }
}
