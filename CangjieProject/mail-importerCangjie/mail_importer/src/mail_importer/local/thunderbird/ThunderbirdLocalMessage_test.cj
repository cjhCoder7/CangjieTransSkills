package mail_importer.local.thunderbird

import std.collection.ArrayList
import std.collection.HashMap
import std.io.OutputStream
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage
import mail_importer.local.MailAddress

// === 测试桩 ===

class TLMTestFakeMailFolder <: MailFolder {
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

class TLMTestFakeMailMessage <: MailMessage {
    var headers: HashMap<String, Array<String>>
    var folder: MailFolder
    var bodyContent: Array<UInt8>

    init() {
        this.headers = HashMap<String, Array<String>>()
        this.folder = TLMTestFakeMailFolder("", "", 0)
        this.bodyContent = Array<UInt8>()
    }

    public func getHeader(name: String): Array<String> {
        if (let Some(v) <- headers.get(name)) { return v }
        Array<String>()
    }
    public func getFolder(): MailFolder { folder }
    public func writeTo(os: OutputStream): Unit {
        os.write(bodyContent)
    }
    public func getFrom(): Array<MailAddress> { Array<MailAddress>() }
    public func getSize(): Int64 { bodyContent.size }
    public func getMessageNumber(): Int64 { 1 }
}

// === 测试用例 ===

@Test
class ThunderbirdLocalMessageTest {

    func makeMessage(): TLMTestFakeMailMessage {
        let message = TLMTestFakeMailMessage()
        let folder = TLMTestFakeMailFolder("folder", "folder", 1)
        message.folder = folder
        message.bodyContent = Array<UInt8>()
        message.headers["X-Mozilla-Status"] = ["00000000"]
        message
    }

    @TestCase
    func testGetMessageId_normal(): Unit {
        let message = makeMessage()
        message.headers["Message-ID"] = ["<XYZ@pdq>"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @Expect(msg.getMessageId(), "<XYZ@pdq>")
    }

    @TestCase
    func testGetMessageId_missing(): Unit {
        let message = makeMessage()
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @ExpectThrows[IllegalStateException]({
            msg.getMessageId()
        })
    }

    @TestCase
    func testGetMessageId_multiple(): Unit {
        let message = makeMessage()
        message.headers["Message-ID"] = ["<XYZ@pdq>", "<ABC@123>"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @ExpectThrows[IllegalStateException]({
            msg.getMessageId()
        })
    }

    @TestCase
    func testGetFromHeader_normal(): Unit {
        let message = makeMessage()
        message.headers["From"] = ["<XYZ@pdq>"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @Expect(msg.getFromHeader(), "<XYZ@pdq>")
    }

    @TestCase
    func testGetFromHeader_missing(): Unit {
        let message = makeMessage()
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @ExpectThrows[IllegalStateException]({
            msg.getFromHeader()
        })
    }

    @TestCase
    func testGetFromHeader_multiple(): Unit {
        let message = makeMessage()
        message.headers["From"] = ["<XYZ@pdq>", "<ABC@123>"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @ExpectThrows[IllegalStateException]({
            msg.getFromHeader()
        })
    }

    @TestCase
    func testGetFolders(): Unit {
        let message = makeMessage()
        let msg = ThunderbirdLocalMessage(message, { s => "*" + s + "*" }, XMozillaStatusParser())
        let folders = msg.getFolders()

        @Expect(folders.size, 1)
        @Expect(folders[0], "*folder*")
    }

    @TestCase
    func testGetRawContent(): Unit {
        let message = makeMessage()
        let bodyBytes = ArrayList<UInt8>()
        bodyBytes.add(66)  // B
        bodyBytes.add(79)  // O
        bodyBytes.add(68)  // D
        bodyBytes.add(89)  // Y
        message.bodyContent = bodyBytes.toArray()
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        let raw = msg.getRawContent()
        @Expect(raw.size, 4)
        @Expect(UInt64(raw[0]), UInt64(66))
        @Expect(UInt64(raw[1]), UInt64(79))
        @Expect(UInt64(raw[2]), UInt64(68))
        @Expect(UInt64(raw[3]), UInt64(89))
    }

    @TestCase
    func testIsUnread_true(): Unit {
        let message = makeMessage()
        message.headers["X-Mozilla-Status"] = ["00000000"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @Expect(msg.isUnread(), true)
    }

    @TestCase
    func testIsUnread_false(): Unit {
        let message = makeMessage()
        message.headers["X-Mozilla-Status"] = ["00000001"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @Expect(msg.isUnread(), false)
    }

    @TestCase
    func testIsStarred_true(): Unit {
        let message = makeMessage()
        message.headers["X-Mozilla-Status"] = ["00000004"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @Expect(msg.isStarred(), true)
    }

    @TestCase
    func testIsStarred_false(): Unit {
        let message = makeMessage()
        message.headers["X-Mozilla-Status"] = ["00000000"]
        let msg = ThunderbirdLocalMessage(message, { s => s }, XMozillaStatusParser())

        @Expect(msg.isStarred(), false)
    }
}
