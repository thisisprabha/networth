import SwiftUI

struct AssetFormView: View {
    let store: AssetStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: AssetDraft
    @State private var selectedCategory: AssetCategory
    private let isEditing: Bool

    init(store: AssetStore, asset: Asset?) {
        self.store = store
        if let asset {
            let draft = AssetDraft(asset: asset)
            _draft = State(initialValue: draft)
            _selectedCategory = State(initialValue: draft.category)
            isEditing = true
        } else {
            let draft = AssetDraft.new(category: AssetCategoryDefinition.ordered.first ?? .stocks)
            _draft = State(initialValue: draft)
            _selectedCategory = State(initialValue: draft.category)
            isEditing = false
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(AssetCategoryDefinition.ordered, id: \.self) { category in
                            Text(category.definition.name).tag(category)
                        }
                    }
                    .disabled(isEditing)
                }

                Section("Details") {
                    ForEach(selectedCategory.definition.fields, id: \.id) { field in
                        fieldView(field)
                    }
                }

                Section("Projection") {
                    growthRateField
                }
            }
            .navigationTitle(isEditing ? "Edit Asset" : "Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .onChange(of: selectedCategory) { _, newValue in
                if isEditing { return }
                draft = AssetDraft.new(category: newValue)
            }
        }
    }

    private func save() {
        var updatedDraft = draft
        updatedDraft.category = selectedCategory
        let asset = updatedDraft.asAsset(updatedAt: Date())
        store.upsert(asset)
        dismiss()
    }

    @ViewBuilder
    private func fieldView(_ field: AssetFieldDefinition) -> some View {
        switch field.kind {
        case .slider:
            SliderFieldView(
                title: field.label,
                value: numberBinding(for: field),
                min: field.min ?? 0,
                max: field.max ?? 1,
                step: field.step ?? 1,
                format: field.format
            )
        case .number:
            TextField(field.label, value: numberBinding(for: field), format: .number)
                .keyboardType(.decimalPad)
        case .text:
            TextField(field.label, text: textBinding(for: field))
        case .select:
            Picker(field.label, selection: textBinding(for: field)) {
                ForEach(field.options) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .onChange(of: draft.values[field.id]) { _, newValue in
                guard case let .text(selected)? = newValue else { return }
                guard let defaultNumber = field.options.first(where: { $0.value == selected })?.defaultNumber else { return }
                if selectedCategory == .personalAssets {
                    draft.values["assetValue"] = .number(defaultNumber)
                }
            }
        case .date:
            DatePicker(field.label, selection: dateBinding(for: field), displayedComponents: .date)
        }
    }

    private var growthRateField: some View {
        let range = selectedCategory.definition.growthRateRange
        return VStack(alignment: .leading, spacing: 6) {
            Text("Annual Growth Rate (%)")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
            TextField(
                "Rate",
                value: growthRateBinding,
                format: .number.precision(.fractionLength(1))
            )
            .keyboardType(.decimalPad)
            if let range {
                Text("Suggested range: \(range.lowerBound, format: .number)–\(range.upperBound, format: .number)")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    private var growthRateBinding: Binding<Double> {
        Binding(
            get: { store.growthRate(for: selectedCategory) },
            set: { store.setGrowthRate($0, for: selectedCategory) }
        )
    }

    private func numberBinding(for field: AssetFieldDefinition) -> Binding<Double> {
        Binding(
            get: {
                if case let .number(value)? = draft.values[field.id] {
                    return value
                }
                if case let .text(text)? = draft.values[field.id], let value = Double(text) {
                    return value
                }
                if case let .number(value) = field.defaultValue { return value }
                return 0
            },
            set: { newValue in
                draft.values[field.id] = .number(newValue)
            }
        )
    }

    private func textBinding(for field: AssetFieldDefinition) -> Binding<String> {
        Binding(
            get: {
                if case let .text(value)? = draft.values[field.id] {
                    return value
                }
                if case let .number(value)? = draft.values[field.id] {
                    return String(value)
                }
                if case let .text(value) = field.defaultValue {
                    return value
                }
                return ""
            },
            set: { newValue in
                draft.values[field.id] = .text(newValue)
            }
        )
    }

    private func dateBinding(for field: AssetFieldDefinition) -> Binding<Date> {
        Binding(
            get: {
                if case let .date(value)? = draft.values[field.id] {
                    return value
                }
                if case let .date(value) = field.defaultValue {
                    return value
                }
                return Date()
            },
            set: { newValue in
                draft.values[field.id] = .date(newValue)
            }
        )
    }
}

private struct SliderFieldView: View {
    let title: String
    let value: Binding<Double>
    let min: Double
    let max: Double
    let step: Double
    let format: FieldFormat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text(displayValue)
                    .foregroundStyle(Theme.secondaryText)
            }
            Slider(value: value, in: min...max, step: step)
        }
    }

    private var displayValue: String {
        switch format {
        case .currency:
            return Formatters.formatINR(value.wrappedValue)
        case .plain:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value.wrappedValue)) ?? "0"
        }
    }
}
