package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceSourceParityTests {
    @TestCase
    public func getMessagesShouldExposeSignalLikePublicShape(): Unit {
        let peerId = PeerId(0, 5301)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildSourceParityHistory(peerId))
        let service = RealMessageService(adapter)

        let signal = service.getMessages(peerId, 2)
        let snapshot = signal.currentSnapshot()

        assertEqual("source parity 形态下 signal-like 读取应先暴露快照接口", "", true, snapshot.size >= 0)
    }

    @TestCase
    public func sendMessageShouldAcceptSourceAlignedParamsBag(): Unit {
        let peerId = PeerId(0, 5302)
        let adapter = FakeMessageAdapter()
        let service = RealMessageService(adapter)
        let params = SendMessageParams(peerId, "source-parity-outbound")

        let sent = service.sendMessage(params)

        assertEqual("source parity 形态下 sendMessage 应接受 params bag", "", "source-parity-outbound", sent.text)
    }
}

func buildSourceParityHistory(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(10001, "source-parity-1", peerId)
        } else {
            DomainMessage(10002, "source-parity-2", peerId)
        }
    })
}
