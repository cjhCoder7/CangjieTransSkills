package mail_importer.local.thunderbird

import mail_importer.local.SimpleLogger
import mail_importer.local.MailProvider
import mail_importer.local.LocalMessageStorage
import mail_importer.local.mbox.MboxDirectoryScanner

// 读取 Thunderbird 邮箱
// 使用 MboxDirectoryScanner 扫描 Thunderbird 目录结构并解析 mbox 文件
public class ThunderbirdMailbox <: MailProvider<LocalMessageStorage> {
    let logger: SimpleLogger
    let mailboxFileName: String
    let statusParser: XMozillaStatusParser

    public init(logger: SimpleLogger, mailboxFileName: String, statusParser: XMozillaStatusParser) {
        this.logger = logger
        this.mailboxFileName = mailboxFileName
        this.statusParser = statusParser
    }

    public func get(): LocalMessageStorage {
        let scanner = MboxDirectoryScanner()
        let rootFolder = scanner.scan(mailboxFileName)
        ThunderbirdMailStorage(logger, rootFolder, statusParser)
    }
}
