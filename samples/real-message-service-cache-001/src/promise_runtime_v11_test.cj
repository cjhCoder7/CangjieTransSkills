package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServicePromiseRuntimeV11Tests {
    @TestCase
    public func getMessagesShouldExposeSeededSnapshotBeforeFetchPromiseDrain(): Unit {
        let peerId = PeerId(0, 5601)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV11RemoteHistory(peerId))
        let service = RealMessageService(adapter)

        let local = service.sendMessage(SendMessageParams(peerId, "v11-local-seed"))
        let signal = service.getMessages(peerId, 2)
        let beforeDrain = signal.currentSnapshot()

        assertEqual("fetch promise drain 前 signal 必须仍暴露本地 seed 快照", "", 1, beforeDrain.size)
        assertEqual("drain 前尾消息必须仍是本地 seed", "", local.text, beforeDrain[beforeDrain.size - 1].text)
        assertEqual("首次 signal 创建仍必须立即触发一次 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("fetch 结果必须先进入 pending promise 队列", "", 1, service.debugPendingPromiseCount())

        service.debugDrainPromiseResolutions()
        let afterDrain = signal.currentSnapshot()

        assertEqual("drain 后 pending promise 队列必须清空", "", 0, service.debugPendingPromiseCount())
        assertEqual("drain 后 signal 应切换为远端历史", "", 2, afterDrain.size)
        assertEqual("drain 后尾消息必须来自远端历史", "", "v11-remote-2", afterDrain[afterDrain.size - 1].text)
    }

    @TestCase
    public func fetchPromiseDrainShouldQueueUiRefreshOnlyAfterResolution(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5602)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV11RemoteHistory(peerId))
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let signal = service.getMessages(peerId, 2)

        assertEqual("fetch promise drain 前 UI 不得提前排队 refresh", "", 0, bridge.pendingRefreshCount())
        assertEqual("fetch promise drain 前 observer 不得收到交付", "", 0, observer.notificationCount())
        assertEqual("fetch promise drain 前 signal 仍应暴露初始空快照", "", 0, signal.currentSnapshot().size)

        service.debugDrainPromiseResolutions()

        assertEqual("fetch promise drain 后才允许排队 refresh", "", 1, bridge.pendingRefreshCount())
        assertEqual("fetch promise drain 后 signal 应刷新为远端历史", "", 2, signal.currentSnapshot().size)

        setExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 observer 才应收到第一次交付", "", 1, observer.notificationCount())
        assertEqual("main drain 后 observer 尾消息必须与远端历史一致", "", "v11-remote-2", observer.lastMessageText())
    }

    @TestCase
    public func sendMessageShouldKeepOptimisticSignalContractAndLeavePromiseSettlementTrace(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5603)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV11RemoteHistory(peerId))
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let signal = service.getMessages(peerId, 2)
        service.debugDrainPromiseResolutions()
        bridge.drainOnMain()

        let sent = runWorkerSendMessage(service, peerId, "v11-send-outbound", "worker-v11-send")
        let optimistic = signal.currentSnapshot()
        let trace = service.debugThreadLog()

        assertEqual("send 后 signal 仍必须保持 V9 乐观更新契约", "", 3, optimistic.size)
        assertEqual("乐观更新后的尾消息必须与发送结果一致", "", sent.text, optimistic[optimistic.size - 1].text)
        assertEqual("promise trace 中必须留下 send queued 证据", "", true, traceContains(trace, "promise:queued:send:worker-v11-send"))
        assertEqual("promise trace 中必须留下 send settled 证据", "", true, traceContains(trace, "promise:settled:send:worker-v11-send"))
    }
}

func buildV11RemoteHistory(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(13001, "v11-remote-1", peerId)
        } else {
            DomainMessage(13002, "v11-remote-2", peerId)
        }
    })
}

func traceContains(entries: Array<String>, fragment: String): Bool {
    for (entry in entries) {
        if (entry == fragment) {
            return true
        }
    }
    false
}
