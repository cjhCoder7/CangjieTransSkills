/**
 * Created on 2024/8/24
 */
package ohos_app_cangjie_entry.utils

import ohos.hilog.*

public class HiLog {
    static let tag = 'MusicUI'

    public static func info(msg: String) {
        Hilog.info(0x0001, tag, msg)
    }

    public static func error(msg: String) {
        Hilog.error(0x0001, tag, msg)
    }
}
