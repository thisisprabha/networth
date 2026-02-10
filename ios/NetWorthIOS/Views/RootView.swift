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
            Tab(value: .overview) {
                NavigationStack {
                    HomeView(store: assetStore, tabSelection: $tabSelection)
                }
            } label: {
                Label("Overview", systemImage: "chart.pie")
                    .symbolEffect(.bounce, value: tabSelection == .overview)
            }

            Tab(value: .assets) {
                AssetsListView(store: assetStore)
            } label: {
                Label("Assets", systemImage: "tray.full")
                    .symbolEffect(.bounce, value: tabSelection == .assets)
            }

            Tab(value: .settings) {
                NavigationStack {
                    SettingsView(store: assetStore, appLockStore: appLockStore)
                }
            } label: {
                Label("Settings", systemImage: "gearshape")
                    .symbolEffect(.bounce, value: tabSelection == .settings)
            }
        }
        .background(Theme.background)
        .font(AppFont.font(.body))
        .environment(\.moneyConfig, MoneyFormatConfig(currencyCode: assetStore.settings.currencyCode, regionCode: assetStore.settings.regionCode))
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
        .fullScreenCover(
            isPresented: Binding(
                get: { shouldPresentOnboarding },
                set: { _ in }
            )
        ) {
            GetStartedView(store: assetStore)
        }
        .task {
            assetStore.load()
            appLockStore.isEnabled = assetStore.settings.appLockEnabled
            if assetStore.settings.monthlyReminderEnabled {
                Task { _ = await NotificationService.scheduleMonthlyCheckInIfAuthorized() }
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

    private var shouldPresentOnboarding: Bool {
        guard assetStore.isLoaded else { return false }
        guard assetStore.settings.hasCompletedOnboarding == false else { return false }
        if let snoozeUntil = assetStore.settings.onboardingSnoozeUntil {
            return snoozeUntil <= Date()
        }
        return true
    }
}
