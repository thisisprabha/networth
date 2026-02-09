import SwiftUI

struct CountryOnboardingView: View {
    let store: AssetStore

    private var selectedRegion: SupportedRegion? {
        SupportedRegion.match(currencyCode: store.settings.currencyCode, regionCode: store.settings.regionCode)
    }

    var body: some View {
        RegionPickerView(
            title: "Choose your country",
            subtitle: "We’ll format amounts in your local currency.",
            selected: selectedRegion,
            showsCancel: false
        ) { region in
            store.setRegion(region, markOnboardingComplete: true)
        }
        .interactiveDismissDisabled()
    }
}

