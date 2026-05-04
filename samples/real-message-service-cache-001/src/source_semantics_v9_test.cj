package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceSourceSemanticsV9Tests {
    @TestCase
    public func firstSignalCreationShouldFetchEvenWhenCacheAlreadySeeded(): Unit {
        let peerId = PeerId(0, 5401)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV9RemoteHistory(peerId))
        let service = RealMessageService(adapter)

        _ = service.sendMessage(SendMessageParams(peerId, "v9-local-seed"))
        assertEqual("本地 seed cache 时不应提前触发历史拉取", "", 0, adapter.getHistoryCallCount())

        let signal = service.getMessages(peerId, 2)
        let beforeDrain = signal.currentSnapshot()

        assertEqual("首次创建 signal 时即使 cache 已存在也必须触发 fetch", "", 1, adapter.getHistoryCallCount())
        assertEqual("fetch promise drain 前必须先暴露本地 seed 快照", "", 1, beforeDrain.size)
        assertEqual("drain 前尾消息必须仍是本地 seed", "", "v9-local-seed", beforeDrain[beforeDrain.size - 1].text)

        service.debugDrainPromiseResolutions()
        let snapshot = signal.currentSnapshot()
        assertEqual("fetch promise drain 后快照应以远端历史为准", "", 2, snapshot.size)
        assertEqual("fetch 刷新后的尾消息必须来自远端历史", "", "v9-remote-2", snapshot[snapshot.size - 1].text)
    }

    @TestCase
    public func sendMessageShouldOptimisticallyUpdateExistingSignalBeforeUiDrain(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5402)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV9RemoteHistory(peerId))
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let signal = service.getMessages(peerId, 2)
        service.debugDrainPromiseResolutions()
        setExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup 后 UI 应已有一次历史交付", "", 1, observer.notificationCount())

        let sent = runWorkerV9SendMessage(service, peerId, "v9-optimistic-send", "worker-v9-send")
        let optimistic = signal.currentSnapshot()

        assertEqual("main drain 前 signal 必须已更新到 3 条消息", "", 3, optimistic.size)
        assertEqual("main drain 前 signal 尾消息必须是刚发送结果", "", sent.text, optimistic[optimistic.size - 1].text)
        assertEqual("main drain 前 observer 不得提前收到第二次交付", "", 1, observer.notificationCount())
        assertEqual("发送后应存在 1 个待 main drain 的刷新任务", "", 1, bridge.pendingRefreshCount())

        setExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 UI observer 才能看到第二次交付", "", 2, observer.notificationCount())
        assertEqual("最终 UI 尾消息必须与乐观 signal 一致", "", sent.text, observer.lastMessageText())
    }
}

func buildV9RemoteHistory(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(11001, "v9-remote-1", peerId)
        } else {
            DomainMessage(11002, "v9-remote-2", peerId)
        }
    })
}

func runWorkerV9SendMessage(service: RealMessageService, peerId: PeerId, text: String, label: String): DomainMessage {
    let task = spawn {
        setExecutionContext(label)
        service.sendMessage(SendMessageParams(peerId, text))
    }
    task.get()
}
