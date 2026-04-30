package mail_importer.local

import std.collection.ArrayList
import std.collection.HashMap
import std.io.OutputStream

// === 测试桩 ===

class MSFakeMailFolder <: MailFolder {
    var folderName: String
    var folderFullName: String
    var folderType: Int64
    var messages: ArrayList<MSFakeMailMessage>
    var subFolders: ArrayList<MSFakeMailFolder>
    var isOpenFlag: Bool = false

    init(name: String, fullName: String, folderType: Int64) {
        this.folderName = name
        this.folderFullName = fullName
        this.folderType = folderType
        this.messages = ArrayList<MSFakeMailMessage>()
        this.subFolders = ArrayList<MSFakeMailFolder>()
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

class MSFakeMailMessage <: MailMessage {
    var headers: HashMap<String, Array<String>>
    var folder: MailFolder
    var bodyContent: Array<UInt8>

    init() {
        this.headers = HashMap<String, Array<String>>()
        this.folder = MSFakeMailFolder("", "", 0)
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

class MSFakeLocalMessage <: LocalMessage {
    public func getMessageId(): String { "test-id" }
    public func getFromHeader(): String { "test@test.com" }
    public func getFolders(): ArrayList<String> { ArrayList<String>() }
    public func getRawContent(): Array<UInt8> { Array<UInt8>() }
    public func isUnread(): Bool { true }
    public func isStarred(): Bool { false }
}

// === 测试用例 ===

@Test
class MailStorageTest {

    func makeFolderWithMessages(numMessages: Int64, subFolders: Array<MSFakeMailFolder>): MSFakeMailFolder {
        let folder = MSFakeMailFolder("test", "test", 3)
        for (i in 0..numMessages) {
            folder.messages.add(MSFakeMailMessage())
        }
        for (sub in subFolders) {
            folder.subFolders.add(sub)
        }
        folder
    }

    @TestCase
    func testIterator_simple(): Unit {
        let folder = makeFolderWithMessages(5, [])
        let storage = TestableMailStorage(ConsoleLogger("test"), folder)

        var count: Int64 = 0
        let iter = storage.iterator()
        while (let Some(_) <- iter.next()) {
            count++
        }
        @Expect(count, 5)
    }

    @TestCase
    func testIterator_withSubFolders(): Unit {
        let deepSub = makeFolderWithMessages(6, [
            makeFolderWithMessages(9, []),
            makeFolderWithMessages(3, [])
        ])
        let deepEmpty = makeFolderWithMessages(0, [
            makeFolderWithMessages(0, [
                makeFolderWithMessages(5, [])
            ])
        ])
        let mid = makeFolderWithMessages(15, [deepSub, deepEmpty])
        let folder = makeFolderWithMessages(5, [
            mid,
            makeFolderWithMessages(10, []),
            makeFolderWithMessages(7, [])
        ])
        let storage = TestableMailStorage(ConsoleLogger("test"), folder)

        var count: Int64 = 0
        let iter = storage.iterator()
        while (let Some(_) <- iter.next()) {
            count++
        }
        @Expect(count, 60)
    }

    @TestCase
    func testIterator_pathologicalNoMessages(): Unit {
        let folder = makeFolderWithMessages(0, [
            makeFolderWithMessages(0, []),
            makeFolderWithMessages(0, [])
        ])
        let storage = TestableMailStorage(ConsoleLogger("test"), folder)

        var count: Int64 = 0
        let iter = storage.iterator()
        while (let Some(_) <- iter.next()) {
            count++
        }
        @Expect(count, 0)
    }

    @TestCase
    func testIterator_getWithoutLooking(): Unit {
        let folder = makeFolderWithMessages(0, [
            makeFolderWithMessages(0, []),
            makeFolderWithMessages(0, [
                makeFolderWithMessages(0, []),
                makeFolderWithMessages(1, [])
            ])
        ])
        let storage = TestableMailStorage(ConsoleLogger("test"), folder)

        let iter = storage.iterator()
        var found = false
        if (let Some(_) <- iter.next()) {
            found = true
        }
        @Expect(found, true)
    }
}

class TestableMailStorage <: MailStorage {
    public init(logger: SimpleLogger, root: MailFolder) {
        super(logger, root)
    }

    public func createLocalMessage(message: MailMessage): LocalMessage {
        MSFakeLocalMessage()
    }
}
