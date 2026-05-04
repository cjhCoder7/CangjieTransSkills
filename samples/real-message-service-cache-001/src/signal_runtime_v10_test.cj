package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*
import std.sync.*

@Test
public class RealMessageServiceSignalRuntimeV10Tests {
    @TestCase
    public func samePeerShouldReuseSignalInstanceUntilInvalidation(): Unit {
        let peerId = PeerId(0, 5501)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV10History(peerId))
        let service = RealMessageService(adapter)

        let firstSignal = service.getMessages(peerId, 2)
        let secondSignal = service.getMessages(peerId, 2)

        assertEqual("同一 peer 的 signal 在 invalidation 前必须复用同一实例", "", firstSignal.runtimeId(), secondSignal.runtimeId())

        _ = service.debugInvalidateCache(peerId)
        let replacementSignal = service.getMessages(peerId, 2)

        assertEqual("invalidate 后必须创建新的 signal 实例", "", true, replacementSignal.runtimeId() != firstSignal.runtimeId())
    }

    @TestCase
    public func signalVersionShouldAdvanceMonotonicallyAcrossFetchAndSend(): Unit {
        let peerId = PeerId(0, 5502)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV10History(peerId))
        let service = RealMessageService(adapter)
        let signal = service.getMessages(peerId, 2)
        let observer = RecordingSignalRuntimeObserver()

        service.debugDrainPromiseResolutions()
        _ = signal.observeRuntime(observer)
        assertEqual("首次 fetch 完成后 signal version 应推进到 1", "", 1, signal.updateVersion())

        let sent = service.sendMessage(SendMessageParams(peerId, "v10-runtime-send"))

        assertEqual("send 后 signal version 必须继续推进", "", 2, signal.updateVersion())
        assertEqual("runtime observer 应看到一次 send 更新", "", 1, observer.notificationCount())
        assertEqual("observer 记录的最后版本号必须与 signal 一致", "", 2, observer.lastVersion())
        assertEqual("observer 记录的尾消息必须与发送结果一致", "", sent.text, observer.lastTailText())
    }

    @TestCase
    public func invalidateShouldDetachOldSignalFromFutureUpdates(): Unit {
        let peerId = PeerId(0, 5503)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(peerId, buildV10History(peerId))
        let service = RealMessageService(adapter)
        let oldSignal = service.getMessages(peerId, 2)
        let oldObserver = RecordingSignalRuntimeObserver()

        _ = oldSignal.observeRuntime(oldObserver)
        _ = service.debugInvalidateCache(peerId)

        let newSignal = service.getMessages(peerId, 2)
        let newObserver = RecordingSignalRuntimeObserver()
        _ = newSignal.observeRuntime(newObserver)
        let sent = service.sendMessage(SendMessageParams(peerId, "v10-post-invalidate-send"))

        assertEqual("invalidate 后旧 signal 不得再收到后续更新", "", 0, oldObserver.notificationCount())
        assertEqual("invalidate 后新 signal 必须接到新的 send 更新", "", 1, newObserver.notificationCount())
        assertEqual("新 signal observer 必须看到发送后的尾消息", "", sent.text, newObserver.lastTailText())
        assertEqual("旧新 signal 的 runtimeId 必须不同", "", true, oldSignal.runtimeId() != newSignal.runtimeId())
    }
}

class RecordingSignalRuntimeObserver <: SignalRuntimeObserver {
    private let observerLock = Mutex()
    private var total: Int64 = 0
    private var lastSeenVersion: Int64 = 0
    private var lastSeenTail: String = ""

    init() {}

    public func onSignalUpdated(signalId: Int64, version: Int64, messages: Array<DomainMessage>): Unit {
        _ = signalId
        this.observerLock.lock()
        this.total = this.total + 1
        this.lastSeenVersion = version
        this.lastSeenTail = if (messages.size == 0) {
            ""
        } else {
            messages[messages.size - 1].text
        }
        this.observerLock.unlock()
    }

    func notificationCount(): Int64 {
        this.observerLock.lock()
        let snapshot = this.total
        this.observerLock.unlock()
        snapshot
    }

    func lastVersion(): Int64 {
        this.observerLock.lock()
        let snapshot = this.lastSeenVersion
        this.observerLock.unlock()
        snapshot
    }

    func lastTailText(): String {
        this.observerLock.lock()
        let snapshot = this.lastSeenTail
        this.observerLock.unlock()
        snapshot
    }
}

func buildV10History(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(12001, "v10-history-1", peerId)
        } else {
            DomainMessage(12002, "v10-history-2", peerId)
        }
    })
}
