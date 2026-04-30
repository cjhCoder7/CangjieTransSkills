package mail_importer.local

public class MessagingException <: Exception {
    public init(message: String) {
        super(message)
    }

    public init(message: String, cause: Exception) {
        super(message, cause)
    }
}
