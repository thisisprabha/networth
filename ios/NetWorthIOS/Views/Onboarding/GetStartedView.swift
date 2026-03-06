import SwiftUI
import UniformTypeIdentifiers

struct GetStartedView: View {
    let store: AssetStore

    @State private var isAddingAsset = false
    @State private var isImporting = false
    @State private var alertMessage: String?
    @State private var isChoosingRegion = false
    @State private var showReminderUpsell = false
    @State private var shouldCompleteOnboardingAfterAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xxLarge) {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Know your net worth.")
                        .font(AppFont.font(.largeTitle, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Update once a month in under a minute.")
                        .font(AppFont.font(.title3))
                        .foregroundStyle(Theme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Theme.Spacing.medium) {
                    Button {
                        isAddingAsset = true
                    } label: {
                        Text("Add your first asset")
                            .font(AppFont.font(.headline, weight: .bold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentAlt)

                    Button {
                        isImporting = true
                    } label: {
                        Text("Import CSV")
                            .font(AppFont.font(.headline, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.accentAlt)
                }

                CardContainer {
                    Button {
                        isChoosingRegion = true
                    } label: {
                        HStack {
                            Text("Country & currency")
                                .font(AppFont.font(.subheadline, weight: .semibold))
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Text(selectedRegion.displayName)
                                .font(AppFont.font(.subheadline))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)

                HStack(spacing: Theme.Spacing.large) {
                    Button("Remind me later") {
                        snoozeOnboarding()
                    }
                    .font(AppFont.font(.subheadline, weight: .semibold))

                    Spacer()

                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(AppFont.font(.subheadline, weight: .semibold))
                }
            }
            .padding(Theme.Spacing.xxxLarge)
            .navigationBarHidden(true)
            .sheet(isPresented: $isAddingAsset, onDismiss: handleAddedAssetDismissed) {
                AssetFormView(store: store, asset: nil, initialCategory: .savings)
            }
            .sheet(isPresented: $isChoosingRegion) {
                RegionPickerView(
                    title: "Country & currency",
                    subtitle: "Pick the currency you want to use in the app.",
                    selected: selectedRegion,
                    showsCancel: true
                ) { region in
                    store.setRegion(region, markOnboardingComplete: false)
                }
            }
            .sheet(isPresented: $showReminderUpsell, onDismiss: handleReminderUpsellDismissed) {
                MonthlyReminderUpsellView(
                    store: store,
                    onFinish: {
                        showReminderUpsell = false
                        completeOnboarding()
                    }
                )
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.commaSeparatedText]
            ) { result in
                handleImport(result)
            }
            .alert("Notice", isPresented: Binding(get: { alertMessage != nil }, set: { _ in alertMessage = nil })) {
                Button("OK", role: .cancel) {
                    if shouldCompleteOnboardingAfterAlert {
                        shouldCompleteOnboardingAfterAlert = false
                        completeOnboarding()
                    }
                }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private var selectedRegion: SupportedRegion {
        SupportedRegion.match(currencyCode: store.settings.currencyCode, regionCode: store.settings.regionCode)
            ?? SupportedRegion.all.first(where: { $0.currencyCode == store.settings.currencyCode })
            ?? SupportedRegion.all.first!
    }

    private func handleFirstMeaningfulAction() {
        guard store.settings.hasCompletedOnboarding == false else { return }

        if store.settings.monthlyReminderEnabled {
            completeOnboarding()
            return
        }

        if store.settings.didShowReminderUpsell {
            completeOnboarding()
            return
        }

        store.settings.didShowReminderUpsell = true
        store.save()
        showReminderUpsell = true
    }

    private func completeOnboarding() {
        showReminderUpsell = false
        store.settings.hasCompletedOnboarding = true
        store.settings.onboardingSnoozeUntil = nil
        store.save()
    }

    private func snoozeOnboarding() {
        store.settings.onboardingSnoozeUntil = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        store.save()
    }

    private func handleImport(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let isScoped = url.startAccessingSecurityScopedResource()
            defer {
                if isScoped {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            let data = try Data(contentsOf: url)
            let imported = try CSVService.importCSV(data: data)
            guard !imported.isEmpty else {
                Haptics.error()
                shouldCompleteOnboardingAfterAlert = false
                alertMessage = "No assets found in this CSV."
                return
            }
            let existingCount = store.assets.count
            store.merge(imported)
            let newCount = max(0, store.assets.count - existingCount)
            Haptics.success()
            shouldCompleteOnboardingAfterAlert = store.assets.isEmpty == false
            if newCount > 0 {
                alertMessage = "Imported \(imported.count) assets (\(newCount) new)."
            } else {
                alertMessage = "Import complete. Synced \(imported.count) assets."
            }
        } catch {
            Haptics.error()
            shouldCompleteOnboardingAfterAlert = false
            alertMessage = "Import failed."
        }
    }

    private func handleAddedAssetDismissed() {
        guard store.assets.isEmpty == false else { return }
        handleFirstMeaningfulAction()
    }

    private func handleReminderUpsellDismissed() {
        guard showReminderUpsell == false else { return }
        guard store.assets.isEmpty == false else { return }
        guard store.settings.hasCompletedOnboarding == false else { return }
        completeOnboarding()
    }
}
