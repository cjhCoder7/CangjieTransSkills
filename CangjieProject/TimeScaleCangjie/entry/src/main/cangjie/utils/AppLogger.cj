package ohos_app_cangjie_entry.utils

import std.console.*

public class AppLogger {
    private static let ENABLE_INFO_LOGS: Bool = false

    public static func info(tag: String, message: String): Unit {
        if (!AppLogger.ENABLE_INFO_LOGS) {
            return
        }
        println("[INFO][${tag}] ${message}")
    }

    public static func warn(tag: String, message: String): Unit {
        println("[WARN][${tag}] ${message}")
    }

    public static func error(tag: String, message: String): Unit {
        println("[ERROR][${tag}] ${message}")
    }
}
