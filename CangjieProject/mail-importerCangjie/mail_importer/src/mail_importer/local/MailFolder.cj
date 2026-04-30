package mail_importer.local

// javax.mail.Folder 的精简等价接口，仅包含业务代码实际使用的方法
public interface MailFolder {
    func getName(): String

    func getFullName(): String

    func getType(): Int64

    func getMessageCount(): Int64

    func getMessage(index: Int64): MailMessage

    func list(): Array<MailFolder>

    func isOpen(): Bool

    func open(mode: Int64): Unit

    func close(expunge: Bool): Unit
}
