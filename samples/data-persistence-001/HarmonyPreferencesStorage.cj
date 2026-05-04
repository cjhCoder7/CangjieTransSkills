import kit.AbilityKit.*
import kit.ArkData.*
import kit.PerformanceAnalysisKit.Hilog

class HarmonyPreferencesStorage <: KeyValueStorage {
    private let context: UIAbilityContext
    private let storeName: String

    public init(context: UIAbilityContext, storeName: String) {
        this.context = context
        this.storeName = storeName
    }

    private func preferences(): Preferences {
        Preferences.getPreferences(this.context, PreferencesOptions(this.storeName))
    }

    private func toPreferencesValue(value: StorageValue): PreferencesValueType {
        match (value) {
            case StorageValue.StringValue(text) => PreferencesValueType.StringData(text)
            case StorageValue.BoolValue(flag) => PreferencesValueType.BoolData(flag)
            case StorageValue.IntValue(number) => PreferencesValueType.Integer(number)
            case StorageValue.DoubleValue(number) => PreferencesValueType.Double(number)
        }
    }

    private func fromPreferencesValue(value: PreferencesValueType, defaultValue: StorageValue): StorageValue {
        match (value) {
            case PreferencesValueType.StringData(text) => StorageValue.StringValue(text)
            case PreferencesValueType.BoolData(flag) => StorageValue.BoolValue(flag)
            case PreferencesValueType.Integer(number) => StorageValue.IntValue(number)
            case PreferencesValueType.Double(number) => StorageValue.DoubleValue(number)
            case _ => defaultValue
        }
    }

    public func has(key: String): Bool {
        this.preferences().has(key)
    }

    public func get(key: String, defaultValue: StorageValue): StorageValue {
        let store = this.preferences()
        let result = store.get(key, this.toPreferencesValue(defaultValue))
        let mapped = this.fromPreferencesValue(result, defaultValue)
        Hilog.info(0, "PrefsStore", "read key=${key} from ${storeName}")
        mapped
    }

    public func put(key: String, value: StorageValue): Unit {
        let store = this.preferences()
        store.put(key, this.toPreferencesValue(value))
        Hilog.info(0, "PrefsStore", "write key=${key} into ${storeName}")
    }

    public func remove(key: String): Unit {
        let store = this.preferences()
        if (store.has(key)) {
            store.delete(key)
            Hilog.info(0, "PrefsStore", "remove key=${key} from ${storeName}")
        }
    }

    public func flush(): Unit {
        let store = this.preferences()
        store.flush()
        Hilog.info(0, "PrefsStore", "flush store=${storeName}")
    }

    public func deleteStore(): Unit {
        Preferences.deletePreferences(this.context, this.storeName)
        Hilog.info(0, "PrefsStore", "delete persisted store=${storeName}")
    }
}

func createUserSettingsStorage(context: UIAbilityContext): HarmonyPreferencesStorage {
    HarmonyPreferencesStorage(context: context, storeName: "user-settings.db")
}
