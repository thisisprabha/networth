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
        Form {
            Section("Security") {
                Toggle("App Lock", isOn: appLockBinding)
            }

            Section("Reminders") {
                Toggle("Monthly check‑in reminder", isOn: monthlyReminderBinding)
                    .tint(Theme.accentAlt)
            }

            Section("Backup & Restore") {
                Button("Export CSV") { exportCSV() }
                Button("Import CSV") { isImporting = true }
            }
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(Theme.background)
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
            alertMessage = "Imported \(imported.count) assets."
        } catch {
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
