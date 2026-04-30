package mail_importer.local.thunderbird

import mail_importer.local.MailMessage

public class XMozillaStatusParser {
    public init() {}

    public func parse(message: MailMessage): XMozillaStatus {
        var status: Int64 = 0

        let statusHeader = message.getHeader("X-Mozilla-Status")
        if (statusHeader.size > 0) {
            if (statusHeader.size != 1) {
                throw IllegalStateException("Status header length should be 1. (${statusHeader})")
            }
            status = parseHex(statusHeader[0])
        }

        XMozillaStatus(status)
    }
}

// 十六进制字符串转 Int64
func parseHex(hex: String): Int64 {
    var result: Int64 = 0
    var i = 0
    while (i < hex.size) {
        let b = hex[i]  // UInt8
        result = result * 16
        if (b >= 48 && b <= 57) {       // '0'-'9'
            result += Int64(b) - 48
        } else if (b >= 97 && b <= 102) {  // 'a'-'f'
            result += Int64(b) - 97 + 10
        } else if (b >= 65 && b <= 70) {    // 'A'-'F'
            result += Int64(b) - 65 + 10
        }
        i++
    }
    result
}
