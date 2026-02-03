import SwiftUI

struct RootView: View {
    @State private var assetStore = AssetStore()
    @State private var appLockStore = AppLockStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    HomeView(store: assetStore)
                }
            }

            Tab("Assets", systemImage: "list.bullet") {
                NavigationStack {
                    AssetsListView(store: assetStore)
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView(store: assetStore, appLockStore: appLockStore)
                }
            }
        }
        .background(Theme.background)
        .ignoresSafeArea()
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
