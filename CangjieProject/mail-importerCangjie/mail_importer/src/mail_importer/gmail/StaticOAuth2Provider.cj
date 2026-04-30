package mail_importer.gmail

// 测试用 OAuth2 提供者：返回固定 token
public class StaticOAuth2Provider <: OAuth2Provider {
    let token: String

    public init(token: String) {
        this.token = token
    }

    public func getAccessToken(): String {
        token
    }
}
