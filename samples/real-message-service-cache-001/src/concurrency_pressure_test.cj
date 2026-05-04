package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceConcurrencyTests {
    @TestCase
    public func concurrentSendAndReadShouldKeepCacheConsistent(): Unit {
        let peerId = PeerId(0, 3001)
        let adapter = ConcurrencyProbeAdapter(4000)
        adapter.seedHistory(peerId, buildHistory(peerId))
        let service = RealMessageService(adapter)

        let warmup = runWorkerGetMessages(service, peerId, 2, "worker-warmup")
        assertEqual("worker 预热应先拿到两条历史消息", "", 2, warmup.size)

        runConcurrentBurst(service, peerId, 48, 32)

        let snapshot = service.debugCachedMessages(peerId)
        assertEqual("压测后缓存 size 必须稳定为历史 2 + 并发发送 48", "", 50, snapshot.size)
        assertBurstMessagesPresent(snapshot, 48)
    }

    @TestCase
    public func heavyOperationsShouldStayOffMainContext(): Unit {
        let peerId = PeerId(0, 3002)
        let adapter = ConcurrencyProbeAdapter(2000)
        adapter.seedHistory(peerId, buildHistory(peerId))
        let service = RealMessageService(adapter)

        _ = runWorkerGetMessages(service, peerId, 2, "worker-fetch")
        _ = runWorkerSendMessage(service, peerId, "burst-0", "worker-send-0")
        _ = runWorkerSendMessage(service, peerId, "burst-1", "worker-send-1")

        assertNoMainContextLeak(adapter.debugInvocationLog(), "adapter:")
        assertNoMainContextLeak(service.debugThreadLog(), "cache:")
    }
}

func runConcurrentBurst(service: RealMessageService, peerId: PeerId, sendWorkers: Int64, readWorkers: Int64): Unit {
    let totalWorkers = sendWorkers + readWorkers
    let tasks = Array(totalWorkers, { index: Int64 =>
        spawn {
            if (index < sendWorkers) {
                let label = "worker-send-${index}"
                _ = runWorkerSendMessage(service, peerId, "burst-${index}", label)
            } else {
                let readIndex = index - sendWorkers
                let label = "worker-read-${readIndex}"
                _ = runWorkerGetMessages(service, peerId, 2, label)
            }
            0
        }
    })
    for (task in tasks) {
        _ = task.get()
    }
}

func runWorkerGetMessages(service: RealMessageService, peerId: PeerId, limit: Int32, label: String): Array<DomainMessage> {
    let task = spawn {
        setExecutionContext(label)
        let signal = service.getMessages(peerId, limit)
        service.debugDrainPromiseResolutions()
        signal.currentSnapshot()
    }
    task.get()
}

func runWorkerSendMessage(service: RealMessageService, peerId: PeerId, text: String, label: String): DomainMessage {
    let task = spawn {
        setExecutionContext(label)
        service.sendMessage(SendMessageParams(peerId, text))
    }
    task.get()
}

func assertBurstMessagesPresent(snapshot: Array<DomainMessage>, sendWorkers: Int64): Unit {
    var index: Int64 = 0
    while (index < sendWorkers) {
        let expected = "burst-${index}"
        assertEqual("缓存中必须包含 ${expected}", "", true, hasMessageText(snapshot, expected))
        index = index + 1
    }
}

func hasMessageText(snapshot: Array<DomainMessage>, expected: String): Bool {
    for (message in snapshot) {
        if (message.text == expected) {
            return true
        }
    }
    false
}

func assertNoMainContextLeak(entries: Array<String>, prefix: String): Unit {
    for (entry in entries) {
        if (entry.startsWith(prefix)) {
            assertEqual("重操作日志不得落在 main context: ${entry}", "", false, entry.endsWith(":main"))
        }
    }
}
