package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceDoubleFetchInvalidationTests {
    @TestCase
    public func debugInvalidateCacheShouldClearPeerCacheAndAdvanceEpoch(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5101)
        let adapter = DelayedHandoffProbeAdapter()
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)
        adapter.primeScenario("worker-fetch-A", buildDoubleFetchMessages(peerId, "double-fetch-a-tail"))

        _ = runWorkerDoubleFetchScenario(service, peerId, 2, "worker-fetch-A")
        assertEqual("warmup 后 cache 内必须已有 2 条消息", "", 2, service.debugCacheSize(peerId))

        let beforeEpoch = bridge.debugCurrentEpoch()
        let invalidationEpoch = service.debugInvalidateCache(peerId)

        assertEqual("invalidate 后 peer cache 必须被清空", "", 0, service.debugCacheSize(peerId))
        assertEqual("invalidate 必须显式推高 epoch", "", true, invalidationEpoch > beforeEpoch)
    }

    @TestCase
    public func forceRefreshDoubleFetchShouldLeaveOnlyBPayloadInUiObserverLog(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5102)
        let adapter = DelayedHandoffProbeAdapter()
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)
        adapter.primeScenario("worker-fetch-A", buildDoubleFetchMessages(peerId, "double-fetch-a-tail"))
        adapter.primeScenario("worker-force-refresh-B", buildDoubleFetchMessages(peerId, "double-fetch-b-tail"))

        bridge.delayNextHandoffFor("worker-fetch-A")
        _ = runWorkerDoubleFetchScenario(service, peerId, 2, "worker-fetch-A")
        let forced = runWorkerForceRefreshFetchScenario(service, peerId, 2, "worker-force-refresh-B")

        setExecutionContext("main")
        bridge.drainOnMain()
        bridge.releaseDelayedHandoffs()
        bridge.drainOnMain()

        assertEqual("force refresh fetch 必须拿到 B 快照", "", "double-fetch-b-tail", forced[forced.size - 1].text)
        assertEqual("observer 最终只能看到 B 尾消息", "", "double-fetch-b-tail", observer.lastMessageText())
        assertEqual("observer delivery log 中只能有 1 次有效 UI 交付", "", 1, observer.debugDeliveryLog().size)
        assertEqual("observer delivery log 必须只包含 B payload", "", true, deliveryLogContains(observer.debugDeliveryLog(), "double-fetch-b-tail"))
        assertEqual("observer delivery log 不得出现 A payload 幽灵交付", "", false, deliveryLogContains(observer.debugDeliveryLog(), "double-fetch-a-tail"))
        assertEqual("bridge 必须保留 force refresh 的 queued meta 证据", "", true, delayedDispatchLogContains(bridge.debugDispatchLog(), "refresh:queued-meta:worker-force-refresh-B"))
        assertEqual("bridge 必须保留 stale A discard 证据", "", true, delayedDispatchLogContains(bridge.debugDispatchLog(), "refresh:discarded:stale-epoch:worker-fetch-A"))
    }
}

func runWorkerDoubleFetchScenario(service: RealMessageService, peerId: PeerId, limit: Int32, workerLabel: String): Array<DomainMessage> {
    let task = spawn {
        setExecutionContext(workerLabel)
        let signal = service.getMessages(peerId, limit)
        service.debugDrainPromiseResolutions()
        signal.currentSnapshot()
    }
    task.get()
}

func runWorkerForceRefreshFetchScenario(service: RealMessageService, peerId: PeerId, limit: Int32, workerLabel: String): Array<DomainMessage> {
    let task = spawn {
        setExecutionContext(workerLabel)
        _ = service.debugInvalidateCache(peerId)
        let signal = service.getMessages(peerId, limit)
        service.debugDrainPromiseResolutions()
        signal.currentSnapshot()
    }
    task.get()
}

func buildDoubleFetchMessages(peerId: PeerId, tailText: String): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(9101, "seed-${tailText}", peerId)
        } else {
            DomainMessage(9102, tailText, peerId)
        }
    })
}

func deliveryLogContains(entries: Array<String>, fragment: String): Bool {
    for (entry in entries) {
        if (entry.contains(fragment)) {
            return true
        }
    }
    false
}
