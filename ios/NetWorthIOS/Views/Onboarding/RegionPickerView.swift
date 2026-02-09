import SwiftUI

struct RegionPickerView: View {
    let title: String
    let subtitle: String
    let selected: SupportedRegion?
    let showsCancel: Bool
    let onSelect: (SupportedRegion) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredRegions) { region in
                        Button {
                            dismiss()
                            onSelect(region)
                        } label: {
                            RegionRow(region: region, isSelected: region == selected)
                        }
                        .foregroundStyle(Theme.primaryText)
                    }
                } header: {
                    Text(subtitle)
                        .font(AppFont.font(.subheadline))
                        .foregroundStyle(Theme.secondaryText)
                        .textCase(nil)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                if showsCancel {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    private var filteredRegions: [SupportedRegion] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return SupportedRegion.all }
        return SupportedRegion.all.filter {
            $0.name.localizedStandardContains(trimmed) ||
            $0.currencyCode.localizedStandardContains(trimmed) ||
            $0.regionCode.localizedStandardContains(trimmed)
        }
    }
}

private struct RegionRow: View {
    let region: SupportedRegion
    let isSelected: Bool

    private var moneyConfig: MoneyFormatConfig {
        MoneyFormatConfig(currencyCode: region.currencyCode, regionCode: region.regionCode)
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(region.name)
                    .font(AppFont.font(.subheadline, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(Formatters.currencyDisplay(config: moneyConfig))
                    .font(AppFont.font(.caption))
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(AppFont.font(.subheadline, weight: .bold))
                    .foregroundStyle(Theme.accentAlt)
            }
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}
