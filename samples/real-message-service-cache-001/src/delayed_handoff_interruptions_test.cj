package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceDelayedHandoffTests {
    @TestCase
    public func epochRegisterShouldAdvanceMonotonicallyForNewHandoffs(): Unit {
        let register = MutexEpochRegister()
        assertEqual("epoch 第一次递增必须返回 1", "", 1, register.nextEpoch())
        assertEqual("epoch 第二次递增必须返回 2", "", 2, register.nextEpoch())
        assertEqual("currentEpoch 必须暴露最新世代", "", 2, register.currentEpoch())
    }

    @TestCase
    public func delayedHandoffShouldDiscardStaleEpochBeforeUiDelivery(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5001)
        let adapter = DelayedHandoffProbeAdapter()
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)
        adapter.primeScenario("worker-fetch-A", buildDelayedScenarioMessages(peerId, "request-a-tail"))
        bridge.delayNextHandoffFor("worker-fetch-A")

        _ = runWorkerDelayedFetchScenario(service, peerId, 2, "worker-fetch-A")
        let sent = runWorkerSendMessage(service, peerId, "request-b-tail", "worker-send-B")

        setExecutionContext("main")
        bridge.drainOnMain()
        bridge.releaseDelayedHandoffs()
        bridge.drainOnMain()

        assertEqual("最终 UI 只能看到 B 的尾消息", "", sent.text, observer.lastMessageText())
        assertEqual("stale A 不得落到 UI", "", 1, observer.notificationCount())
        assertEqual(
            "必须留下 stale discard 日志",
            "",
            true,
            delayedDispatchLogContains(bridge.debugDispatchLog(), "refresh:discarded:stale-epoch:worker-fetch-A"),
        )
    }

    @TestCase
    public func interruptionShouldNotLeakCacheWriteLockWithinBudget(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5002)
        let adapter = DelayedHandoffProbeAdapter()
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)
        adapter.primeScenario("worker-fetch-A", buildDelayedScenarioMessages(peerId, "request-a-tail"))
        bridge.delayNextHandoffFor("worker-fetch-A")
        _ = runWorkerDelayedFetchScenario(service, peerId, 2, "worker-fetch-A")
        _ = runWorkerSendMessage(service, peerId, "request-b-tail", "worker-send-B")

        setExecutionContext("main")
        bridge.drainOnMain()
        bridge.releaseDelayedHandoffs()
        bridge.drainOnMain()

        assertEqual("中断后必须能在预算内重新获取 cache 写锁", "", true, service.debugAcquireCacheWriteLockWithin(50))
    }
}

func runWorkerDelayedFetchScenario(service: RealMessageService, peerId: PeerId, limit: Int32, workerLabel: String): Array<DomainMessage> {
    let task = spawn {
        setExecutionContext(workerLabel)
        let signal = service.getMessages(peerId, limit)
        service.debugDrainPromiseResolutions()
        signal.currentSnapshot()
    }
    task.get()
}

func buildDelayedScenarioMessages(peerId: PeerId, tailText: String): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(8101, "seed-${tailText}", peerId)
        } else {
            DomainMessage(8102, tailText, peerId)
        }
    })
}

func delayedDispatchLogContains(entries: Array<String>, fragment: String): Bool {
    for (entry in entries) {
        if (entry.startsWith(fragment)) {
            return true
        }
    }
    false
}
