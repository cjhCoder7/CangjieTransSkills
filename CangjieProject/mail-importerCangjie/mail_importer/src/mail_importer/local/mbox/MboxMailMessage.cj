package mail_importer.local.mbox

import std.collection.ArrayList
import std.io.OutputStream
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage
import mail_importer.local.MailAddress

// 基于 MboxRawMessage 的 MailMessage 实现
public class MboxMailMessage <: MailMessage {
    let rawMessage: MboxRawMessage
    var folder: MailFolder

    public init(rawMessage: MboxRawMessage, folder: MailFolder) {
        this.rawMessage = rawMessage
        this.folder = folder
    }

    public func getHeader(name: String): Array<String> {
        if (let Some(values) <- rawMessage.headers.get(name.toAsciiLower())) {
            values
        } else {
            Array<String>()
        }
    }

    public func getFolder(): MailFolder {
        folder
    }

    public func writeTo(os: OutputStream): Unit {
        os.write(rawMessage.rawBytes)
    }

    public func getFrom(): Array<MailAddress> {
        let fromHeaders = getHeader("from")
        if (fromHeaders.size == 0) {
            return Array<MailAddress>()
        }
        let result = ArrayList<MailAddress>()
        for (h in fromHeaders) {
            let email = extractEmailAddress(h)
            result.add(MailAddress(email))
        }
        result.toArray()
    }

    public func getSize(): Int64 {
        rawMessage.rawBytes.size
    }

    public func getMessageNumber(): Int64 {
        rawMessage.messageNumber
    }

    // 从 From 头部值中提取邮件地址
    // 支持格式: "Name <email@domain>", "<email@domain>", "email@domain"
    func extractEmailAddress(header: String): String {
        if (let Some(startIdx) <- header.indexOf("<")) {
            if (let Some(endIdx) <- header.indexOf(">")) {
                if (endIdx > startIdx + 1) {
                    return header[startIdx + 1..endIdx].trimAscii()
                }
            }
        }
        header.trimAscii()
    }
}
