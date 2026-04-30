package mail_importer.local.mbox

import std.collection.ArrayList
import std.collection.HashMap

// mbox 文件中解析出的原始消息数据
public class MboxRawMessage {
    public var rawBytes: Array<UInt8>
    public var headers: HashMap<String, Array<String>>
    public var messageNumber: Int64
    public var envelopeSender: String

    public init(rawBytes: Array<UInt8>, headers: HashMap<String, Array<String>>,
                messageNumber: Int64, envelopeSender: String) {
        this.rawBytes = rawBytes
        this.headers = headers
        this.messageNumber = messageNumber
        this.envelopeSender = envelopeSender
    }
}
