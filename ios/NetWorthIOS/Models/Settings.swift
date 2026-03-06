import Foundation

struct Settings: Codable, Hashable {
    var currencyCode: String
    var regionCode: String
    var hasCompletedOnboarding: Bool
    var onboardingSnoozeUntil: Date?
    var didShowReminderUpsell: Bool
    var didRequestReviewPrompt: Bool
    var feedbackSubmitted: Bool
    var feedbackRating: Int?
    var feedbackSnoozeUntil: Date?
    var growthRates: [String: Double]
    var appLockEnabled: Bool
    var monthlyReminderEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case currencyCode
        case regionCode
        case hasCompletedOnboarding
        case onboardingSnoozeUntil
        case didShowReminderUpsell
        case didRequestReviewPrompt
        case feedbackSubmitted
        case feedbackRating
        case feedbackSnoozeUntil
        case growthRates
        case appLockEnabled
        case monthlyReminderEnabled
    }

    init(
        currencyCode: String,
        regionCode: String,
        hasCompletedOnboarding: Bool,
        onboardingSnoozeUntil: Date?,
        didShowReminderUpsell: Bool,
        didRequestReviewPrompt: Bool,
        feedbackSubmitted: Bool,
        feedbackRating: Int?,
        feedbackSnoozeUntil: Date?,
        growthRates: [String: Double],
        appLockEnabled: Bool,
        monthlyReminderEnabled: Bool
    ) {
        self.currencyCode = currencyCode
        self.regionCode = regionCode
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.onboardingSnoozeUntil = onboardingSnoozeUntil
        self.didShowReminderUpsell = didShowReminderUpsell
        self.didRequestReviewPrompt = didRequestReviewPrompt
        self.feedbackSubmitted = feedbackSubmitted
        self.feedbackRating = feedbackRating
        self.feedbackSnoozeUntil = feedbackSnoozeUntil
        self.growthRates = growthRates
        self.appLockEnabled = appLockEnabled
        self.monthlyReminderEnabled = monthlyReminderEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode) ?? "INR"
        self.currencyCode = currencyCode
        self.regionCode = try container.decodeIfPresent(String.self, forKey: .regionCode)
            ?? SupportedRegion.defaultRegionCode(forCurrencyCode: currencyCode)

        self.hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? true
        self.onboardingSnoozeUntil = try container.decodeIfPresent(Date.self, forKey: .onboardingSnoozeUntil)
        self.didShowReminderUpsell = try container.decodeIfPresent(Bool.self, forKey: .didShowReminderUpsell) ?? true
        let legacyFeedbackSubmitted = try container.decodeIfPresent(Bool.self, forKey: .feedbackSubmitted) ?? false
        self.didRequestReviewPrompt = try container.decodeIfPresent(Bool.self, forKey: .didRequestReviewPrompt) ?? legacyFeedbackSubmitted
        self.feedbackSubmitted = legacyFeedbackSubmitted
        self.feedbackRating = try container.decodeIfPresent(Int.self, forKey: .feedbackRating)
        self.feedbackSnoozeUntil = try container.decodeIfPresent(Date.self, forKey: .feedbackSnoozeUntil)

        var rates: [String: Double] = [:]
        for category in AssetCategory.allCases {
            rates[category.rawValue] = category.definition.growthRateDefault
        }
        self.growthRates = try container.decodeIfPresent([String: Double].self, forKey: .growthRates) ?? rates

        self.appLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .appLockEnabled) ?? true
        self.monthlyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .monthlyReminderEnabled) ?? false
    }

    static var `default`: Settings {
        var rates: [String: Double] = [:]
        for category in AssetCategory.allCases {
            rates[category.rawValue] = category.definition.growthRateDefault
        }
        let deviceRegion = Locale.current.regionCode
        let suggested = deviceRegion.flatMap(SupportedRegion.bestMatch(forRegionCode:))
        let currencyCode = suggested?.currencyCode ?? "INR"
        let regionCode = suggested?.regionCode ?? "IN"
        return Settings(
            currencyCode: currencyCode,
            regionCode: regionCode,
            hasCompletedOnboarding: false,
            onboardingSnoozeUntil: nil,
            didShowReminderUpsell: false,
            didRequestReviewPrompt: false,
            feedbackSubmitted: false,
            feedbackRating: nil,
            feedbackSnoozeUntil: nil,
            growthRates: rates,
            appLockEnabled: true,
            monthlyReminderEnabled: false
        )
    }
}
