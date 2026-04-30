package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap
import mail_importer.local.LocalMessage

// === 测试桩 ===

class GSFakeMailbox <: Mailbox {
    var uploadedMessages: ArrayList<LocalMessage> = ArrayList<LocalMessage>()

    public init() {
        super(StubGmailHttpClient(), User("test@test.com"))
    }

    public override func connect(): Unit {
        // 不调用 Gmail API
    }

    public override func mapMessageIds(localMessages: ArrayList<LocalMessage>): HashMap<String, ArrayList<GmailMessage>> {
        HashMap<String, ArrayList<GmailMessage>>()
    }

    public override func uploadMessage(localMessage: LocalMessage): GmailMessage {
        uploadedMessages.add(localMessage)
        GmailMessage("fake-id")
    }

    public override func fetchExistingLabels(messages: ArrayList<GmailMessage>): Unit {
        // 不调用 Gmail API
    }

    public override func syncLocalLabelsToGmail(map: HashMap<String, ArrayList<GmailMessage>>, localMessages: ArrayList<LocalMessage>): Unit {
        // 不调用 Gmail API
    }
}

class GSFakeLocalMessage <: LocalMessage {
    var msgId: String
    var fromHdr: String
    var foldersList: ArrayList<String>
    var rawContent: Array<UInt8>
    var unread: Bool
    var starred: Bool

    init(messageId: String, from: String) {
        this.msgId = messageId
        this.fromHdr = from
        this.foldersList = ArrayList<String>()
        this.rawContent = Array<UInt8>()
        this.unread = false
        this.starred = false
    }

    public func getMessageId(): String { msgId }
    public func getFromHeader(): String { fromHdr }
    public func getFolders(): ArrayList<String> { foldersList }
    public func getRawContent(): Array<UInt8> { rawContent }
    public func isUnread(): Bool { unread }
    public func isStarred(): Bool { starred }
}

// === 测试用例 ===

@Test
class GmailSyncerTest {

    @TestCase
    func testInitRequiredBeforeSync(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        let syncer = GmailSyncer(mailbox)

        @ExpectThrows[IllegalStateException]({
            syncer.sync(ArrayList<LocalMessage>())
        })
    }

    @TestCase
    func testSyncEmptyList(): Unit {
        let mailbox = GSFakeMailbox()
        let syncer = GmailSyncer(mailbox)
        syncer.connect()
        syncer.sync(ArrayList<LocalMessage>())

        @Expect(mailbox.uploadedMessages.size, 0)
    }

    @TestCase
    func testSyncWithMessages(): Unit {
        let mailbox = GSFakeMailbox()
        let syncer = GmailSyncer(mailbox)
        syncer.connect()

        let msg1 = GSFakeLocalMessage("id1", "from1@test.com")
        let msg2 = GSFakeLocalMessage("id2", "from2@test.com")
        let messages = ArrayList<LocalMessage>()
        messages.add(msg1)
        messages.add(msg2)

        syncer.sync(messages)

        @Expect(mailbox.uploadedMessages.size, 2)
    }
}
