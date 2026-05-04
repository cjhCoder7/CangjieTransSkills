/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.entity

import encoding.json.*
import ohos.base.*

public class Group {
    public Group(
        public let id: Int64,
        public let users: Array<Int64>,
        public let chatId: Int64,
        public let avatar: CJResource
    ) { }
}