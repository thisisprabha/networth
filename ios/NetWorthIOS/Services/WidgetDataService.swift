import Foundation

struct WidgetState: Codable, Hashable {
    let netWorth: Double
    let lastUpdated: Date
    let deltaPercent: Double?
}

enum WidgetDataService {
    static let appGroup = "group.com.prabhakaran.networth"
    static let key = "widget.state"

    static func save(state: WidgetState) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(state) {
            defaults.set(data, forKey: key)
        }
    }
}
