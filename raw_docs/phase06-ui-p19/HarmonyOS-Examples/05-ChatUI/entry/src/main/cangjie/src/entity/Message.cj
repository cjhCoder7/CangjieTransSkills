/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.entity

import encoding.json.*

public class Message {
    public Message(
        public let id: Int64,
        public let userId: Int64,
        public let time: String,
        public let content: String
    ) { }
}
