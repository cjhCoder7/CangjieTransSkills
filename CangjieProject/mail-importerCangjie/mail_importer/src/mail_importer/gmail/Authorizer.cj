package mail_importer.gmail

// OAuth2 授权器。封装授权流程，创建 OAuth2Provider。
public class Authorizer {
    let user: User
    var provider: Option<OAuth2Provider> = None

    public init(user: User) {
        this.user = user
    }

    // 使用 client_secret.json 文件中的信息创建 OAuth2 提供者
    public func authorize(clientId: String, clientSecret: String): OAuth2Provider {
        let fileProvider = FileBasedOAuth2Provider(clientId, clientSecret, user.getEmailAddress())

        // 尝试加载已有 token
        try {
            fileProvider.getAccessToken()
        } catch (e: Exception) {
            // 需要重新授权
            fileProvider.authorize()
        }

        this.provider = Some(fileProvider)
        fileProvider
    }

    // 使用已有的 access token 创建静态提供者
    public func authorizeWithToken(accessToken: String): OAuth2Provider {
        let staticProvider = StaticOAuth2Provider(accessToken)
        this.provider = Some(staticProvider)
        staticProvider
    }

    // 获取当前提供者
    public func getProvider(): OAuth2Provider {
        if (let Some(p) <- provider) {
            p
        } else {
            throw Exception("尚未授权：请先调用 authorize() 或 authorizeWithToken()")
        }
    }
}
