package mail_importer

@Test
class CommandLineArgumentsTest {

    @TestCase
    func testArgumentParsing_noRequiredArguments(): Unit {
        let args = Array<String>()
        let result = CommandLineArguments.parse(args)
        @ExpectThrows[IllegalArgumentException]({
            result.validate()
        })
    }

    @TestCase
    func testArgumentParsing_bogusMailbox(): Unit {
        let args = ["--mailbox=/no/such/directory"]
        let result = CommandLineArguments.parse(args)

        @Expect(result.mailboxFileName, "/no/such/directory")
        @Expect(result.user, "me")
    }

    @TestCase
    func testArgumentParsing_bogusMailboxAndUser(): Unit {
        let args = ["--mailbox=/no/such/directory", "--user=foobar"]
        let result = CommandLineArguments.parse(args)

        @Expect(result.mailboxFileName, "/no/such/directory")
        @Expect(result.user, "foobar")
    }

    @TestCase
    func testArgumentParsing_maxMessages(): Unit {
        let args = ["--mailbox=/tmp", "--max_messages=50"]
        let result = CommandLineArguments.parse(args)

        @Expect(result.maxMessages, Some(Int64(50)))
    }
}
