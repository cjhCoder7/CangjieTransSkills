package mail_importer.gmail

public class User {
    let emailAddress: String

    public init(emailAddress: String) {
        this.emailAddress = emailAddress
    }

    public func getEmailAddress(): String {
        emailAddress
    }

    // TODO: 替换为 std.encoding.base64.Base64.encodeStr 当 stdx 可用时
    public func getEmailAddressAsKey(): String {
        simpleBase64Encode(emailAddress)
    }
}

// 简易 Base64 编码（仅用于 key 生成，待 stdx 可用后替换）
func simpleBase64Encode(input: String): String {
    let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    let bytes = input.toArray()
    if (bytes.size == 0) {
        return ""
    }
    let result = StringBuilder()
    var i = 0
    while (i < bytes.size) {
        let b0 = UInt8(bytes[i])
        var b1: UInt8 = 0
        var b2: UInt8 = 0
        var padCount = 0
        if (i + 1 < bytes.size) {
            b1 = UInt8(bytes[i + 1])
        } else {
            padCount = 2
        }
        if (i + 2 < bytes.size) {
            b2 = UInt8(bytes[i + 2])
        } else if (padCount == 0) {
            padCount = 1
        }

        let n = (Int64(b0) << 16) | (Int64(b1) << 8) | Int64(b2)
        result.append(chars[((n >> 18) & 0x3F)])
        result.append(chars[((n >> 12) & 0x3F)])
        if (padCount >= 2) {
            result.append("==")
        } else if (padCount == 1) {
            result.append(chars[((n >> 6) & 0x3F)])
            result.append("=")
        } else {
            result.append(chars[((n >> 6) & 0x3F)])
            result.append(chars[(n & 0x3F)])
        }
        i += 3
    }
    result.toString()
}
