package mail_importer

import std.collection.ArrayList
import mail_importer.local.SimpleLogger
import mail_importer.local.ConsoleLogger
import mail_importer.gmail.GmailSyncer
import mail_importer.gmail.User
import mail_importer.gmail.Authorizer
import mail_importer.gmail.RealGmailHttpClient
import mail_importer.gmail.GmailService
import mail_importer.local.LocalMessage
import mail_importer.local.LocalMessageStorage
import mail_importer.local.MailProvider
import mail_importer.local.thunderbird.XMozillaStatusParser
import mail_importer.local.thunderbird.ThunderbirdMailbox

// 邮件导入器。从 LocalStorage 读取消息，按批次通过 GmailSyncer 同步到 Gmail。
public class Importer {
    static let BATCH_SIZE: Int64 = 100

    let logger: SimpleLogger
    let storageProvider: MailProvider<LocalMessageStorage>
    let gmailSyncer: GmailSyncer
    let commandLineArguments: CommandLineArguments

    public init(
        logger: SimpleLogger,
        storageProvider: MailProvider<LocalMessageStorage>,
        gmailSyncer: GmailSyncer,
        commandLineArguments: CommandLineArguments
    ) {
        this.logger = logger
        this.storageProvider = storageProvider
        this.gmailSyncer = gmailSyncer
        this.commandLineArguments = commandLineArguments
    }

    public func importMail(): Unit {
        let storage = storageProvider.get()
        gmailSyncer.connect()

        var messagesImported: Int64 = 0
        let iterator = storage.iterator()

        while (let Some(message) <- iterator.next()) {
            if (!keepImporting(messagesImported)) {
                break
            }

            let batch = ArrayList<LocalMessage>()
            batch.add(message)
            messagesImported++
            logger.fine("Id: ${message.getMessageId()}")
            logger.fine("Folders: ${message.getFolders()}")

            var j: Int64 = 1
            while (j < Importer.BATCH_SIZE) {
                if (let Some(msg) <- iterator.next()) {
                    if (!keepImporting(messagesImported)) {
                        break
                    }
                    batch.add(msg)
                    messagesImported++
                    j++
                } else {
                    break
                }
            }

            gmailSyncer.sync(batch)
        }
    }

    func keepImporting(messagesImported: Int64): Bool {
        if (let Some(max) <- commandLineArguments.maxMessages) {
            return messagesImported < max
        }
        true
    }

    // CLI 入口点（等价 Java main）
    public static func run(args: Array<String>): Unit {
        let commandLineArguments = CommandLineArguments.parse(args)
        try {
            commandLineArguments.validate()
        } catch (e: Exception) {
            println("参数验证失败: ${e}")
            println("用法: mail-importer --mailbox <path> --user <email> [--max_messages <n>]")
            return
        }

        let logger = ConsoleLogger("mail-importer")

        // 1. 创建 OAuth2 认证
        let gmailUser = User(commandLineArguments.user)
        let authorizer = Authorizer(gmailUser)

        // 尝试使用已有 token，否则需要交互式授权
        let provider = try {
            authorizer.authorizeWithToken("placeholder-token")
        } catch (e: Exception) {
            logger.info("需要 OAuth2 授权: ${e}")
            return
        }

        // 2. 创建 Gmail HTTP 客户端
        let accessToken = provider.getAccessToken()
        let httpClient = RealGmailHttpClient(accessToken)
        let gmailService = GmailService(httpClient, "mail-importer")

        // 3. 创建 Mailbox
        let mailbox = gmailService.createMailbox(gmailUser)

        // 4. 创建 GmailSyncer
        let gmailSyncer = GmailSyncer(mailbox)

        // 5. 创建 Thunderbird 本地存储
        let statusParser = XMozillaStatusParser()
        let storageProvider = ThunderbirdMailbox(
            logger, commandLineArguments.mailboxFileName, statusParser)

        // 6. 运行导入
        let importer = Importer(logger, storageProvider, gmailSyncer, commandLineArguments)
        importer.importMail()
    }
}
