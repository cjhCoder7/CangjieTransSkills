package core.mtproto

public abstract class InputPeer {}

public class InputPeerEmpty <: InputPeer {}

public class InputPeerUser <: InputPeer {
    public var userId: Int64 = Int64(0)
    public var accessHash: Int64 = Int64(0)

    public init() {}
}

public class InputPeerChat <: InputPeer {
    public var chatId: Int32 = 0

    public init() {}
}

public class InputPeerChannel <: InputPeer {
    public var channelId: Int64 = Int64(0)
    public var accessHash: Int64 = Int64(0)

    public init() {}
}

public class InputReplyToMessage {
    public var replyToMsgId: Int32 = 0

    public init() {}
}

public class MessagesSendMessage {
    public var peer: InputPeer = InputPeerEmpty()
    public var message: String = ""
    public var randomId: Int64 = Int64(0)

    public init() {}

    public func toBytes(): Array<UInt8> {
        return [0x28, 0x0d, 0x09, 0x6f]
    }
}

public class MessagesGetHistory {
    public var peer: InputPeer = InputPeerEmpty()
    public var limit: Int32 = 20

    public init() {}

    public func toBytes(): Array<UInt8> {
        return [0, 1, 2, 3]
    }
}

public class InitConnection {
    public var query: Array<UInt8> = []

    public init() {}

    public func toBytes(): Array<UInt8> {
        return this.query
    }
}

public class InvokeWithLayer {
    public var query: Array<UInt8> = []

    public init() {}

    public func toBytes(): Array<UInt8> {
        return this.query
    }
}

public class HelpGetConfig {
    public init() {}

    public func toBytes(): Array<UInt8> {
        return [9, 9, 9]
    }
}
