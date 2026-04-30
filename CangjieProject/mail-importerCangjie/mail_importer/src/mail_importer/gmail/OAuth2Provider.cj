package mail_importer.gmail

// OAuth2 访问令牌提供者接口
public interface OAuth2Provider {
    func getAccessToken(): String
}
