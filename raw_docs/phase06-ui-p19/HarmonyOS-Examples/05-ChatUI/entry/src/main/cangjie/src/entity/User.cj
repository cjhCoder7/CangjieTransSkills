/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.entity

import encoding.json.*
import ohos.base.*

public enum UserStatus {
    ONLINE | OFFLINE | LEFT

    // 数字转UserStatus
    public static func fromInt(status: Int64): UserStatus {
        match (status) {
            case 1 => return UserStatus.ONLINE
            case 2 => return UserStatus.OFFLINE
            case 3 => return UserStatus.LEFT
            case _ => return UserStatus.OFFLINE
        }
    }

    // UserStatus转数字
    public static func toInt(status: UserStatus): Int64 {
        match (status) {
            case UserStatus.ONLINE => return 1
            case UserStatus.OFFLINE => return 2
            case UserStatus.LEFT => return 3
        }
    }
}

public class User {
    public User(
        public let id: Int64,
        public let username: String,
        public let state: UserStatus,
        public let chats: Array<Int64>,
        public let friends: Array<Int64>,
        public let groups: Array<Int64>,
        public let avatar: CJResource
    ) { }

    public func status() : String {
        match (this.state) {
            case UserStatus.ONLINE => return "手机在线"
            case UserStatus.OFFLINE => return "离线"
            case UserStatus.LEFT => return "离开"
        }
    }
}