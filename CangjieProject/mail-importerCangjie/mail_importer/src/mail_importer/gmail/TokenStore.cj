package mail_importer.gmail

import std.fs.*
import std.collection.ArrayList
import std.collection.HashMap

// CFFI: getenv
foreign {
    func getenv(name: CString): CString
}

// Token 持久化存储。
// 读写 ~/.mailimporter/credentials/ 目录下的 token 文件。
public class TokenStore {
    let storeDir: String

    public init() {
        this.storeDir = "/tmp/.mailimporter/credentials"
    }

    public init(storeDir: String) {
        this.storeDir = storeDir
    }

    // 延迟初始化 home 目录
    func getEffectiveStoreDir(): String {
        if (storeDir == "/tmp/.mailimporter/credentials") {
            let home = getHomeDir()
            if (!home.isEmpty() && home != "/tmp") {
                return home + "/.mailimporter/credentials"
            }
        }
        storeDir
    }

    // 保存 token
    public func saveToken(userId: String, token: OAuth2Token): Unit {
        let dir = getEffectiveStoreDir()
        ensureDirExists(dir)
        let filePath = "${dir}/${sanitizeFileName(userId)}.token"
        let content = serializeToken(token)
        File.writeTo(filePath, content.toArray())
    }

    // 加载 token
    public func loadToken(userId: String): Option<OAuth2Token> {
        let dir = getEffectiveStoreDir()
        let filePath = "${dir}/${sanitizeFileName(userId)}.token"
        let content = try {
            File.readFrom(filePath)
        } catch (e: Exception) {
            return None
        }
        let text = bytesToString(content)
        deserializeToken(text)
    }

    // 序列化 token 为文本格式
    func serializeToken(token: OAuth2Token): String {
        "accessToken=${token.accessToken}\nrefreshToken=${token.refreshToken}\nexpiresIn=${token.expiresIn}\nobtainedAt=${token.obtainedAt}\ntokenType=${token.tokenType}"
    }

    // 反序列化
    func deserializeToken(text: String): Option<OAuth2Token> {
        let map = HashMap<String, String>()
        for (line in text.split("\n")) {
            if (let Some(eqPos) <- line.indexOf("=")) {
                let key = line[0..eqPos]
                let value = line[eqPos + 1..]
                map[key] = value
            }
        }
        if (let Some(accessToken) <- map.get("accessToken")) {
            if (let Some(refreshToken) <- map.get("refreshToken")) {
                let expiresIn = if (let Some(v) <- map.get("expiresIn")) { parseInt64(v) } else { 3600 }
                let obtainedAt = if (let Some(v) <- map.get("obtainedAt")) { parseInt64(v) } else { 0 }
                return Some(OAuth2Token(accessToken, refreshToken, expiresIn, obtainedAt))
            }
        }
        None
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

    func getHomeDir(): String {
        try {
            let homeCStr = unsafe { LibC.mallocCString("HOME") }
            let home = unsafe { getenv(homeCStr) }
            unsafe { LibC.free(homeCStr) }
            if (!home.isNull()) {
                let result = home.toString()
                if (!result.isEmpty()) {
                    return result
                }
            }
        } catch (e: Exception) {
        }
        "/tmp"
    }

    func sanitizeFileName(name: String): String {
        let sb = StringBuilder()
        for (ch in name) {
            if ((ch >= 48 && ch <= 57) || (ch >= 65 && ch <= 90) ||
                (ch >= 97 && ch <= 122) || ch == 45 || ch == 46 || ch == 95) {
                sb.append(ch)
            } else {
                sb.append("_")
            }
        }
        sb.toString()
    }

    func ensureDirExists(dirPath: String): Unit {
        // 递归创建目录
        let parts = dirPath.split("/")
        var current = ""
        for (part in parts) {
            if (!part.isEmpty()) {
                current = current + "/" + part
                try {
                    Directory.create(current)
                } catch (e: Exception) {
                    // 目录已存在
                }
            }
        }
    }

    func bytesToString(bytes: Array<Byte>): String {
        let arr = ArrayList<UInt8>()
        for (b in bytes) {
            arr.add(UInt8(b))
        }
        String.fromUtf8(arr.toArray())
    }
}
