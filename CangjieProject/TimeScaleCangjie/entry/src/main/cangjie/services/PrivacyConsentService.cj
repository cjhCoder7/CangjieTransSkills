package ohos_app_cangjie_entry.services


public class PrivacyConsentService {
    private static let PREFERENCES_NAME: String = "timescale_privacy"
    private static let AGREEMENT_KEY: String = "privacy_policy_agreed"

    public static func hasAgreed(context: Object): Bool {
        // 简化实现：先返回 false，后续接入 Preferences API
        false
    }

    public static func markAgreed(context: Object): Unit {
        // 简化实现：后续接入 Preferences API
    }
}
