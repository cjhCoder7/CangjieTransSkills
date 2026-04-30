package mail_importer.local

import std.collection.ArrayList

// Folder 常量（对应 javax.mail.Folder 的 HOLDS_MESSAGES / HOLDS_FOLDERS）
public class FolderConstants {
    public static let HOLDS_MESSAGES: Int64 = 1
    public static let HOLDS_FOLDERS: Int64 = 2
    public static let READ_ONLY: Int64 = 1
    public static let READ_WRITE: Int64 = 2
}

// JavaxMailStorage 的等价实现，提供前序遍历文件夹树的迭代器
// 注意：仓颉不支持嵌套类，迭代器类作为顶层类定义
public abstract class MailStorage <: LocalMessageStorage {
    protected let logger: SimpleLogger
    protected let root: MailFolder

    public init(logger: SimpleLogger, root: MailFolder) {
        this.logger = logger
        this.root = root
    }

    public func iterator(): Iterator<LocalMessage> {
        FolderIterator(root, this)
    }

    public open func filterFolders(iterator: Iterator<MailFolder>): Iterator<MailFolder> {
        iterator
    }

    public open func createLocalMessage(message: MailMessage): LocalMessage {
        throw Exception("createLocalMessage must be overridden")
    }
}

// 文件夹前序遍历迭代器
class FolderIterator <: Iterator<LocalMessage> {
    let folder: MailFolder
    var messageIterator: Iterator<LocalMessage>
    var subfolderIterator: Iterator<LocalMessage>

    init(folder: MailFolder, outer: MailStorage) {
        this.folder = folder
        if (!folder.isOpen()) {
            folder.open(FolderConstants.READ_ONLY)
        }
        if ((folder.getType() & FolderConstants.HOLDS_MESSAGES) > 0) {
            this.messageIterator = MessageIterator(folder, outer)
        } else {
            this.messageIterator = EmptyIterator<LocalMessage>()
        }
        if ((folder.getType() & FolderConstants.HOLDS_FOLDERS) > 0) {
            this.subfolderIterator = SubfolderIterator(folder, outer)
        } else {
            this.subfolderIterator = EmptyIterator<LocalMessage>()
        }
    }

    public func next(): Option<LocalMessage> {
        if (let Some(msg) <- messageIterator.next()) {
            return Some(msg)
        }
        if (let Some(msg) <- subfolderIterator.next()) {
            return Some(msg)
        }
        None
    }
}

// 消息迭代器
class MessageIterator <: Iterator<LocalMessage> {
    let folder: MailFolder
    let messageCount: Int64
    var nextMessage: Int64
    let outer: MailStorage

    init(folder: MailFolder, outer: MailStorage) {
        this.folder = folder
        this.messageCount = folder.getMessageCount()
        this.nextMessage = 1
        this.outer = outer
    }

    public func next(): Option<LocalMessage> {
        if (nextMessage <= messageCount) {
            let currentMessage = nextMessage
            nextMessage++
            let message = folder.getMessage(currentMessage)
            return Some(outer.createLocalMessage(message))
        }
        None
    }
}

// 子文件夹迭代器
class SubfolderIterator <: Iterator<LocalMessage> {
    var folderIterator: Iterator<MailFolder>
    var currentMessageIterator: Iterator<LocalMessage>
    let outer: MailStorage

    init(folder: MailFolder, outer: MailStorage) {
        let subFolders = folder.list()
        let list = ArrayList<MailFolder>()
        for (f in subFolders) {
            list.add(f)
        }
        this.folderIterator = outer.filterFolders(list.iterator())
        this.currentMessageIterator = EmptyIterator<LocalMessage>()
        this.outer = outer
    }

    public func next(): Option<LocalMessage> {
        // 先尝试当前子文件夹中的消息
        let currentResult = currentMessageIterator.next()
        if (let Some(msg) <- currentResult) {
            return Some(msg)
        }
        // 尝试推进到下一个子文件夹
        if (let Some(subFolder) <- folderIterator.next()) {
            currentMessageIterator = FolderIterator(subFolder, outer)
            return next()
        }
        None
    }
}

class EmptyIterator<T> <: Iterator<T> {
    public func next(): Option<T> {
        None
    }
}
