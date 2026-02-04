import Foundation

enum AssetCategory: String, Codable, CaseIterable, Identifiable {
    case stocks
    case mutualFunds
    case gold
    case fixedDeposits
    case personalAssets
    case bonds
    case land
    case home
    case savings
    case emergencySavings
    case esop
    case privateEquity
    case vpfPpf = "vpf_ppf"
    case silver
    case lifeInsurance
    case healthInsurance
    case vehicleInsurance
    case homeLoan
    case carLoan
    case personalLoan
    case creditCard
    case otherDebt

    var id: String { rawValue }
}
