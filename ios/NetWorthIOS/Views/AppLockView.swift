import SwiftUI

struct AppLockView: View {
    let store: AppLockStore

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            GlassCard(isInteractive: true) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Unlock NetWorth")
                        .font(.title3.bold())
                        .foregroundStyle(Theme.primaryText)

                    Text("Use Face ID or Touch ID to continue.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)

                    Button {
                        Task { await store.unlock() }
                    } label: {
                        Text("Unlock")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: 320)
            }
            .padding()
        }
    }
}
