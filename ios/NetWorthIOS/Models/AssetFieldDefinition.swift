import Foundation

enum AssetFieldKind: Hashable {
    case slider
    case number
    case text
    case select
    case date
}

enum FieldFormat: Hashable {
    case currency
    case plain
}

struct AssetFieldOption: Hashable, Identifiable {
    var id: String { value }
    let value: String
    let label: String
    let defaultNumber: Double?
}

struct AssetFieldDefinition: Hashable, Identifiable {
    let id: String
    let label: String
    let kind: AssetFieldKind
    let min: Double?
    let max: Double?
    let step: Double?
    let defaultValue: FieldValue
    let format: FieldFormat
    let options: [AssetFieldOption]

    init(
        id: String,
        label: String,
        kind: AssetFieldKind,
        min: Double? = nil,
        max: Double? = nil,
        step: Double? = nil,
        defaultValue: FieldValue,
        format: FieldFormat = .plain,
        options: [AssetFieldOption] = []
    ) {
        self.id = id
        self.label = label
        self.kind = kind
        self.min = min
        self.max = max
        self.step = step
        self.defaultValue = defaultValue
        self.format = format
        self.options = options
    }
}
