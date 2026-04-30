package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap

// 内存实现的 Gmail HTTP 客户端，用于测试 Mailbox 业务逻辑。
// 所有数据存储在内存中的 HashMap 中。
public class StubGmailHttpClient <: GmailHttpClient {
    var labelIdCounter: Int64 = 0
    var messageIdCounter: Int64 = 0
    var labelsById: HashMap<String, GmailLabelResponse> = HashMap<String, GmailLabelResponse>()
    var messagesById: HashMap<String, GmailMessageResponse> = HashMap<String, GmailMessageResponse>()
    // messageId -> rfc822msgid
    var messageRfc822Ids: HashMap<String, String> = HashMap<String, String>()
    // rfc822msgid -> ArrayList<messageId>
    var rfc822ToMessageIds: HashMap<String, ArrayList<String>> = HashMap<String, ArrayList<String>>()

    // 记录调用次数，用于断言
    public var listLabelsCallCount: Int64 = 0
    public var listMessagesCallCount: Int64 = 0
    public var importMessageCallCount: Int64 = 0
    public var modifyMessageCallCount: Int64 = 0
    public var createLabelCallCount: Int64 = 0

    // 429 重试控制
    public var nextModifyStatusCode: Int64 = 0  // 0 表示正常，429 表示限流

    public init() {
        // 预置 Gmail 内置标签
        addBuiltInLabel("INBOX", "INBOX")
        addBuiltInLabel("SPAM", "SPAM")
        addBuiltInLabel("TRASH", "TRASH")
        addBuiltInLabel("UNREAD", "UNREAD")
        addBuiltInLabel("STARRED", "STARRED")
        addBuiltInLabel("DRAFTS", "DRAFTS")
        addBuiltInLabel("SENT", "SENT")
        addBuiltInLabel("CATEGORY_PERSONAL", "CATEGORY_PERSONAL")
    }

    func addBuiltInLabel(id: String, name: String): Unit {
        labelsById[id] = GmailLabelResponse(id, name)
    }

    func nextLabelId(): String {
        labelIdCounter++
        "label_${labelIdCounter}"
    }

    func nextMessageId(): String {
        messageIdCounter++
        "msg_${messageIdCounter}"
    }

    public func listLabels(userId: String): GmailListLabelsResponse {
        listLabelsCallCount++
        let labels = ArrayList<GmailLabelResponse>()
        for ((_, label) in labelsById) {
            labels.add(label)
        }
        GmailListLabelsResponse(labels)
    }

    public func listMessages(userId: String, query: String): GmailListMessagesResponse {
        listMessagesCallCount++
        // 解析 rfc822msgid:<id> 查询
        let prefix = "rfc822msgid:"
        if (query.startsWith(prefix) && query.size > prefix.size) {
            let rfc822Id = query[prefix.size..]
            if (let Some(messageIds) <- rfc822ToMessageIds.get(rfc822Id)) {
                let refs = ArrayList<GmailMessageRef>()
                for (msgId in messageIds) {
                    refs.add(GmailMessageRef(msgId))
                }
                return GmailListMessagesResponse(refs)
            }
        }
        GmailListMessagesResponse()
    }

    public func getMessage(userId: String, messageId: String): GmailMessageResponse {
        if (let Some(msg) <- messagesById.get(messageId)) {
            msg
        } else {
            GmailMessageResponse(messageId)
        }
    }

    public func importMessage(userId: String, rawBytes: Array<UInt8>): GmailMessageResponse {
        importMessageCallCount++
        let msgId = nextMessageId()
        let msg = GmailMessageResponse(msgId)

        // 从原始字节中提取 Message-ID 头部（简化版）
        let rfc822Id = extractMessageIdFromBytes(rawBytes)
        if (!rfc822Id.isEmpty()) {
            messageRfc822Ids[msgId] = rfc822Id
            if (!rfc822ToMessageIds.contains(rfc822Id)) {
                rfc822ToMessageIds[rfc822Id] = ArrayList<String>()
            }
            if (let Some(list) <- rfc822ToMessageIds.get(rfc822Id)) {
                list.add(msgId)
            }
        }

        messagesById[msgId] = msg
        msg
    }

    public func modifyMessage(userId: String, messageId: String,
        addLabelIds: ArrayList<String>, removeLabelIds: ArrayList<String>): Unit {
        modifyMessageCallCount++

        if (nextModifyStatusCode == 429) {
            nextModifyStatusCode = 0  // 重置，下次正常
            throw GmailApiException(429, "Rate limit exceeded")
        }

        if (let Some(msg) <- messagesById.get(messageId)) {
            for (labelId in addLabelIds) {
                if (!msg.labelIds.contains(labelId)) {
                    msg.labelIds.add(labelId)
                }
            }
            // 保留不在移除列表中的标签
            let kept = ArrayList<String>()
            for (labelId in msg.labelIds) {
                if (!removeLabelIds.contains(labelId)) {
                    kept.add(labelId)
                }
            }
            msg.labelIds = kept
        }
    }

    public func createLabel(userId: String, name: String): GmailLabelResponse {
        createLabelCallCount++
        let id = nextLabelId()
        let label = GmailLabelResponse(id, name)
        labelsById[id] = label
        label
    }

    // 从原始字节中提取 Message-ID 头部
    func extractMessageIdFromBytes(bytes: Array<UInt8>): String {
        // 查找 "Message-ID:" 头部
        let target = [77, 101, 115, 115, 97, 103, 101, 45, 73, 68, 58]  // "Message-ID:"
        var pos = 0
        while (pos <= bytes.size - target.size) {
            var found = true
            var j = 0
            while (j < target.size && found) {
                if (Int64(bytes[pos + j]) != target[j]) {
                    found = false
                }
                j++
            }
            if (found) {
                // 找到了，提取到行尾
                var end = pos + target.size
                while (end < bytes.size && bytes[end] != 10) {
                    end++
                }
                let headerValue = bytesToString(bytes, Int64(pos + target.size), Int64(end))
                return headerValue.trimAscii()
            }
            pos++
        }
        ""
    }

    func bytesToString(bytes: Array<UInt8>, start: Int64, end: Int64): String {
        let arr = ArrayList<UInt8>()
        var i = start
        while (i < end && i < bytes.size) {
            arr.add(bytes[i])
            i++
        }
        String.fromUtf8(arr.toArray())
    }

    // 测试辅助：添加已有消息
    public func addExistingMessage(messageId: String, rfc822Id: String, labelIds: ArrayList<String>): Unit {
        let msg = GmailMessageResponse(messageId, labelIds)
        messagesById[messageId] = msg
        messageRfc822Ids[messageId] = rfc822Id
        if (!rfc822ToMessageIds.contains(rfc822Id)) {
            rfc822ToMessageIds[rfc822Id] = ArrayList<String>()
        }
        if (let Some(list) <- rfc822ToMessageIds.get(rfc822Id)) {
            list.add(messageId)
        }
    }
}
