package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap
import std.collection.HashSet
import mail_importer.local.LocalMessage

// Gmail 邮箱 API 封装。
// 通过 GmailHttpClient 接口调用 Gmail REST API，便于测试时替换。
public open class Mailbox {
    static let TOO_MANY_CONCURRENT_REQUESTS_FOR_USER: Int64 = 429

    let httpClient: GmailHttpClient
    let user: User
    let retryHelper: GmailRetryHelper

    var labelsById: HashMap<String, GmailLabel> = HashMap<String, GmailLabel>()
    var labelsByName: HashMap<String, GmailLabel> = HashMap<String, GmailLabel>()

    public init(httpClient: GmailHttpClient, user: User) {
        this.httpClient = httpClient
        this.user = user
        this.retryHelper = GmailRetryHelper()
    }

    public init(httpClient: GmailHttpClient, user: User, retryHelper: GmailRetryHelper) {
        this.httpClient = httpClient
        this.user = user
        this.retryHelper = retryHelper
    }

    public open func connect(): Unit {
        loadLabels()
    }

    // 加载用户标签，建立 id->Label 和 name->Label 映射
    public open func loadLabels(): Unit {
        let response = httpClient.listLabels(user.getEmailAddress())
        for (labelResp in response.labels) {
            let label = GmailLabel(labelResp.id, labelResp.name)
            labelsById[label.id] = label
            labelsByName[label.name] = label
        }
    }

    // 通过 RFC822 Message-ID 映射本地消息到 Gmail 消息
    // 返回 HashMap<messageId, ArrayList<GmailMessage>>
    public open func mapMessageIds(localMessages: ArrayList<LocalMessage>): HashMap<String, ArrayList<GmailMessage>> {
        let results = HashMap<String, ArrayList<GmailMessage>>()
        for (localMessage in localMessages) {
            let rfc822Id = localMessage.getMessageId()
            let query = "rfc822msgid:${rfc822Id}"
            let response = httpClient.listMessages(user.getEmailAddress(), query)
            if (response.messages.size > 0) {
                let gmailMessages = ArrayList<GmailMessage>()
                for (ref in response.messages) {
                    gmailMessages.add(GmailMessage(ref.id))
                }
                results[rfc822Id] = gmailMessages
            }
        }
        results
    }

    // 获取已有 Gmail 消息的标签
    public open func fetchExistingLabels(messages: ArrayList<GmailMessage>): Unit {
        for (gmailMessage in messages) {
            let response = httpClient.getMessage(user.getEmailAddress(), gmailMessage.id)
            gmailMessage.labelIds = ArrayList<String>()
            for (labelId in response.labelIds) {
                gmailMessage.labelIds.add(labelId)
            }
        }
    }

    // 上传本地消息到 Gmail
    public open func uploadMessage(localMessage: LocalMessage): GmailMessage {
        let rawBytes = localMessage.getRawContent()
        let response = httpClient.importMessage(user.getEmailAddress(), rawBytes)
        GmailMessage(response.id)
    }

    // 同步本地标签到 Gmail
    public open func syncLocalLabelsToGmail(map: HashMap<String, ArrayList<GmailMessage>>, localMessages: ArrayList<LocalMessage>): Unit {
        createMissingLabels(localMessages)
        syncLabels(map, localMessages)
    }

    public func normalizeLabelName(localLabel: String): String {
        let upper = localLabel.toAsciiUpper()
        if (upper == "INBOX") {
            return "INBOX"
        }
        if (upper == "DRAFTS") {
            return "Import/Drafts"
        }
        if (upper == "TRASH") {
            return "TRASH"
        }
        if (upper == "SPAM") {
            return "SPAM"
        }
        localLabel
    }

    // 同步标签：为每条 Gmail 消息添加/移除标签
    func syncLabels(
        map: HashMap<String, ArrayList<GmailMessage>>,
        localMessages: ArrayList<LocalMessage>
    ): Unit {
        for (localMessage in localMessages) {
            let msgId = localMessage.getMessageId()
            if (let Some(gmailMessages) <- map.get(msgId)) {
                for (gmailMessage in gmailMessages) {
                    let labelNamesToAdd = HashSet<String>()
                    for (folder in localMessage.getFolders()) {
                        labelNamesToAdd.add(normalizeLabelName(folder))
                    }

                    let labelNamesToRemove = HashSet<String>()
                    labelNamesToRemove.add("SPAM")
                    labelNamesToRemove.add("TRASH")
                    for (label in labelNamesToAdd) {
                        labelNamesToRemove.remove(label)
                    }

                    if (localMessage.isStarred()) {
                        labelNamesToAdd.add("STARRED")
                        labelNamesToRemove.remove("STARRED")
                    }
                    if (localMessage.isUnread()) {
                        labelNamesToAdd.add("UNREAD")
                        labelNamesToRemove.remove("UNREAD")
                    } else {
                        labelNamesToRemove.add("UNREAD")
                        labelNamesToAdd.remove("UNREAD")
                    }

                    if (!labelNamesToAdd.contains("INBOX")) {
                        labelNamesToRemove.add("INBOX")
                        labelNamesToAdd.remove("INBOX")
                    }

                    let labelIdsToAdd = ArrayList<String>()
                    for (name in labelNamesToAdd) {
                        if (let Some(label) <- labelsByName.get(name)) {
                            labelIdsToAdd.add(label.id)
                        }
                    }

                    let labelIdsToRemove = ArrayList<String>()
                    for (name in labelNamesToRemove) {
                        if (let Some(label) <- labelsByName.get(name)) {
                            labelIdsToRemove.add(label.id)
                        }
                    }

                    if (labelIdsToAdd.size > 0 || labelIdsToRemove.size > 0) {
                        retryHelper.executeWithRetry({ =>
                            httpClient.modifyMessage(
                                user.getEmailAddress(), gmailMessage.id,
                                labelIdsToAdd, labelIdsToRemove)
                        })
                    }
                }
            }
        }
    }

    // 创建 Gmail 中尚不存在的标签
    func createMissingLabels(localMessages: ArrayList<LocalMessage>): Unit {
        let missingLabels = HashSet<String>()
        for (localMessage in localMessages) {
            for (folder in localMessage.getFolders()) {
                let upper = folder.toAsciiUpper()
                if (upper != "INBOX") {
                    if (!labelsByName.contains(folder)) {
                        missingLabels.add(folder)
                    }
                }
            }
        }

        for (label in missingLabels) {
            let response = httpClient.createLabel(user.getEmailAddress(), label)
            let newLabel = GmailLabel(response.id, response.name)
            labelsById[newLabel.id] = newLabel
            labelsByName[newLabel.name] = newLabel
        }
    }
}
