package mail_importer.gmail

// CFFI: time() 函数
foreign {
    func time(timer: CPointer<Int64>): Int64
}

// OAuth2 Token 数据类
public class OAuth2Token {
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Int64       // 秒
    public var obtainedAt: Int64      // 获取时的 epoch 毫秒
    public var tokenType: String

    public init(accessToken: String, refreshToken: String,
                expiresIn: Int64, obtainedAt: Int64) {
        this.accessToken = accessToken
        this.refreshToken = refreshToken
        this.expiresIn = expiresIn
        this.obtainedAt = obtainedAt
        this.tokenType = "Bearer"
    }

    // 判断 token 是否已过期（提前 60 秒认为过期）
    public func isExpired(): Bool {
        let now = OAuth2Token.getCurrentTimeMs()
        now > obtainedAt + (expiresIn - 60) * 1000
    }

    // 获取当前时间（毫秒）
    public static func getCurrentTimeMs(): Int64 {
        let seconds = unsafe { time(CPointer<Int64>()) }
        seconds * 1000
    }
}
