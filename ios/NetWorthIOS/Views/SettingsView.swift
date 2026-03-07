import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let store: AssetStore
    let appLockStore: AppLockStore

    @State private var isImporting = false
    @State private var isExporting = false
    @State private var exportDocument = CSVDocument(data: Data())
    @State private var alertMessage: String?
    @State private var isChoosingRegion = false
    @State private var pendingRegion: SupportedRegion?
    @State private var showRegionChangeConfirmation = false
    @State private var showReminderPrePrompt = false

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            Form {
                Section {
                    Button {
                        isChoosingRegion = true
                    } label: {
                        HStack {
                            Text("Country & currency")
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Text(selectedRegion.displayName)
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                } header: {
                    Text("Preferences")
                        .font(AppFont.font(.subheadline, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .textCase(nil)
                } footer: {
                    Text("Changes formatting only. Existing values won’t be converted.")
                        .font(AppFont.font(.caption2))
                        .foregroundStyle(Theme.secondaryText)
                }

                Section {
                    Toggle("App Lock", isOn: appLockBinding)
                        .tint(Theme.accentAlt)
                } header: {
                    Text("Security")
                        .font(AppFont.font(.subheadline, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .textCase(nil)
                } footer: {
                    Text("Locks the app when you reopen it.")
                        .font(AppFont.font(.caption2))
                        .foregroundStyle(Theme.secondaryText)
                }

                Section {
                    Toggle("Monthly check‑in reminder", isOn: monthlyReminderBinding)
                        .tint(Theme.accentAlt)
                } header: {
                    Text("Reminders")
                        .font(AppFont.font(.subheadline, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .textCase(nil)
                } footer: {
                    Text("A gentle nudge to update your net worth each month.")
                        .font(AppFont.font(.caption2))
                        .foregroundStyle(Theme.secondaryText)
                }

                Section {
                    Button("Export CSV") { exportCSV() }
                    Button("Import CSV") { isImporting = true }
                } header: {
                    Text("Backup & Restore")
                        .font(AppFont.font(.subheadline, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .textCase(nil)
                } footer: {
                    Text("CSV files stay on your device unless you share them.")
                        .font(AppFont.font(.caption2))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
        }
        .sheet(isPresented: $isChoosingRegion) {
            RegionPickerView(
                title: "Country & currency",
                subtitle: "Pick the currency you want to use in the app.",
                selected: selectedRegion,
                showsCancel: true
            ) { region in
                guard region != selectedRegion else { return }
                pendingRegion = region
                showRegionChangeConfirmation = true
            }
        }
        .confirmationDialog("Change country & currency?", isPresented: $showRegionChangeConfirmation, titleVisibility: .visible) {
            Button("Change") {
                guard let pendingRegion else { return }
                store.setRegion(pendingRegion, markOnboardingComplete: false)
                self.pendingRegion = nil
            }
            Button("Cancel", role: .cancel) {
                pendingRegion = nil
            }
        } message: {
            Text("This changes formatting only. Existing values will not be converted.")
        }
        .alert("Enable monthly reminders?", isPresented: $showReminderPrePrompt) {
            Button("Not now", role: .cancel) {}
            Button("Continue") {
                Task { await enableMonthlyReminder() }
            }
        } message: {
            Text("NetWorth can send a check‑in reminder on the 1st of each month. iOS will ask for permission next.")
        }
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "networth_backup"
        ) { _ in }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.commaSeparatedText]
        ) { result in
            handleImport(result)
        }
        .alert("Notice", isPresented: Binding(get: { alertMessage != nil }, set: { _ in alertMessage = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var selectedRegion: SupportedRegion {
        SupportedRegion.match(currencyCode: store.settings.currencyCode, regionCode: store.settings.regionCode)
            ?? SupportedRegion.all.first(where: { $0.currencyCode == store.settings.currencyCode })
            ?? SupportedRegion.all.first!
    }

    private var appLockBinding: Binding<Bool> {
        Binding(
            get: { store.settings.appLockEnabled },
            set: { newValue in
                store.settings.appLockEnabled = newValue
                appLockStore.isEnabled = newValue
                store.save()
            }
        )
    }

    private func exportCSV() {
        do {
            let csv = try CSVService.exportCSV(assets: store.assets)
            exportDocument = CSVDocument(data: Data(csv.utf8))
            isExporting = true
        } catch {
            alertMessage = "Export failed."
        }
    }

    private var monthlyReminderBinding: Binding<Bool> {
        Binding(
            get: { store.settings.monthlyReminderEnabled },
            set: { newValue in
                if newValue {
                    showReminderPrePrompt = true
                } else {
                    store.settings.monthlyReminderEnabled = false
                    store.save()
                    NotificationService.cancelMonthlyCheckIn()
                }
            }
        )
    }

    private func enableMonthlyReminder() async {
        let scheduled = await NotificationService.requestAndScheduleMonthlyCheckIn()
        if scheduled {
            store.settings.monthlyReminderEnabled = true
            store.save()
        } else {
            store.settings.monthlyReminderEnabled = false
            store.save()
            alertMessage = "Notifications are disabled. Enable them in Settings."
        }
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
                alertMessage = "No assets found in this CSV."
                return
            }
            let existingCount = store.assets.count
            store.merge(imported)
            let newCount = max(0, store.assets.count - existingCount)
            Haptics.success()
            if newCount > 0 {
                alertMessage = "Imported \(imported.count) assets (\(newCount) new)."
            } else {
                alertMessage = "Import complete. Synced \(imported.count) assets."
            }
        } catch {
            Haptics.error()
            alertMessage = "Import failed."
        }
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
