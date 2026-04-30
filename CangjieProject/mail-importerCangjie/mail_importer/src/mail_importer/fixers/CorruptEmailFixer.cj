package mail_importer.fixers

import mail_importer.local.MailMessage

// 尝试修复损坏的邮件 From 头。
// 注意：原版标注 "not actually used"，此处实现基本功能。
public class CorruptEmailFixer {
    public init() {}

    public func hasValidFrom(message: MailMessage): Bool {
        let fromHeaders = message.getHeader("From")
        if (fromHeaders.size != 1) {
            throw IllegalStateException("Expected exactly 1 From header, got: ${fromHeaders.size}")
        }
        let rawAddress = fromHeaders[0].trimAscii()
        let email = extractEmailAddress(rawAddress)
        isValidEmailAddress(email)
    }

    public func tryToCorrectMessageFrom(message: MailMessage): MailMessage {
        message
    }

    // 从 From 头部值中提取邮件地址
    func extractEmailAddress(header: String): String {
        if (let Some(startIdx) <- header.indexOf("<")) {
            if (let Some(endIdx) <- header.indexOf(">")) {
                if (endIdx > startIdx + 1) {
                    return header[startIdx + 1..endIdx].trimAscii()
                }
            }
        }
        header.trimAscii()
    }

    // 简易邮件地址验证
    func isValidEmailAddress(email: String): Bool {
        if (email.isEmpty()) {
            return false
        }
        if (let Some(atPos) <- email.indexOf("@")) {
            if (atPos > 0 && atPos < email.size - 1) {
                let domain = email[atPos + 1..]
                if (let Some(dotPos) <- domain.indexOf(".")) {
                    return dotPos > 0 && dotPos < domain.size - 1
                }
            }
        }
        false
    }
}
