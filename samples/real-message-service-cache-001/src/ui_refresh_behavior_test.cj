package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceUiRefreshTests {
    @TestCase
    public func fetchShouldDispatchDatasetRefreshToMockUiOnMainContext(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 4001)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildUiHistory(peerId))
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        _ = runWorkerGetMessages(service, peerId, 2, "worker-fetch-ui")
        assertEqual("worker 完成后尚未 main-dispatch，因此 UI 不应提前刷新", "", 0, observer.notificationCount())
        assertEqual("worker 完成后应存在 1 个待派发刷新事件", "", 1, bridge.pendingRefreshCount())
        assertEqual("刷新事件必须先在 worker 上下文排队", "", true, logContains(bridge.debugDispatchLog(), "refresh:queued:worker-fetch-ui"))

        setExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 UI 必须收到一次刷新", "", 1, observer.notificationCount())
        assertEqual("UI 刷新必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("UI 首次刷新后应收到 2 条历史消息", "", 2, observer.lastDatasetSize())
        assertEqual("刷新尾消息必须与缓存尾消息一致", "", "ui-history-2", observer.lastMessageText())
        assertEqual("drain 完成后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sendShouldDispatchUpdatedDatasetToMockUiOnMainContext(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 4002)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildUiHistory(peerId))
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        _ = runWorkerGetMessages(service, peerId, 2, "worker-warmup-ui")
        setExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup drain 后 UI 应已有一次刷新", "", 1, observer.notificationCount())

        let sent = runWorkerSendMessage(service, peerId, "ui-outbound", "worker-send-ui")
        assertEqual("worker-send 后不得直接越线程修改 UI", "", 1, observer.notificationCount())
        assertEqual("send 完成后应排队 1 个新的刷新事件", "", 1, bridge.pendingRefreshCount())
        assertEqual("刷新排队日志应保留 worker-send 上下文", "", true, logContains(bridge.debugDispatchLog(), "refresh:queued:worker-send-ui"))

        setExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 UI 应看到 3 条消息", "", 2, observer.notificationCount())
        assertEqual("刷新后的尾消息必须与发送结果一致", "", sent.text, observer.lastMessageText())
        assertEqual("刷新后的数据集长度必须与 cache 一致", "", 3, observer.lastDatasetSize())
        assertEqual("UI 刷新交付上下文必须是 main", "", "main", observer.lastDeliveryContext())
    }
}

func buildUiHistory(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(101, "ui-history-1", peerId)
        } else {
            DomainMessage(102, "ui-history-2", peerId)
        }
    })
}

func logContains(entries: Array<String>, expected: String): Bool {
    for (entry in entries) {
        if (entry == expected) {
            return true
        }
    }
    false
}
