package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap
import mail_importer.local.LocalMessage

// === 测试桩 ===

class MBFakeLocalMessage <: LocalMessage {
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
class MailboxTest {

    func makeMailbox(): Mailbox {
        let httpClient = StubGmailHttpClient()
        Mailbox(httpClient, User("test@test.com"))
    }

    @TestCase
    func testLoadLabels(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        mailbox.loadLabels()

        // StubGmailHttpClient 预置了内置标签
        @Expect(httpClient.listLabelsCallCount, 1)
        @Expect(mailbox.labelsByName.contains("INBOX"), true)
        @Expect(mailbox.labelsByName.contains("SPAM"), true)
        @Expect(mailbox.labelsByName.contains("UNREAD"), true)
    }

    @TestCase
    func testMapMessageIds_empty(): Unit {
        let mailbox = makeMailbox()
        mailbox.loadLabels()
        let result = mailbox.mapMessageIds(ArrayList<LocalMessage>())
        @Expect(result.size, 0)
    }

    @TestCase
    func testMapMessageIds_found(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        mailbox.loadLabels()

        // 预置一条消息
        let labelIds = ArrayList<String>()
        labelIds.add("INBOX")
        httpClient.addExistingMessage("msg_1", "<id1@test.com>", labelIds)

        let msg = MBFakeLocalMessage("<id1@test.com>", "from@test.com")
        let messages = ArrayList<LocalMessage>()
        messages.add(msg)

        let result = mailbox.mapMessageIds(messages)
        @Expect(result.size, 1)
        if (let Some(gmailMsgs) <- result.get("<id1@test.com>")) {
            @Expect(gmailMsgs.size, 1)
            @Expect(gmailMsgs[0].id, "msg_1")
        } else {
            @Expect(true, false)
        }
    }

    @TestCase
    func testUploadMessage(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        mailbox.loadLabels()

        let rawContent = Array<UInt8>()
        let msg = MBFakeLocalMessage("<new@test.com>", "from@test.com")
        msg.rawContent = rawContent

        let result = mailbox.uploadMessage(msg)
        @Expect(httpClient.importMessageCallCount, 1)
        @Expect(result.id.startsWith("msg_"), true)
    }

    @TestCase
    func testSyncLabels_addsLabels(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        mailbox.loadLabels()

        // 创建本地消息
        let msg = MBFakeLocalMessage("<id1@test.com>", "from@test.com")
        msg.foldersList.add("Inbox")
        msg.unread = true

        // 预置对应的 Gmail 消息
        let labelIds = ArrayList<String>()
        let gmailMsg = GmailMessage("msg_1", labelIds)

        let map = HashMap<String, ArrayList<GmailMessage>>()
        let gmailMsgs = ArrayList<GmailMessage>()
        gmailMsgs.add(gmailMsg)
        map["<id1@test.com>"] = gmailMsgs

        let localMsgs = ArrayList<LocalMessage>()
        localMsgs.add(msg)

        mailbox.syncLocalLabelsToGmail(map, localMsgs)
        @Expect(httpClient.modifyMessageCallCount, 1)
    }

    @TestCase
    func testCreateMissingLabels(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        mailbox.loadLabels()

        let msg = MBFakeLocalMessage("<id1@test.com>", "from@test.com")
        msg.foldersList.add("MyCustomFolder")

        let localMsgs = ArrayList<LocalMessage>()
        localMsgs.add(msg)

        mailbox.syncLocalLabelsToGmail(HashMap<String, ArrayList<GmailMessage>>(), localMsgs)
        @Expect(httpClient.createLabelCallCount, 1)
        @Expect(mailbox.labelsByName.contains("MyCustomFolder"), true)
    }

    @TestCase
    func testNormalizeLabelName(): Unit {
        let mailbox = makeMailbox()

        @Expect(mailbox.normalizeLabelName("Inbox"), "INBOX")
        @Expect(mailbox.normalizeLabelName("INBOX"), "INBOX")
        @Expect(mailbox.normalizeLabelName("Drafts"), "Import/Drafts")
        @Expect(mailbox.normalizeLabelName("TRASH"), "TRASH")
        @Expect(mailbox.normalizeLabelName("SPAM"), "SPAM")
        @Expect(mailbox.normalizeLabelName("Custom"), "Custom")
    }

    @TestCase
    func testFetchExistingLabels(): Unit {
        let httpClient = StubGmailHttpClient()
        let mailbox = Mailbox(httpClient, User("test@test.com"))
        mailbox.loadLabels()

        // 预置一条消息带标签
        let labelIds = ArrayList<String>()
        labelIds.add("INBOX")
        httpClient.addExistingMessage("msg_1", "<id1@test.com>", labelIds)

        let gmailMsg = GmailMessage("msg_1")
        let messages = ArrayList<GmailMessage>()
        messages.add(gmailMsg)

        mailbox.fetchExistingLabels(messages)
        @Expect(gmailMsg.labelIds.size, 1)
        @Expect(gmailMsg.labelIds[0], "INBOX")
    }
}
