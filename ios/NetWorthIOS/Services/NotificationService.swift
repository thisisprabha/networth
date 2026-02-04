import Foundation
import UserNotifications

enum NotificationService {
    static let monthlyIdentifier = "networth.monthly.checkin"

    static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    static func scheduleMonthlyCheckIn(hour: Int = 9) async -> Bool {
        let granted = await requestAuthorization()
        guard granted else { return false }

        let content = UNMutableNotificationContent()
        content.title = "Monthly Net Worth Check‑in"
        content.body = "Update your assets to see how your net worth changed."
        content.sound = .default

        var components = DateComponents()
        components.calendar = Calendar.current
        components.day = 1
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: monthlyIdentifier, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [monthlyIdentifier])
        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    static func cancelMonthlyCheckIn() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [monthlyIdentifier])
    }
}
