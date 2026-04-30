package mail_importer.local.thunderbird

import std.collection.HashMap
import std.collection.ArrayList
import std.io.OutputStream
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage
import mail_importer.local.MailAddress

// === 测试桩 ===

class TestFakeMailFolder <: MailFolder {
    var folderName: String
    var folderFullName: String
    var folderType: Int64
    var messages: ArrayList<TestFakeMailMessage>
    var subFolders: ArrayList<TestFakeMailFolder>
    var isOpenFlag: Bool = false

    init(name: String, fullName: String, folderType: Int64) {
        this.folderName = name
        this.folderFullName = fullName
        this.folderType = folderType
        this.messages = ArrayList<TestFakeMailMessage>()
        this.subFolders = ArrayList<TestFakeMailFolder>()
    }

    public func getName(): String { folderName }
    public func getFullName(): String { folderFullName }
    public func getType(): Int64 { folderType }
    public func getMessageCount(): Int64 { messages.size }
    public func getMessage(index: Int64): MailMessage {
        if (index < 1 || index > messages.size) {
            throw Exception("Message index out of bounds: ${index}")
        }
        messages[index - 1]
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

class TestFakeMailMessage <: MailMessage {
    var headers: HashMap<String, Array<String>>
    var folder: MailFolder
    var bodyContent: Array<UInt8>

    init() {
        this.headers = HashMap<String, Array<String>>()
        this.folder = TestFakeMailFolder("", "", 0)
        this.bodyContent = Array<UInt8>()
    }

    public func getHeader(name: String): Array<String> {
        if (let Some(v) <- headers.get(name)) { return v }
        Array<String>()
    }
    public func getFolder(): MailFolder { folder }
    public func writeTo(os: OutputStream): Unit {
        for (b in bodyContent) { os.write(b) }
    }
    public func getFrom(): Array<MailAddress> { Array<MailAddress>() }
    public func getSize(): Int64 { bodyContent.size }
    public func getMessageNumber(): Int64 { 1 }
}

// === 测试用例 ===

@Test
class XMozillaStatusTest {
    let parser = XMozillaStatusParser()

    @TestCase
    func testNoStatusHeader(): Unit {
        let message = TestFakeMailMessage()
        let status = parser.parse(message)
        @Expect(status.isRead(), false)
        @Expect(status.isMarked(), false)
    }

    @TestCase
    func testMultipleStatusHeadersThrowsException(): Unit {
        let message = TestFakeMailMessage()
        message.headers["X-Mozilla-Status"] = ["00000000", "00000000"]
        @ExpectThrows[IllegalStateException]({
            parser.parse(message)
        })
    }

    @TestCase
    func testIsRead(): Unit {
        let message = TestFakeMailMessage()
        message.headers["X-Mozilla-Status"] = ["00000001"]
        let status = parser.parse(message)
        @Expect(status.isRead(), true)
    }

    @TestCase
    func testIsMarked(): Unit {
        let message = TestFakeMailMessage()
        message.headers["X-Mozilla-Status"] = ["00000004"]
        let status = parser.parse(message)
        @Expect(status.isMarked(), true)
    }

    @TestCase
    func testIsMarkedAndRead(): Unit {
        let message = TestFakeMailMessage()
        message.headers["X-Mozilla-Status"] = ["00000005"]
        let status = parser.parse(message)
        @Expect(status.isRead(), true)
        @Expect(status.isMarked(), true)
    }
}
