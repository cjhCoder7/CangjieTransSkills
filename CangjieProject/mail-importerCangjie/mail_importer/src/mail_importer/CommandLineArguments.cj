package mail_importer

// 命令行参数封装
public class CommandLineArguments {
    public var mailboxFileName: String = ""
    public var user: String = "me"
    public var maxMessages: ?Int64 = None
    public var clientSecretResourcePath: String = "/resources/client_secret.json"

    public init() {}

    public init(mailboxFileName: String, user: String, maxMessages: ?Int64, clientSecretResourcePath: String) {
        this.mailboxFileName = mailboxFileName
        this.user = user
        this.maxMessages = maxMessages
        this.clientSecretResourcePath = clientSecretResourcePath
    }

    // 从命令行参数数组解析
    public static func parse(args: Array<String>): CommandLineArguments {
        let result = CommandLineArguments()
        var i = 0
        while (i < args.size) {
            let arg = args[i]
            if (arg.startsWith("--mailbox=")) {
                result.mailboxFileName = arg[10..]  // "--mailbox=".size = 10
            } else if (arg == "--mailbox" && i + 1 < args.size) {
                i++
                result.mailboxFileName = args[i]
            } else if (arg.startsWith("--user=")) {
                result.user = arg[7..]  // "--user=".size = 7
            } else if (arg == "--user" && i + 1 < args.size) {
                i++
                result.user = args[i]
            } else if (arg.startsWith("--max_messages=")) {
                result.maxMessages = parseInt64(arg[15..])  // "--max_messages=".size = 15
            } else if (arg == "--max_messages" && i + 1 < args.size) {
                i++
                result.maxMessages = parseInt64(args[i])
            } else if (arg.startsWith("--client_secret_resource_path=")) {
                result.clientSecretResourcePath = arg[30..]  // "--client_secret_resource_path=".size = 30
            }
            i++
        }
        return result
    }

    public func validate(): Unit {
        if (mailboxFileName.isEmpty()) {
            throw IllegalArgumentException("--mailbox is required")
        }
    }
}

// 简易十进制字符串转 Int64
func parseInt64(s: String): Int64 {
    var result: Int64 = 0
    var i = 0
    var neg = false
    if (i < s.size && s[i] == 45) {  // '-'
        neg = true
        i++
    }
    while (i < s.size) {
        let b = s[i]
        if (b >= 48 && b <= 57) {  // '0'-'9'
            result = result * 10 + (Int64(b) - 48)
        }
        i++
    }
    if (neg) { -result } else { result }
}
