import Foundation
import Observation
import LocalAuthentication

@MainActor
@Observable
final class AppLockStore {
    var isUnlocked = true
    var isEnabled = true
    var gracePeriodSeconds: TimeInterval = 0
    var lastUnlockDate: Date?
    private var requiresUnlock = false

    var isLocked: Bool {
        isEnabled && !isUnlocked
    }

    func lock() {
        requiresUnlock = true
        isUnlocked = false
    }

    func unlockIfNeeded() async {
        guard isEnabled else {
            isUnlocked = true
            requiresUnlock = false
            return
        }
        guard requiresUnlock || !isUnlocked else { return }
        if let lastUnlockDate {
            let elapsed = Date().timeIntervalSince(lastUnlockDate)
            if elapsed <= gracePeriodSeconds {
                isUnlocked = true
                requiresUnlock = false
                return
            }
        }
    }

    func unlock() async {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isUnlocked = true
            return
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock NetWorth"
            )
            isUnlocked = success
            if success {
                lastUnlockDate = Date()
                requiresUnlock = false
            }
        } catch {
            isUnlocked = false
        }
    }

    func markBackgrounded() {
        requiresUnlock = true
        isUnlocked = false
    }
}
