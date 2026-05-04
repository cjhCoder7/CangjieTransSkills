import std.unittest.*
import std.unittest.testmacro.*

@Test
public class UserSettingsManagerTests {
    @TestCase
    public func themeShouldFallbackToDefaultWhenUnset(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        assertEqual("未写入 theme 时应回退到默认值", "", "default", manager.currentTheme())
        assertEqual("仅执行读取时不应触发 flush", "", 0, storage.flushCount())
    }

    @TestCase
    public func saveThemeShouldWriteValueAndFlush(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        manager.saveTheme("simplicity")
        assertEqual("保存后应能读取到 simplicity", "", "simplicity", manager.currentTheme())
        assertEqual("Fake Store 中应存下正确的 theme 值", "", "simplicity", storage.debugString("theme", ""))
        assertEqual("保存 theme 后应触发一次 flush", "", 1, storage.flushCount())
        assertEqual("最后一个操作应为 flush", "", "flush", storage.lastOperation())
    }

    @TestCase
    public func themeShouldFallbackWhenUnderlyingTypeIsWrong(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        storage.put("theme", StorageValue.BoolValue(false))
        assertEqual("底层类型错误时应回退默认主题", "", "default", manager.currentTheme())
        assertEqual("纯读取类型错误值时不应触发 flush", "", 0, storage.flushCount())
    }

    @TestCase
    public func notificationShouldFallbackToTrueWhenUnset(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        assertEqual("未写入通知开关时应回退为 true", "", true, manager.notificationEnabled())
    }

    @TestCase
    public func setNotificationEnabledShouldPersistFalseAndFlush(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        manager.setNotificationEnabled(false)
        assertEqual("通知开关应保存为 false", "", false, manager.notificationEnabled())
        assertEqual("Fake Store 中的通知开关应为 false", "", false, storage.debugBool("notificationEnabled", true))
        assertEqual("保存通知开关后应触发一次 flush", "", 1, storage.flushCount())
    }

    @TestCase
    public func resetThemeShouldRemoveKeyAndRestoreDefault(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        manager.saveTheme("pomeloWhtie")
        manager.resetTheme()
        assertEqual("重置后主题应恢复为 default", "", "default", manager.currentTheme())
        assertEqual("重置主题一共会触发两次 flush", "", 2, storage.flushCount())
    }

    @TestCase
    public func snapshotShouldCombineThemeAndNotificationState(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        manager.saveTheme("pomeloWhtie")
        manager.setNotificationEnabled(false)
        let snapshot = manager.snapshot()
        assertEqual("快照中的主题应为 pomeloWhtie", "", "pomeloWhtie", snapshot.theme)
        assertEqual("快照中的通知开关应为 false", "", false, snapshot.notificationEnabled)
        assertEqual("两次写入应对应两次 flush", "", 2, storage.flushCount())
    }

    @TestCase
    public func clearAllSettingsShouldRestoreDefaultsWithSingleFinalFlush(): Unit {
        let storage = FakeKeyValueStorage()
        let manager = UserSettingsManager(storage: storage)
        manager.saveTheme("simplicity")
        manager.setNotificationEnabled(false)
        manager.clearAllSettings()
        assertEqual("清空后主题应恢复 default", "", "default", manager.currentTheme())
        assertEqual("清空后通知开关应恢复 true", "", true, manager.notificationEnabled())
        assertEqual("清空全部设置后总 flush 次数应为 3", "", 3, storage.flushCount())
        assertEqual("清空完成后 Fake Store 中不应残留任何键", "", 0, storage.storedKeyCount())
    }
}
