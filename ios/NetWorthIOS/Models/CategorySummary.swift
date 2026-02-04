import Foundation

struct CategorySummary: Identifiable, Hashable {
    let category: AssetCategory
    let total: Double
    let percentage: Double?

    var id: AssetCategory { category }
}
