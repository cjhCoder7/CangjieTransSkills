package mail_importer.gmail

import std.collection.ArrayList

// Gmail REST API HTTP 客户端接口。
// 抽象出所有 Gmail API 调用，便于测试时替换为内存实现。
public interface GmailHttpClient {
    // GET /gmail/v1/users/{userId}/labels
    func listLabels(userId: String): GmailListLabelsResponse

    // GET /gmail/v1/users/{userId}/messages?q=...
    func listMessages(userId: String, query: String): GmailListMessagesResponse

    // GET /gmail/v1/users/{userId}/messages/{id}?fields=id,labelIds
    func getMessage(userId: String, messageId: String): GmailMessageResponse

    // POST /gmail/v1/users/{userId}/messages/import (media upload)
    func importMessage(userId: String, rawBytes: Array<UInt8>): GmailMessageResponse

    // POST /gmail/v1/users/{userId}/messages/{id}/modify
    func modifyMessage(userId: String, messageId: String,
        addLabelIds: ArrayList<String>, removeLabelIds: ArrayList<String>): Unit

    // POST /gmail/v1/users/{userId}/labels
    func createLabel(userId: String, name: String): GmailLabelResponse
}

// API 响应类型

public class GmailListLabelsResponse {
    public var labels: ArrayList<GmailLabelResponse>

    public init() {
        this.labels = ArrayList<GmailLabelResponse>()
    }

    public init(labels: ArrayList<GmailLabelResponse>) {
        this.labels = labels
    }
}

public class GmailLabelResponse {
    public var id: String
    public var name: String

    public init(id: String, name: String) {
        this.id = id
        this.name = name
    }
}

public class GmailListMessagesResponse {
    public var messages: ArrayList<GmailMessageRef>

    public init() {
        this.messages = ArrayList<GmailMessageRef>()
    }

    public init(messages: ArrayList<GmailMessageRef>) {
        this.messages = messages
    }
}

public class GmailMessageRef {
    public var id: String

    public init(id: String) {
        this.id = id
    }
}

public class GmailMessageResponse {
    public var id: String
    public var labelIds: ArrayList<String>
    public var threadId: String

    public init(id: String) {
        this.id = id
        this.labelIds = ArrayList<String>()
        this.threadId = ""
    }

    public init(id: String, labelIds: ArrayList<String>) {
        this.id = id
        this.labelIds = labelIds
        this.threadId = ""
    }
}

// Gmail API 异常
public class GmailApiException <: Exception {
    public var statusCode: Int64
    public var errorBody: String

    public init(statusCode: Int64, errorBody: String) {
        super(errorBody)
        this.statusCode = statusCode
        this.errorBody = errorBody
    }
}
