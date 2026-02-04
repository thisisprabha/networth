import WidgetKit
import SwiftUI

struct WidgetState: Codable, Hashable {
    let netWorth: Double
    let lastUpdated: Date
    let deltaPercent: Double?
}

struct NetWorthEntry: TimelineEntry {
    let date: Date
    let state: WidgetState
}

struct NetWorthProvider: TimelineProvider {
    func placeholder(in context: Context) -> NetWorthEntry {
        NetWorthEntry(
            date: .now,
            state: WidgetState(netWorth: 0, lastUpdated: .now, deltaPercent: nil)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NetWorthEntry) -> Void) {
        completion(NetWorthEntry(date: .now, state: loadState()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NetWorthEntry>) -> Void) {
        let entry = NetWorthEntry(date: .now, state: loadState())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
        completion(timeline)
    }

    private func loadState() -> WidgetState {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroup)
        if let data = defaults?.data(forKey: WidgetConstants.key) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode(WidgetState.self, from: data) {
                return decoded
            }
        }
        return WidgetState(netWorth: 0, lastUpdated: .now, deltaPercent: nil)
    }
}

@main
struct NetWorthWidget: Widget {
    let kind: String = "NetWorthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetWorthProvider()) { entry in
            NetWorthWidgetView(entry: entry)
        }
        .configurationDisplayName("Net Worth")
        .description("Quick glance at your net worth.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
