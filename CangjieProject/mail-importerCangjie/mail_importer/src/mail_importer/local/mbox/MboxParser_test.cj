package mail_importer.local.mbox

import std.collection.ArrayList
import std.collection.HashMap
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage
import mail_importer.local.MailAddress

// === 测试桩 ===

class MPMFakeMailFolder <: MailFolder {
    var folderName: String
    var folderFullName: String
    var folderType: Int64
    var isOpenFlag: Bool = false

    init(name: String, fullName: String, folderType: Int64) {
        this.folderName = name
        this.folderFullName = fullName
        this.folderType = folderType
    }

    public func getName(): String { folderName }
    public func getFullName(): String { folderFullName }
    public func getType(): Int64 { folderType }
    public func getMessageCount(): Int64 { 0 }
    public func getMessage(index: Int64): MailMessage {
        throw Exception("not implemented")
    }
    public func list(): Array<MailFolder> { Array<MailFolder>() }
    public func isOpen(): Bool { isOpenFlag }
    public func open(mode: Int64): Unit { isOpenFlag = true }
    public func close(expunge: Bool): Unit { isOpenFlag = false }
}

// === 测试用例 ===

@Test
class MboxParserTest {

    func makeMboxBytes(): ArrayList<UInt8> {
        let bytes = ArrayList<UInt8>()
        bytes
    }

    func addString(bytes: ArrayList<UInt8>, s: String): Unit {
        for (b in s.toArray()) {
            bytes.add(UInt8(b))
        }
    }

    func addLine(bytes: ArrayList<UInt8>, s: String): Unit {
        addString(bytes, s)
        bytes.add(10)  // '\n'
    }

    @TestCase
    func testParseEmptyContent(): Unit {
        let parser = MboxParser()
        let result = parser.parseBytes(Array<UInt8>())
        @Expect(result.size, 0)
    }

    @TestCase
    func testParseSingleMessage(): Unit {
        let bytes = makeMboxBytes()
        addLine(bytes, "From sender@test.com Mon Jan 1 00:00:00 2024")
        addLine(bytes, "Message-ID: <msg1@test.com>")
        addLine(bytes, "From: <sender@test.com>")
        addLine(bytes, "Subject: Test")
        addLine(bytes, "")
        addLine(bytes, "Hello World")

        let parser = MboxParser()
        let result = parser.parseBytes(bytes.toArray())
        @Expect(result.size, 1)

        let msg = result[0]
        @Expect(msg.messageNumber, 1)
        @Expect(msg.envelopeSender, "sender@test.com")

        // 检查头部解析
        if (let Some(ids) <- msg.headers.get("message-id")) {
            @Expect(ids.size, 1)
            @Expect(ids[0], "<msg1@test.com>")
        } else {
            @Expect(true, false)  // 不应该到这里
        }
    }

    @TestCase
    func testParseMultipleMessages(): Unit {
        let bytes = makeMboxBytes()
        addLine(bytes, "From sender1@test.com Mon Jan 1 00:00:00 2024")
        addLine(bytes, "Message-ID: <msg1@test.com>")
        addLine(bytes, "")
        addLine(bytes, "Body 1")
        addLine(bytes, "From sender2@test.com Mon Jan 2 00:00:00 2024")
        addLine(bytes, "Message-ID: <msg2@test.com>")
        addLine(bytes, "")
        addLine(bytes, "Body 2")

        let parser = MboxParser()
        let result = parser.parseBytes(bytes.toArray())
        @Expect(result.size, 2)
        @Expect(result[0].messageNumber, 1)
        @Expect(result[1].messageNumber, 2)
    }

    @TestCase
    func testParseFoldedHeaders(): Unit {
        let bytes = makeMboxBytes()
        addLine(bytes, "From sender@test.com Mon Jan 1 00:00:00 2024")
        addLine(bytes, "Subject: This is a")
        addString(bytes, " continued subject line")
        bytes.add(10)  // '\n'
        addLine(bytes, "Message-ID: <folded@test.com>")
        addLine(bytes, "")
        addLine(bytes, "Body")

        let parser = MboxParser()
        let result = parser.parseBytes(bytes.toArray())
        @Expect(result.size, 1)

        if (let Some(subjects) <- result[0].headers.get("subject")) {
            @Expect(subjects.size, 1)
            @Expect(subjects[0].contains("continued"), true)
        } else {
            @Expect(true, false)
        }
    }

    @TestCase
    func testMboxMailMessageGetHeader(): Unit {
        let headers = HashMap<String, Array<String>>()
        headers["message-id"] = ["<test@example.com>"]
        headers["from"] = ["John <john@example.com>"]
        let rawMsg = MboxRawMessage(Array<UInt8>(), headers, 1, "sender")
        let folder = MPMFakeMailFolder("test", "test", 1)
        let msg = MboxMailMessage(rawMsg, folder)

        let msgId = msg.getHeader("Message-ID")
        @Expect(msgId.size, 1)
        @Expect(msgId[0], "<test@example.com>")

        // 大小写不敏感
        let msgId2 = msg.getHeader("message-id")
        @Expect(msgId2.size, 1)

        // 不存在的头
        let noHeader = msg.getHeader("X-NonExistent")
        @Expect(noHeader.size, 0)
    }

    @TestCase
    func testMboxMailMessageGetFrom(): Unit {
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["John <john@example.com>"]
        let rawMsg = MboxRawMessage(Array<UInt8>(), headers, 1, "sender")
        let folder = MPMFakeMailFolder("test", "test", 1)
        let msg = MboxMailMessage(rawMsg, folder)

        let from = msg.getFrom()
        @Expect(from.size, 1)
        @Expect(from[0].address, "john@example.com")
    }

    @TestCase
    func testMboxMailFolderMessages(): Unit {
        let folder = MboxMailFolder("Inbox", "/mail/Inbox", 1)
        let headers = HashMap<String, Array<String>>()
        headers["message-id"] = ["<msg1@test.com>"]
        folder.messages.add(MboxRawMessage(Array<UInt8>(), headers, 1, "sender"))

        @Expect(folder.getMessageCount(), 1)
        @Expect(folder.getName(), "Inbox")

        let msg = folder.getMessage(1)
        let msgId = msg.getHeader("message-id")
        @Expect(msgId.size, 1)
    }

    @TestCase
    func testMboxMailFolderSubfolders(): Unit {
        let root = MboxMailFolder("root", "/mail", 3)
        let sub = MboxMailFolder("Inbox", "/mail/Inbox", 1)
        root.subFolders.add(sub)

        let subs = root.list()
        @Expect(subs.size, 1)
        @Expect(subs[0].getName(), "Inbox")
    }
}
