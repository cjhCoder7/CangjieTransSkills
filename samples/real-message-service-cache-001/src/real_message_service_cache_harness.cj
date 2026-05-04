package real_message_service_cache_001

import std.collection.*
import std.sync.*

let EXECUTION_CONTEXT = ThreadLocal<String>()

let SIGNAL_RUNTIME_ID_LOCK = Mutex()
var NEXT_SIGNAL_RUNTIME_ID: Int64 = 0

func setExecutionContext(label: String): Unit {
    EXECUTION_CONTEXT.set(label)
}

func currentExecutionContext(): String {
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

interface SignalRuntimeObserver {
    func onSignalUpdated(signalId: Int64, version: Int64, messages: Array<DomainMessage>): Unit
}

class SignalRuntimeObserverRegistration {
    let observerId: Int64
    let observer: SignalRuntimeObserver

    init(observerId: Int64, observer: SignalRuntimeObserver) {
        this.observerId = observerId
        this.observer = observer
    }
}

public class MessageSignal {
    private let signalLock = Mutex()
    private let signalRuntimeId: Int64
    private var snapshot = emptyMessages()
    private var version: Int64 = 0
    private var nextObserverId: Int64 = 0
    private var runtimeObservers = emptySignalRuntimeObserverRegistrations()

    public init(initialSnapshot: Array<DomainMessage>) {
        this.signalRuntimeId = allocateSignalRuntimeId()
        this.snapshot = cloneMessages(initialSnapshot)
    }

    public func currentSnapshot(): Array<DomainMessage> {
        this.signalLock.lock()
        let current = cloneMessages(this.snapshot)
        this.signalLock.unlock()
        current
    }

    func runtimeId(): Int64 {
        this.signalRuntimeId
    }

    func updateVersion(): Int64 {
        this.signalLock.lock()
        let currentVersion = this.version
        this.signalLock.unlock()
        currentVersion
    }

    func observeRuntime(observer: SignalRuntimeObserver): Int64 {
        this.signalLock.lock()
        this.nextObserverId = this.nextObserverId + 1
        let observerId = this.nextObserverId
        this.runtimeObservers = appendSignalRuntimeObserverRegistration(this.runtimeObservers, SignalRuntimeObserverRegistration(observerId, observer))
        this.signalLock.unlock()
        observerId
    }

    func replace(messages: Array<DomainMessage>): Unit {
        let nextSnapshot = cloneMessages(messages)
        var observerSnapshot = emptySignalRuntimeObserverRegistrations()
        var nextVersion: Int64 = 0
        this.signalLock.lock()
        this.snapshot = cloneMessages(nextSnapshot)
        this.version = this.version + 1
        nextVersion = this.version
        observerSnapshot = cloneSignalRuntimeObserverRegistrations(this.runtimeObservers)
        this.signalLock.unlock()
        for (registration in observerSnapshot) {
            registration.observer.onSignalUpdated(this.signalRuntimeId, nextVersion, nextSnapshot)
        }
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

interface IMTProtoAdapter {
    func getHistory(peerId: PeerId, _limit: Int32): Array<DomainMessage>
    func sendMessage(peerId: PeerId, text: String): DomainMessage
}

interface DatasetRefreshObserver {
    func onDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
}

interface DatasetRefreshBridge {
    func notifyDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
    func debugForceAdvanceEpoch(reason: String): Int64
}

interface EpochRegister {
    func nextEpoch(): Int64
    func currentEpoch(): Int64
}

class MutexEpochRegister <: EpochRegister {
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

class PendingDatasetRefresh {
    public let peerId: PeerId
    public let messages: Array<DomainMessage>
    public let sourceContext: String
    public let epoch: Int64

    public init(peerId: PeerId, messages: Array<DomainMessage>, sourceContext: String, epoch: Int64) {
        this.peerId = peerId
        this.messages = messages
        this.sourceContext = sourceContext
        this.epoch = epoch
    }
}

class NoopDatasetRefreshBridge <: DatasetRefreshBridge {
    public init() {}

    public func notifyDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        _ = peerId
        _ = messages
    }

    public func debugForceAdvanceEpoch(reason: String): Int64 {
        _ = reason
        0
    }
}

class MockUiDatasetObserver <: DatasetRefreshObserver {
    private let observerLock = Mutex()
    private var notificationTotal: Int64 = 0
    private var lastSnapshot = emptyMessages()
    private var lastDelivery: String = ""
    private var lastPeer = PeerId(0, 0)
    private var deliveryLog = emptyStrings()

    public init() {}

    public func onDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        this.observerLock.lock()
        this.notificationTotal = this.notificationTotal + 1
        this.lastPeer = peerId
        this.lastSnapshot = cloneMessages(messages)
        this.lastDelivery = currentExecutionContext()
        this.deliveryLog = appendString(this.deliveryLog, buildObserverDeliveryLogEntry(peerId, messages))
        this.observerLock.unlock()
    }

    public func notificationCount(): Int64 {
        this.observerLock.lock()
        let count = this.notificationTotal
        this.observerLock.unlock()
        count
    }

    public func lastDatasetSize(): Int64 {
        this.observerLock.lock()
        let size = this.lastSnapshot.size
        this.observerLock.unlock()
        size
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
        let context = this.lastDelivery
        this.observerLock.unlock()
        context
    }

    public func lastPeerId(): Int64 {
        this.observerLock.lock()
        let peerId = this.lastPeer.id
        this.observerLock.unlock()
        peerId
    }

    public func debugDeliveryLog(): Array<String> {
        this.observerLock.lock()
        let snapshot = cloneStrings(this.deliveryLog)
        this.observerLock.unlock()
        snapshot
    }
}

class MainContextDatasetRefreshBridge <: DatasetRefreshBridge {
    private let queueLock = Mutex()
    private let logLock = Mutex()
    private var pendingQueue = emptyPendingRefreshes()
    private var delayedQueue = emptyPendingRefreshes()
    private var delayedSources = emptyStrings()
    private var dispatchLog = emptyStrings()
    private var latestDeliveredEpoch: Int64 = 0
    private let epochRegister: EpochRegister
    private let observer: DatasetRefreshObserver

    public init(observer: DatasetRefreshObserver) {
        this.observer = observer
        this.epochRegister = MutexEpochRegister()
    }

    public func notifyDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        let source = currentExecutionContext()
        let epoch = this.epochRegister.nextEpoch()
        let pending = PendingDatasetRefresh(peerId, cloneMessages(messages), source, epoch)

        this.queueLock.lock()
        let shouldDelay = this.consumeDelayedSourceLocked(source)
        if (shouldDelay) {
            this.delayedQueue = appendPendingRefresh(this.delayedQueue, pending)
        } else {
            this.pendingQueue = appendPendingRefresh(this.pendingQueue, pending)
        }
        this.queueLock.unlock()

        if (shouldDelay) {
            this.appendDispatchLog("refresh:queued-delayed:${source}")
            this.appendDispatchLog("refresh:queued-delayed-meta:${source}:epoch=${epoch}")
        } else {
            this.appendDispatchLog("refresh:queued:${source}")
            this.appendDispatchLog("refresh:queued-meta:${source}:epoch=${epoch}")
        }
    }

    public func delayNextHandoffFor(sourceContext: String): Unit {
        this.queueLock.lock()
        this.delayedSources = appendString(this.delayedSources, sourceContext)
        this.queueLock.unlock()
        this.appendDispatchLog("refresh:delay-armed:${sourceContext}")
    }

    public func releaseDelayedHandoffs(): Unit {
        this.queueLock.lock()
        let delayed = clonePendingRefreshes(this.delayedQueue)
        this.delayedQueue = emptyPendingRefreshes()
        this.queueLock.unlock()

        for (item in delayed) {
            this.queueLock.lock()
            this.pendingQueue = appendPendingRefresh(this.pendingQueue, item)
            this.queueLock.unlock()
            this.appendDispatchLog("refresh:released:${item.sourceContext}:epoch=${item.epoch}")
        }
    }

    public func pendingRefreshCount(): Int64 {
        this.queueLock.lock()
        let size = this.pendingQueue.size
        this.queueLock.unlock()
        size
    }

    public func delayedRefreshCount(): Int64 {
        this.queueLock.lock()
        let size = this.delayedQueue.size
        this.queueLock.unlock()
        size
    }

    public func drainOnMain(): Unit {
        this.queueLock.lock()
        let pending = clonePendingRefreshes(this.pendingQueue)
        this.pendingQueue = emptyPendingRefreshes()
        this.queueLock.unlock()
        for (item in pending) {
            this.queueLock.lock()
            let currentEpoch = this.epochRegister.currentEpoch()
            let stale = item.epoch < currentEpoch
            if (!stale && item.epoch > this.latestDeliveredEpoch) {
                this.latestDeliveredEpoch = item.epoch
            }
            let latestEpoch = if (currentEpoch > this.latestDeliveredEpoch) {
                currentEpoch
            } else {
                this.latestDeliveredEpoch
            }
            this.queueLock.unlock()
            if (stale) {
                this.appendDispatchLog("refresh:discarded:stale-epoch:${item.sourceContext}:${item.epoch}->${latestEpoch}")
            } else {
                this.appendDispatchLog("refresh:delivered:${currentExecutionContext()}:source=${item.sourceContext}:epoch=${item.epoch}")
                this.observer.onDatasetChanged(item.peerId, item.messages)
            }
        }
    }

    public func debugForceAdvanceEpoch(reason: String): Int64 {
        let forcedEpoch = this.epochRegister.nextEpoch()
        this.appendDispatchLog("refresh:epoch-forced:${reason}:epoch=${forcedEpoch}")
        forcedEpoch
    }

    public func debugCurrentEpoch(): Int64 {
        this.epochRegister.currentEpoch()
    }

    public func debugDispatchLog(): Array<String> {
        this.logLock.lock()
        let snapshot = cloneStrings(this.dispatchLog)
        this.logLock.unlock()
        snapshot
    }

    private func consumeDelayedSourceLocked(target: String): Bool {
        let sources = cloneStrings(this.delayedSources)
        var found = false
        this.delayedSources = emptyStrings()
        for (entry in sources) {
            if (!found && entry == target) {
                found = true
            } else {
                this.delayedSources = appendString(this.delayedSources, entry)
            }
        }
        found
    }

    private func appendDispatchLog(entry: String): Unit {
        this.logLock.lock()
        this.dispatchLog = appendString(this.dispatchLog, entry)
        this.logLock.unlock()
    }
}

class FakeMessageAdapter <: IMTProtoAdapter {
    private let seededHistory = HashMap<String, Array<DomainMessage>>()
    private var historyCallCounter: Int64 = 0
    private var sendCallCounter: Int64 = 0
    private var nextMessageId: Int32 = 9000

    public init() {}

    public func seedHistory(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        this.seededHistory[this.buildCacheKey(peerId)] = messages
    }

    public func getHistoryCallCount(): Int64 {
        this.historyCallCounter
    }

    public func sendMessageCallCount(): Int64 {
        this.sendCallCounter
    }

    public func getHistory(peerId: PeerId, limit: Int32): Array<DomainMessage> {
        this.historyCallCounter = this.historyCallCounter + 1
        match (this.seededHistory.get(this.buildCacheKey(peerId))) {
            case Some(messages) => takeMessages(messages, limit)
            case None => emptyMessages()
        }
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.sendCallCounter = this.sendCallCounter + 1
        this.nextMessageId = this.nextMessageId + 1
        DomainMessage(this.nextMessageId, text, peerId)
    }

    private func buildCacheKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

class DirtyTLMessage {
    public let constructorId: Int32
    public let payloadText: String
    public let peerId: PeerId
    public let wireBytes: Array<UInt8>

    public init(constructorId: Int32, payloadText: String, peerId: PeerId, wireBytes: Array<UInt8>) {
        this.constructorId = constructorId
        this.payloadText = payloadText
        this.peerId = peerId
        this.wireBytes = wireBytes
    }
}

class PurifyingMessageAdapter <: IMTProtoAdapter {
    private let dirtyHistory = HashMap<String, Array<DirtyTLMessage>>()
    private var dirtyOutboundText: String = ""
    private var sendCallCounter: Int64 = 0
    private var historyCallCounter: Int64 = 0
    private var nextMessageId: Int32 = 12000

    public init() {}

    public func seedDirtyHistory(peerId: PeerId, messages: Array<DirtyTLMessage>): Unit {
        this.dirtyHistory[this.buildCacheKey(peerId)] = messages
    }

    public func seedDirtyOutboundText(text: String): Unit {
        this.dirtyOutboundText = text
    }

    public func getHistory(peerId: PeerId, limit: Int32): Array<DomainMessage> {
        this.historyCallCounter = this.historyCallCounter + 1
        match (this.dirtyHistory.get(this.buildCacheKey(peerId))) {
            case Some(messages) => this.mapDirtyMessages(messages, limit)
            case None => emptyMessages()
        }
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.sendCallCounter = this.sendCallCounter + 1
        this.nextMessageId = this.nextMessageId + 1
        let outbound = if (this.dirtyOutboundText == "") {
            text
        } else {
            this.dirtyOutboundText
        }
        DomainMessage(this.nextMessageId, sanitizeProtocolText(outbound), peerId)
    }

    private func mapDirtyMessages(source: Array<DirtyTLMessage>, limit: Int32): Array<DomainMessage> {
        let bounded = if (Int64(limit) < source.size) {
            Int64(limit)
        } else {
            source.size
        }
        Array<DomainMessage>(bounded, { index: Int64 =>
            let item = source[index]
            DomainMessage(item.constructorId, sanitizeProtocolText(item.payloadText), item.peerId)
        })
    }

    private func buildCacheKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

class ConcurrencyProbeAdapter <: IMTProtoAdapter {
    private let seededHistory = HashMap<String, Array<DomainMessage>>()
    private let historyLock = Mutex()
    private let counterLock = Mutex()
    private let logLock = Mutex()
    private var invocationLog = emptyStrings()
    private var nextMessageId: Int32 = 20000
    private let artificialSpin: Int64

    public init(artificialSpin: Int64) {
        this.artificialSpin = artificialSpin
    }

    public func seedHistory(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        this.historyLock.lock()
        this.seededHistory[this.buildCacheKey(peerId)] = messages
        this.historyLock.unlock()
    }

    public func getHistory(peerId: PeerId, limit: Int32): Array<DomainMessage> {
        this.appendInvocation("adapter:getHistory")
        spinWait(this.artificialSpin)
        this.historyLock.lock()
        let result = match (this.seededHistory.get(this.buildCacheKey(peerId))) {
            case Some(messages) => takeMessages(messages, limit)
            case None => emptyMessages()
        }
        this.historyLock.unlock()
        result
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.appendInvocation("adapter:send")
        spinWait(this.artificialSpin)
        this.counterLock.lock()
        this.nextMessageId = this.nextMessageId + 1
        let nextId = this.nextMessageId
        this.counterLock.unlock()
        DomainMessage(nextId, text, peerId)
    }

    public func debugInvocationLog(): Array<String> {
        this.logLock.lock()
        let snapshot = cloneStrings(this.invocationLog)
        this.logLock.unlock()
        snapshot
    }

    private func appendInvocation(prefix: String): Unit {
        this.logLock.lock()
        this.invocationLog = appendString(this.invocationLog, "${prefix}:${currentExecutionContext()}")
        this.logLock.unlock()
    }

    private func buildCacheKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

class DelayedHandoffProbeAdapter <: IMTProtoAdapter {
    private let seededHistory = HashMap<String, Array<DomainMessage>>()
    private let historyLock = Mutex()
    private let counterLock = Mutex()
    private let logLock = Mutex()
    private var invocationLog = emptyStrings()
    private var nextMessageId: Int32 = 30000

    public init() {}

    public func primeScenario(label: String, messages: Array<DomainMessage>): Unit {
        this.historyLock.lock()
        this.seededHistory[label] = cloneMessages(messages)
        this.historyLock.unlock()
    }

    public func getHistory(peerId: PeerId, _limit: Int32): Array<DomainMessage> {
        _ = peerId
        _ = _limit
        let label = currentExecutionContext()
        this.appendInvocation("adapter:getHistory:${label}")
        this.historyLock.lock()
        let result = match (this.seededHistory.get(label)) {
            case Some(messages) => cloneMessages(messages)
            case None => emptyMessages()
        }
        this.historyLock.unlock()
        result
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.appendInvocation("adapter:send:${currentExecutionContext()}")
        this.counterLock.lock()
        this.nextMessageId = this.nextMessageId + 1
        let nextId = this.nextMessageId
        this.counterLock.unlock()
        DomainMessage(nextId, text, peerId)
    }

    public func debugInvocationLog(): Array<String> {
        this.logLock.lock()
        let snapshot = cloneStrings(this.invocationLog)
        this.logLock.unlock()
        snapshot
    }

    private func appendInvocation(entry: String): Unit {
        this.logLock.lock()
        this.invocationLog = appendString(this.invocationLog, entry)
        this.logLock.unlock()
    }
}

open class RealMessageService {

    private let messageCache = HashMap<String, Array<DomainMessage>>()
    private let messageSignals = HashMap<String, MessageSignal>()
    private let adapter: IMTProtoAdapter
    private let cacheLock = Mutex()
    private let promiseLock = Mutex()
    private let traceLock = Mutex()
    private var traceLog = emptyStrings()
    private var pendingPromiseResolutions = emptyPendingPromiseResolutions()
    private var refreshBridge: DatasetRefreshBridge

    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
        this.refreshBridge = NoopDatasetRefreshBridge()
    }

    func attachRefreshBridge(bridge: DatasetRefreshBridge): Unit {
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
        if (hadSignal) {
            this.appendTrace("cache:signal-reuse:${currentExecutionContext()}")
            this.appendTrace("cache:read-hit:${currentExecutionContext()}")
        } else {
            this.appendTrace("cache:signal-create:${currentExecutionContext()}")
            _ = this.fetchMessages(GetHistoryParams(peerId, limit))
        }
        signal
    }

    private func fetchMessages(params: GetHistoryParams): Array<DomainMessage> {
        this.appendTrace("cache:fetch-request:${currentExecutionContext()}")
        let messages = this.adapter.getHistory(params.peerId, params.limit)
        this.appendTrace("promise:queued:fetch:${currentExecutionContext()}")
        this.enqueuePromiseResolution(PendingPromiseResolution(params.peerId, "fetch", messages))
        messages
    }

    public func sendMessage(params: SendMessageParams): DomainMessage {
        this.appendTrace("promise:queued:send:${currentExecutionContext()}")
        let message = this.adapter.sendMessage(params.peerId, params.text)
        this.cacheLock.lock()
        let updated = this.appendMessageToCacheLocked(params.peerId, message)
        let key = this.buildCacheKey(params.peerId)
        this.replaceExistingSignalLocked(key, updated)
        this.cacheLock.unlock()
        this.appendTrace("cache:write-append:${currentExecutionContext()}")
        this.publishDatasetChanged(params.peerId, updated)
        this.appendTrace("promise:settled:send:${currentExecutionContext()}")
        message
    }

    func debugCacheSize(peerId: PeerId): Int64 {
        this.cacheLock.lock()
        let size = match (this.messageCache.get(this.buildCacheKey(peerId))) {
            case Some(messages) => messages.size
            case None => 0
        }
        this.cacheLock.unlock()
        size
    }

    func debugLastCachedMessageText(peerId: PeerId): String {
        this.cacheLock.lock()
        let text = match (this.messageCache.get(this.buildCacheKey(peerId))) {
            case Some(messages) =>
                if (messages.size == 0) {
                    ""
                } else {
                    messages[messages.size - 1].text
                }
            case None => ""
        }
        this.cacheLock.unlock()
        text
    }

    func debugCachedMessages(peerId: PeerId): Array<DomainMessage> {
        this.cacheLock.lock()
        let snapshot = match (this.messageCache.get(this.buildCacheKey(peerId))) {
            case Some(messages) => cloneMessages(messages)
            case None => emptyMessages()
        }
        this.cacheLock.unlock()
        snapshot
    }

    func debugThreadLog(): Array<String> {
        this.traceLock.lock()
        let snapshot = cloneStrings(this.traceLog)
        this.traceLock.unlock()
        snapshot
    }

    func debugPendingPromiseCount(): Int64 {
        this.promiseLock.lock()
        let snapshot = this.pendingPromiseResolutions.size
        this.promiseLock.unlock()
        snapshot
    }

    func debugDrainPromiseResolutions(): Unit {
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

    func debugAcquireCacheWriteLockWithin(timeoutBudgetMs: Int64): Bool {
        this.cacheLock.lock()
        this.appendTrace("cache:lock-probe:acquired:${currentExecutionContext()}:budget=${timeoutBudgetMs}")
        this.cacheLock.unlock()
        true
    }

    func debugInvalidateCache(peerId: PeerId): Int64 {
        let key = this.buildCacheKey(peerId)
        this.cacheLock.lock()
        if (this.messageCache.contains(key)) {
            this.messageCache.remove(key)
        }
        if (this.messageSignals.contains(key)) {
            this.messageSignals.remove(key)
            this.appendTrace("cache:signal-evict:${currentExecutionContext()}:${key}")
        }
        this.appendTrace("cache:invalidate:${currentExecutionContext()}:${key}")
        this.cacheLock.unlock()

        this.promiseLock.lock()
        let pending = clonePendingPromiseResolutions(this.pendingPromiseResolutions)
        this.pendingPromiseResolutions = emptyPendingPromiseResolutions()
        var discarded: Int64 = 0
        for (item in pending) {
            if (item.peerId.namespace == peerId.namespace && item.peerId.id == peerId.id) {
                discarded = discarded + 1
            } else {
                this.pendingPromiseResolutions = appendPendingPromiseResolution(this.pendingPromiseResolutions, item)
            }
        }
        this.promiseLock.unlock()
        if (discarded > 0) {
            this.appendTrace("promise:discarded:${currentExecutionContext()}:${key}:count=${discarded}")
        }

        let forcedEpoch = this.refreshBridge.debugForceAdvanceEpoch("invalidate:${currentExecutionContext()}:${key}")
        this.appendTrace("cache:invalidate-epoch:${currentExecutionContext()}:epoch=${forcedEpoch}")
        forcedEpoch
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
        this.appendTrace("cache:write-fetch:${currentExecutionContext()}")
        this.publishDatasetChanged(item.peerId, messages)
        this.appendTrace("promise:settled:fetch:${currentExecutionContext()}")
    }

    private func publishDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        this.appendTrace("cache:refresh-publish:${currentExecutionContext()}")
        this.refreshBridge.notifyDatasetChanged(peerId, cloneMessages(messages))
    }

    private func appendTrace(entry: String): Unit {
        this.traceLock.lock()
        this.traceLog = appendString(this.traceLog, entry)
        this.traceLock.unlock()
    }

    private func buildCacheKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

func buildObserverDeliveryLogEntry(peerId: PeerId, messages: Array<DomainMessage>): String {
    let tailText = if (messages.size == 0) {
        ""
    } else {
        messages[messages.size - 1].text
    }
    "ui:delivery:${currentExecutionContext()}:peer=${peerId.id}:size=${messages.size}:tail=${tailText}"
}

func appendMessage(source: Array<DomainMessage>, item: DomainMessage): Array<DomainMessage> {
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

func appendString(source: Array<String>, item: String): Array<String> {
    Array<String>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

func cloneMessages(source: Array<DomainMessage>): Array<DomainMessage> {
    Array<DomainMessage>(source.size, { index: Int64 => source[index] })
}

func clonePendingRefreshes(source: Array<PendingDatasetRefresh>): Array<PendingDatasetRefresh> {
    Array<PendingDatasetRefresh>(source.size, { index: Int64 => source[index] })
}

func cloneStrings(source: Array<String>): Array<String> {
    Array<String>(source.size, { index: Int64 => source[index] })
}

func appendSignalRuntimeObserverRegistration(source: Array<SignalRuntimeObserverRegistration>, item: SignalRuntimeObserverRegistration): Array<SignalRuntimeObserverRegistration> {
    Array<SignalRuntimeObserverRegistration>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

func cloneSignalRuntimeObserverRegistrations(source: Array<SignalRuntimeObserverRegistration>): Array<SignalRuntimeObserverRegistration> {
    Array<SignalRuntimeObserverRegistration>(source.size, { index: Int64 => source[index] })
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

func emptySignalRuntimeObserverRegistrations(): Array<SignalRuntimeObserverRegistration> {
    Array<SignalRuntimeObserverRegistration>(0, { _: Int64 =>
        throw Exception("unreachable")
    })
}

func allocateSignalRuntimeId(): Int64 {
    SIGNAL_RUNTIME_ID_LOCK.lock()
    NEXT_SIGNAL_RUNTIME_ID = NEXT_SIGNAL_RUNTIME_ID + 1
    let nextId = NEXT_SIGNAL_RUNTIME_ID
    SIGNAL_RUNTIME_ID_LOCK.unlock()
    nextId
}

func emptyMessages(): Array<DomainMessage> {
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

func emptyStrings(): Array<String> {
    Array<String>(0, { _: Int64 => "" })
}

func takeMessages(source: Array<DomainMessage>, limit: Int32): Array<DomainMessage> {
    let boundedSize = if (Int64(limit) < source.size) {
        Int64(limit)
    } else {
        source.size
    }
    Array<DomainMessage>(boundedSize, { index: Int64 => source[index] })
}

func sanitizeProtocolText(raw: String): String {
    let fragments = raw.split(" ")
    var result = ""
    for (fragment in fragments) {
        if (fragment.startsWith("TL#")) {
            continue
        }
        if (fragment.startsWith("@ohos/")) {
            continue
        }
        if (fragment.startsWith("@ohos.")) {
            continue
        }
        if (fragment.startsWith("bytes:")) {
            continue
        }
        if (fragment == "") {
            continue
        }
        if (result == "") {
            result = fragment
        } else {
            result = result + " " + fragment
        }
    }
    result
}

func spinWait(cycles: Int64): Unit {
    var index: Int64 = 0
    while (index < cycles) {
        index = index + 1
    }
}
