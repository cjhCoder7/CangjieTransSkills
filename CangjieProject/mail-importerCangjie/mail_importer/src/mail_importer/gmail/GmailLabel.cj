package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap
import std.collection.HashSet
import mail_importer.local.LocalMessage

// Gmail 标签的简化数据类
public class GmailLabel {
    public var id: String
    public var name: String

    public init(id: String, name: String) {
        this.id = id
        this.name = name
    }
}

// Gmail 消息的简化数据类
public class GmailMessage {
    public var id: String
    public var labelIds: ArrayList<String>
    public var threadId: String = ""

    public init(id: String) {
        this.id = id
        this.labelIds = ArrayList<String>()
    }

    public init(id: String, labelIds: ArrayList<String>) {
        this.id = id
        this.labelIds = labelIds
    }
}
