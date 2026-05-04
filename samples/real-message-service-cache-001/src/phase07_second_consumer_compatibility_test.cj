package real_message_service_cache_001

import phase07_shared_service_refresh_harness.{
    PeerId as SharedPeerId,
    DomainMessage as SharedDomainMessage,
    IMTProtoAdapter as SharedIMTProtoAdapter,
    DatasetRefreshObserver as SharedDatasetRefreshObserver,
    MainContextDatasetRefreshBridge as SharedMainContextDatasetRefreshBridge,
    RealMessageService as SharedRealMessageService,
    SendMessageParams as SharedSendMessageParams,
    runWorkerGetMessages,
    setExecutionContext as setSharedExecutionContext,
    currentExecutionContext as currentSharedExecutionContext,
    cloneMessages as cloneSharedMessages,
    emptyMessages as emptySharedMessages,
    takeMessages as takeSharedMessages
}
import std.collection.*
import std.sync.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class Phase07SecondConsumerCompatibilityTests {
    @TestCase
    public func sharedHarnessShouldSupportCacheSampleAsSecondConsumer(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6101)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-shared"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let snapshot = runWorkerGetMessages(service, peerId, 2, "worker-second-consumer")
        setSharedExecutionContext("main")
        bridge.drainOnMain()

        assertEqual("second consumer 读取应只触发一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("second consumer 应拿到两条共享历史消息", "", 2, snapshot.size)
        assertEqual("second consumer 共享尾消息应与 seed 对齐", "", "phase07-shared-2", snapshot[1].text)
        assertEqual("second consumer 应收到一次共享 refresh 交付", "", 1, observer.notificationCount())
        assertEqual("shared refresh 交付尾消息应保持一致", "", "phase07-shared-2", observer.lastMessageText())
        assertEqual("shared refresh 必须在 main context 交付", "", "main", observer.lastDeliveryContext())
        assertEqual("shared refresh drain 后不得残留 pending queue", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldDispatchSecondConsumerSendRefreshOnMainContext(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6102)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-send"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let warmup = runWorkerGetMessages(service, peerId, 2, "worker-second-consumer-warmup")
        assertEqual("warmup fetch 应先拿到两条共享历史消息", "", 2, warmup.size)
        assertEqual("warmup fetch 后应先排队 1 个共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup main drain 后 observer 应收到一次共享 refresh", "", 1, observer.notificationCount())
        assertEqual("warmup main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())

        let sentTask = spawn {
            setSharedExecutionContext("worker-second-consumer-send")
            service.sendMessage(SharedSendMessageParams(peerId, "phase07-send-tail"))
        }
        let sent = sentTask.get()

        assertEqual("worker send 后 observer 不得在 main drain 前提前增加", "", 1, observer.notificationCount())
        assertEqual("worker send 后应排队 1 个新的共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("send 后 main drain 应触发第二次共享 refresh", "", 2, observer.notificationCount())
        assertEqual("send 后尾消息必须与 worker 返回值一致", "", sent.text, observer.lastMessageText())
        assertEqual("send refresh 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("send refresh drain 后不得残留 pending queue", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldKeepSecondConsumerSignalOptimisticBeforeMainDrain(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6103)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-signal"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let signal = service.getMessages(peerId, 2)
        assertEqual("首次创建 shared signal 时必须触发一次远端历史拉取", "", 1, adapter.getHistoryCallCount())
        assertEqual("fetch promise drain 前 shared signal 必须仍暴露初始空快照", "", 0, signal.currentSnapshot().size)
        assertEqual("fetch promise drain 前不得提前排队 shared refresh", "", 0, bridge.pendingRefreshCount())

        service.debugDrainPromiseResolutions()
        assertEqual("fetch promise drain 后应先排队 1 个 shared refresh", "", 1, bridge.pendingRefreshCount())
        assertEqual("fetch promise drain 后 shared signal 应切到远端历史", "", 2, signal.currentSnapshot().size)

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup main drain 后 observer 应收到一次共享历史交付", "", 1, observer.notificationCount())

        let sentTask = spawn {
            setSharedExecutionContext("worker-second-consumer-signal-send")
            service.sendMessage(SharedSendMessageParams(peerId, "phase07-signal-tail"))
        }
        let sent = sentTask.get()
        let optimistic = signal.currentSnapshot()

        assertEqual("main drain 前 shared signal 必须已乐观追加发送结果", "", 3, optimistic.size)
        assertEqual("main drain 前 shared signal 尾消息必须与发送结果一致", "", sent.text, optimistic[optimistic.size - 1].text)
        assertEqual("main drain 前 observer 不得提前收到第二次共享交付", "", 1, observer.notificationCount())
        assertEqual("send 后应排队 1 个新的 shared refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 observer 才能看到第二次共享交付", "", 2, observer.notificationCount())
        assertEqual("最终共享 observer 尾消息必须与乐观 signal 一致", "", sent.text, observer.lastMessageText())
        assertEqual("共享 send 交付上下文必须是 main", "", "main", observer.lastDeliveryContext())
        assertEqual("send refresh drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldRefetchSecondConsumerAfterInvalidate(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6104)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-invalidate-a"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        setSharedExecutionContext("worker-second-consumer-invalidate-warmup")
        let warmSignal = service.getMessages(peerId, 2)

        assertEqual("首次 warmup fetch 必须触发一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("warmup fetch promise drain 前共享 signal 必须仍为空", "", 0, warmSignal.currentSnapshot().size)

        service.debugDrainPromiseResolutions()
        let warmSnapshot = warmSignal.currentSnapshot()

        assertEqual("warmup fetch promise drain 后共享 signal 应切到第一份远端历史", "", 2, warmSnapshot.size)
        assertEqual("warmup fetch promise drain 后共享尾消息必须来自第一份远端历史", "", "phase07-invalidate-a-2", warmSnapshot[warmSnapshot.size - 1].text)
        assertEqual("warmup fetch promise drain 后应先排队 1 个共享 refresh", "", 1, bridge.pendingRefreshCount())
        assertEqual("warmup main drain 前 observer 不得提前收到共享交付", "", 0, observer.notificationCount())

        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-invalidate-b"))
        let invalidationEpoch = service.debugInvalidateCache(peerId)
        let detachedSnapshot = warmSignal.currentSnapshot()
        let replacementSignal = service.getMessages(peerId, 2)

        assertEqual("invalidate 必须显式推进共享 epoch", "", true, invalidationEpoch > 0)
        assertEqual("invalidate 后旧 shared signal 必须保持既有历史", "", 2, detachedSnapshot.size)
        assertEqual("invalidate 后旧 shared signal 尾消息必须仍来自第一份远端历史", "", "phase07-invalidate-a-2", detachedSnapshot[detachedSnapshot.size - 1].text)
        assertEqual("invalidate 后 replacement signal 必须重新从空快照开始", "", 0, replacementSignal.currentSnapshot().size)
        assertEqual("invalidate 后 refetch 必须重新触发一次共享 adapter.getHistory", "", 2, adapter.getHistoryCallCount())
        assertEqual("invalidate/refetch 过程中 observer 仍不得在 main drain 前收到共享交付", "", 0, observer.notificationCount())

        service.debugDrainPromiseResolutions()
        let replacementSnapshot = replacementSignal.currentSnapshot()

        assertEqual("refetch promise drain 后 replacement signal 应切到第二份远端历史", "", 2, replacementSnapshot.size)
        assertEqual("refetch promise drain 后 replacement tail 必须来自第二份远端历史", "", "phase07-invalidate-b-2", replacementSnapshot[replacementSnapshot.size - 1].text)
        assertEqual("refetch promise drain 后 main drain 前 observer 仍不得提前收到共享交付", "", 0, observer.notificationCount())
        assertEqual("refetch promise drain 后 pending queue 至少应包含新的共享 refresh", "", true, bridge.pendingRefreshCount() >= 1)

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 observer 应只收到一次有效共享交付", "", 1, observer.notificationCount())
        assertEqual("最终共享 observer 尾消息必须切到 refetch 后的新历史", "", "phase07-invalidate-b-2", observer.lastMessageText())
        assertEqual("invalidate/refetch 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldDiscardPreDrainFetchWhenSecondConsumerInvalidates(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6105)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-pre-drain-a"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        let oldHeldSignal = service.getMessages(peerId, 2)

        assertEqual("first fetch 一旦触发就必须命中一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("pre-drain 窗口内旧 shared signal 必须仍为空", "", 0, oldHeldSignal.currentSnapshot().size)
        assertEqual("pre-drain 窗口内不得提前排队 shared refresh", "", 0, bridge.pendingRefreshCount())
        assertEqual("pre-drain 窗口内 observer 不得提前收到共享交付", "", 0, observer.notificationCount())

        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-pre-drain-b"))
        _ = service.debugInvalidateCache(peerId)

        assertEqual("invalidate 后旧 held signal 仍不得被旧 pending fetch 污染", "", 0, oldHeldSignal.currentSnapshot().size)
        assertEqual("invalidate 后仍不得提前排队 shared refresh", "", 0, bridge.pendingRefreshCount())
        assertEqual("invalidate 后 observer 仍不得提前收到共享交付", "", 0, observer.notificationCount())

        let replacementSignal = service.getMessages(peerId, 2)

        assertEqual("replacement getMessages 必须重新触发一次共享 adapter.getHistory", "", 2, adapter.getHistoryCallCount())
        assertEqual("replacement drain 前 replacement signal 必须仍为空", "", 0, replacementSignal.currentSnapshot().size)
        assertEqual("replacement drain 前旧 held signal 必须继续保持空快照", "", 0, oldHeldSignal.currentSnapshot().size)
        assertEqual("replacement drain 前 pending queue 仍必须为空", "", 0, bridge.pendingRefreshCount())

        service.debugDrainPromiseResolutions()
        let replacementSnapshot = replacementSignal.currentSnapshot()

        assertEqual("replacement drain 后 replacement signal 应只切到 replacement payload", "", 2, replacementSnapshot.size)
        assertEqual("replacement drain 后 replacement signal 尾消息必须来自 replacement payload", "", "phase07-pre-drain-b-2", replacementSnapshot[replacementSnapshot.size - 1].text)
        assertEqual("replacement drain 后旧 held signal 不得被旧 pending fetch 反向污染", "", 0, oldHeldSignal.currentSnapshot().size)
        assertEqual("replacement drain 后只允许排队 1 个 replacement refresh", "", 1, bridge.pendingRefreshCount())
        assertEqual("main drain 前 observer 仍不得提前收到共享交付", "", 0, observer.notificationCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 observer 只能看到 replacement payload 的一次共享交付", "", 1, observer.notificationCount())
        assertEqual("main drain 后 observer 尾消息必须只来自 replacement payload", "", "phase07-pre-drain-b-2", observer.lastMessageText())
        assertEqual("replacement 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldExposeColdSendSeedBeforeFirstFetchDrain(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6106)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-cold-send-remote"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)

        setSharedExecutionContext("worker-second-consumer-cold-send")
        let sent = service.sendMessage(SharedSendMessageParams(peerId, "phase07-cold-send-local"))

        assertEqual("cold send seed cache 时不应提前触发共享 adapter.getHistory", "", 0, adapter.getHistoryCallCount())
        assertEqual("cold send 后 observer 仍不得提前收到共享交付", "", 0, observer.notificationCount())
        assertEqual("cold send 后 pending queue 必须保持为空", "", 0, bridge.pendingRefreshCount())

        service.attachRefreshBridge(bridge)
        setSharedExecutionContext("worker-second-consumer-cold-send-fetch")
        let signal = service.getMessages(peerId, 2)
        let seededSnapshot = signal.currentSnapshot()

        assertEqual("首次 getMessages 仍必须触发一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("fetch promise drain 前 shared signal 必须先暴露 cold send seeded 快照", "", 1, seededSnapshot.size)
        assertEqual("fetch promise drain 前 seeded 尾消息必须与 cold send 返回值一致", "", sent.text, seededSnapshot[seededSnapshot.size - 1].text)
        assertEqual("fetch promise drain 前 observer 不得提前收到共享交付", "", 0, observer.notificationCount())
        assertEqual("fetch promise drain 前 pending queue 必须仍为空", "", 0, bridge.pendingRefreshCount())

        service.debugDrainPromiseResolutions()
        let remoteSnapshot = signal.currentSnapshot()

        assertEqual("fetch promise drain 后 shared signal 必须切到远端历史", "", 2, remoteSnapshot.size)
        assertEqual("fetch promise drain 后 shared signal 尾消息必须来自远端历史", "", "phase07-cold-send-remote-2", remoteSnapshot[remoteSnapshot.size - 1].text)
        assertEqual("fetch promise drain 后 main drain 前 observer 仍不得提前收到共享交付", "", 0, observer.notificationCount())
        assertEqual("fetch promise drain 后应排队 1 个共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("main drain 后 observer 应只收到一次共享交付", "", 1, observer.notificationCount())
        assertEqual("main drain 后 observer 尾消息必须来自远端历史", "", "phase07-cold-send-remote-2", observer.lastMessageText())
        assertEqual("cold-send seeded fetch 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldReuseWarmSecondConsumerSignalWithoutRefetch(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6107)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-reuse"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        setSharedExecutionContext("worker-second-consumer-reuse-first")
        let firstSignal = service.getMessages(peerId, 2)

        assertEqual("same peer 首次 getMessages 必须触发一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())

        service.debugDrainPromiseResolutions()
        let warmSnapshot = firstSignal.currentSnapshot()

        assertEqual("warmup fetch promise drain 后 shared signal 应切到远端历史", "", 2, warmSnapshot.size)
        assertEqual("warmup fetch promise drain 后 shared signal 尾消息必须来自远端历史", "", "phase07-reuse-2", warmSnapshot[warmSnapshot.size - 1].text)
        assertEqual("warmup fetch promise drain 后应先排队 1 个共享 refresh", "", 1, bridge.pendingRefreshCount())
        assertEqual("warmup main drain 前 observer 不得提前收到共享交付", "", 0, observer.notificationCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup main drain 后 observer 应收到一次共享交付", "", 1, observer.notificationCount())
        assertEqual("warmup main drain 后 observer 尾消息必须来自已 warmup 的远端历史", "", "phase07-reuse-2", observer.lastMessageText())
        assertEqual("warmup 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("warmup main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())

        setSharedExecutionContext("worker-second-consumer-reuse-second")
        let secondSignal = service.getMessages(peerId, 2)
        let secondSnapshot = secondSignal.currentSnapshot()

        assertEqual("same peer 第二次 getMessages 不得再次触发共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("same peer 第二次读取应继续暴露已 warmup 的远端历史", "", 2, secondSnapshot.size)
        assertEqual("same peer 第二次读取尾消息必须继续来自第一次 warmup 的远端历史", "", "phase07-reuse-2", secondSnapshot[secondSnapshot.size - 1].text)
        assertEqual("same peer 第二次读取不得新增共享 refresh 交付", "", 1, observer.notificationCount())
        assertEqual("same peer 第二次读取后 pending queue 必须继续保持为空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldAppendWarmSendWithoutRefetchingHistory(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6108)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-warm-send"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        setSharedExecutionContext("worker-second-consumer-warm-send-warmup")
        let signal = service.getMessages(peerId, 2)

        assertEqual("warmup getMessages 必须只触发一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())

        service.debugDrainPromiseResolutions()
        let warmSnapshot = signal.currentSnapshot()

        assertEqual("warmup fetch promise drain 后 shared signal 应切到远端历史", "", 2, warmSnapshot.size)
        assertEqual("warmup fetch promise drain 后 shared signal 尾消息必须来自远端历史", "", "phase07-warm-send-2", warmSnapshot[warmSnapshot.size - 1].text)
        assertEqual("warmup fetch promise drain 后应先排队 1 个共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup main drain 后 observer 应收到一次共享交付", "", 1, observer.notificationCount())
        assertEqual("warmup main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())

        let sentTask = spawn {
            setSharedExecutionContext("worker-second-consumer-warm-send")
            service.sendMessage(SharedSendMessageParams(peerId, "phase07-warm-send-tail"))
        }
        let sent = sentTask.get()
        let appendedSnapshot = signal.currentSnapshot()

        assertEqual("warm send 后不得触发第二次共享 history pull", "", 1, adapter.getHistoryCallCount())
        assertEqual("warm send 后已 warmup 的 shared signal 必须只表现为 append 后 payload", "", 3, appendedSnapshot.size)
        assertEqual("warm send 后 shared signal 尾消息必须与发送结果一致", "", sent.text, appendedSnapshot[appendedSnapshot.size - 1].text)
        assertEqual("warm send 后 observer 仍必须保持 main-gated", "", 1, observer.notificationCount())
        assertEqual("warm send 后应只排队 1 个新的共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warm send main drain 后 observer 才能收到第二次共享交付", "", 2, observer.notificationCount())
        assertEqual("warm send main drain 后 observer 尾消息必须与 append payload 一致", "", sent.text, observer.lastMessageText())
        assertEqual("warm send 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("warm send refresh drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }

    @TestCase
    public func sharedHarnessShouldReuseWarmSendSnapshotOnRepeatedSamePeerGetWithoutRefetch(): Unit {
        setSharedExecutionContext("main")
        let peerId = SharedPeerId(0, 6109)
        let adapter = Phase07SharedFakeAdapter()
        adapter.seedHistory(peerId, buildSharedHistory(peerId, "phase07-warm-send-reget"))
        let observer = Phase07SharedObserver()
        let bridge = SharedMainContextDatasetRefreshBridge(observer)
        let service = SharedRealMessageService(adapter)
        service.attachRefreshBridge(bridge)

        setSharedExecutionContext("worker-second-consumer-warm-send-reget-warmup")
        let warmSignal = service.getMessages(peerId, 2)

        assertEqual("warmup getMessages 必须只触发一次共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())

        service.debugDrainPromiseResolutions()
        let warmSnapshot = warmSignal.currentSnapshot()

        assertEqual("warmup fetch promise drain 后 shared signal 应切到远端历史", "", 2, warmSnapshot.size)
        assertEqual("warmup fetch promise drain 后 shared signal 尾消息必须来自远端历史", "", "phase07-warm-send-reget-2", warmSnapshot[warmSnapshot.size - 1].text)
        assertEqual("warmup fetch promise drain 后应先排队 1 个共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warmup main drain 后 observer 应收到一次共享交付", "", 1, observer.notificationCount())
        assertEqual("warmup main drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())

        let sentTask = spawn {
            setSharedExecutionContext("worker-second-consumer-warm-send-reget-send")
            service.sendMessage(SharedSendMessageParams(peerId, "phase07-warm-send-reget-tail"))
        }
        let sent = sentTask.get()
        let optimisticSnapshot = warmSignal.currentSnapshot()

        assertEqual("warm send 后不得触发第二次共享 history pull", "", 1, adapter.getHistoryCallCount())
        assertEqual("warm send 后已 warmup 的 shared signal 必须先表现为 append 后 payload", "", 3, optimisticSnapshot.size)
        assertEqual("warm send 后 shared signal 尾消息必须与发送结果一致", "", sent.text, optimisticSnapshot[optimisticSnapshot.size - 1].text)
        assertEqual("warm send 后 observer 仍必须保持 main-gated", "", 1, observer.notificationCount())
        assertEqual("warm send 后应只排队 1 个新的共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("worker-second-consumer-warm-send-reget-second")
        let secondSignal = service.getMessages(peerId, 2)
        let secondSnapshot = secondSignal.currentSnapshot()

        assertEqual("warm send 后 same peer 第二次 getMessages 不得再次触发共享 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
        assertEqual("warm send 后 same peer 第二次读取必须继续复用 append 后 payload", "", 3, secondSnapshot.size)
        assertEqual("warm send 后 same peer 第二次读取尾消息必须继续与发送结果一致", "", sent.text, secondSnapshot[secondSnapshot.size - 1].text)
        assertEqual("warm send 后 same peer 第二次读取不得新增共享 refresh 交付", "", 1, observer.notificationCount())
        assertEqual("warm send 后 same peer 第二次读取不得额外排队新的共享 refresh", "", 1, bridge.pendingRefreshCount())

        setSharedExecutionContext("main")
        bridge.drainOnMain()
        assertEqual("warm send repeated get main drain 后 observer 才能收到第二次共享交付", "", 2, observer.notificationCount())
        assertEqual("warm send repeated get main drain 后 observer 尾消息必须与 append payload 一致", "", sent.text, observer.lastMessageText())
        assertEqual("warm send repeated get 交付必须发生在 main context", "", "main", observer.lastDeliveryContext())
        assertEqual("warm send repeated get refresh drain 后 pending queue 必须清空", "", 0, bridge.pendingRefreshCount())
    }
}

class Phase07SharedFakeAdapter <: SharedIMTProtoAdapter {
    private let seededHistory = HashMap<String, Array<SharedDomainMessage>>()
    private var historyCallCounter: Int64 = 0
    private var nextMessageId: Int32 = 6200

    public init() {}

    public func seedHistory(peerId: SharedPeerId, messages: Array<SharedDomainMessage>): Unit {
        this.seededHistory[this.buildCacheKey(peerId)] = cloneSharedMessages(messages)
    }

    public func getHistoryCallCount(): Int64 {
        this.historyCallCounter
    }

    public func getHistory(peerId: SharedPeerId, limit: Int32): Array<SharedDomainMessage> {
        this.historyCallCounter = this.historyCallCounter + 1
        match (this.seededHistory.get(this.buildCacheKey(peerId))) {
            case Some(messages) => takeSharedMessages(messages, limit)
            case None => emptySharedMessages()
        }
    }

    public func sendMessage(peerId: SharedPeerId, text: String): SharedDomainMessage {
        this.nextMessageId = this.nextMessageId + 1
        SharedDomainMessage(this.nextMessageId, text, peerId)
    }

    private func buildCacheKey(peerId: SharedPeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

class Phase07SharedObserver <: SharedDatasetRefreshObserver {
    private let observerLock = Mutex()
    private var notificationTotal: Int64 = 0
    private var lastSnapshot = emptySharedMessages()
    private var lastContext: String = ""

    public init() {}

    public func onDatasetChanged(peerId: SharedPeerId, messages: Array<SharedDomainMessage>): Unit {
        _ = peerId
        this.observerLock.lock()
        this.notificationTotal = this.notificationTotal + 1
        this.lastSnapshot = cloneSharedMessages(messages)
        this.lastContext = currentSharedExecutionContext()
        this.observerLock.unlock()
    }

    public func notificationCount(): Int64 {
        this.observerLock.lock()
        let count = this.notificationTotal
        this.observerLock.unlock()
        count
    }

    public func lastMessageText(): String {
        this.observerLock.lock()
        let text = if (this.lastSnapshot.size == 0) {
            ""
        } else {
            this.lastSnapshot[this.lastSnapshot.size - 1].text
        }
        this.observerLock.unlock()
        text
    }

    public func lastDeliveryContext(): String {
        this.observerLock.lock()
        let context = this.lastContext
        this.observerLock.unlock()
        context
    }
}

func buildSharedHistory(peerId: SharedPeerId, prefix: String): Array<SharedDomainMessage> {
    Array<SharedDomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            SharedDomainMessage(Int32(6100 + index), "${prefix}-1", peerId)
        } else {
            SharedDomainMessage(Int32(6100 + index), "${prefix}-2", peerId)
        }
    })
}
