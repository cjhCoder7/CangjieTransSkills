package telegram_ui_vertical_slice_001

import phase07_shared_service_refresh_harness.*
import std.collection.*
import std.sync.*

public class TelegramConversationSeed {
    public let peerId: PeerId
    public let title: String

    public init(peerId: PeerId, title: String) {
        this.peerId = peerId
        this.title = title
    }
}

public class TelegramConversationSummary {
    public let peerId: PeerId
    public let title: String
    public let previewText: String
    public let messageCount: Int64

    public init(peerId: PeerId, title: String, previewText: String, messageCount: Int64) {
        this.peerId = peerId
        this.title = title
        this.previewText = previewText
        this.messageCount = messageCount
    }
}

class TelegramRouteRequest {
    let pageName: String
    let hasConversation: Bool
    let conversation: TelegramConversationSummary

    public init(pageName: String, hasConversation: Bool, conversation: TelegramConversationSummary) {
        this.pageName = pageName
        this.hasConversation = hasConversation
        this.conversation = conversation
    }
}

func makeTelegramSessionListRoute(): TelegramRouteRequest {
    TelegramRouteRequest("TelegramSessionListPage", false, emptyConversationSummary())
}

func makeTelegramChatDetailRoute(conversation: TelegramConversationSummary): TelegramRouteRequest {
    TelegramRouteRequest("TelegramChatDetailPage", true, conversation)
}

interface TelegramPageRouter {
    func push(request: TelegramRouteRequest): Unit
    func replace(request: TelegramRouteRequest): Unit
    func back(): Unit
    func current(): TelegramRouteRequest
    func historySize(): Int64
}

class MemoryTelegramPageRouter <: TelegramPageRouter {
    private var history = emptyTelegramRouteRequests()
    private var currentIndex: Int64 = 0

    public init() {
        this.history = appendTelegramRouteRequest(this.history, makeTelegramSessionListRoute())
    }

    public func push(request: TelegramRouteRequest): Unit {
        let nextIndex = this.currentIndex + 1
        this.history = pushTelegramRouteRequest(this.history, nextIndex, request)
        this.currentIndex = nextIndex
    }

    public func replace(request: TelegramRouteRequest): Unit {
        this.history = replaceTelegramRouteRequest(this.history, this.currentIndex, request)
    }

    public func back(): Unit {
        if (this.currentIndex > 0) {
            this.currentIndex = this.currentIndex - 1
        }
    }

    public func current(): TelegramRouteRequest {
        this.history[this.currentIndex]
    }

    public func historySize(): Int64 {
        this.history.size
    }
}

class SpyTelegramPageRouter <: TelegramPageRouter {
    private var history = emptyTelegramRouteRequests()
    private var pushedPages = emptyRouteNames()
    private var currentIndex: Int64 = 0

    public init() {
        this.history = appendTelegramRouteRequest(this.history, makeTelegramSessionListRoute())
    }

    public func push(request: TelegramRouteRequest): Unit {
        let nextIndex = this.currentIndex + 1
        this.history = pushTelegramRouteRequest(this.history, nextIndex, request)
        this.pushedPages = appendRouteName(this.pushedPages, request.pageName)
        this.currentIndex = nextIndex
    }

    public func replace(request: TelegramRouteRequest): Unit {
        this.history = replaceTelegramRouteRequest(this.history, this.currentIndex, request)
    }

    public func back(): Unit {
        if (this.currentIndex > 0) {
            this.currentIndex = this.currentIndex - 1
        }
    }

    public func current(): TelegramRouteRequest {
        this.history[this.currentIndex]
    }

    public func historySize(): Int64 {
        this.history.size
    }

    public func lastPushedPage(): String {
        if (this.pushedPages.size == 0) {
            ""
        } else {
            this.pushedPages[this.pushedPages.size - 1]
        }
    }
}

class TelegramSessionListController <: DatasetRefreshObserver {
    private let controllerLock = Mutex()
    private let service: RealMessageService
    private let sessionSeeds: Array<TelegramConversationSeed>
    private let titleByPeerKey = HashMap<String, String>()
    private let threadsByPeerKey = HashMap<String, Array<DomainMessage>>()
    private var summaries = emptyConversationSummaries()

    public init(service: RealMessageService, sessionSeeds: Array<TelegramConversationSeed>) {
        this.service = service
        this.sessionSeeds = cloneConversationSeeds(sessionSeeds)
        for (seed in this.sessionSeeds) {
            this.titleByPeerKey[this.buildPeerKey(seed.peerId)] = seed.title
            this.summaries = appendConversationSummary(
                this.summaries,
                TelegramConversationSummary(seed.peerId, seed.title, "Pull to refresh", 0)
            )
        }
    }

    func attachRefreshBridge(bridge: DatasetRefreshBridge): Unit {
        this.service.attachRefreshBridge(bridge)
    }

    public func loadInitialSessions(limit: Int32): Unit {
        for (seed in this.sessionSeeds) {
            _ = runWorkerGetMessages(this.service, seed.peerId, limit, "worker-session-load-${seed.peerId.id}")
        }
    }

    public func refreshConversation(peerId: PeerId, limit: Int32): Unit {
        _ = this.service.debugInvalidateCache(peerId)
        _ = runWorkerGetMessages(this.service, peerId, limit, "worker-session-refresh-${peerId.id}")
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.service.sendMessage(SendMessageParams(peerId, text))
    }

    public func onDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit {
        let summary = buildConversationSummary(peerId, this.lookupTitle(peerId), messages)
        this.controllerLock.lock()
        this.summaries = replaceConversationSummary(this.summaries, summary)
        this.threadsByPeerKey[this.buildPeerKey(peerId)] = cloneMessages(messages)
        this.controllerLock.unlock()
    }

    public func summariesSnapshot(): Array<TelegramConversationSummary> {
        this.controllerLock.lock()
        let snapshot = cloneConversationSummaries(this.summaries)
        this.controllerLock.unlock()
        snapshot
    }

    public func summaryFor(peerId: PeerId): TelegramConversationSummary {
        this.controllerLock.lock()
        let snapshot = findConversationSummary(this.summaries, peerId)
        this.controllerLock.unlock()
        snapshot
    }

    public func messagesFor(peerId: PeerId): Array<DomainMessage> {
        this.controllerLock.lock()
        let snapshot = match (this.threadsByPeerKey.get(this.buildPeerKey(peerId))) {
            case Some(messages) => cloneMessages(messages)
            case None => emptyMessages()
        }
        this.controllerLock.unlock()
        snapshot
    }

    private func lookupTitle(peerId: PeerId): String {
        match (this.titleByPeerKey.get(this.buildPeerKey(peerId))) {
            case Some(title) => title
            case None => "Peer ${peerId.id}"
        }
    }

    private func buildPeerKey(peerId: PeerId): String {
        "${peerId.namespace}_${peerId.id}"
    }
}

class TelegramSessionListPage {
    private let router: TelegramPageRouter
    private let controller: TelegramSessionListController
    private let bridge: MainContextDatasetRefreshBridge

    public init(router: TelegramPageRouter, controller: TelegramSessionListController, bridge: MainContextDatasetRefreshBridge) {
        this.router = router
        this.controller = controller
        this.bridge = bridge
    }

    public func loadInitialSessions(limit: Int32): Unit {
        setExecutionContext("main")
        this.controller.loadInitialSessions(limit)
        setExecutionContext("main")
        this.bridge.drainOnMain()
    }

    public func visibleSessions(): Array<TelegramConversationSummary> {
        this.controller.summariesSnapshot()
    }

    public func openConversation(conversation: TelegramConversationSummary): Unit {
        this.router.push(makeTelegramChatDetailRoute(conversation))
    }

    public func refreshConversation(peerId: PeerId, limit: Int32): Unit {
        setExecutionContext("main")
        this.controller.refreshConversation(peerId, limit)
        setExecutionContext("main")
        this.bridge.drainOnMain()
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        setExecutionContext("main")
        let message = this.controller.sendMessage(peerId, text)
        setExecutionContext("main")
        this.bridge.drainOnMain()
        message
    }

    public func summaryFor(peerId: PeerId): TelegramConversationSummary {
        this.controller.summaryFor(peerId)
    }

    public func messagesFor(peerId: PeerId): Array<DomainMessage> {
        this.controller.messagesFor(peerId)
    }

    public func pendingRefreshCount(): Int64 {
        this.bridge.pendingRefreshCount()
    }
}

class TelegramChatDetailPage {
    private let router: TelegramPageRouter
    private let controller: TelegramSessionListController
    private var hasActiveConversation: Bool = false
    private var currentConversation = emptyConversationSummary()
    private var currentDraft: String = ""
    private var currentDraftArmsRecovery: Bool = false
    private var hasRecoverySlot: Bool = false
    private var recoveryPeerId = PeerId(0, 0)
    private var recoveryDraft: String = ""

    public init(router: TelegramPageRouter, controller: TelegramSessionListController) {
        this.router = router
        this.controller = controller
    }

    public func aboutToAppear(): Unit {
        let route = this.router.current()
        if (route.hasConversation) {
            if (this.hasActiveConversation) {
                if (!samePeer(this.currentConversation.peerId, route.conversation.peerId)) {
                    this.clearDraftState()
                    this.clearRecoverySlot()
                }
            } else {
                if (this.hasRecoverySlot && samePeer(this.recoveryPeerId, route.conversation.peerId)) {
                    this.currentDraft = this.recoveryDraft
                    this.currentDraftArmsRecovery = false
                    this.clearRecoverySlot()
                } else {
                    if (this.hasRecoverySlot) {
                        this.clearRecoverySlot()
                    }
                    this.clearDraftState()
                }
            }
            this.hasActiveConversation = true
            this.currentConversation = route.conversation
        } else {
            this.hasActiveConversation = false
            this.currentConversation = emptyConversationSummary()
            this.clearDraftState()
        }
    }

    public func showConversation(conversation: TelegramConversationSummary): Unit {
        this.router.replace(makeTelegramChatDetailRoute(conversation))
    }

    public func dropRecoverySlotOnOtherPeerRefresh(peerId: PeerId): Unit {
        if (!this.hasActiveConversation && this.hasRecoverySlot && !samePeer(this.recoveryPeerId, peerId)) {
            this.clearRecoverySlot()
        }
    }

    public func currentTitle(): String {
        this.currentConversation.title
    }

    public func currentPeerLabel(): String {
        if (this.hasActiveConversation) {
            "peer:${this.currentConversation.peerId.id}"
        } else {
            ""
        }
    }

    public func placeholderBody(): String {
        if (this.hasActiveConversation) {
            "Chat detail placeholder"
        } else {
            ""
        }
    }

    public func projectedMessages(): Array<DomainMessage> {
        if (this.hasActiveConversation) {
            this.controller.messagesFor(this.currentConversation.peerId)
        } else {
            emptyMessages()
        }
    }

    public func composerDraft(): String {
        if (this.hasActiveConversation) {
            this.currentDraft
        } else {
            ""
        }
    }

    public func updateDraft(text: String): Unit {
        if (this.hasActiveConversation) {
            this.currentDraft = text
            this.currentDraftArmsRecovery = (text != "")
        }
    }

    public func sendDraft(sessionListPage: TelegramSessionListPage): Unit {
        if (!this.hasActiveConversation || this.currentDraft == "") {
            return
        }
        let text = this.currentDraft
        _ = sessionListPage.sendMessage(this.currentConversation.peerId, text)
        this.clearDraftState()
        this.clearRecoverySlot()
    }

    public func tapBack(): Unit {
        if (this.hasActiveConversation && this.currentDraft != "" && this.currentDraftArmsRecovery) {
            this.hasRecoverySlot = true
            this.recoveryPeerId = this.currentConversation.peerId
            this.recoveryDraft = this.currentDraft
        }
        this.router.back()
        this.hasActiveConversation = false
        this.currentConversation = emptyConversationSummary()
        this.clearDraftState()
    }

    private func clearDraftState(): Unit {
        this.currentDraft = ""
        this.currentDraftArmsRecovery = false
    }

    private func clearRecoverySlot(): Unit {
        this.hasRecoverySlot = false
        this.recoveryPeerId = PeerId(0, 0)
        this.recoveryDraft = ""
    }
}

func buildConversationSummary(peerId: PeerId, title: String, messages: Array<DomainMessage>): TelegramConversationSummary {
    let preview = if (messages.size == 0) {
        "No messages yet"
    } else {
        messages[messages.size - 1].text
    }
    TelegramConversationSummary(peerId, title, preview, messages.size)
}

func emptyConversationSummary(): TelegramConversationSummary {
    TelegramConversationSummary(PeerId(0, 0), "", "", 0)
}

func emptyConversationSummaries(): Array<TelegramConversationSummary> {
    Array<TelegramConversationSummary>(0, { _: Int64 =>
        emptyConversationSummary()
    })
}

func appendConversationSummary(source: Array<TelegramConversationSummary>, item: TelegramConversationSummary): Array<TelegramConversationSummary> {
    Array<TelegramConversationSummary>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

func cloneConversationSummaries(source: Array<TelegramConversationSummary>): Array<TelegramConversationSummary> {
    Array<TelegramConversationSummary>(source.size, { index: Int64 => source[index] })
}

func replaceConversationSummary(source: Array<TelegramConversationSummary>, item: TelegramConversationSummary): Array<TelegramConversationSummary> {
    let hasTarget = conversationSummaryExists(source, item.peerId)
    let replaced = Array<TelegramConversationSummary>(source.size, { index: Int64 =>
        let current = source[index]
        if (samePeer(current.peerId, item.peerId)) {
            item
        } else {
            current
        }
    })
    if (hasTarget) {
        replaced
    } else {
        appendConversationSummary(replaced, item)
    }
}

func findConversationSummary(source: Array<TelegramConversationSummary>, peerId: PeerId): TelegramConversationSummary {
    for (item in source) {
        if (samePeer(item.peerId, peerId)) {
            return item
        }
    }
    emptyConversationSummary()
}

func cloneConversationSeeds(source: Array<TelegramConversationSeed>): Array<TelegramConversationSeed> {
    Array<TelegramConversationSeed>(source.size, { index: Int64 => source[index] })
}

func conversationSummaryExists(source: Array<TelegramConversationSummary>, peerId: PeerId): Bool {
    for (item in source) {
        if (samePeer(item.peerId, peerId)) {
            return true
        }
    }
    false
}

func samePeer(left: PeerId, right: PeerId): Bool {
    left.namespace == right.namespace && left.id == right.id
}

func emptyTelegramRouteRequests(): Array<TelegramRouteRequest> {
    Array<TelegramRouteRequest>(0, { _: Int64 =>
        makeTelegramSessionListRoute()
    })
}

func appendTelegramRouteRequest(source: Array<TelegramRouteRequest>, item: TelegramRouteRequest): Array<TelegramRouteRequest> {
    Array<TelegramRouteRequest>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}

func replaceTelegramRouteRequest(source: Array<TelegramRouteRequest>, targetIndex: Int64, item: TelegramRouteRequest): Array<TelegramRouteRequest> {
    Array<TelegramRouteRequest>(source.size, { index: Int64 =>
        if (index == targetIndex) {
            item
        } else {
            source[index]
        }
    })
}

func pushTelegramRouteRequest(source: Array<TelegramRouteRequest>, targetIndex: Int64, item: TelegramRouteRequest): Array<TelegramRouteRequest> {
    Array<TelegramRouteRequest>(targetIndex + 1, { index: Int64 =>
        if (index < targetIndex) {
            source[index]
        } else {
            item
        }
    })
}

func emptyRouteNames(): Array<String> {
    Array<String>(0, { _: Int64 => "" })
}

func appendRouteName(source: Array<String>, item: String): Array<String> {
    Array<String>(source.size + 1, { index: Int64 =>
        if (index < source.size) {
            source[index]
        } else {
            item
        }
    })
}
