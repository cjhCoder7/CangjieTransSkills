package mail_importer.fixers

import std.collection.ArrayList
import std.collection.HashMap
import std.io.OutputStream
import mail_importer.local.MailMessage
import mail_importer.local.MailFolder
import mail_importer.local.MailAddress

// === 测试桩 ===

class CEFakeMailMessage <: MailMessage {
    var headers: HashMap<String, Array<String>>
    var fromAddresses: Array<MailAddress>

    init(headers: HashMap<String, Array<String>>, fromAddresses: Array<MailAddress>) {
        this.headers = headers
        this.fromAddresses = fromAddresses
    }

    public func getHeader(name: String): Array<String> {
        if (let Some(values) <- headers.get(name.toAsciiLower())) {
            values
        } else {
            Array<String>()
        }
    }

    public func getFolder(): MailFolder {
        throw Exception("not implemented")
    }

    public func writeTo(os: OutputStream): Unit {
        throw Exception("not implemented")
    }

    public func getFrom(): Array<MailAddress> {
        fromAddresses
    }

    public func getSize(): Int64 { 0 }
    public func getMessageNumber(): Int64 { 0 }
}

// === 测试用例 ===

@Test
class CorruptEmailFixerTest {

    @TestCase
    func testHasValidFrom_validEmail(): Unit {
        let fixer = CorruptEmailFixer()
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["John <john@example.com>"]
        let msg = CEFakeMailMessage(headers, [MailAddress("john@example.com")])
        let result = fixer.hasValidFrom(msg)
        @Expect(result, true)
    }

    @TestCase
    func testHasValidFrom_simpleEmail(): Unit {
        let fixer = CorruptEmailFixer()
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["test@example.com"]
        let msg = CEFakeMailMessage(headers, [MailAddress("test@example.com")])
        let result = fixer.hasValidFrom(msg)
        @Expect(result, true)
    }

    @TestCase
    func testHasValidFrom_invalidEmail(): Unit {
        let fixer = CorruptEmailFixer()
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["not-an-email"]
        let msg = CEFakeMailMessage(headers, [MailAddress("not-an-email")])
        @Expect(fixer.hasValidFrom(msg), false)
    }

    @TestCase
    func testHasValidFrom_missingAt(): Unit {
        let fixer = CorruptEmailFixer()
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["userexample.com"]
        let msg = CEFakeMailMessage(headers, [MailAddress("userexample.com")])
        @Expect(fixer.hasValidFrom(msg), false)
    }

    @TestCase
    func testHasValidFrom_multipleFromHeaders(): Unit {
        let fixer = CorruptEmailFixer()
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["a@test.com", "b@test.com"]
        let msg = CEFakeMailMessage(headers, Array<MailAddress>())
        @ExpectThrows[IllegalStateException]({
            fixer.hasValidFrom(msg)
        })
    }

    @TestCase
    func testTryToCorrectMessageFrom_returnsOriginal(): Unit {
        let fixer = CorruptEmailFixer()
        let headers = HashMap<String, Array<String>>()
        headers["from"] = ["test@example.com"]
        let msg = CEFakeMailMessage(headers, [MailAddress("test@example.com")])
        let result = fixer.tryToCorrectMessageFrom(msg)
        @Expect(result.getMessageNumber(), msg.getMessageNumber())
    }

    @TestCase
    func testIsValidEmailAddress_basic(): Unit {
        let fixer = CorruptEmailFixer()
        @Expect(fixer.isValidEmailAddress("test@example.com"), true)
        @Expect(fixer.isValidEmailAddress("not-an-email"), false)
        @Expect(fixer.isValidEmailAddress(""), false)
        @Expect(fixer.isValidEmailAddress("user@"), false)
    }

    @TestCase
    func testExtractEmailAddress(): Unit {
        let fixer = CorruptEmailFixer()
        @Expect(fixer.extractEmailAddress("John <john@example.com>"), "john@example.com")
        @Expect(fixer.extractEmailAddress("test@example.com"), "test@example.com")
    }
}
