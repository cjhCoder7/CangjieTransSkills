package phase07_shared_service_refresh_harness

import std.collection.*
import std.sync.*

// Phase07 P1-6 relocates the shared service / refresh surface into a static package.

let EXECUTION_CONTEXT = ThreadLocal<String>()

public func setExecutionContext(label: String): Unit {
    EXECUTION_CONTEXT.set(label)
}

public func currentExecutionContext(): String {
    match (EXECUTION_CONTEXT.get()) {
        case Some(value) => value
        case None => "main"
    }
}

public class PeerId {
    public let namespace: Int32
    public let id: Int64

    public init(namespace: Int32, id: Int64) {
        this.namespace = namespace
        this.id = id
    }
}

public class DomainMessage {
    public let id: Int32
    public let text: String
    public let peerId: PeerId

    public init(id: Int32, text: String, peerId: PeerId) {
        this.id = id
        this.text = text
        this.peerId = peerId
    }
}

public class SendMessageParams {
    public let peerId: PeerId
    public let text: String

    public init(peerId: PeerId, text: String) {
        this.peerId = peerId
        this.text = text
    }
}

public class MessageSignal {
    private let signalLock = Mutex()
    private var snapshot = emptyMessages()

    public init(initialSnapshot: Array<DomainMessage>) {
        this.snapshot = cloneMessages(initialSnapshot)
    }

    public func currentSnapshot(): Array<DomainMessage> {
        this.signalLock.lock()
        let current = cloneMessages(this.snapshot)
        this.signalLock.unlock()
        current
    }

    func replace(messages: Array<DomainMessage>): Unit {
        this.signalLock.lock()
        this.snapshot = cloneMessages(messages)
        this.signalLock.unlock()
    }
}

class GetHistoryParams {
    let peerId: PeerId
    let limit: Int32

    init(peerId: PeerId, limit: Int32) {
        this.peerId = peerId
        this.limit = limit
    }
}

class PendingPromiseResolution {
    let peerId: PeerId
    let kind: String
    let payload: Array<DomainMessage>

    init(peerId: PeerId, kind: String, payload: Array<DomainMessage>) {
        this.peerId = peerId
        this.kind = kind
        this.payload = cloneMessages(payload)
    }
}

public interface IMTProtoAdapter {
    func getHistory(peerId: PeerId, _limit: Int32): Array<DomainMessage>
    func sendMessage(peerId: PeerId, text: String): DomainMessage
}

public interface DatasetRefreshObserver {
    func onDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
}

public interface DatasetRefreshBridge {
    func notifyDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
    func debugForceAdvanceEpoch(reason: String): Int64
}

public interface EpochRegister {
    func nextEpoch(): Int64
    func currentEpoch(): Int64
}

public class MutexEpochRegister <: EpochRegister {
    private let epochLock = Mutex()
    private var currentValue: Int64 = 0

    public init() {}

    public func nextEpoch(): Int64 {
        this.epochLock.lock()
        this.currentValue = this.currentValue + 1
        let snapshot = this.currentValue
        this.epochLock.unlock()
        snapshot
    }

    public func currentEpoch(): Int64 {
        this.epochLock.lock()
        let snapshot = this.currentValue
        this.epochLock.unlock()
        snapshot
    }
}

public class PendingDatasetRefresh {
    public let peerId: PeerId
    public let messages: Array<DomainMessage>
    public let sourceContext: String
    public let epoch: Int64

    public init(peerId: PeerId, messages: Array<DomainMessage>, sourceContext: String, epoch: Int64) {
        this.peerId = peerId
        this.messages = cloneMessages(messages)
        this.sourceContext = sourceContext
        this.epoch = epoch
    }
}

public class NoopDatasetRefreshBridge <: DatasetRefreshBridge {
    public init() {}

    public func notifyDatasetChanged(_peerId: PeerId, _messages: Array<DomainMessage>): Unit {
        _ = _peerId
        _ = _messages
    }

    public func debugForceAdvanceEpoch(_reason: String): Int64 {
        _ = _reason
        0
    }
}

public class MainContextDatasetRefreshBridge <: DatasetRefreshBridge {
    private let queueLock = Mutex()
    private var pendingQueue = emptyPendingRefreshes()
    private let epochRegister: EpochRegister
    private let observer: DatasetRefreshObserver

    public init(observer: DatasetRefreshObserver) {
        this.observer = observer
        this.epochRegister = MutexEpochRegister()
    }

    public func notifyDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        let source = currentExecutionContext()
        let epoch = this.epochRegister.currentEpoch()
        let pending = PendingDatasetRefresh(peerId, messages, source, epoch)
        this.queueLock.lock()
        this.pendingQueue = appendPendingRefresh(this.pendingQueue, pending)
        this.queueLock.unlock()
    }

    public func pendingRefreshCount(): Int64 {
        this.queueLock.lock()
        let size = this.pendingQueue.size
        this.queueLock.unlock()
        size
    }

    public func drainOnMain(): Unit {
        this.queueLock.lock()
        let pending = clonePendingRefreshes(this.pendingQueue)
        this.pendingQueue = emptyPendingRefreshes()
        this.queueLock.unlock()
        let currentEpoch = this.epochRegister.currentEpoch()

        for (item in pending) {
            if (item.epoch >= currentEpoch) {
                this.observer.onDatasetChanged(item.peerId, item.messages)
            }
        }
    }

    public func debugForceAdvanceEpoch(_reason: String): Int64 {
        _ = _reason
        this.epochRegister.nextEpoch()
    }
}

public class RealMessageService {
    private let messageCache = HashMap<String, Array<DomainMessage>>()
    private let messageSignals = HashMap<String, MessageSignal>()
    private let adapter: IMTProtoAdapter
    private let cacheLock = Mutex()
    private let promiseLock = Mutex()
    private var pendingPromiseResolutions = emptyPendingPromiseResolutions()
    private var refreshBridge: DatasetRefreshBridge

    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
        this.refreshBridge = NoopDatasetRefreshBridge()
    }

    public func attachRefreshBridge(bridge: DatasetRefreshBridge): Unit {
        this.refreshBridge = bridge
    }

    public func getMessages(peerId: PeerId, limit: Int32): MessageSignal {
        let key = this.buildCacheKey(peerId)
        this.cacheLock.lock()
        let hadSignal = this.messageSignals.contains(key)
        let signal = if (hadSignal) {
            match (this.messageSignals.get(key)) {
                case Some(existing) => existing
                case None => MessageSignal(emptyMessages())
            }
        } else {
            let initialSnapshot = match (this.messageCache.get(key)) {
                case Some(messages) => cloneMessages(messages)
                case None => emptyMessages()
            }
            let created = MessageSignal(initialSnapshot)
            this.messageSignals[key] = created
            created
        }
        this.cacheLock.unlock()
        if (!hadSignal) {
            _ = this.fetchMessages(GetHistoryParams(peerId, limit))
        }
        signal
    }

    private func fetchMessages(params: GetHistoryParams): Array<DomainMessage> {
        let messages = this.adapter.getHistory(params.peerId, params.limit)
        this.enqueuePromiseResolution(PendingPromiseResolution(params.peerId, "fetch", messages))
        messages
    }

    public func sendMessage(params: SendMessageParams): DomainMessage {
        let message = this.adapter.sendMessage(params.peerId, params.text)
        this.cacheLock.lock()
        let updated = this.appendMessageToCacheLocked(params.peerId, message)
        let key = this.buildCacheKey(params.peerId)
        this.replaceExistingSignalLocked(key, updated)
        this.cacheLock.unlock()
        this.publishDatasetChanged(params.peerId, updated)
        message
    }

    public func debugDrainPromiseResolutions(): Unit {
        this.promiseLock.lock()
        let pending = clonePendingPromiseResolutions(this.pendingPromiseResolutions)
        this.pendingPromiseResolutions = emptyPendingPromiseResolutions()
        this.promiseLock.unlock()

        for (item in pending) {
            if (item.kind == "fetch") {
                this.applyFetchPromiseResolution(item)
            }
        }
    }

    public func debugInvalidateCache(peerId: PeerId): Int64 {
        let key = this.buildCacheKey(peerId)
        this.cacheLock.lock()
        if (this.messageCache.contains(key)) {
            this.messageCache.remove(key)
        }
        if (this.messageSignals.contains(key)) {
            this.messageSignals.remove(key)
        }
        this.cacheLock.unlock()

        this.promiseLock.lock()
        let pending = clonePendingPromiseResolutions(this.pendingPromiseResolutions)
        this.pendingPromiseResolutions = emptyPendingPromiseResolutions()
        for (item in pending) {
            if (!(item.peerId.namespace == peerId.namespace && item.peerId.id == peerId.id)) {
                this.pendingPromiseResolutions = appendPendingPromiseResolution(this.pendingPromiseResolutions, item)
            }
        }
        this.promiseLock.unlock()

        this.refreshBridge.debugForceAdvanceEpoch("invalidate:${key}")
    }

    private func replaceExistingSignalLocked(key: String, messages: Array<DomainMessage>): Unit {
        if (this.messageSignals.contains(key)) {
            let signal = match (this.messageSignals.get(key)) {
                case Some(existing) => existing
                case None => MessageSignal(emptyMessages())
            }
            signal.replace(messages)
        }
    }

    private func appendMessageToCacheLocked(peerId: PeerId, message: DomainMessage): Array<DomainMessage> {
        let key = this.buildCacheKey(peerId)
        let updated = match (this.messageCache.get(key)) {
            case Some(messages) => appendMessage(messages, message)
            case None => Array<DomainMessage>(1, { _: Int64 => message })
        }
        this.messageCache[key] = updated
        updated
    }

    private func enqueuePromiseResolution(item: PendingPromiseResolution): Unit {
        this.promiseLock.lock()
        this.pendingPromiseResolutions = appendPendingPromiseResolution(this.pendingPromiseResolutions, item)
        this.promiseLock.unlock()
    }

    private func applyFetchPromiseResolution(item: PendingPromiseResolution): Unit {
        let key = this.buildCacheKey(item.peerId)
        let messages = cloneMessages(item.payload)
        this.cacheLock.lock()
        this.messageCache[key] = cloneMessages(messages)
        this.replaceExistingSignalLocked(key, messages)
        this.cacheLock.unlock()
        this.publishDatasetChanged(item.peerId, messages)
    }

    private func publishDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        this.refreshBridge.notifyDatasetChanged(peerId, cloneMessages(messages))
    }

    private func buildCacheKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

public func runWorkerGetMessages(service: RealMessageService, peerId: PeerId, limit: Int32, label: String): Array<DomainMessage> {
    let task = spawn {
        setExecutionContext(label)
        let signal = service.getMessages(peerId, limit)
        service.debugDrainPromiseResolutions()
        signal.currentSnapshot()
    }
    task.get()
}

public func appendMessage(source: Array<DomainMessage>, item: DomainMessage): Array<DomainMessage> {
    Array<DomainMessage>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

func appendPendingRefresh(source: Array<PendingDatasetRefresh>, item: PendingDatasetRefresh): Array<PendingDatasetRefresh> {
    Array<PendingDatasetRefresh>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

public func cloneMessages(source: Array<DomainMessage>): Array<DomainMessage> {
    Array<DomainMessage>(source.size, { index: Int64 => source[index] })
}

func clonePendingRefreshes(source: Array<PendingDatasetRefresh>): Array<PendingDatasetRefresh> {
    Array<PendingDatasetRefresh>(source.size, { index: Int64 => source[index] })
}

func appendPendingPromiseResolution(source: Array<PendingPromiseResolution>, item: PendingPromiseResolution): Array<PendingPromiseResolution> {
    Array<PendingPromiseResolution>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

func clonePendingPromiseResolutions(source: Array<PendingPromiseResolution>): Array<PendingPromiseResolution> {
    Array<PendingPromiseResolution>(source.size, { index: Int64 => source[index] })
}

func emptyPendingPromiseResolutions(): Array<PendingPromiseResolution> {
    let placeholderPeerId = PeerId(0, 0)
    Array<PendingPromiseResolution>(0, { _: Int64 =>
        PendingPromiseResolution(placeholderPeerId, "", emptyMessages())
    })
}

public func emptyMessages(): Array<DomainMessage> {
    let placeholderPeerId = PeerId(0, 0)
    Array<DomainMessage>(0, { _: Int64 =>
        DomainMessage(0, "", placeholderPeerId)
    })
}

func emptyPendingRefreshes(): Array<PendingDatasetRefresh> {
    let placeholderPeerId = PeerId(0, 0)
    Array<PendingDatasetRefresh>(0, { _: Int64 =>
        PendingDatasetRefresh(placeholderPeerId, emptyMessages(), "", 0)
    })
}

public func takeMessages(source: Array<DomainMessage>, limit: Int32): Array<DomainMessage> {
    let boundedSize = if (Int64(limit) < source.size) {
        Int64(limit)
    } else {
        source.size
    }
    Array<DomainMessage>(boundedSize, { index: Int64 => source[index] })
}
