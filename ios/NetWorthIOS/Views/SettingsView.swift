import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let store: AssetStore
    let appLockStore: AppLockStore

    @State private var isImporting = false
    @State private var isExporting = false
    @State private var exportDocument = CSVDocument(data: Data())
    @State private var alertMessage: String?

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            Form {
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
                store.settings.monthlyReminderEnabled = newValue
                store.save()
                if newValue {
                    Task {
                        let scheduled = await NotificationService.scheduleMonthlyCheckIn()
                        if !scheduled {
                            store.settings.monthlyReminderEnabled = false
                            store.save()
                            alertMessage = "Notifications are disabled. Enable them in Settings."
                        }
                    }
                } else {
                    NotificationService.cancelMonthlyCheckIn()
                }
            }
        )
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
            guard let content = String(data: data, encoding: .utf8) else {
                alertMessage = "Invalid file."
                return
            }
            let imported = try CSVService.importCSV(content)
            store.merge(imported)
            Haptics.success()
            alertMessage = "Imported \(imported.count) assets."
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
