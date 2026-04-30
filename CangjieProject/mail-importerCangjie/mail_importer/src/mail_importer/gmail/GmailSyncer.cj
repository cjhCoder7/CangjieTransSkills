package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap
import mail_importer.local.LocalMessage
import mail_importer.errorstrategy.ErrorStrategy
import mail_importer.errorstrategy.ErrorStrategyResult
import mail_importer.errorstrategy.Fail

// 核心同步逻辑。connect() 连接 Gmail，sync() 按批次同步消息。
// 上传失败时使用 ErrorStrategy 决定重试/跳过/终止。
public class GmailSyncer {
    let mailbox: Mailbox
    let errorStrategy: ErrorStrategy
    var initialized: Bool = false

    public init(mailbox: Mailbox) {
        this.mailbox = mailbox
        this.errorStrategy = Fail()
    }

    public init(mailbox: Mailbox, errorStrategy: ErrorStrategy) {
        this.mailbox = mailbox
        this.errorStrategy = errorStrategy
    }

    public func connect(): Unit {
        mailbox.connect()
        this.initialized = true
    }

    public func sync(messages: ArrayList<LocalMessage>): Unit {
        if (!initialized) {
            throw IllegalStateException("GmailSyncer.connect() must be called first")
        }

        // 用 messageId 映射，而非 LocalMessage 对象（因为 LocalMessage 不实现 Hashable）
        let map = mailbox.mapMessageIds(messages)

        // 上传 Gmail 中不存在的消息
        for (message in messages) {
            let msgId = message.getMessageId()
            if (!map.contains(msgId)) {
                try {
                    let gmailMessage = mailbox.uploadMessage(message)
                    addToMap(map, msgId, gmailMessage)
                } catch (e: Exception) {
                    let result = errorStrategy.handleError(message, e)
                    handleErrorResult(result, e, message, map, msgId)
                }
            }
        }

        // 获取已有消息的标签
        let allGmailMessages = ArrayList<GmailMessage>()
        for ((_, gmailMessages) in map) {
            for (msg in gmailMessages) {
                allGmailMessages.add(msg)
            }
        }
        mailbox.fetchExistingLabels(allGmailMessages)

        // 同步本地标签到 Gmail
        mailbox.syncLocalLabelsToGmail(map, messages)
    }

    func addToMap(map: HashMap<String, ArrayList<GmailMessage>>,
                  msgId: String, gmailMessage: GmailMessage): Unit {
        if (!map.contains(msgId)) {
            map[msgId] = ArrayList<GmailMessage>()
        }
        if (let Some(list) <- map.get(msgId)) {
            list.add(gmailMessage)
        }
    }

    func handleErrorResult(result: ErrorStrategyResult, e: Exception,
                           message: LocalMessage,
                           map: HashMap<String, ArrayList<GmailMessage>>,
                           msgId: String): Unit {
        match (result) {
            case ErrorStrategyResult.STOP =>
                throw e
            case ErrorStrategyResult.RETRY =>
                retryUpload(message, map, msgId)
            case ErrorStrategyResult.SKIP =>
                ()  // 跳过此消息
        }
    }

    func retryUpload(message: LocalMessage,
                     map: HashMap<String, ArrayList<GmailMessage>>,
                     msgId: String): Unit {
        try {
            let gmailMessage = mailbox.uploadMessage(message)
            addToMap(map, msgId, gmailMessage)
        } catch (e2: Exception) {
            // 重试仍失败，跳过此消息
        }
    }
}
