/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.entity

import encoding.json.*
import std.collection.ArrayList

public enum ChatType {
    PRIVATE | PUBLIC
}

public class Chat {
    public Chat(
        public let id: Int64,
        public let count: Int64,
        public let msgs: Array<Message>
    ) { }
}
