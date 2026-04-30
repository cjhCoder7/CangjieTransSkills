package mail_importer.local.thunderbird

import mail_importer.local.SimpleLogger
import mail_importer.local.MailFolder
import mail_importer.local.MailMessage
import mail_importer.local.MailStorage
import mail_importer.local.LocalMessage

public class ThunderbirdMailStorage <: MailStorage {
    let statusParser: XMozillaStatusParser

    public init(logger: SimpleLogger, store: MailFolder, statusParser: XMozillaStatusParser) {
        super(logger, store)
        this.statusParser = statusParser
    }

    public func filterFolders(iterator: Iterator<MailFolder>): Iterator<MailFolder> {
        FilteredFolderIterator(iterator)
    }

    public func createLocalMessage(message: MailMessage): LocalMessage {
        ThunderbirdLocalMessage(message, { folder => relativize(folder) }, statusParser)
    }

    public func relativize(folder: String): String {
        let rootFullName = root.getFullName()
        var result = folder
        if (folder.startsWith(rootFullName)) {
            // 仓颉 String 切片使用 [start..end] 语法
            let startIdx = rootFullName.size + 1
            result = folder[startIdx..]
        }
        result.replace(".sbd", "")
    }
}

class FilteredFolderIterator <: Iterator<MailFolder> {
    var inner: Iterator<MailFolder>
    var nextItem: ?MailFolder = None

    init(inner: Iterator<MailFolder>) {
        this.inner = inner
        advance()
    }

    func advance(): Unit {
        while (let Some(f) <- inner.next()) {
            if (!f.getName().contains("@")) {
                nextItem = Some(f)
                return
            }
        }
        nextItem = None
    }

    public func next(): Option<MailFolder> {
        if (let Some(item) <- nextItem) {
            nextItem = None
            advance()
            return Some(item)
        }
        None
    }
}
