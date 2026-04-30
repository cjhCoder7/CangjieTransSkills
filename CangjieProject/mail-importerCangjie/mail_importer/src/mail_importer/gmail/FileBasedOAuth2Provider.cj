package mail_importer.gmail

import std.collection.ArrayList
import mail_importer.gmail.curl.CurlHelper
import mail_importer.gmail.curl.CurlResponse

// CFFI: fgets() 和 stdin
foreign {
    func fgets(str: CPointer<UInt8>, num: Int32, stream: CPointer<Unit>): CPointer<UInt8>
}

foreign {
    func cjangjie_get_stdin(): CPointer<Unit>
}

// 基于 client_secret.json 文件的 OAuth2 认证提供者。
// 支持授权码流程和 token 刷新。
public class FileBasedOAuth2Provider <: OAuth2Provider {
    let clientId: String
    let clientSecret: String
    let redirectUri: String
    let tokenStore: TokenStore
    let userId: String
    var currentToken: Option<OAuth2Token> = None

    static let TOKEN_URL: String = "https://oauth2.googleapis.com/token"
    static let AUTH_URL: String = "https://accounts.google.com/o/oauth2/v2/auth"
    static let SCOPE: String = "https://www.googleapis.com/auth/gmail.modify https://www.googleapis.com/auth/gmail.readonly"

    public init(clientId: String, clientSecret: String, userId: String) {
        this.clientId = clientId
        this.clientSecret = clientSecret
        this.redirectUri = "http://localhost:8080/oauth2callback"
        this.tokenStore = TokenStore()
        this.userId = userId
    }

    public func getAccessToken(): String {
        // 1. 检查内存中的 token
        if (let Some(token) <- currentToken) {
            if (!token.isExpired()) {
                return token.accessToken
            }
        }

        // 2. 检查持久化的 token
        if (let Some(token) <- tokenStore.loadToken(userId)) {
            if (!token.isExpired()) {
                currentToken = Some(token)
                return token.accessToken
            }
            // token 过期，尝试刷新
            if (let Some(refreshed) <- refreshToken(token.refreshToken)) {
                currentToken = Some(refreshed)
                tokenStore.saveToken(userId, refreshed)
                return refreshed.accessToken
            }
        }

        // 3. 需要重新授权
        throw Exception("需要重新授权：请运行授权流程获取新的 access token")
    }

    // 启动授权码流程（需要用户在浏览器中操作）
    public func authorize(): Unit {
        let authUrl = buildAuthUrl()
        println("请在浏览器中打开以下 URL 进行授权：")
        println(authUrl)
        println("")
        println("授权后请输入回调 URL 中的 code 参数：")

        // 读取用户输入的授权码
        let code = readLine()
        if (code.isEmpty()) {
            throw Exception("未输入授权码")
        }

        // 用授权码换取 token
        if (let Some(token) <- exchangeCodeForToken(code)) {
            currentToken = Some(token)
            tokenStore.saveToken(userId, token)
        } else {
            throw Exception("授权码换取 token 失败")
        }
    }

    // 构建授权 URL
    func buildAuthUrl(): String {
        "${AUTH_URL}?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=${SCOPE}&access_type=offline&prompt=consent"
    }

    // 用授权码换取 token
    func exchangeCodeForToken(code: String): Option<OAuth2Token> {
        let curlHelper = CurlHelper("")
        let body = "code=${code}&client_id=${clientId}&client_secret=${clientSecret}&redirect_uri=${redirectUri}&grant_type=authorization_code"
        let response = curlHelper.httpPostJson(TOKEN_URL, body)

        if (!response.isSuccessful()) {
            return None
        }

        parseTokenResponse(response.body)
    }

    // 刷新 token
    func refreshToken(refreshToken: String): Option<OAuth2Token> {
        let curlHelper = CurlHelper("")
        let body = "refresh_token=${refreshToken}&client_id=${clientId}&client_secret=${clientSecret}&grant_type=refresh_token"
        let response = curlHelper.httpPostJson(TOKEN_URL, body)

        if (!response.isSuccessful()) {
            return None
        }

        if (let Some(token) <- parseTokenResponse(response.body)) {
            if (token.refreshToken.isEmpty()) {
                return Some(OAuth2Token(token.accessToken, refreshToken,
                    token.expiresIn, token.obtainedAt))
            }
            return Some(token)
        }
        None
    }

    // 解析 token 响应 JSON
    func parseTokenResponse(json: String): Option<OAuth2Token> {
        let accessToken = extractJsonValue(json, "access_token")
        let refreshTokenVal = extractJsonValue(json, "refresh_token")
        let expiresInStr = extractJsonValue(json, "expires_in")

        if (accessToken.isEmpty()) {
            return None
        }

        let expiresIn = if (expiresInStr.isEmpty()) { 3600 } else { parseInt64(expiresInStr) }
        let now = OAuth2Token.getCurrentTimeMs()

        Some(OAuth2Token(accessToken, refreshTokenVal, expiresIn, now))
    }

    // 从 JSON 中提取字符串值
    func extractJsonValue(json: String, key: String): String {
        let searchKey = "\"${key}\""
        if (let Some(keyPos) <- json.indexOf(searchKey)) {
            var pos = keyPos + searchKey.size
            while (pos < json.size && json[pos] != 58) {
                pos++
            }
            if (pos >= json.size) {
                return ""
            }
            pos++
            while (pos < json.size && (json[pos] == 32 || json[pos] == 9 ||
                   json[pos] == 10 || json[pos] == 13)) {
                pos++
            }
            if (pos < json.size && json[pos] == 34) {
                pos++
                let start = pos
                while (pos < json.size && json[pos] != 34) {
                    if (json[pos] == 92 && pos + 1 < json.size) {
                        pos += 2
                    } else {
                        pos++
                    }
                }
                return json[start..pos]
            }
        }
        ""
    }

    func parseInt64(s: String): Int64 {
        var result: Int64 = 0
        for (ch in s) {
            if (ch >= 48 && ch <= 57) {
                result = result * 10 + Int64(ch - 48)
            }
        }
        result
    }

    // 从标准输入读取一行
    func readLine(): String {
        try {
            // 分配缓冲区并从 stdin 读取
            let bufSize: Int64 = 256
            let buf = LibC.malloc<UInt8>(count: bufSize)
            unsafe {
                let stdinPtr = cjangjie_get_stdin()
                let result = fgets(buf, Int32(bufSize - 1), stdinPtr)
                if (result.isNull()) {
                    LibC.free(CPointer<Unit>(buf))
                    return ""
                }
            }
            // 将 C 字符串转为 Cangjie String
            let cStr = unsafe { CString(buf) }
            let line = cStr.toString().trimAscii()
            unsafe { LibC.free(CPointer<Unit>(buf)) }
            line
        } catch (e: Exception) {
            ""
        }
    }
}
