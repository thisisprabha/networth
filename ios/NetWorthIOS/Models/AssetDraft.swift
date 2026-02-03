import Foundation

struct AssetDraft: Identifiable, Hashable {
    var id: String
    var category: AssetCategory
    var values: [String: FieldValue]
    var createdAt: Date
    var updatedAt: Date

    var name: String {
        category.definition.name
    }

    static func new(category: AssetCategory) -> AssetDraft {
        let defaults = defaultValues(for: category)
        return AssetDraft(
            id: UUID().uuidString,
            category: category,
            values: defaults,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    init(id: String, category: AssetCategory, values: [String: FieldValue], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.category = category
        self.values = values
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(asset: Asset) {
        id = asset.id
        category = asset.category
        values = asset.values
        createdAt = asset.createdAt
        updatedAt = asset.updatedAt
    }

    func asAsset(updatedAt: Date = Date()) -> Asset {
        Asset(
            id: id,
            category: category,
            name: name,
            values: values,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private static func defaultValues(for category: AssetCategory) -> [String: FieldValue] {
        var defaults: [String: FieldValue] = [:]
        for field in category.definition.fields {
            defaults[field.id] = field.defaultValue
        }
        if category == .personalAssets,
           case let .text(selected)? = defaults["assetType"] {
            if let option = category.definition.fields.first(where: { $0.id == "assetType" })?.options.first(where: { $0.value == selected }),
               let defaultNumber = option.defaultNumber {
                defaults["assetValue"] = .number(defaultNumber)
            }
        }
        return defaults
    }
}
