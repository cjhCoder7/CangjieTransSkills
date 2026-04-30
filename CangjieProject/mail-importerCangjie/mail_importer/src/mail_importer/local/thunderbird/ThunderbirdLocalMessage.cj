package mail_importer.local.thunderbird

import std.collection.ArrayList
import std.io.OutputStream
import mail_importer.local.MailMessage
import mail_importer.local.LocalMessage

// 简单的字节收集输出流，替代 ByteArrayOutputStream
class ByteArrayListStream <: OutputStream {
    let buffer = ArrayList<UInt8>()

    public func write(buffer: Array<Byte>): Unit {
        for (b in buffer) {
            this.buffer.add(b)
        }
    }

    public func toArray(): Array<UInt8> {
        buffer.toArray()
    }
}

public class ThunderbirdLocalMessage <: LocalMessage {
    let message: MailMessage
    let relativize: (String) -> String
    let statusParser: XMozillaStatusParser
    var status: ?XMozillaStatus = None

    public init(message: MailMessage, relativize: (String) -> String, statusParser: XMozillaStatusParser) {
        this.message = message
        this.relativize = relativize
        this.statusParser = statusParser
    }

    public func getMessageId(): String {
        let messageId = message.getHeader("Message-ID")
        if (messageId.size != 1) {
            throw IllegalStateException("Expected 1 message id, got: ${messageId}")
        }
        messageId[0]
    }

    public func getFromHeader(): String {
        let fromHeader = message.getHeader("From")
        if (fromHeader.size != 1) {
            throw IllegalStateException("Expected 1 From header, got: ${fromHeader}")
        }
        fromHeader[0]
    }

    public func getFolders(): ArrayList<String> {
        let result = ArrayList<String>()
        result.add(relativize(message.getFolder().getFullName()))
        result
    }

    public func getRawContent(): Array<UInt8> {
        let buffer = ByteArrayListStream()
        message.writeTo(buffer)
        buffer.toArray()
    }

    public func isUnread(): Bool {
        if (let Some(s) <- status) {
            return !s.isRead()
        }
        let s = statusParser.parse(message)
        status = s
        !s.isRead()
    }

    public func isStarred(): Bool {
        if (let Some(s) <- status) {
            return s.isMarked()
        }
        let s = statusParser.parse(message)
        status = s
        s.isMarked()
    }
}
