import std.collection.*

class UserSettingsSnapshot {
    let theme: String
    let notificationEnabled: Bool

    public init(theme: String, notificationEnabled: Bool) {
        this.theme = theme
        this.notificationEnabled = notificationEnabled
    }
}

class UserSettingsManager {
    private let storage: KeyValueStorage
    private let themeKey: String
    private let notificationEnabledKey: String
    private let defaultThemeValue: String
    private let defaultNotificationEnabledValue: Bool

    public init(storage: KeyValueStorage) {
        this.storage = storage
        this.themeKey = "theme"
        this.notificationEnabledKey = "notificationEnabled"
        this.defaultThemeValue = "default"
        this.defaultNotificationEnabledValue = true
    }

    public func supportedThemes(): ArrayList<String> {
        ArrayList<String>([
            "default",
            "simplicity",
            "pomeloWhtie"
        ])
    }

    public func currentTheme(): String {
        let value = this.storage.get(this.themeKey, StorageValue.StringValue(this.defaultThemeValue))
        readStringValue(value, this.defaultThemeValue)
    }

    public func saveTheme(theme: String): Unit {
        this.storage.put(this.themeKey, StorageValue.StringValue(theme))
        this.storage.flush()
    }

    public func resetTheme(): Unit {
        this.storage.remove(this.themeKey)
        this.storage.flush()
    }

    public func notificationEnabled(): Bool {
        let value = this.storage.get(this.notificationEnabledKey, StorageValue.BoolValue(this.defaultNotificationEnabledValue))
        readBoolValue(value, this.defaultNotificationEnabledValue)
    }

    public func setNotificationEnabled(enabled: Bool): Unit {
        this.storage.put(this.notificationEnabledKey, StorageValue.BoolValue(enabled))
        this.storage.flush()
    }

    public func resetNotificationPreference(): Unit {
        this.storage.remove(this.notificationEnabledKey)
        this.storage.flush()
    }

    public func snapshot(): UserSettingsSnapshot {
        UserSettingsSnapshot(
            theme: this.currentTheme(),
            notificationEnabled: this.notificationEnabled()
        )
    }

    public func clearAllSettings(): Unit {
        this.storage.remove(this.themeKey)
        this.storage.remove(this.notificationEnabledKey)
        this.storage.flush()
    }
}
