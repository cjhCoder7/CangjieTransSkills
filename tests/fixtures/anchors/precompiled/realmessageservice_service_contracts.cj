package services

import std.sync.*

public interface Signal<T> {}

public class PeerId {
    public var namespace: Int32 = 0
    public var id: Int64 = Int64(0)
}

public class Message {
    public var id: Int32 = 0
    public var text: String = ""
    public var peerId: PeerId = PeerId()
    public var flags: Int32 = 0
    public var stableVersion: Int32 = 0
}

public class SendMessageParams {
    public var peerId: PeerId = PeerId()
    public var text: String = ""
}

public class GetHistoryParams {
    public var peerId: PeerId = PeerId()
    public var limit: Int32 = 20
}

private class EmptyMessageSignal <: Signal<Array<Message>> {
    public init() {}
}

public class MessageTimeline {
    private let fallbackSignal: Signal<Array<Message>> = EmptyMessageSignal()

    public init() {}

    public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {
        this.fallbackSignal
    }

    public func fetchMessages(params: GetHistoryParams): Future<Array<Message>> {
        spawn { Array<Message>() }
    }

    public func sendMessage(params: SendMessageParams): Future<Message> {
        spawn { Message() }
    }

    public func replaceMessages(peerId: PeerId, messages: Array<Message>): Unit {
        ()
    }

    public func appendMessage(peerId: PeerId, message: Message): Unit {
        ()
    }
}

public class TLUser {
    public var id: Int64 = Int64(0)
    public var accessHash: ?Int64 = None
    public var firstName: ?String = None
}

public class TLChannel {
    public var id: Int64 = Int64(0)
    public var accessHash: ?Int64 = None
}

public interface IMessageService {
    func cacheUsers(users: Array<TLUser>): Unit
    func cacheChannels(channels: Array<TLChannel>): Unit
    func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>
    func fetchMessages(params: GetHistoryParams): Future<Array<Message>>
    func sendMessage(params: SendMessageParams): Future<Message>
}
