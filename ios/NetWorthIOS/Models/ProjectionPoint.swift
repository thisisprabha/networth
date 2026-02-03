import Foundation

struct ProjectionPoint: Identifiable, Hashable {
    let month: Int
    let value: Double

    var id: Int { month }
}
