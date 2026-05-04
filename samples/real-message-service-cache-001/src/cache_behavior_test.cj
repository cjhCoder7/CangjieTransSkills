package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceCacheTests {
    @TestCase
    public func firstGetMessagesShouldPopulateCacheAndCallAdapterOnce(): Unit {
        let peerId = PeerId(0, 1001)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildHistory(peerId))
        let service = RealMessageService(adapter)
        let signal = service.getMessages(peerId, 2)
        assertEqual("首次读取应调用一次 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        service.debugDrainPromiseResolutions()
        let messages = signal.currentSnapshot()
        assertEqual("首次读取应返回两条历史消息", "", 2, messages.size)
        assertEqual("首次读取后缓存大小应为 2", "", 2, service.debugCacheSize(peerId))
    }

    @TestCase
    public func secondGetMessagesShouldReuseCacheWithoutRefetch(): Unit {
        let peerId = PeerId(0, 1002)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildHistory(peerId))
        let service = RealMessageService(adapter)
        let firstSignal = service.getMessages(peerId, 2)
        service.debugDrainPromiseResolutions()
        _ = firstSignal.currentSnapshot()
        let secondSignal = service.getMessages(peerId, 2)
        let second = secondSignal.currentSnapshot()
        assertEqual("第二次读取不应再次调用 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("第二次读取仍应返回两条历史消息", "", 2, second.size)
        assertEqual("缓存内容应保持第一条历史消息文本", "", "history-1", second[0].text)
    }

    @TestCase
    public func sendMessageShouldAppendToExistingCache(): Unit {
        let peerId = PeerId(0, 1003)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildHistory(peerId))
        let service = RealMessageService(adapter)
        let signal = service.getMessages(peerId, 2)
        service.debugDrainPromiseResolutions()
        _ = signal.currentSnapshot()
        let sent = service.sendMessage(SendMessageParams(peerId, "outbound"))
        assertEqual("发送后不应额外触发历史拉取", "", 1, adapter.getHistoryCallCount())
        assertEqual("发送后应调用一次 adapter.sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("发送后缓存大小应追加到 3", "", 3, service.debugCacheSize(peerId))
        assertEqual("发送后缓存尾部文本应与返回消息一致", "", sent.text, service.debugLastCachedMessageText(peerId))
    }

    @TestCase
    public func sendMessageShouldSeedCacheWhenEmpty(): Unit {
        let peerId = PeerId(0, 1004)
        let adapter = FakeMessageAdapter()
        let service = RealMessageService(adapter)
        let sent = service.sendMessage(SendMessageParams(peerId, "first-message"))
        assertEqual("空缓存直接发送时不应触发历史拉取", "", 0, adapter.getHistoryCallCount())
        assertEqual("空缓存直接发送后应调用一次发送", "", 1, adapter.sendMessageCallCount())
        assertEqual("空缓存直接发送后应生成单条缓存", "", 1, service.debugCacheSize(peerId))
        assertEqual("空缓存直接发送后的缓存尾部应与返回消息一致", "", sent.text, service.debugLastCachedMessageText(peerId))
    }
}

func buildHistory(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(1, "history-1", peerId)
        } else {
            DomainMessage(2, "history-2", peerId)
        }
    })
}
