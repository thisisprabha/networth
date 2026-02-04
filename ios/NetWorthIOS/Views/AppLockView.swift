import SwiftUI

struct AppLockView: View {
    let store: AppLockStore

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            GlassCard(isInteractive: true) {
                VStack(spacing: Theme.Spacing.large) {
                    Image(systemName: "lock.fill")
                        .font(Theme.Typography.lockIcon)
                        .foregroundStyle(Theme.primaryText)

                    Text("Unlock NetWorth")
                        .font(AppFont.font(.title3, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Use Face ID or Touch ID to continue.")
                        .font(AppFont.font(.subheadline))
                        .foregroundStyle(Theme.secondaryText)

                    Button {
                        Task { await store.unlock() }
                    } label: {
                        Text("Unlock")
                            .font(AppFont.font(.headline, weight: .bold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, Theme.Spacing.small)
                .frame(maxWidth: Theme.Size.appLockCardMaxWidth)
            }
            .padding(Theme.Spacing.large)
        }
    }
}
