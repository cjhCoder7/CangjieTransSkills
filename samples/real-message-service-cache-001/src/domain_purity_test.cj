package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceDomainPurityTests {
    @TestCase
    public func dirtyTlHistoryShouldBePurifiedIntoDomainMessages(): Unit {
        let peerId = PeerId(0, 2001)
        let adapter = PurifyingMessageAdapter()
        adapter.seedDirtyHistory(peerId, buildDirtyHistory(peerId))
        let service = RealMessageService(adapter)
        let signal = service.getMessages(peerId, 1)
        service.debugDrainPromiseResolutions()
        let messages = signal.currentSnapshot()
        assertEqual("恶意 TL 历史消息应被净化为单条 DomainMessage", "", 1, messages.size)
        assertEqual("净化后的文本不应再包含 TL 前缀与 transport 污染", "", "hello-world", messages[0].text)
        assertEqual("缓存中保留的也必须是净化后的 DomainMessage", "", "hello-world", service.debugLastCachedMessageText(peerId))
    }

    @TestCase
    public func outboundSendShouldReturnPurifiedDomainMessage(): Unit {
        let peerId = PeerId(0, 2002)
        let adapter = PurifyingMessageAdapter()
        adapter.seedDirtyOutboundText("TL#7788 @ohos/signalkit bytes:deadbeef outbound-clean")
        let service = RealMessageService(adapter)
        let sent = service.sendMessage(SendMessageParams(peerId, "ignored-by-dirty-outbound"))
        assertEqual("对外返回的消息必须是净化后的 DomainMessage 文本", "", "outbound-clean", sent.text)
        assertEqual("发送后缓存中只能保留净化后的文本", "", "outbound-clean", service.debugLastCachedMessageText(peerId))
    }
}

func buildDirtyHistory(peerId: PeerId): Array<DirtyTLMessage> {
    Array<DirtyTLMessage>(1, { _: Int64 =>
        DirtyTLMessage(71, "TL#4455 @ohos/models bytes:beadfeed hello-world", peerId, Array<UInt8>(4, { index: Int64 => UInt8(index) }))
    })
}
