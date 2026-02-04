import SwiftUI

enum RootTab: Hashable {
    case overview
    case assets
    case settings
}

struct RootView: View {
    @State private var assetStore = AssetStore()
    @State private var appLockStore = AppLockStore()
    @State private var tabSelection: RootTab = .overview
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $tabSelection) {
            Tab("Overview", systemImage: "chart.pie", value: .overview) {
                NavigationStack {
                    HomeView(store: assetStore, tabSelection: $tabSelection)
                }
            }

            Tab("Assets", systemImage: "tray.full", value: .assets) {
                NavigationStack {
                    AssetsListView(store: assetStore)
                }
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView(store: assetStore, appLockStore: appLockStore)
                }
            }
        }
        .background(Theme.background)
        .ignoresSafeArea()
        .tint(Theme.accentAlt)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Theme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.light, for: .navigationBar, .tabBar)
        .overlay {
            if appLockStore.isLocked {
                AppLockView(store: appLockStore)
            }
        }
        .task {
            assetStore.load()
            appLockStore.isEnabled = assetStore.settings.appLockEnabled
            if assetStore.settings.monthlyReminderEnabled {
                Task { _ = await NotificationService.scheduleMonthlyCheckIn() }
            }
            await appLockStore.unlockIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                Task { await appLockStore.unlockIfNeeded() }
            case .background:
                appLockStore.markBackgrounded()
            default:
                break
            }
        }
    }
}
