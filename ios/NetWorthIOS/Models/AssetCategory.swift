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

    var id: String { rawValue }
}
