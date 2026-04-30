package mail_importer.gmail

import std.collection.ArrayList
import mail_importer.gmail.curl.CurlHelper
import mail_importer.gmail.curl.CurlResponse

// 真实 Gmail HTTP 客户端实现。
// 使用 CFFI libcurl 发送 HTTPS 请求，解析 JSON 响应。
public class RealGmailHttpClient <: GmailHttpClient {
    let curlHelper: CurlHelper
    static let BASE_URL: String = "https://gmail.googleapis.com/gmail/v1/users"

    public init(accessToken: String) {
        this.curlHelper = CurlHelper(accessToken)
    }

    func userUrl(userId: String): String {
        "${BASE_URL}/${userId}"
    }

    public func listLabels(userId: String): GmailListLabelsResponse {
        let url = "${userUrl(userId)}/labels"
        let response = curlHelper.httpGet(url)
        checkResponse(response)
        parseListLabelsResponse(response.body)
    }

    public func listMessages(userId: String, query: String): GmailListMessagesResponse {
        // URL encode query 中的特殊字符（简化版）
        let encodedQuery = simpleUrlEncode(query)
        let url = "${userUrl(userId)}/messages?q=${encodedQuery}"
        let response = curlHelper.httpGet(url)
        checkResponse(response)
        parseListMessagesResponse(response.body)
    }

    public func getMessage(userId: String, messageId: String): GmailMessageResponse {
        let url = "${userUrl(userId)}/messages/${messageId}?fields=id,labelIds,threadId"
        let response = curlHelper.httpGet(url)
        checkResponse(response)
        parseMessageResponse(response.body)
    }

    public func importMessage(userId: String, rawBytes: Array<UInt8>): GmailMessageResponse {
        let url = "${userUrl(userId)}/messages/import"
        let response = curlHelper.httpUpload(url, "message/rfc822", rawBytes)
        checkResponse(response)
        parseMessageResponse(response.body)
    }

    public func modifyMessage(userId: String, messageId: String,
        addLabelIds: ArrayList<String>, removeLabelIds: ArrayList<String>): Unit {
        let url = "${userUrl(userId)}/messages/${messageId}/modify"
        let jsonBody = buildModifyRequest(addLabelIds, removeLabelIds)
        let response = curlHelper.httpPostJson(url, jsonBody)
        checkResponse(response)
    }

    public func createLabel(userId: String, name: String): GmailLabelResponse {
        let url = "${userUrl(userId)}/labels"
        let jsonBody = buildCreateLabelRequest(name)
        let response = curlHelper.httpPostJson(url, jsonBody)
        checkResponse(response)
        parseLabelResponse(response.body)
    }

    // 检查 HTTP 响应状态
    func checkResponse(response: CurlResponse): Unit {
        if (response.statusCode == 429) {
            throw GmailApiException(429, "Rate limit exceeded")
        }
        if (!response.isSuccessful()) {
            throw GmailApiException(response.statusCode, response.body)
        }
    }

    // 构建 modify 请求的 JSON body
    func buildModifyRequest(addLabelIds: ArrayList<String>, removeLabelIds: ArrayList<String>): String {
        let sb = StringBuilder()
        sb.append("{\"addLabelIds\":[")
        var first = true
        for (id in addLabelIds) {
            if (!first) { sb.append(",") }
            sb.append("\"${id}\"")
            first = false
        }
        sb.append("],\"removeLabelIds\":[")
        first = true
        for (id in removeLabelIds) {
            if (!first) { sb.append(",") }
            sb.append("\"${id}\"")
            first = false
        }
        sb.append("]}")
        sb.toString()
    }

    // 构建 createLabel 请求的 JSON body
    func buildCreateLabelRequest(name: String): String {
        "{\"name\":\"${escapeJsonString(name)}\",\"labelListVisibility\":\"labelHide\",\"messageListVisibility\":\"show\"}"
    }

    // JSON 字符串转义
    func escapeJsonString(s: String): String {
        let sb = StringBuilder()
        for (ch in s) {
            if (ch == BYTE_QUOTE) {
                sb.append("\\\"")
            } else if (ch == BYTE_BACKSLASH) {
                sb.append("\\\\")
            } else if (ch == BYTE_NEWLINE) {
                sb.append("\\n")
            } else if (ch == BYTE_TAB) {
                sb.append("\\t")
            } else if (ch == BYTE_CR) {
                sb.append("\\r")
            } else {
                sb.append(ch)
            }
        }
        sb.toString()
    }

    // 简易 URL 编码
    func simpleUrlEncode(s: String): String {
        let sb = StringBuilder()
        for (ch in s) {
            if ((ch >= 97 && ch <= 122) || (ch >= 65 && ch <= 90) ||
                (ch >= 48 && ch <= 57) || ch == 45 || ch == 95 ||
                ch == 46 || ch == 126) {
                sb.append(ch)
            } else {
                sb.append("%")
                let hexChars = "0123456789ABCDEF"
                sb.append(hexChars[Int64(ch >> 4)])
                sb.append(hexChars[Int64(ch & 0x0F)])
            }
        }
        sb.toString()
    }
}
