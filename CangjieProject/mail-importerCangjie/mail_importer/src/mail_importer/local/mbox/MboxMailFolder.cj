package mail_importer.local.mbox

import std.collection.ArrayList
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage

// 基于 mbox 解析结果的 MailFolder 实现
public class MboxMailFolder <: MailFolder {
    let folderName: String
    let folderFullName: String
    let folderType: Int64
    let messages: ArrayList<MboxRawMessage>
    let subFolders: ArrayList<MboxMailFolder>
    var isOpenFlag: Bool = false

    public init(name: String, fullName: String, folderType: Int64) {
        this.folderName = name
        this.folderFullName = fullName
        this.folderType = folderType
        this.messages = ArrayList<MboxRawMessage>()
        this.subFolders = ArrayList<MboxMailFolder>()
    }

    public func getName(): String { folderName }
    public func getFullName(): String { folderFullName }
    public func getType(): Int64 { folderType }
    public func getMessageCount(): Int64 { messages.size }

    public func getMessage(index: Int64): MailMessage {
        if (index < 1 || index > messages.size) {
            throw Exception("Message index out of bounds: ${index}")
        }
        MboxMailMessage(messages[index - 1], this)
    }

    public func list(): Array<MailFolder> {
        let arr = ArrayList<MailFolder>()
        for (f in subFolders) { arr.add(f) }
        arr.toArray()
    }

    public func isOpen(): Bool { isOpenFlag }
    public func open(mode: Int64): Unit { isOpenFlag = true }
    public func close(expunge: Bool): Unit { isOpenFlag = false }
}
