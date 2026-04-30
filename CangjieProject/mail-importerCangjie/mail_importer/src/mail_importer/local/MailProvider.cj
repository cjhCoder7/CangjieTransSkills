package mail_importer.local

public interface MailProvider<T> {
    func get(): T
}
