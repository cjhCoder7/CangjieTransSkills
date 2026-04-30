package mail_importer.local

import std.io.OutputStream

// javax.mail.Message 的精简等价接口，仅包含业务代码实际使用的方法
public interface MailMessage {
    func getHeader(name: String): Array<String>

    func getFolder(): MailFolder

    func writeTo(os: OutputStream): Unit

    func getFrom(): Array<MailAddress>

    func getSize(): Int64

    func getMessageNumber(): Int64
}

// 邮件地址的简化表示
public class MailAddress {
    public let address: String

    public init(address: String) {
        this.address = address
    }
}
