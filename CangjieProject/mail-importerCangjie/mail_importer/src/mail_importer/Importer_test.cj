package mail_importer

import std.collection.ArrayList
import mail_importer.gmail.GmailSyncer
import mail_importer.gmail.Mailbox
import mail_importer.gmail.GmailService
import mail_importer.gmail.User
import mail_importer.local.LocalMessage
import mail_importer.local.LocalMessageStorage
import mail_importer.local.MailProvider
import mail_importer.local.ConsoleLogger

@Test
class ImporterTest {

    @TestCase
    func testImportMail_maxMessagesRespected(): Unit {
        let args = CommandLineArguments()
        args.mailboxFileName = "/tmp"
        args.maxMessages = 50

        @Expect(args.maxMessages, Some(50))
    }

    @TestCase
    func testImportMail_noMaxMessages(): Unit {
        let args = CommandLineArguments()
        args.mailboxFileName = "/tmp"

        @Expect(args.maxMessages, None)
    }
}

class FakeStorageProvider <: MailProvider<LocalMessageStorage> {
    let storage: LocalMessageStorage

    init(storage: LocalMessageStorage) {
        this.storage = storage
    }

    public func get(): LocalMessageStorage {
        storage
    }
}

class FakeLocalStorage <: LocalMessageStorage {
    let messages: ArrayList<LocalMessage>

    init(messages: ArrayList<LocalMessage>) {
        this.messages = messages
    }

    public func iterator(): Iterator<LocalMessage> {
        messages.iterator()
    }
}
