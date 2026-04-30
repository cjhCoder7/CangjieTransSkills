package mail_importer.local.thunderbird

// X-Mozilla-Status 头部标志位常量
// 参考 http://www.eyrich-net.org/mozilla/X-Mozilla-Status.html

public class XMozillaStatus {
    // X-Mozilla-Status 标志位
    static let MSG_FLAG_READ: Int64 = 0x0001
    static let MSG_FLAG_REPLIED: Int64 = 0x0002
    static let MSG_FLAG_MARKED: Int64 = 0x0004
    static let MSG_FLAG_EXPUNGED: Int64 = 0x0008
    static let MSG_FLAG_HAS_RE: Int64 = 0x0010
    static let MSG_FLAG_ELIDED: Int64 = 0x0020
    static let MSG_FLAG_OFFLINE: Int64 = 0x0080
    static let MSG_FLAG_WATCHED: Int64 = 0x0100
    static let MSG_FLAG_SENDER_AUTHED: Int64 = 0x0200
    static let MSG_FLAG_PARTIAL: Int64 = 0x0400
    static let MSG_FLAG_QUEUED: Int64 = 0x0800
    static let MSG_FLAG_FORWARDED: Int64 = 0x1000
    static let MSG_FLAG_PRIORITIES: Int64 = 0xE000

    // X-Mozilla-Status2 标志位
    static let MSG_FLAG_NEW: Int64 = 0x00010000
    static let MSG_FLAG_IGNORED: Int64 = 0x00040000
    static let MSG_FLAG_IMAP_DELETED: Int64 = 0x00200000
    static let MSG_FLAG_MDN_REPORT_NEEDED: Int64 = 0x00400000
    static let MSG_FLAG_MDN_REPORT_SENT: Int64 = 0x00800000
    static let MSG_FLAG_TEMPLATE: Int64 = 0x01000000
    static let MSG_FLAG_LABELS: Int64 = 0x0E000000
    static let MSG_FLAG_ATTACHMENT: Int64 = 0x10000000

    let status: Int64

    public init(status: Int64) {
        this.status = status
    }

    public func isRead(): Bool {
        (status & XMozillaStatus.MSG_FLAG_READ) != 0
    }

    public func isMarked(): Bool {
        (status & XMozillaStatus.MSG_FLAG_MARKED) != 0
    }
}
