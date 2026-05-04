package telegram_ui_vertical_slice_001

import phase07_shared_service_refresh_harness.*
import std.collection.*

class FakeMessageAdapter <: IMTProtoAdapter {
    private let seededHistory = HashMap<String, Array<DomainMessage>>()
    private var historyCallCounter: Int64 = 0
    private var sendCallCounter: Int64 = 0
    private var nextMessageId: Int32 = 9000

    public init() {}

    public func seedHistory(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        this.seededHistory[this.buildCacheKey(peerId)] = cloneMessages(messages)
    }

    public func getHistoryCallCount(): Int64 {
        this.historyCallCounter
    }

    public func sendMessageCallCount(): Int64 {
        this.sendCallCounter
    }

    public func getHistory(peerId: PeerId, limit: Int32): Array<DomainMessage> {
        this.historyCallCounter = this.historyCallCounter + 1
        match (this.seededHistory.get(this.buildCacheKey(peerId))) {
            case Some(messages) => takeMessages(messages, limit)
            case None => emptyMessages()
        }
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.sendCallCounter = this.sendCallCounter + 1
        this.nextMessageId = this.nextMessageId + 1
        DomainMessage(this.nextMessageId, text, peerId)
    }

    private func buildCacheKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}
