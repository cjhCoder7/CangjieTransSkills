package mail_importer.gmail

// Gmail 服务：持有 HTTP 客户端和用户信息，构造 Mailbox 实例。
public class GmailService {
    let httpClient: GmailHttpClient
    let retryHelper: GmailRetryHelper
    let appName: String

    public init(httpClient: GmailHttpClient, appName: String) {
        this.httpClient = httpClient
        this.retryHelper = GmailRetryHelper()
        this.appName = appName
    }

    public init(httpClient: GmailHttpClient, retryHelper: GmailRetryHelper, appName: String) {
        this.httpClient = httpClient
        this.retryHelper = retryHelper
        this.appName = appName
    }

    public func createMailbox(user: User): Mailbox {
        Mailbox(httpClient, user, retryHelper)
    }
}
