import Foundation

struct ProjectionPoint: Identifiable, Hashable {
    let month: Int
    let value: Double

    var id: Int { month }
}

enum ProjectionSeries: String, Hashable {
    case growth = "Growing assets"
    case decline = "Declining assets"
}

struct ProjectionSeriesPoint: Identifiable, Hashable {
    let id = UUID()
    let month: Int
    let percent: Double
    let series: ProjectionSeries
}
