package telegram_ui_vertical_slice_001

import phase07_shared_service_refresh_harness.*

func buildTelegramAppShell(service: RealMessageService, sessionSeeds: Array<TelegramConversationSeed>): TelegramAppShell {
    let router = MemoryTelegramPageRouter()
    let controller = TelegramSessionListController(service, sessionSeeds)
    let bridge = MainContextDatasetRefreshBridge(controller)
    controller.attachRefreshBridge(bridge)
    let sessionListPage = TelegramSessionListPage(router, controller, bridge)
    let chatDetailPage = TelegramChatDetailPage(router, controller)
    TelegramAppShell(router, sessionListPage, chatDetailPage)
}

class TelegramAppShell {
    private let router: TelegramPageRouter
    private let sessionListPage: TelegramSessionListPage
    private let chatDetailPage: TelegramChatDetailPage

    public init(router: TelegramPageRouter, sessionListPage: TelegramSessionListPage, chatDetailPage: TelegramChatDetailPage) {
        this.router = router
        this.sessionListPage = sessionListPage
        this.chatDetailPage = chatDetailPage
    }

    public func currentPageName(): String {
        this.router.current().pageName
    }

    public func historySize(): Int64 {
        this.router.historySize()
    }

    public func loadInitialSessions(limit: Int32): Unit {
        this.sessionListPage.loadInitialSessions(limit)
    }

    public func visibleSessions(): Array<TelegramConversationSummary> {
        this.sessionListPage.visibleSessions()
    }

    public func refreshConversation(peerId: PeerId, limit: Int32): Unit {
        this.chatDetailPage.dropRecoverySlotOnOtherPeerRefresh(peerId)
        this.sessionListPage.refreshConversation(peerId, limit)
    }

    public func openConversation(conversation: TelegramConversationSummary): Unit {
        if (this.currentPageName() == "TelegramChatDetailPage") {
            this.chatDetailPage.showConversation(conversation)
        } else {
            this.sessionListPage.openConversation(conversation)
        }
        this.chatDetailPage.aboutToAppear()
    }

    public func currentDetailTitle(): String {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.currentTitle()
    }

    public func currentDetailPeerLabel(): String {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.currentPeerLabel()
    }

    public func currentDetailBody(): String {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.placeholderBody()
    }

    public func currentDetailMessages(): Array<DomainMessage> {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.projectedMessages()
    }

    public func currentDetailDraft(): String {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.composerDraft()
    }

    public func updateDetailDraft(text: String): Unit {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.updateDraft(text)
    }

    public func sendDetailDraft(): Unit {
        this.chatDetailPage.aboutToAppear()
        this.chatDetailPage.sendDraft(this.sessionListPage)
    }

    public func sendMessageToActiveConversation(text: String): Unit {
        let currentRoute = this.router.current()
        if (currentRoute.hasConversation) {
            _ = this.sessionListPage.sendMessage(currentRoute.conversation.peerId, text)
        }
    }

    public func backFromDetail(): Unit {
        this.chatDetailPage.tapBack()
    }
}
