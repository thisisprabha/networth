import SwiftUI

struct MonthlyReminderUpsellView: View {
    let store: AssetStore
    let onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isRequesting = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xxLarge) {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Monthly check‑in reminder?")
                        .font(AppFont.font(.title2, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Get a gentle nudge to update your net worth. We’ll ask iOS for permission next.")
                        .font(AppFont.font(.subheadline))
                        .foregroundStyle(Theme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Theme.Spacing.medium) {
                    Button {
                        Task { await enableReminder() }
                    } label: {
                        if isRequesting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Enable reminder")
                                .font(AppFont.font(.headline, weight: .bold))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentAlt)
                    .disabled(isRequesting)

                    Button("Not now") {
                        dismiss()
                        onFinish()
                    }
                    .font(AppFont.font(.headline, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .disabled(isRequesting)
                }

                Spacer(minLength: 0)
            }
            .padding(Theme.Spacing.xxxLarge)
            .navigationBarHidden(true)
            .alert("Notice", isPresented: Binding(get: { alertMessage != nil }, set: { _ in alertMessage = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func enableReminder() async {
        guard !isRequesting else { return }
        isRequesting = true
        defer { isRequesting = false }

        let scheduled = await NotificationService.requestAndScheduleMonthlyCheckIn()
        if scheduled {
            store.settings.monthlyReminderEnabled = true
            store.save()
            dismiss()
            onFinish()
        } else {
            store.settings.monthlyReminderEnabled = false
            store.save()
            alertMessage = "Notifications are disabled. Enable them in Settings."
        }
    }
}

