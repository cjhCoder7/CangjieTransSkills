package ohos_app_cangjie_entry

class PrivacyManager {
    public func hasAcceptedPolicy(): Bool {
        false
    }

    public func acceptPolicy(): FeatureResult {
        featureSuccess("privacy:accepted")
    }
}
