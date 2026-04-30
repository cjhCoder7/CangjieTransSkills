package mail_importer.local.thunderbird

import std.collection.ArrayList
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage
import mail_importer.local.ConsoleLogger

// === 测试桩 ===

class TMSFakeMailFolder <: MailFolder {
    var folderName: String
    var folderFullName: String
    var folderType: Int64
    var subFolders: ArrayList<TMSFakeMailFolder>
    var isOpenFlag: Bool = false

    init(name: String, fullName: String, folderType: Int64) {
        this.folderName = name
        this.folderFullName = fullName
        this.folderType = folderType
        this.subFolders = ArrayList<TMSFakeMailFolder>()
    }

    public func getName(): String { folderName }
    public func getFullName(): String { folderFullName }
    public func getType(): Int64 { folderType }
    public func getMessageCount(): Int64 { 0 }
    public func getMessage(index: Int64): MailMessage {
        throw Exception("not implemented")
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

// === 测试用例 ===

@Test
class ThunderbirdMailStorageTest {

    @TestCase
    func testFilterFolders(): Unit {
        let folder1 = TMSFakeMailFolder("folder1", "folder1", 1)
        let atFolder = TMSFakeMailFolder("@folder2", "@folder2", 1)
        let folder3 = TMSFakeMailFolder("!folder3", "!folder3", 1)

        let rootFolder = TMSFakeMailFolder("root", "root", 3)
        rootFolder.subFolders.add(folder1)
        rootFolder.subFolders.add(atFolder)
        rootFolder.subFolders.add(folder3)

        let storage = ThunderbirdMailStorage(
            ConsoleLogger("test"),
            rootFolder,
            XMozillaStatusParser()
        )

        let allFolders = ArrayList<MailFolder>()
        allFolders.add(folder1)
        allFolders.add(atFolder)
        allFolders.add(folder3)

        let filtered = ArrayList<MailFolder>()
        let iter = storage.filterFolders(allFolders.iterator())
        while (let Some(f) <- iter.next()) {
            filtered.add(f)
        }

        @Expect(filtered.size, 2)
        @Expect(filtered[0].getName(), "folder1")
        @Expect(filtered[1].getName(), "!folder3")
    }

    @TestCase
    func testRelativize(): Unit {
        let rootFolder = TMSFakeMailFolder("root", "/abc/root", 3)
        let storage = ThunderbirdMailStorage(
            ConsoleLogger("test"),
            rootFolder,
            XMozillaStatusParser()
        )

        let result = storage.relativize("/abc/root/xyz/pdq.sbd")
        @Expect(result, "xyz/pdq")
    }
}
