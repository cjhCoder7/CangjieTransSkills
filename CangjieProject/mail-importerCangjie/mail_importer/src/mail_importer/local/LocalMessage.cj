package mail_importer.local

import std.collection.ArrayList

public interface LocalMessage {
    func getMessageId(): String

    func getFromHeader(): String

    func getFolders(): ArrayList<String>

    func getRawContent(): Array<UInt8>

    func isUnread(): Bool

    func isStarred(): Bool
}
