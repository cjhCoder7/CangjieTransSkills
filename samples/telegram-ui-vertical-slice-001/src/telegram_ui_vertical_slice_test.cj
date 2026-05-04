package telegram_ui_vertical_slice_001

import phase07_shared_service_refresh_harness.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class TelegramUiVerticalSliceTests {
    @TestCase
    public func appShellShouldStartOnSessionListRouteAndExposeSessions(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7301)
        let teamPeer = PeerId(0, 7302)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        assertEqual("shell 初始路由必须停在会话列表", "", "TelegramSessionListPage", shell.currentPageName())

        shell.loadInitialSessions(2)
        let sessions = shell.visibleSessions()

        assertEqual("shell 应暴露两个会话摘要", "", 2, sessions.size)
        assertEqual("shell 通过 list page 消费第一页标题", "", "Alice", sessions[0].title)
        assertEqual("shell 通过 list page 消费第二页尾消息", "", "team-2", sessions[1].previewText)
    }

    @TestCase
    public func appShellShouldConsumeListSelectionIntoDetailPlaceholder(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7401)
        let teamPeer = PeerId(0, 7402)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let chosen = shell.visibleSessions()[1]
        shell.openConversation(chosen)

        assertEqual("shell 打开会话后应切到详情页路由", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("shell 路由历史应增加到 2", "", 2, shell.historySize())
        assertEqual("shell 应通过 detail page 消费标题", "", "Team", shell.currentDetailTitle())
        assertEqual("shell 应通过 detail page 暴露 peer 标签", "", "peer:7402", shell.currentDetailPeerLabel())
        assertEqual("shell 当前只暴露详情占位内容", "", "Chat detail placeholder", shell.currentDetailBody())

        shell.backFromDetail()
        assertEqual("shell 返回后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
    }

    @TestCase
    public func appShellOpenDetailShouldProjectRealHistoryForActiveConversation(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7403)
        let teamPeer = PeerId(0, 7404)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let chosen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(chosen)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("打开会话后应切到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("打开会话后 history 应保持为 2", "", 2, shell.historySize())
        assertEqual("详情标题应绑定到目标会话", "", "Team", shell.currentDetailTitle())
        assertEqual("详情 peer 标签应绑定到目标会话", "", "peer:7404", shell.currentDetailPeerLabel())
        assertEqual("详情线程应投影两条真实消息", "", 2, detailMessages.size)
        assertEqual("详情线程第一条消息应来自真实历史", "", "team-1", detailMessages[0].text)
        assertEqual("详情线程第二条消息应来自真实历史", "", "team-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellActiveDetailSendShouldAppendIntoProjectedThreadWithoutBreakingSummaryCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7405)
        let teamPeer = PeerId(0, 7406)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-thread-3")
        let detailMessages = shell.currentDetailMessages()
        let sentTargetSummary = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherSummary = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("active detail send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail send 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("active detail send 后标题应继续绑定原会话", "", "Team", shell.currentDetailTitle())
        assertEqual("active detail send 后 peer 标签应继续绑定原会话", "", "peer:7406", shell.currentDetailPeerLabel())
        assertEqual("active detail send 后详情线程应追加到 3 条", "", 3, detailMessages.size)
        assertEqual("active detail send 后线程前两条消息应保持稳定", "", "team-1", detailMessages[0].text)
        assertEqual("active detail send 后线程第二条消息应保持稳定", "", "team-2", detailMessages[1].text)
        assertEqual("active detail send 后线程第三条消息应是新发送文本", "", "team-thread-3", detailMessages[2].text)
        assertEqual("列表摘要应同步 sent text", "", "team-thread-3", sentTargetSummary.previewText)
        assertEqual("列表摘要应同步 messageCount = 3", "", 3, sentTargetSummary.messageCount)
        assertEqual("非目标摘要不应被污染", "", "alice-2", otherSummary.previewText)
        assertEqual("非目标摘要消息数应保持为 2", "", 2, otherSummary.messageCount)
        assertEqual("active detail send 应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("active detail send 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRetargetBackReopenShouldKeepProjectedThreadOwnershipCoherent(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7407)
        let teamPeer = PeerId(0, 7408)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(originalConversation)

        let originalMessages = shell.currentDetailMessages()
        shell.openConversation(retargetConversation)
        let retargetedMessages = shell.currentDetailMessages()

        assertEqual("第一次打开原会话时应投影原线程", "", 2, originalMessages.size)
        assertEqual("原线程第一条消息应正确", "", "team-1", originalMessages[0].text)
        assertEqual("原线程第二条消息应正确", "", "team-2", originalMessages[1].text)
        assertEqual("direct retarget 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("direct retarget 后 history 不应膨胀到 3", "", 2, shell.historySize())
        assertEqual("direct retarget 后标题应切到新目标", "", "Alice", shell.currentDetailTitle())
        assertEqual("direct retarget 后 peer 标签应切到新目标", "", "peer:7407", shell.currentDetailPeerLabel())
        assertEqual("direct retarget 后详情线程应切到新目标线程", "", 2, retargetedMessages.size)
        assertEqual("retarget 后第一条线程消息应来自新目标", "", "alice-1", retargetedMessages[0].text)
        assertEqual("retarget 后第二条线程消息应来自新目标", "", "alice-2", retargetedMessages[1].text)

        shell.backFromDetail()
        let messagesAfterBack = shell.currentDetailMessages()

        assertEqual("back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("back 后线程投影应清空", "", 0, messagesAfterBack.size)

        shell.openConversation(originalConversation)
        let reopenedMessages = shell.currentDetailMessages()

        assertEqual("reopen 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 后标题应重新绑定到原会话", "", "Team", shell.currentDetailTitle())
        assertEqual("reopen 后 peer 标签应重新绑定到原会话", "", "peer:7408", shell.currentDetailPeerLabel())
        assertEqual("reopen 后详情线程应恢复原线程", "", 2, reopenedMessages.size)
        assertEqual("reopen 后第一条线程消息应恢复原线程", "", "team-1", reopenedMessages[0].text)
        assertEqual("reopen 后第二条线程消息应恢复原线程", "", "team-2", reopenedMessages[1].text)
    }

    @TestCase
    public func appShellActiveDetailComposerShouldTrackDraftAndClearAfterSend(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7409)
        let teamPeer = PeerId(0, 7410)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(targetConversation)

        assertEqual("detail composer 初始 draft 应为空", "", "", shell.currentDetailDraft())

        shell.updateDetailDraft("team-thread-3")
        assertEqual("detail composer 应暴露当前 draft", "", "team-thread-3", shell.currentDetailDraft())

        shell.sendDetailDraft()
        let detailMessages = shell.currentDetailMessages()
        let targetSummary = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherSummary = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("detail composer send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("detail composer send 后 history 应保持为 2", "", 2, shell.historySize())
        assertEqual("detail composer send 后标题应继续绑定原会话", "", "Team", shell.currentDetailTitle())
        assertEqual("detail composer send 后 peer 标签应继续绑定原会话", "", "peer:7410", shell.currentDetailPeerLabel())
        assertEqual("detail composer send 后 draft 应清空", "", "", shell.currentDetailDraft())
        assertEqual("detail composer send 后详情线程应追加到 3 条", "", 3, detailMessages.size)
        assertEqual("detail composer send 后线程第三条消息应是 draft 文本", "", "team-thread-3", detailMessages[2].text)
        assertEqual("detail composer send 后列表摘要应同步 sent text", "", "team-thread-3", targetSummary.previewText)
        assertEqual("detail composer send 后列表摘要应同步 messageCount = 3", "", 3, targetSummary.messageCount)
        assertEqual("detail composer send 不应污染非目标摘要", "", "alice-2", otherSummary.previewText)
        assertEqual("detail composer send 应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("detail composer send 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellDetailComposerShouldNoopWithoutActiveConversation(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7411)
        let teamPeer = PeerId(0, 7412)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamSummaryBefore = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let aliceSummaryBefore = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.updateDetailDraft("should-not-send")
        shell.sendDetailDraft()

        let teamSummaryAfter = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let aliceSummaryAfter = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("list route 下 composer update 不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route 下 composer send 不应增长 history", "", 1, shell.historySize())
        assertEqual("list route 下 composer draft 应保持为空", "", "", shell.currentDetailDraft())
        assertEqual("list route 下 composer 不应暴露 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("list route 下 composer 不应暴露 detail 线程", "", 0, shell.currentDetailMessages().size)
        assertEqual("list route 下 composer send 不应改写目标摘要", "", teamSummaryBefore.previewText, teamSummaryAfter.previewText)
        assertEqual("list route 下 composer send 不应改写非目标摘要", "", aliceSummaryBefore.previewText, aliceSummaryAfter.previewText)
        assertEqual("list route 下 composer send 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list route 下 composer send 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellDetailComposerShouldResetAcrossRetargetBackReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7413)
        let teamPeer = PeerId(0, 7414)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(originalConversation)

        shell.updateDetailDraft("team-draft")
        assertEqual("原会话详情 draft 应可写入", "", "team-draft", shell.currentDetailDraft())

        shell.openConversation(retargetConversation)
        let retargetedMessages = shell.currentDetailMessages()

        assertEqual("retarget 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("retarget 后标题应切到新目标", "", "Alice", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到新目标", "", "peer:7413", shell.currentDetailPeerLabel())
        assertEqual("retarget 后 draft 应被重置", "", "", shell.currentDetailDraft())
        assertEqual("retarget 后详情线程应切到新目标线程", "", 2, retargetedMessages.size)
        assertEqual("retarget 后第一条线程消息应来自新目标", "", "alice-1", retargetedMessages[0].text)
        assertEqual("retarget 后第二条线程消息应来自新目标", "", "alice-2", retargetedMessages[1].text)

        shell.backFromDetail()

        assertEqual("back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后 draft 应清空", "", "", shell.currentDetailDraft())
        assertEqual("back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("back 后不应残留 detail 线程", "", 0, shell.currentDetailMessages().size)

        shell.openConversation(originalConversation)
        let reopenedMessages = shell.currentDetailMessages()

        assertEqual("reopen 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 后标题应重新绑定原会话", "", "Team", shell.currentDetailTitle())
        assertEqual("reopen 后 peer 标签应重新绑定原会话", "", "peer:7414", shell.currentDetailPeerLabel())
        assertEqual("reopen 后 draft 应保持为空", "", "", shell.currentDetailDraft())
        assertEqual("reopen 后详情线程应恢复原线程", "", 2, reopenedMessages.size)
        assertEqual("reopen 后第一条线程消息应恢复原线程", "", "team-1", reopenedMessages[0].text)
        assertEqual("reopen 后第二条线程消息应恢复原线程", "", "team-2", reopenedMessages[1].text)
        assertEqual("composer reset round-trip 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("composer reset round-trip 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellDetailDraftShouldRecoverAfterBackAndReopenSameConversation(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7415)
        let teamPeer = PeerId(0, 7416)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("team-recovery-draft")
        shell.backFromDetail()

        assertEqual("back 到 list 后 draft 不应直接暴露", "", "", shell.currentDetailDraft())
        assertEqual("back 到 list 后当前页应回到列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 到 list 后 history 应保持为 2", "", 2, shell.historySize())

        shell.openConversation(targetConversation)

        assertEqual("same-peer reopen 后 draft 应恢复", "", "team-recovery-draft", shell.currentDetailDraft())
        assertEqual("same-peer reopen 后标题应重新绑定原会话", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer reopen 后 peer 标签应重新绑定原会话", "", "peer:7416", shell.currentDetailPeerLabel())
        assertEqual("same-peer reopen 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("same-peer reopen 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.backFromDetail()
        shell.openConversation(targetConversation)

        assertEqual("restore 后 slot 应立即被消费，第二次 reopen 不应幽灵恢复", "", "", shell.currentDetailDraft())
        assertEqual("第二次 reopen 后线程应仍绑定原会话", "", 2, shell.currentDetailMessages().size)
        assertEqual("第二次 reopen 仍不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("第二次 reopen 仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellRecoveredDetailDraftShouldStillClearAfterSend(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7417)
        let teamPeer = PeerId(0, 7418)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("team-recovered-send-3")
        shell.backFromDetail()
        shell.openConversation(targetConversation)

        assertEqual("send 前恢复的 draft 应可见", "", "team-recovered-send-3", shell.currentDetailDraft())

        shell.sendDetailDraft()
        let detailMessages = shell.currentDetailMessages()
        let targetSummary = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherSummary = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("恢复后 send 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("恢复后 send history 应保持为 2", "", 2, shell.historySize())
        assertEqual("恢复后 send 后 draft 应清空", "", "", shell.currentDetailDraft())
        assertEqual("恢复后 send 后详情线程应追加到 3 条", "", 3, detailMessages.size)
        assertEqual("恢复后 send 后线程第三条消息应是 draft 文本", "", "team-recovered-send-3", detailMessages[2].text)
        assertEqual("恢复后 send 后列表摘要应同步 sent text", "", "team-recovered-send-3", targetSummary.previewText)
        assertEqual("恢复后 send 后列表摘要应同步 messageCount = 3", "", 3, targetSummary.messageCount)
        assertEqual("恢复后 send 不应污染非目标摘要", "", otherConversation.previewText, otherSummary.previewText)
        assertEqual("恢复后 send 应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("恢复后 send 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())

        shell.backFromDetail()
        shell.openConversation(targetConversation)

        assertEqual("send 成功后 slot 应被清空，reopen 不应再恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("send 成功后 reopen 仍应绑定目标线程", "", "Team", shell.currentDetailTitle())
    }

    @TestCase
    public func appShellRecoveredDetailDraftShouldDropOnOtherPeerAndListRouteNoop(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7419)
        let teamPeer = PeerId(0, 7420)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let aliceConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let teamSummaryBefore = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let aliceSummaryBefore = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(teamConversation)
        shell.updateDetailDraft("team-other-peer-drop")
        shell.backFromDetail()

        shell.updateDetailDraft("list-route-should-not-touch-slot")
        shell.sendDetailDraft()

        assertEqual("list route composer API 不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route composer API 不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list route composer API 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list route composer API 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("list route composer API 不应改写 team 摘要", "", teamSummaryBefore.previewText, findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)
        assertEqual("list route composer API 不应改写 alice 摘要", "", aliceSummaryBefore.previewText, findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)

        shell.openConversation(aliceConversation)

        assertEqual("reopen other peer 后 draft 不应泄漏到新目标", "", "", shell.currentDetailDraft())
        assertEqual("reopen other peer 后标题应绑定新目标", "", "Alice", shell.currentDetailTitle())

        shell.backFromDetail()
        shell.openConversation(teamConversation)

        assertEqual("other-peer reopen 后旧 slot 应被清空，回到原 peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())

        shell.updateDetailDraft("team-retarget-drop")
        shell.backFromDetail()
        shell.openConversation(teamConversation)

        assertEqual("same-peer reopen 后 draft 应再次恢复", "", "team-retarget-drop", shell.currentDetailDraft())

        shell.openConversation(aliceConversation)

        assertEqual("direct retarget 到 other peer 后 draft 应被清空", "", "", shell.currentDetailDraft())
        assertEqual("direct retarget 后标题应绑定 other peer", "", "Alice", shell.currentDetailTitle())

        shell.backFromDetail()
        shell.openConversation(teamConversation)

        assertEqual("direct retarget 清空后 reopen 原 peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("other-peer / list-route round-trip 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("other-peer / list-route round-trip 不应新增历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellDraftRecoverySlotShouldSurviveSamePeerRefreshBeforeReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7421)
        let teamPeer = PeerId(0, 7422)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-refresh-recovery-draft")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("armed slot 遇到 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("same-peer refresh 期间 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("same-peer refresh 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("same-peer refresh 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("same-peer refresh 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("same-peer refresh 应更新 refreshed target 摘要", "", "alice-refresh-2", refreshedConversation.previewText)
        assertEqual("same-peer refresh 后 refreshed target 消息数应保持为 2", "", 2, refreshedConversation.messageCount)
        assertEqual("same-peer refresh 不应污染非目标摘要", "", "team-2", otherAfterRefresh.previewText)
        assertEqual("same-peer refresh 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("same-peer refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.openConversation(refreshedConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("refresh 后首次 reopen same refreshed target 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("refresh 后首次 reopen same refreshed target 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("refresh 后首次 reopen 应重新绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("refresh 后首次 reopen 应重新绑定 refreshed target peer 标签", "", "peer:7421", shell.currentDetailPeerLabel())
        assertEqual("refresh 后首次 reopen 应恢复 draft", "", "alice-refresh-recovery-draft", shell.currentDetailDraft())
        assertEqual("refresh 后首次 reopen 应绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("refresh 后首次 reopen 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("refresh 后首次 reopen 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)

        shell.backFromDetail()
        shell.openConversation(refreshedConversation)

        assertEqual("refresh 后 restore 完成后 slot 应立即被消费，第二次 reopen 不应再恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("refresh 后第二次 reopen 仍应保持 refreshed target ownership", "", "Alice", shell.currentDetailTitle())
    }

    @TestCase
    public func appShellRecoveredDraftAfterSamePeerRefreshShouldStillClearAfterSend(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7423)
        let teamPeer = PeerId(0, 7424)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-refresh-send-3")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(refreshedConversation)

        assertEqual("refresh 后恢复的 draft 在 send 前应可见", "", "alice-refresh-send-3", shell.currentDetailDraft())

        shell.sendDetailDraft()
        let detailMessages = shell.currentDetailMessages()
        let targetAfterSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("refresh 恢复后 send 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("refresh 恢复后 send 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("refresh 恢复后 send 后 draft 应清空", "", "", shell.currentDetailDraft())
        assertEqual("refresh 恢复后 send 后详情线程应追加到 3 条", "", 3, detailMessages.size)
        assertEqual("refresh 恢复后 send 后前两条消息应仍来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("refresh 恢复后 send 后第二条消息应仍来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
        assertEqual("refresh 恢复后 send 后第三条消息应是 draft 文本", "", "alice-refresh-send-3", detailMessages[2].text)
        assertEqual("refresh 恢复后 send 后列表摘要应同步 sent text", "", "alice-refresh-send-3", targetAfterSend.previewText)
        assertEqual("refresh 恢复后 send 后列表摘要应同步 messageCount = 3", "", 3, targetAfterSend.messageCount)
        assertEqual("refresh 恢复后 send 不应污染非目标摘要", "", "team-2", otherAfterSend.previewText)
        assertEqual("refresh 恢复后 send 只应触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("refresh 恢复后 send 不应新增额外历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.backFromDetail()
        shell.openConversation(findSummaryByPeer(shell.visibleSessions(), alicePeer))

        assertEqual("refresh 恢复后 send 成功应清空 slot，reopen 不应再恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("refresh 恢复后 send 成功后 reopen 仍应绑定目标线程", "", "Alice", shell.currentDetailTitle())
    }

    @TestCase
    public func appShellListRouteSamePeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndBounded(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7425)
        let teamPeer = PeerId(0, 7426)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-refresh-hidden-draft")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("armed slot + same-peer refresh 期间仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("armed slot + same-peer refresh 期间 draft 不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("armed slot + same-peer refresh 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("armed slot + same-peer refresh 应更新 refreshed target 摘要", "", "alice-refresh-2", refreshedConversation.previewText)
        assertEqual("armed slot + same-peer refresh 不应污染非目标摘要", "", "team-2", otherAfterRefresh.previewText)
        assertEqual("armed slot + same-peer refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("armed slot + same-peer refresh 只应新增一次历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.updateDetailDraft("list-route-should-not-touch-refresh-recovery-slot")
        shell.sendDetailDraft()

        assertEqual("list-route composer API 在 same-peer refresh 后仍不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list-route composer API 在 same-peer refresh 后仍不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list-route composer API 在 same-peer refresh 后仍不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("list-route composer API 在 same-peer refresh 后仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list-route composer API 在 same-peer refresh 后仍不应新增额外历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("list-route composer API 在 same-peer refresh 后不应改写 refreshed target 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)
        assertEqual("list-route composer API 在 same-peer refresh 后不应改写非目标摘要", "", "team-2", findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)

        shell.openConversation(refreshedConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("same-peer refresh 后首次 reopen 仍应恢复旧 draft", "", "alice-refresh-hidden-draft", shell.currentDetailDraft())
        assertEqual("same-peer refresh 后首次 reopen 应绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("same-peer refresh 后首次 reopen 应绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("same-peer refresh 后首次 reopen 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("same-peer refresh 后首次 reopen 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellRecoverySlotShouldStayHiddenAcrossRepeatedSamePeerRefreshes(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7441)
        let teamPeer = PeerId(0, 7442)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-repeated-refresh-hidden-draft")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let firstRefreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterFirstRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let secondRefreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterSecondRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("第一次 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第一次 same-peer refresh 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("第一次 same-peer refresh 后应更新 refreshed target 摘要", "", "alice-refresh-2", firstRefreshedConversation.previewText)
        assertEqual("第一次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterFirstRefresh.previewText)
        assertEqual("第二次 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第二次 same-peer refresh 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("第二次 same-peer refresh 后不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第二次 same-peer refresh 后不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第二次 same-peer refresh 后不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("第二次 same-peer refresh 后 refreshed target 摘要应保持有界", "", "alice-refresh-2", secondRefreshedConversation.previewText)
        assertEqual("第二次 same-peer refresh 后 refreshed target 消息数应保持为 2", "", 2, secondRefreshedConversation.messageCount)
        assertEqual("第二次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterSecondRefresh.previewText)
        assertEqual("两次 same-peer refresh 总共只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("两次 same-peer refresh 都不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellRepeatedSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7443)
        let teamPeer = PeerId(0, 7444)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-repeated-refresh-restore-once")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(refreshedConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("两次 same-peer refresh 后首次 reopen 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("两次 same-peer refresh 后首次 reopen 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("两次 same-peer refresh 后首次 reopen 应重新绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("两次 same-peer refresh 后首次 reopen 应重新绑定 refreshed target peer 标签", "", "peer:7443", shell.currentDetailPeerLabel())
        assertEqual("两次 same-peer refresh 后首次 reopen 应恢复 draft", "", "alice-repeated-refresh-restore-once", shell.currentDetailDraft())
        assertEqual("两次 same-peer refresh 后首次 reopen 应继续绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("两次 same-peer refresh 后首次 reopen 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("两次 same-peer refresh 后首次 reopen 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
        assertEqual("两次 same-peer refresh -> 首次 reopen 总共只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("两次 same-peer refresh -> 首次 reopen 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.backFromDetail()
        shell.openConversation(refreshedConversation)

        assertEqual("首次 reopen restore 后 slot 应立即被消费，第二次 reopen 不应再次恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("第二次 reopen 后仍应绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("第二次 reopen 后线程仍应保持 refreshed ownership", "", 2, shell.currentDetailMessages().size)
    }

    @TestCase
    public func appShellRepeatedSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7445)
        let teamPeer = PeerId(0, 7446)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-repeated-refresh-noop-draft")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("两次 same-peer refresh 期间仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("两次 same-peer refresh 期间 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("两次 same-peer refresh 后不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("两次 same-peer refresh 后 refreshed target 摘要应保持有界", "", "alice-refresh-2", refreshedConversation.previewText)
        assertEqual("两次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterRefresh.previewText)
        assertEqual("两次 same-peer refresh 后不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("两次 same-peer refresh 总共只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())

        shell.updateDetailDraft("list-route-should-not-touch-repeated-same-peer-slot")
        shell.sendDetailDraft()

        assertEqual("list-route composer API 在 repeated same-peer refresh 后仍不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list-route composer API 在 repeated same-peer refresh 后仍不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list-route composer API 在 repeated same-peer refresh 后仍不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("list-route composer API 在 repeated same-peer refresh 后仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list-route composer API 在 repeated same-peer refresh 后仍不应新增额外历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("list-route composer API 在 repeated same-peer refresh 后不应改写 refreshed target 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)
        assertEqual("list-route composer API 在 repeated same-peer refresh 后不应改写非目标摘要", "", "team-2", findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)

        shell.openConversation(refreshedConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("repeated same-peer refresh 后首次 reopen 仍应恢复旧 draft", "", "alice-repeated-refresh-noop-draft", shell.currentDetailDraft())
        assertEqual("repeated same-peer refresh 后首次 reopen 应绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("repeated same-peer refresh 后首次 reopen 应绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("repeated same-peer refresh 后首次 reopen 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("repeated same-peer refresh 后首次 reopen 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellRecoverySlotShouldStayHiddenAcrossThirdSamePeerRefreshBeforeFirstReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7447)
        let teamPeer = PeerId(0, 7448)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-third-refresh-hidden-draft")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let firstRefreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterFirstRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let secondRefreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterSecondRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let thirdRefreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterThirdRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("第一次 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第一次 same-peer refresh 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("第一次 same-peer refresh 后应更新 refreshed target 摘要", "", "alice-refresh-2", firstRefreshedConversation.previewText)
        assertEqual("第一次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterFirstRefresh.previewText)
        assertEqual("第二次 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第二次 same-peer refresh 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("第二次 same-peer refresh 后应继续保持 refreshed target 摘要有界", "", "alice-refresh-2", secondRefreshedConversation.previewText)
        assertEqual("第二次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterSecondRefresh.previewText)
        assertEqual("第三次 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第三次 same-peer refresh 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("第三次 same-peer refresh 后不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第三次 same-peer refresh 后不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第三次 same-peer refresh 后不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("第三次 same-peer refresh 后 refreshed target 摘要应保持有界", "", "alice-refresh-2", thirdRefreshedConversation.previewText)
        assertEqual("第三次 same-peer refresh 后 refreshed target 消息数应保持为 2", "", 2, thirdRefreshedConversation.messageCount)
        assertEqual("第三次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterThirdRefresh.previewText)
        assertEqual("三次 same-peer refresh 总共只应新增三次历史拉取", "", 5, adapter.getHistoryCallCount())
        assertEqual("三次 same-peer refresh 都不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellThirdSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7449)
        let teamPeer = PeerId(0, 7450)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-third-refresh-restore-once")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(refreshedConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("三次 same-peer refresh 后首次 reopen 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("三次 same-peer refresh 后首次 reopen 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("三次 same-peer refresh 后首次 reopen 应重新绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("三次 same-peer refresh 后首次 reopen 应重新绑定 refreshed target peer 标签", "", "peer:7449", shell.currentDetailPeerLabel())
        assertEqual("三次 same-peer refresh 后首次 reopen 应恢复 draft", "", "alice-third-refresh-restore-once", shell.currentDetailDraft())
        assertEqual("三次 same-peer refresh 后首次 reopen 应继续绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("三次 same-peer refresh 后首次 reopen 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("三次 same-peer refresh 后首次 reopen 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
        assertEqual("三次 same-peer refresh -> 首次 reopen 总共只应新增三次历史拉取", "", 5, adapter.getHistoryCallCount())
        assertEqual("三次 same-peer refresh -> 首次 reopen 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.backFromDetail()
        shell.openConversation(refreshedConversation)

        assertEqual("首次 reopen restore 后 slot 应立即被消费，第二次 reopen 不应再次恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("第二次 reopen 后仍应绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("第二次 reopen 后线程仍应保持 refreshed ownership", "", 2, shell.currentDetailMessages().size)
    }

    @TestCase
    public func appShellThirdSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7451)
        let teamPeer = PeerId(0, 7452)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(targetConversation)
        shell.updateDetailDraft("alice-third-refresh-noop-draft")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("三次 same-peer refresh 期间仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("三次 same-peer refresh 期间 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("三次 same-peer refresh 后不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("三次 same-peer refresh 后 refreshed target 摘要应保持有界", "", "alice-refresh-2", refreshedConversation.previewText)
        assertEqual("三次 same-peer refresh 后不应污染非目标摘要", "", "team-2", otherAfterRefresh.previewText)
        assertEqual("三次 same-peer refresh 后不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("三次 same-peer refresh 总共只应新增三次历史拉取", "", 5, adapter.getHistoryCallCount())

        shell.updateDetailDraft("list-route-should-not-touch-third-same-peer-slot")
        shell.sendDetailDraft()

        assertEqual("list-route composer API 在 third same-peer refresh 后仍不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list-route composer API 在 third same-peer refresh 后仍不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list-route composer API 在 third same-peer refresh 后仍不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("list-route composer API 在 third same-peer refresh 后仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list-route composer API 在 third same-peer refresh 后仍不应新增额外历史拉取", "", 5, adapter.getHistoryCallCount())
        assertEqual("list-route composer API 在 third same-peer refresh 后不应改写 refreshed target 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)
        assertEqual("list-route composer API 在 third same-peer refresh 后不应改写非目标摘要", "", "team-2", findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)

        shell.openConversation(refreshedConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("third same-peer refresh 后首次 reopen 仍应恢复旧 draft", "", "alice-third-refresh-noop-draft", shell.currentDetailDraft())
        assertEqual("third same-peer refresh 后首次 reopen 应绑定 refreshed target 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("third same-peer refresh 后首次 reopen 应绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("third same-peer refresh 后首次 reopen 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("third same-peer refresh 后首次 reopen 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellRecoverySlotShouldDropAfterOtherPeerRefreshBeforeReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7427)
        let teamPeer = PeerId(0, 7428)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("team-other-refresh-drop")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedOtherConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let originalAfterRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("armed slot 遇到 other-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("other-peer refresh 期间 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("other-peer refresh 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("other-peer refresh 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("other-peer refresh 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("other-peer refresh 应更新 refreshed other-peer 摘要", "", "alice-refresh-2", refreshedOtherConversation.previewText)
        assertEqual("other-peer refresh 后 refreshed other-peer 消息数应保持为 2", "", 2, refreshedOtherConversation.messageCount)
        assertEqual("other-peer refresh 不应污染原 draft peer 摘要", "", "team-2", originalAfterRefresh.previewText)
        assertEqual("other-peer refresh 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("other-peer refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.openConversation(refreshedOtherConversation)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("other-peer refresh 后首次 reopen refreshed other peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("other-peer refresh 后首次 reopen refreshed other peer 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("other-peer refresh 后首次 reopen 应重新绑定 refreshed other peer 标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("other-peer refresh 后首次 reopen 应重新绑定 refreshed other peer peer 标签", "", "peer:7427", shell.currentDetailPeerLabel())
        assertEqual("other-peer refresh 后首次 reopen refreshed other peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("other-peer refresh 后首次 reopen refreshed other peer 应绑定 refreshed thread", "", 2, detailMessages.size)
        assertEqual("other-peer refresh 后首次 reopen refreshed other peer 的第一条消息应来自 refreshed thread", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("other-peer refresh 后首次 reopen refreshed other peer 的第二条消息应来自 refreshed thread", "", "alice-refresh-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellDroppedRecoveryAfterOtherPeerRefreshShouldNotRestoreOnOriginalReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7429)
        let teamPeer = PeerId(0, 7430)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("team-original-reopen-should-drop")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        shell.openConversation(findSummaryByPeer(shell.visibleSessions(), teamPeer))
        let detailMessages = shell.currentDetailMessages()

        assertEqual("other-peer refresh 后 reopen 原 peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("other-peer refresh 后 reopen 原 peer 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("other-peer refresh 后 reopen 原 peer 应重新绑定原标题", "", "Team", shell.currentDetailTitle())
        assertEqual("other-peer refresh 后 reopen 原 peer 应重新绑定原 peer 标签", "", "peer:7430", shell.currentDetailPeerLabel())
        assertEqual("other-peer refresh 后 reopen 原 peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("other-peer refresh 后 reopen 原 peer 应仍绑定原线程", "", 2, detailMessages.size)
        assertEqual("other-peer refresh 后 reopen 原 peer 的第一条消息应来自原线程", "", "team-1", detailMessages[0].text)
        assertEqual("other-peer refresh 后 reopen 原 peer 的第二条消息应来自原线程", "", "team-2", detailMessages[1].text)
        assertEqual("other-peer refresh -> original reopen 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("other-peer refresh -> original reopen 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.backFromDetail()
        shell.openConversation(findSummaryByPeer(shell.visibleSessions(), teamPeer))

        assertEqual("other-peer refresh 丢弃后第二次 reopen 原 peer 仍不应幽灵恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("other-peer refresh 丢弃后第二次 reopen 原 peer 仍应绑定原标题", "", "Team", shell.currentDetailTitle())
    }

    @TestCase
    public func appShellOtherPeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7431)
        let teamPeer = PeerId(0, 7432)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("team-hidden-after-other-refresh")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedOtherConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let originalAfterRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("armed slot + other-peer refresh 期间仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("armed slot + other-peer refresh 期间 draft 不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("armed slot + other-peer refresh 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("armed slot + other-peer refresh 应更新 refreshed other-peer 摘要", "", "alice-refresh-2", refreshedOtherConversation.previewText)
        assertEqual("armed slot + other-peer refresh 不应污染原 draft peer 摘要", "", "team-2", originalAfterRefresh.previewText)
        assertEqual("armed slot + other-peer refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("armed slot + other-peer refresh 只应新增一次历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.updateDetailDraft("list-route-should-not-touch-other-peer-refresh-slot")
        shell.sendDetailDraft()

        assertEqual("list-route composer API 在 other-peer refresh 后仍不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list-route composer API 在 other-peer refresh 后仍不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list-route composer API 在 other-peer refresh 后仍不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("list-route composer API 在 other-peer refresh 后仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list-route composer API 在 other-peer refresh 后仍不应新增额外历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("list-route composer API 在 other-peer refresh 后不应改写 refreshed other-peer 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)
        assertEqual("list-route composer API 在 other-peer refresh 后不应改写原 draft peer 摘要", "", "team-2", findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)
    }

    @TestCase
    public func appShellRecoverySlotShouldSurviveSamePeerRefreshThenDropAfterOtherPeerRefreshBeforeReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7433)
        let teamPeer = PeerId(0, 7434)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-mixed-refresh-drop")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let samePeerAfterRefresh = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherBeforeDrop = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("same-peer refresh 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("same-peer refresh 后不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("same-peer refresh 应更新原 recovery peer 摘要", "", "alice-refresh-2", samePeerAfterRefresh.previewText)
        assertEqual("same-peer refresh 不应污染 other peer 摘要", "", "team-2", otherBeforeDrop.previewText)
        assertEqual("same-peer refresh 只应新增一次历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("same-peer refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        adapter.seedHistory(teamPeer, buildUpdatedRemoteHistory(teamPeer))
        shell.refreshConversation(teamPeer, 2)
        let originalAfterDrop = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let refreshedOtherConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("other-peer refresh 紧跟 same-peer refresh 后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("mixed refresh drop 后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("mixed refresh drop 后不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("mixed refresh drop 后不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("mixed refresh drop 后不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("mixed refresh drop 后原 recovery peer 的 refreshed 摘要仍应保留", "", "alice-refresh-2", originalAfterDrop.previewText)
        assertEqual("mixed refresh drop 后 refreshed other peer 摘要应更新", "", "alice-refresh-2", refreshedOtherConversation.previewText)
        assertEqual("mixed refresh 序列只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("mixed refresh 序列不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.openConversation(originalAfterDrop)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("mixed refresh drop 后首次 reopen 原 recovery peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("mixed refresh drop 后首次 reopen 原 recovery peer 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("mixed refresh drop 后首次 reopen 原 recovery peer 应重新绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("mixed refresh drop 后首次 reopen 原 recovery peer 应重新绑定原 peer 标签", "", "peer:7433", shell.currentDetailPeerLabel())
        assertEqual("same-peer refresh 后紧跟 other-peer refresh 再 reopen 原 peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 应绑定 refreshed 原线程", "", 2, detailMessages.size)
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 的第一条消息应来自 refreshed 原线程", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 的第二条消息应来自 refreshed 原线程", "", "alice-refresh-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellDroppedRecoveryAfterMixedRefreshShouldNotRestoreOnAnyLaterReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7435)
        let teamPeer = PeerId(0, 7436)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-mixed-refresh-no-restore")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(teamPeer, buildUpdatedRemoteHistory(teamPeer))
        shell.refreshConversation(teamPeer, 2)

        let originalAfterDrop = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterDrop = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(originalAfterDrop)
        let originalMessages = shell.currentDetailMessages()

        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 应绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 应绑定 refreshed 原线程", "", 2, originalMessages.size)
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 的第一条消息应来自 refreshed 原线程", "", "alice-refresh-1", originalMessages[0].text)
        assertEqual("mixed refresh drop 后 reopen 原 recovery peer 的第二条消息应来自 refreshed 原线程", "", "alice-refresh-2", originalMessages[1].text)

        shell.backFromDetail()
        shell.openConversation(otherAfterDrop)
        let otherMessages = shell.currentDetailMessages()

        assertEqual("mixed refresh drop 后 reopen other peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("mixed refresh drop 后 reopen other peer 也不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("mixed refresh drop 后 reopen other peer 应绑定 other peer 标题", "", "Team", shell.currentDetailTitle())
        assertEqual("mixed refresh drop 后 reopen other peer 应绑定 refreshed other thread", "", 2, otherMessages.size)
        assertEqual("mixed refresh drop 后 reopen other peer 的第一条消息应来自 refreshed other thread", "", "alice-refresh-1", otherMessages[0].text)
        assertEqual("mixed refresh drop 后 reopen other peer 的第二条消息应来自 refreshed other thread", "", "alice-refresh-2", otherMessages[1].text)

        shell.backFromDetail()
        shell.openConversation(originalAfterDrop)

        assertEqual("mixed refresh drop 后任何后续 reopen 都不应幽灵恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("mixed refresh drop 后再次 reopen 原 recovery peer 仍应绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("mixed refresh 序列后的 later reopen 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("mixed refresh 序列后的 later reopen 不应新增额外历史拉取", "", 4, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7437)
        let teamPeer = PeerId(0, 7438)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-mixed-refresh-hidden")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        adapter.seedHistory(teamPeer, buildUpdatedRemoteHistory(teamPeer))
        shell.refreshConversation(teamPeer, 2)

        let originalAfterMixedRefresh = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterMixedRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("armed slot + mixed refresh 期间仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("armed slot + mixed refresh 期间 draft 不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("armed slot + mixed refresh 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("armed slot + mixed refresh 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("armed slot + mixed refresh 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("armed slot + mixed refresh 后原 recovery peer 的 refreshed 摘要仍应保留", "", "alice-refresh-2", originalAfterMixedRefresh.previewText)
        assertEqual("armed slot + mixed refresh 后 other peer 的 refreshed 摘要应更新", "", "alice-refresh-2", otherAfterMixedRefresh.previewText)
        assertEqual("armed slot + mixed refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("armed slot + mixed refresh 只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())

        shell.updateDetailDraft("list-route-should-not-touch-mixed-refresh-slot")
        shell.sendDetailDraft()

        assertEqual("list-route composer API 在 mixed refresh 后仍不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list-route composer API 在 mixed refresh 后仍不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list-route composer API 在 mixed refresh 后仍不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("list-route composer API 在 mixed refresh 后仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list-route composer API 在 mixed refresh 后仍不应新增额外历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("list-route composer API 在 mixed refresh 后不应改写原 recovery peer 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)
        assertEqual("list-route composer API 在 mixed refresh 后不应改写 other peer 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)
    }

    @TestCase
    public func appShellRecoverySlotShouldDropBeforeSamePeerRefreshCanRearmOrRestore(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7439)
        let teamPeer = PeerId(0, 7440)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-reverse-order-drop")
        shell.backFromDetail()

        adapter.seedHistory(teamPeer, buildUpdatedRemoteHistory(teamPeer))
        shell.refreshConversation(teamPeer, 2)
        let otherAfterDrop = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let originalBeforeSamePeerRefresh = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("other-peer refresh 先发生后仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("other-peer refresh 先发生后 draft 仍不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("other-peer refresh 先发生后不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("other-peer refresh 先发生后不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("other-peer refresh 先发生后应更新 other peer 摘要", "", "alice-refresh-2", otherAfterDrop.previewText)
        assertEqual("other-peer refresh 先发生后不应污染原 recovery peer 摘要", "", "alice-2", originalBeforeSamePeerRefresh.previewText)
        assertEqual("reverse-order mixed refresh 的第一跳只应新增一次历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("reverse-order mixed refresh 的第一跳不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let originalAfterFinalRefresh = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterFinalRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("drop 后再 same-peer refresh 仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("drop 后再 same-peer refresh 不应 resurrect 旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("drop 后再 same-peer refresh 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("drop 后再 same-peer refresh 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("drop 后再 same-peer refresh 应只更新原 recovery peer 摘要", "", "alice-refresh-2", originalAfterFinalRefresh.previewText)
        assertEqual("drop 后的 other peer refreshed 摘要应继续保留", "", "alice-refresh-2", otherAfterFinalRefresh.previewText)
        assertEqual("reverse-order mixed refresh 序列不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("reverse-order mixed refresh 序列只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("reverse-order mixed refresh 序列不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())

        shell.openConversation(originalAfterFinalRefresh)
        let detailMessages = shell.currentDetailMessages()

        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 应重新绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 应重新绑定原 peer 标签", "", "peer:7439", shell.currentDetailPeerLabel())
        assertEqual("other-peer refresh 先 drop 后 same-peer refresh 再 reopen 原 peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 应绑定 refreshed 原线程", "", 2, detailMessages.size)
        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 的第一条消息应来自 refreshed 原线程", "", "alice-refresh-1", detailMessages[0].text)
        assertEqual("drop 后再 same-peer refresh 后 reopen 原 recovery peer 的第二条消息应来自 refreshed 原线程", "", "alice-refresh-2", detailMessages[1].text)
    }

    @TestCase
    public func appShellDroppedRecoveryAfterReverseOrderMixedRefreshShouldNotRestoreOnAnyLaterReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7441)
        let teamPeer = PeerId(0, 7442)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-reverse-order-no-restore")
        shell.backFromDetail()

        adapter.seedHistory(teamPeer, buildUpdatedRemoteHistory(teamPeer))
        shell.refreshConversation(teamPeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)

        let originalAfterMixedRefresh = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterMixedRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(originalAfterMixedRefresh)
        let originalMessages = shell.currentDetailMessages()

        assertEqual("reverse-order mixed refresh 后 reopen 原 recovery peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reverse-order mixed refresh 后 reopen 原 recovery peer 不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("reverse-order mixed refresh 后 reopen 原 recovery peer 应绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("reverse-order mixed refresh 后 reopen 原 recovery peer 应绑定 refreshed 原线程", "", 2, originalMessages.size)
        assertEqual("reverse-order mixed refresh 后 reopen 原 recovery peer 的第一条消息应来自 refreshed 原线程", "", "alice-refresh-1", originalMessages[0].text)
        assertEqual("reverse-order mixed refresh 后 reopen 原 recovery peer 的第二条消息应来自 refreshed 原线程", "", "alice-refresh-2", originalMessages[1].text)

        shell.backFromDetail()
        shell.openConversation(otherAfterMixedRefresh)
        let otherMessages = shell.currentDetailMessages()

        assertEqual("reverse-order mixed refresh 后 reopen other peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reverse-order mixed refresh 后 reopen other peer 也不应恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("reverse-order mixed refresh 后 reopen other peer 应绑定 other peer 标题", "", "Team", shell.currentDetailTitle())
        assertEqual("reverse-order mixed refresh 后 reopen other peer 应绑定 refreshed other thread", "", 2, otherMessages.size)
        assertEqual("reverse-order mixed refresh 后 reopen other peer 的第一条消息应来自 refreshed other thread", "", "alice-refresh-1", otherMessages[0].text)
        assertEqual("reverse-order mixed refresh 后 reopen other peer 的第二条消息应来自 refreshed other thread", "", "alice-refresh-2", otherMessages[1].text)

        shell.backFromDetail()
        shell.openConversation(originalAfterMixedRefresh)

        assertEqual("reverse-order mixed refresh 后任何后续 reopen 都不应幽灵恢复旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("reverse-order mixed refresh 后再次 reopen 原 recovery peer 仍应绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("reverse-order mixed refresh 序列后的 later reopen 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("reverse-order mixed refresh 序列后的 later reopen 不应新增额外历史拉取", "", 4, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellReverseOrderMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7443)
        let teamPeer = PeerId(0, 7444)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-reverse-order-hidden")
        shell.backFromDetail()

        adapter.seedHistory(teamPeer, buildUpdatedRemoteHistory(teamPeer))
        shell.refreshConversation(teamPeer, 2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)

        let originalAfterMixedRefresh = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterMixedRefresh = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("armed slot + reverse-order mixed refresh 期间仍应停在列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("armed slot + reverse-order mixed refresh 期间 draft 不得暴露", "", "", shell.currentDetailDraft())
        assertEqual("armed slot + reverse-order mixed refresh 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("armed slot + reverse-order mixed refresh 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("armed slot + reverse-order mixed refresh 不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("armed slot + reverse-order mixed refresh 后原 recovery peer 的 refreshed 摘要应更新", "", "alice-refresh-2", originalAfterMixedRefresh.previewText)
        assertEqual("armed slot + reverse-order mixed refresh 后 other peer 的 refreshed 摘要应保留", "", "alice-refresh-2", otherAfterMixedRefresh.previewText)
        assertEqual("armed slot + reverse-order mixed refresh 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("armed slot + reverse-order mixed refresh 只应新增两次历史拉取", "", 4, adapter.getHistoryCallCount())

        shell.updateDetailDraft("list-route-should-not-touch-reverse-order-slot")
        shell.sendDetailDraft()

        assertEqual("list-route composer API 在 reverse-order mixed refresh 后仍不应激活详情页", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list-route composer API 在 reverse-order mixed refresh 后仍不应暴露 draft", "", "", shell.currentDetailDraft())
        assertEqual("list-route composer API 在 reverse-order mixed refresh 后仍不应打破 bounded history", "", 2, shell.historySize())
        assertEqual("list-route composer API 在 reverse-order mixed refresh 后仍不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("list-route composer API 在 reverse-order mixed refresh 后仍不应新增额外历史拉取", "", 4, adapter.getHistoryCallCount())
        assertEqual("list-route composer API 在 reverse-order mixed refresh 后不应改写原 recovery peer 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), alicePeer).previewText)
        assertEqual("list-route composer API 在 reverse-order mixed refresh 后不应改写 other peer 摘要", "", "alice-refresh-2", findSummaryByPeer(shell.visibleSessions(), teamPeer).previewText)
    }

    @TestCase
    public func appShellRecoveredDraftAfterSamePeerRefreshReopenShouldDropOnDirectRetargetToOtherPeer(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7445)
        let teamPeer = PeerId(0, 7446)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-refresh-reopen-retarget-drop")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(refreshedConversation)
        assertEqual("refresh 后首次 reopen 应恢复 draft", "", "alice-refresh-reopen-retarget-drop", shell.currentDetailDraft())

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)
        let retargetedMessages = shell.currentDetailMessages()
        let refreshedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("恢复后的 draft direct retarget 到 other peer 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("恢复后的 draft direct retarget 到 other peer 后 history 不应膨胀到 3", "", 2, shell.historySize())
        assertEqual("恢复后的 draft direct retarget 到 other peer 后标题应切到新目标", "", "Team", shell.currentDetailTitle())
        assertEqual("恢复后的 draft direct retarget 到 other peer 后 peer 标签应切到新目标", "", "peer:7446", shell.currentDetailPeerLabel())
        assertEqual("恢复后的 draft direct retarget 到 other peer 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("恢复后的 draft 不得泄漏到 new target", "", "", shell.currentDetailDraft())
        assertEqual("恢复后的 draft direct retarget 到 other peer 后应绑定 new target 线程", "", 2, retargetedMessages.size)
        assertEqual("恢复后的 draft direct retarget 到 other peer 后第一条消息应来自 new target 原线程", "", "team-1", retargetedMessages[0].text)
        assertEqual("恢复后的 draft direct retarget 到 other peer 后第二条消息应来自 new target 原线程", "", "team-2", retargetedMessages[1].text)
        assertEqual("原 recovery peer 的 refreshed 摘要在 direct retarget 后仍应保留", "", "alice-refresh-2", refreshedAfterRetarget.previewText)
        assertEqual("原 recovery peer 的 refreshed 消息数在 direct retarget 后仍应保持为 2", "", 2, refreshedAfterRetarget.messageCount)
        assertEqual("other peer 摘要在 direct retarget 后不应被旧 draft 污染", "", "team-2", otherAfterRetarget.previewText)
        assertEqual("refresh -> reopen -> direct retarget after recovery 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("refresh -> reopen -> direct retarget after recovery 不应新增额外历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellDirectRetargetAfterRecoveredDraftShouldNotGhostRestoreOnLaterOriginalPeerReopen(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7447)
        let teamPeer = PeerId(0, 7448)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-refresh-reopen-retarget-no-ghost")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(refreshedConversation)

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)
        shell.backFromDetail()

        let originalAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(originalAfterRetarget)
        let originalMessages = shell.currentDetailMessages()

        assertEqual("direct retarget 之后 later reopen 原 peer 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("direct retarget 之后 later reopen 原 peer 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("direct retarget 之后 later reopen 原 peer 应重新绑定原标题", "", "Alice", shell.currentDetailTitle())
        assertEqual("direct retarget 之后 later reopen 原 peer 应重新绑定原 peer 标签", "", "peer:7447", shell.currentDetailPeerLabel())
        assertEqual("direct retarget 丢弃后 later reopen 原 peer 不得 ghost-restore 旧 draft", "", "", shell.currentDetailDraft())
        assertEqual("direct retarget 之后 later reopen 原 peer 应绑定 refreshed 原线程", "", 2, originalMessages.size)
        assertEqual("direct retarget 之后 later reopen 原 peer 的第一条消息应来自 refreshed 原线程", "", "alice-refresh-1", originalMessages[0].text)
        assertEqual("direct retarget 之后 later reopen 原 peer 的第二条消息应来自 refreshed 原线程", "", "alice-refresh-2", originalMessages[1].text)
        assertEqual("direct retarget 之后 other peer 摘要在 back 后不应被污染", "", "team-2", otherAfterBack.previewText)
        assertEqual("direct retarget 之后 later reopen 原 peer 不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("direct retarget 之后 later reopen 原 peer 不应新增额外历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshReopenRetargetAfterRecoveryShouldKeepOtherPeerOwnershipAndBoundedHistory(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7449)
        let teamPeer = PeerId(0, 7450)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(originalConversation)
        shell.updateDetailDraft("alice-refresh-reopen-retarget-bounded")
        shell.backFromDetail()

        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))
        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.openConversation(refreshedConversation)
        assertEqual("bounded-chain refresh 后首次 reopen 应恢复 draft", "", "alice-refresh-reopen-retarget-bounded", shell.currentDetailDraft())

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)

        let refreshedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("refresh -> reopen -> retarget after recovery 链路应停在 other peer 详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("refresh -> reopen -> retarget after recovery 链路 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("refresh -> reopen -> retarget after recovery 链路标题应切到 other peer", "", "Team", shell.currentDetailTitle())
        assertEqual("refresh -> reopen -> retarget after recovery 链路 peer 标签应切到 other peer", "", "peer:7450", shell.currentDetailPeerLabel())
        assertEqual("refresh -> reopen -> retarget after recovery 链路占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("refresh -> reopen -> retarget after recovery 链路不应把 recovered draft 泄漏到 other peer", "", "", shell.currentDetailDraft())
        assertEqual("refresh -> reopen -> retarget after recovery 链路原 peer refreshed 摘要应保留", "", "alice-refresh-2", refreshedAfterRetarget.previewText)
        assertEqual("refresh -> reopen -> retarget after recovery 链路原 peer refreshed 消息数应保持为 2", "", 2, refreshedAfterRetarget.messageCount)
        assertEqual("refresh -> reopen -> retarget after recovery 链路 other peer 摘要应保持稳定", "", "team-2", otherAfterRetarget.previewText)
        assertEqual("refresh -> reopen -> retarget after recovery 链路不应触发 sendMessage", "", 0, adapter.sendMessageCallCount())
        assertEqual("refresh -> reopen -> retarget after recovery 链路不应新增额外历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshShouldUpdateOnlyTheTargetSummaryWithoutBreakingDetailBoundary(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7451)
        let teamPeer = PeerId(0, 7452)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let chosen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(chosen)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshed = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let unchanged = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("shell refresh 后目标会话摘要应更新", "", "alice-refresh-2", refreshed.previewText)
        assertEqual("shell refresh 后目标会话消息数应保持为 2", "", 2, refreshed.messageCount)
        assertEqual("非目标会话摘要不应被污染", "", "team-2", unchanged.previewText)
        assertEqual("refresh 不应改变当前 detail route", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("refresh 不应打穿 detail 标题边界", "", "Team", shell.currentDetailTitle())
        assertEqual("refresh 不应打穿 detail peer 标签边界", "", "peer:7452", shell.currentDetailPeerLabel())
        assertEqual("refresh 不应改变 detail 占位内容", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("detail route 历史不应因 refresh 扩大", "", 2, shell.historySize())
        assertEqual("refresh 必须新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellShouldRetargetActiveDetailConversationWithoutGrowingRouteHistory(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7461)
        let teamPeer = PeerId(0, 7462)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let aliceConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(teamConversation)
        shell.openConversation(aliceConversation)

        assertEqual("detail 内切换会话后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("detail 内切换会话不应继续增长路由历史", "", 2, shell.historySize())
        assertEqual("detail 内切换会话后标题应切到新目标", "", "Alice", shell.currentDetailTitle())
        assertEqual("detail 内切换会话后 peer 标签应切到新目标", "", "peer:7461", shell.currentDetailPeerLabel())
        assertEqual("切换 detail 会话不应改变占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
    }

    @TestCase
    public func appShellBackShouldReturnToSessionListAfterDetailRetargetsWithoutForwardHistoryGrowth(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7471)
        let teamPeer = PeerId(0, 7472)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let aliceConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(teamConversation)
        shell.openConversation(aliceConversation)
        shell.openConversation(teamConversation)

        shell.backFromDetail()
        assertEqual("多次 retarget 后 back 应稳定回到列表", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后 history 仍应保持为 2", "", 2, shell.historySize())

        shell.openConversation(aliceConversation)

        assertEqual("回到列表后再次打开会话应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("back 后再次打开不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("重新打开后标题应来自新目标会话", "", "Alice", shell.currentDetailTitle())
        assertEqual("重新打开后 peer 标签应来自新目标会话", "", "peer:7471", shell.currentDetailPeerLabel())
        assertEqual("重新打开后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
    }

    @TestCase
    public func appShellBackShouldClearDetailProjectionAfterReturningToSessionList(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7481)
        let teamPeer = PeerId(0, 7482)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(teamConversation)
        assertEqual("进入详情后标题应先绑定到目标会话", "", "Team", shell.currentDetailTitle())

        shell.backFromDetail()

        assertEqual("back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("返回列表后不应继续泄漏旧 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("返回列表后不应继续泄漏旧 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("返回列表后不应继续泄漏旧 detail 占位正文", "", "", shell.currentDetailBody())
    }

    @TestCase
    public func appShellRefreshAfterBackShouldKeepListRouteAndDetailProjectionIsolation(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7491)
        let teamPeer = PeerId(0, 7492)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(teamConversation)
        shell.backFromDetail()
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshed = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let unchanged = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("back 后 refresh 仍应停在会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后 refresh 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("back 后 refresh 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("back 后 refresh 不应重新激活 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("back 后 refresh 不应改变 bounded history 大小", "", 2, shell.historySize())
        assertEqual("目标会话摘要应刷新为新尾消息", "", "alice-refresh-2", refreshed.previewText)
        assertEqual("目标会话消息数应保持为 2", "", 2, refreshed.messageCount)
        assertEqual("非目标会话摘要不应被污染", "", "team-2", unchanged.previewText)
        assertEqual("refresh 必须新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshThenReopenShouldPreserveCoherentDetailAndListState(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7493)
        let teamPeer = PeerId(0, 7494)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(teamConversation)
        shell.backFromDetail()
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let unchangedBeforeReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        shell.openConversation(refreshedConversation)
        let refreshedAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let unchangedAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("refresh 后重新打开目标会话应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("refresh 后重新打开目标会话不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("重新打开后的标题应来自刷新的目标会话", "", "Alice", shell.currentDetailTitle())
        assertEqual("重新打开后的 peer 标签应来自刷新的目标会话", "", "peer:7493", shell.currentDetailPeerLabel())
        assertEqual("重新打开后的占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("列表里的已刷新目标摘要在重新打开后不应丢失", "", "alice-refresh-2", refreshedAfterReopen.previewText)
        assertEqual("列表里的已刷新目标消息数在重新打开后不应丢失", "", 2, refreshedAfterReopen.messageCount)
        assertEqual("重新打开前的非目标摘要不应被污染", "", "team-2", unchangedBeforeReopen.previewText)
        assertEqual("重新打开后的非目标摘要不应被污染", "", "team-2", unchangedAfterReopen.previewText)
        assertEqual("refresh 加 reopen 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshActiveDetailTargetThenBackAndReopenShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7501)
        let teamPeer = PeerId(0, 7502)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(targetConversation)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail target refresh 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail target refresh 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("active detail target refresh 不应打穿标题绑定", "", "Alice", shell.currentDetailTitle())
        assertEqual("active detail target refresh 不应打穿 peer 标签绑定", "", "peer:7501", shell.currentDetailPeerLabel())
        assertEqual("active detail target refresh 不应改变占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("active detail target refresh 应刷新同一 target 摘要", "", "alice-refresh-2", refreshedWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 后同一 target 消息数应保持为 2", "", 2, refreshedWhileActiveDetail.messageCount)
        assertEqual("active detail target refresh 不应污染非目标摘要", "", "team-2", otherWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.backFromDetail()
        let refreshedAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后 detail 标题应清空", "", "", shell.currentDetailTitle())
        assertEqual("back 后 detail peer 标签应清空", "", "", shell.currentDetailPeerLabel())
        assertEqual("back 后 detail 占位正文应清空", "", "", shell.currentDetailBody())
        assertEqual("back 后 bounded history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("back 后同一 refreshed target 摘要不应丢失", "", "alice-refresh-2", refreshedAfterBack.previewText)
        assertEqual("back 后非目标摘要不应被污染", "", "team-2", otherAfterBack.previewText)

        shell.openConversation(refreshedAfterBack)
        let refreshedAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("reopen same refreshed target 后应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen same refreshed target 后 history 不应膨胀到 3", "", 2, shell.historySize())
        assertEqual("reopen same refreshed target 后标题应重新绑定到 target", "", "Alice", shell.currentDetailTitle())
        assertEqual("reopen same refreshed target 后 peer 标签应重新绑定到 target", "", "peer:7501", shell.currentDetailPeerLabel())
        assertEqual("reopen same refreshed target 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("reopen same refreshed target 后 refreshed 摘要不应丢失", "", "alice-refresh-2", refreshedAfterReopen.previewText)
        assertEqual("reopen same refreshed target 后 refreshed 消息数应保持为 2", "", 2, refreshedAfterReopen.messageCount)
        assertEqual("reopen same refreshed target 后非目标摘要不应被污染", "", "team-2", otherAfterReopen.previewText)
        assertEqual("active detail refresh round-trip 不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshActiveDetailTargetThenRetargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7503)
        let teamPeer = PeerId(0, 7504)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let activeTargetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(activeTargetConversation)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail target refresh 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail target refresh 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("active detail target refresh 不应打穿标题绑定", "", "Alice", shell.currentDetailTitle())
        assertEqual("active detail target refresh 不应打穿 peer 标签绑定", "", "peer:7503", shell.currentDetailPeerLabel())
        assertEqual("active detail target refresh 不应改变占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("active detail target refresh 应刷新同一 target 摘要", "", "alice-refresh-2", refreshedWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 后同一 target 消息数应保持为 2", "", 2, refreshedWhileActiveDetail.messageCount)
        assertEqual("active detail target refresh 不应污染非目标摘要", "", "team-2", otherWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)

        let refreshedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail refresh 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail refresh 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到新目标会话", "", "Team", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到新目标会话", "", "peer:7504", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 摘要在 retarget 后仍应保留在列表面", "", "alice-refresh-2", refreshedAfterRetarget.previewText)
        assertEqual("原 refreshed target 消息数在 retarget 后仍应保持为 2", "", 2, refreshedAfterRetarget.messageCount)
        assertEqual("other visible summary 在 retarget 后不应被污染", "", "team-2", otherAfterRetarget.previewText)
        assertEqual("active detail refresh 后直接 retarget 不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshActiveDetailRetargetBackThenReopenOriginalTargetShouldPreserveRoundTripStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7505)
        let teamPeer = PeerId(0, 7506)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let activeTargetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(activeTargetConversation)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail target refresh 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail target refresh 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("active detail target refresh 不应打穿标题绑定", "", "Alice", shell.currentDetailTitle())
        assertEqual("active detail target refresh 不应打穿 peer 标签绑定", "", "peer:7505", shell.currentDetailPeerLabel())
        assertEqual("active detail target refresh 不应改变占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("active detail target refresh 应刷新同一 target 摘要", "", "alice-refresh-2", refreshedWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 后同一 target 消息数应保持为 2", "", 2, refreshedWhileActiveDetail.messageCount)
        assertEqual("active detail target refresh 不应污染非目标摘要", "", "team-2", otherWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)

        let refreshedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail refresh 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail refresh 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到新目标会话", "", "Team", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到新目标会话", "", "peer:7506", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 摘要在 retarget 后仍应保留在列表面", "", "alice-refresh-2", refreshedAfterRetarget.previewText)
        assertEqual("原 refreshed target 消息数在 retarget 后仍应保持为 2", "", 2, refreshedAfterRetarget.messageCount)
        assertEqual("other visible summary 在 retarget 后不应被污染", "", "team-2", otherAfterRetarget.previewText)
        assertEqual("active detail refresh 后直接 retarget 不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.backFromDetail()
        let refreshedAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("retarget 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("retarget 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("retarget 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("retarget 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("retarget 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("retarget 后 back 原 refreshed target 摘要不应丢失", "", "alice-refresh-2", refreshedAfterBack.previewText)
        assertEqual("retarget 后 back 原 refreshed target 消息数应保持为 2", "", 2, refreshedAfterBack.messageCount)
        assertEqual("retarget 后 back 非目标摘要不应被污染", "", "team-2", otherAfterBack.previewText)

        shell.openConversation(refreshedAfterBack)
        let refreshedAfterRoundTrip = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRoundTrip = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("round-trip 后重新打开原 refreshed target 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("round-trip 后 history 不应膨胀到 3", "", 2, shell.historySize())
        assertEqual("round-trip 后标题应重新绑定到原 refreshed target", "", "Alice", shell.currentDetailTitle())
        assertEqual("round-trip 后 peer 标签应重新绑定到原 refreshed target", "", "peer:7505", shell.currentDetailPeerLabel())
        assertEqual("round-trip 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 的摘要在 round-trip 后不应丢失", "", "alice-refresh-2", refreshedAfterRoundTrip.previewText)
        assertEqual("原 refreshed target 的消息数在 round-trip 后应保持为 2", "", 2, refreshedAfterRoundTrip.messageCount)
        assertEqual("重新打开原 refreshed target 后非目标摘要不应被污染", "", "team-2", otherAfterRoundTrip.previewText)
        assertEqual("active detail refresh-retarget-back-reopen 链路不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshActiveDetailRetargetAlternatingReopenShouldKeepBoundedStableDetailOwnership(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7507)
        let teamPeer = PeerId(0, 7508)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let activeTargetConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(activeTargetConversation)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherWhileActiveDetail = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail target refresh 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail target refresh 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("active detail target refresh 不应打穿标题绑定", "", "Alice", shell.currentDetailTitle())
        assertEqual("active detail target refresh 不应打穿 peer 标签绑定", "", "peer:7507", shell.currentDetailPeerLabel())
        assertEqual("active detail target refresh 不应改变占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("active detail target refresh 应刷新同一 target 摘要", "", "alice-refresh-2", refreshedWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 后同一 target 消息数应保持为 2", "", 2, refreshedWhileActiveDetail.messageCount)
        assertEqual("active detail target refresh 不应污染 other visible summary", "", "team-2", otherWhileActiveDetail.previewText)
        assertEqual("active detail target refresh 只应新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)

        let refreshedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("active detail refresh 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("active detail refresh 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到 other visible conversation", "", "Team", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到 other visible conversation", "", "peer:7508", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 摘要在 retarget 后仍应保留在列表面", "", "alice-refresh-2", refreshedAfterRetarget.previewText)
        assertEqual("原 refreshed target 消息数在 retarget 后仍应保持为 2", "", 2, refreshedAfterRetarget.messageCount)
        assertEqual("other visible summary 在 retarget 后不应被污染", "", "team-2", otherAfterRetarget.previewText)
        assertEqual("active detail refresh 后直接 retarget 不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())

        shell.backFromDetail()
        let refreshedAfterFirstBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterFirstBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("第一次 back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第一次 back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第一次 back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第一次 back 后不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("第一次 back 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("第一次 back 后原 refreshed target 摘要不应丢失", "", "alice-refresh-2", refreshedAfterFirstBack.previewText)
        assertEqual("第一次 back 后原 refreshed target 消息数应保持为 2", "", 2, refreshedAfterFirstBack.messageCount)
        assertEqual("第一次 back 后 other visible summary 不应被污染", "", "team-2", otherAfterFirstBack.previewText)

        shell.openConversation(refreshedAfterFirstBack)
        let refreshedAfterOriginalReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterOriginalReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("重新打开原 refreshed target 后应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("重新打开原 refreshed target 后 history 不应膨胀到 3", "", 2, shell.historySize())
        assertEqual("重新打开原 refreshed target 后标题应重新绑定到 target", "", "Alice", shell.currentDetailTitle())
        assertEqual("重新打开原 refreshed target 后 peer 标签应重新绑定到 target", "", "peer:7507", shell.currentDetailPeerLabel())
        assertEqual("重新打开原 refreshed target 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 摘要在重新打开后不应丢失", "", "alice-refresh-2", refreshedAfterOriginalReopen.previewText)
        assertEqual("原 refreshed target 消息数在重新打开后应保持为 2", "", 2, refreshedAfterOriginalReopen.messageCount)
        assertEqual("other visible summary 在重新打开原 target 后不应被污染", "", "team-2", otherAfterOriginalReopen.previewText)

        shell.backFromDetail()
        let refreshedAfterSecondBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterSecondBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("第二次 back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第二次 back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第二次 back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第二次 back 后不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("第二次 back 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("第二次 back 后原 refreshed target 摘要不应丢失", "", "alice-refresh-2", refreshedAfterSecondBack.previewText)
        assertEqual("第二次 back 后原 refreshed target 消息数应保持为 2", "", 2, refreshedAfterSecondBack.messageCount)
        assertEqual("other visible summary 在最终 reopen 前不应被污染", "", "team-2", otherAfterSecondBack.previewText)

        shell.openConversation(otherAfterSecondBack)
        let refreshedAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("最终 reopen other visible conversation 后应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("最终 reopen other visible conversation 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("最终 reopen 后标题应切到 other visible conversation", "", "Team", shell.currentDetailTitle())
        assertEqual("最终 reopen 后 peer 标签应切到 other visible conversation", "", "peer:7508", shell.currentDetailPeerLabel())
        assertEqual("最终 reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("最终 reopen other visible conversation 后原 refreshed target 摘要仍应保留在列表面", "", "alice-refresh-2", refreshedAfterAlternatingReopen.previewText)
        assertEqual("最终 reopen other visible conversation 后原 refreshed target 消息数仍应保持为 2", "", 2, refreshedAfterAlternatingReopen.messageCount)
        assertEqual("other visible summary 在最终 reopen 后不应被污染", "", "team-2", otherAfterAlternatingReopen.previewText)
        assertEqual("active detail refresh-retarget alternating-reopen 链路不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendOnActiveDetailShouldKeepSummaryAndDetailCoherentWithoutHistoryRefetch(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7521)
        let teamPeer = PeerId(0, 7522)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(targetConversation)

        let nonTargetBeforeSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.sendMessageToActiveConversation("team-warm-send-3")

        let targetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let nonTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("same-peer warm send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("same-peer warm send 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("same-peer warm send 不应打穿 detail 标题绑定", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer warm send 不应打穿 detail peer 标签绑定", "", "peer:7522", shell.currentDetailPeerLabel())
        assertEqual("same-peer warm send 不应改变 detail 占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("target summary previewText 应更新为 sent text", "", "team-warm-send-3", targetAfterSend.previewText)
        assertEqual("target summary messageCount 应从 2 增长到 3", "", 3, targetAfterSend.messageCount)
        assertEqual("非目标 summary 在 send 前不应被污染", "", "alice-2", nonTargetBeforeSend.previewText)
        assertEqual("非目标 summary 在 send 前的消息数应保持为 2", "", 2, nonTargetBeforeSend.messageCount)
        assertEqual("非目标 summary 在 send 后不应被污染", "", "alice-2", nonTargetAfterSend.previewText)
        assertEqual("非目标 summary 在 send 后的消息数应保持为 2", "", 2, nonTargetAfterSend.messageCount)
        assertEqual("warm send 不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("warm send 应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellWarmSendBackThenReopenSameSentTargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7529)
        let teamPeer = PeerId(0, 7530)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        let otherBeforeSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.sendMessageToActiveConversation("team-warm-send-3")

        let sentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("same-peer warm send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("same-peer warm send 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("same-peer warm send 不应打穿 detail 标题绑定", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer warm send 不应打穿 detail peer 标签绑定", "", "peer:7530", shell.currentDetailPeerLabel())
        assertEqual("same-peer warm send 不应改变 detail 占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", sentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应变为 3", "", 3, sentTargetAfterSend.messageCount)
        assertEqual("其他 visible summary 在 send 前不应被污染", "", "alice-2", otherBeforeSend.previewText)
        assertEqual("其他 visible summary 在 send 前消息数应保持为 2", "", 2, otherBeforeSend.messageCount)
        assertEqual("其他 visible summary 在 send 后不应被污染", "", "alice-2", otherAfterSend.previewText)
        assertEqual("其他 visible summary 在 send 后消息数应保持为 2", "", 2, otherAfterSend.messageCount)

        shell.backFromDetail()
        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后直接 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后直接 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后直接 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后直接 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后直接 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.openConversation(sentTargetAfterBack)
        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen 同一个 sent target 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 同一个 sent target 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 后标题应重新绑定到同一个 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("reopen 后 peer 标签应重新绑定到同一个 sent target", "", "peer:7530", shell.currentDetailPeerLabel())
        assertEqual("reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("其他 visible summary 在 reopen 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("其他 visible summary 在 reopen 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)
        assertEqual("warm-send -> back -> reopen same target 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("warm-send -> back -> reopen same target 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellWarmSendBackThenReopenSameSentTargetThenDirectRetargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7541)
        let teamPeer = PeerId(0, 7542)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        let otherBeforeSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        shell.sendMessageToActiveConversation("team-warm-send-3")

        let sentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("same-peer warm send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("same-peer warm send 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("same-peer warm send 不应打穿 detail 标题绑定", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer warm send 不应打穿 detail peer 标签绑定", "", "peer:7542", shell.currentDetailPeerLabel())
        assertEqual("same-peer warm send 不应改变 detail 占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", sentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应变为 3", "", 3, sentTargetAfterSend.messageCount)
        assertEqual("其他 visible summary 在 send 前不应被污染", "", "alice-2", otherBeforeSend.previewText)
        assertEqual("其他 visible summary 在 send 前消息数应保持为 2", "", 2, otherBeforeSend.messageCount)
        assertEqual("其他 visible summary 在 send 后不应被污染", "", "alice-2", otherAfterSend.previewText)
        assertEqual("其他 visible summary 在 send 后消息数应保持为 2", "", 2, otherAfterSend.messageCount)

        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.openConversation(sentTargetAfterBack)

        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen 同一个 sent target 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 同一个 sent target 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 后标题应重新绑定到同一个 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("reopen 后 peer 标签应重新绑定到同一个 sent target", "", "peer:7542", shell.currentDetailPeerLabel())
        assertEqual("reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("其他 visible summary 在 reopen 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("其他 visible summary 在 reopen 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)

        shell.openConversation(otherAfterReopen)

        let sentTargetAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen same sent target 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen same sent target 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到另一条 visible conversation", "", "peer:7541", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterRetarget.previewText)
        assertEqual("原 sent target summary 在 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterRetarget.messageCount)
        assertEqual("另一条 visible conversation 在 retarget 后摘要不应被污染", "", "alice-2", otherAfterRetarget.previewText)
        assertEqual("另一条 visible conversation 在 retarget 后消息数应保持为 2", "", 2, otherAfterRetarget.messageCount)
        assertEqual("warm-send -> back -> reopen same target -> direct retarget 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> reopen same target -> direct retarget 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackThenReopenOtherVisibleConversationShouldPreserveBoundedStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7543)
        let teamPeer = PeerId(0, 7544)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")

        let sentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterSend = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("same-peer warm send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("same-peer warm send 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("same-peer warm send 不应打穿 detail 标题绑定", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer warm send 不应打穿 detail peer 标签绑定", "", "peer:7544", shell.currentDetailPeerLabel())
        assertEqual("same-peer warm send 不应改变 detail 占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", sentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应变为 3", "", 3, sentTargetAfterSend.messageCount)
        assertEqual("另一条 visible conversation 在 send 后不应被污染", "", "alice-2", otherAfterSend.previewText)
        assertEqual("另一条 visible conversation 在 send 后消息数应保持为 2", "", 2, otherAfterSend.messageCount)

        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherBeforeReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("另一条 visible conversation 在 reopen 前摘要不应被污染", "", "alice-2", otherBeforeReopen.previewText)
        assertEqual("另一条 visible conversation 在 reopen 前消息数应保持为 2", "", 2, otherBeforeReopen.messageCount)

        shell.openConversation(otherBeforeReopen)

        let sentTargetAfterOtherReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOtherReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen 另一条 visible conversation 后应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 另一条 visible conversation 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 另一条 visible conversation 后标题应绑定到该会话", "", "Alice", shell.currentDetailTitle())
        assertEqual("reopen 另一条 visible conversation 后 peer 标签应绑定到该会话", "", "peer:7543", shell.currentDetailPeerLabel())
        assertEqual("reopen 另一条 visible conversation 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在最终 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOtherReopen.previewText)
        assertEqual("原 sent target summary 在最终 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterOtherReopen.messageCount)
        assertEqual("另一条 visible conversation 在 reopen 后摘要不应被污染", "", "alice-2", otherAfterOtherReopen.previewText)
        assertEqual("另一条 visible conversation 在 reopen 后消息数应保持为 2", "", 2, otherAfterOtherReopen.messageCount)
        assertEqual("warm-send -> back -> reopen other visible conversation 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> reopen other visible conversation 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackThenReopenOtherVisibleConversationThenDirectRetargetOriginalSentTargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7545)
        let teamPeer = PeerId(0, 7546)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")

        let sentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("same-peer warm send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("same-peer warm send 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("same-peer warm send 不应打穿 detail 标题绑定", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer warm send 不应打穿 detail peer 标签绑定", "", "peer:7546", shell.currentDetailPeerLabel())
        assertEqual("same-peer warm send 不应改变 detail 占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", sentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应变为 3", "", 3, sentTargetAfterSend.messageCount)

        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherBeforeOtherReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("另一条 visible conversation 在 reopen 前摘要不应被污染", "", "alice-2", otherBeforeOtherReopen.previewText)
        assertEqual("另一条 visible conversation 在 reopen 前消息数应保持为 2", "", 2, otherBeforeOtherReopen.messageCount)

        shell.openConversation(otherBeforeOtherReopen)

        let sentTargetAfterOtherReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOtherReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen 另一条 visible conversation 后应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 另一条 visible conversation 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 另一条 visible conversation 后标题应绑定到该会话", "", "Alice", shell.currentDetailTitle())
        assertEqual("reopen 另一条 visible conversation 后 peer 标签应绑定到该会话", "", "peer:7545", shell.currentDetailPeerLabel())
        assertEqual("reopen 另一条 visible conversation 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen other 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOtherReopen.previewText)
        assertEqual("原 sent target summary 在 reopen other 后 messageCount 应保持为 3", "", 3, sentTargetAfterOtherReopen.messageCount)
        assertEqual("另一条 visible conversation 在 reopen other 后摘要不应被污染", "", "alice-2", otherAfterOtherReopen.previewText)
        assertEqual("另一条 visible conversation 在 reopen other 后消息数应保持为 2", "", 2, otherAfterOtherReopen.messageCount)

        shell.openConversation(sentTargetAfterOtherReopen)

        let sentTargetAfterRetargetBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterRetargetBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen other 后直接 retarget 回原 sent target 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen other 后直接 retarget 回原 sent target 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 回原 sent target 后标题应重新绑定到原会话", "", "Team", shell.currentDetailTitle())
        assertEqual("retarget 回原 sent target 后 peer 标签应重新绑定到原会话", "", "peer:7546", shell.currentDetailPeerLabel())
        assertEqual("retarget 回原 sent target 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 retarget 回原会话后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterRetargetBack.previewText)
        assertEqual("原 sent target summary 在 retarget 回原会话后 messageCount 应保持为 3", "", 3, sentTargetAfterRetargetBack.messageCount)
        assertEqual("另一条 visible conversation 在 retarget 回原会话后摘要不应被污染", "", "alice-2", otherAfterRetargetBack.previewText)
        assertEqual("另一条 visible conversation 在 retarget 回原会话后消息数应保持为 2", "", 2, otherAfterRetargetBack.messageCount)
        assertEqual("warm-send -> back -> reopen other -> direct retarget original 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> reopen other -> direct retarget original 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendThenDirectRetargetOtherVisibleConversationThenDirectRetargetOriginalSentTargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7547)
        let teamPeer = PeerId(0, 7548)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let originalSentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(originalSentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")

        let originalSentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherBeforeFirstRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("same-peer warm send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("same-peer warm send 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("same-peer warm send 不应打穿 detail 标题绑定", "", "Team", shell.currentDetailTitle())
        assertEqual("same-peer warm send 不应打穿 detail peer 标签绑定", "", "peer:7548", shell.currentDetailPeerLabel())
        assertEqual("same-peer warm send 不应改变 detail 占位正文合同", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", originalSentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应变为 3", "", 3, originalSentTargetAfterSend.messageCount)
        assertEqual("另一条 visible conversation 在第一次 retarget 前摘要不应被污染", "", "alice-2", otherBeforeFirstRetarget.previewText)
        assertEqual("另一条 visible conversation 在第一次 retarget 前消息数应保持为 2", "", 2, otherBeforeFirstRetarget.messageCount)

        shell.openConversation(otherBeforeFirstRetarget)

        let originalSentTargetAfterFirstRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterFirstRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后第一次直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("warm-send 后第一次直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("第一次直接 retarget 后标题应切到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("第一次直接 retarget 后 peer 标签应切到另一条 visible conversation", "", "peer:7547", shell.currentDetailPeerLabel())
        assertEqual("第一次直接 retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在第一次直接 retarget 后仍应保留 sent text", "", "team-warm-send-3", originalSentTargetAfterFirstRetarget.previewText)
        assertEqual("原 sent target summary 在第一次直接 retarget 后 messageCount 应保持为 3", "", 3, originalSentTargetAfterFirstRetarget.messageCount)
        assertEqual("另一条 visible conversation 在第一次直接 retarget 后摘要不应被污染", "", "alice-2", otherAfterFirstRetarget.previewText)
        assertEqual("另一条 visible conversation 在第一次直接 retarget 后消息数应保持为 2", "", 2, otherAfterFirstRetarget.messageCount)

        shell.openConversation(originalSentTargetAfterFirstRetarget)

        let originalSentTargetAfterSecondRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterSecondRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第一次 retarget 到 other 后再直接 retarget 回原 sent target 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("第一次 retarget 到 other 后再直接 retarget 回原 sent target 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("第二次直接 retarget 后标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("第二次直接 retarget 后 peer 标签应重新绑定到原 sent target", "", "peer:7548", shell.currentDetailPeerLabel())
        assertEqual("第二次直接 retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在第二次直接 retarget 后仍应保留 sent text", "", "team-warm-send-3", originalSentTargetAfterSecondRetarget.previewText)
        assertEqual("原 sent target summary 在第二次直接 retarget 后 messageCount 应保持为 3", "", 3, originalSentTargetAfterSecondRetarget.messageCount)
        assertEqual("另一条 visible conversation 在第二次直接 retarget 后摘要不应被污染", "", "alice-2", otherAfterSecondRetarget.previewText)
        assertEqual("另一条 visible conversation 在第二次直接 retarget 后消息数应保持为 2", "", 2, otherAfterSecondRetarget.messageCount)
        assertEqual("warm-send -> direct retarget other -> direct retarget original 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> direct retarget other -> direct retarget original 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackThenListRouteSendShouldNoopWithoutLeakingOldActivePeer(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7531)
        let teamPeer = PeerId(0, 7532)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.sendMessageToActiveConversation("should-not-send")

        let sentTargetAfterNoop = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterNoop = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("list route 上的 sendMessageToActiveConversation 应继续停在会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("原 sent target summary 不应被 list-route send 污染", "", "team-warm-send-3", sentTargetAfterNoop.previewText)
        assertEqual("原 sent target summary 的 messageCount 不应被 list-route send 污染", "", 3, sentTargetAfterNoop.messageCount)
        assertEqual("其他 visible summary 在 list-route send 后不应被污染", "", "alice-2", otherAfterNoop.previewText)
        assertEqual("其他 visible summary 在 list-route send 后消息数应保持为 2", "", 2, otherAfterNoop.messageCount)
        assertEqual("warm-send -> back -> list-route send-noop 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> list-route send-noop 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackListRouteSendNoopThenReopenSameSentTargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7533)
        let teamPeer = PeerId(0, 7534)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.sendMessageToActiveConversation("should-not-send")

        let sentTargetAfterNoop = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterNoop = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("list route 上的 sendMessageToActiveConversation 应继续停在会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("原 sent target summary 不应被 list-route send 污染", "", "team-warm-send-3", sentTargetAfterNoop.previewText)
        assertEqual("原 sent target summary 的 messageCount 不应被 list-route send 污染", "", 3, sentTargetAfterNoop.messageCount)
        assertEqual("其他 visible summary 在 list-route send 后不应被污染", "", "alice-2", otherAfterNoop.previewText)
        assertEqual("其他 visible summary 在 list-route send 后消息数应保持为 2", "", 2, otherAfterNoop.messageCount)

        shell.openConversation(sentTargetAfterNoop)

        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("no-op 后 reopen 同一个 sent target 应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("no-op 后 reopen 同一个 sent target 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("no-op 后 reopen 标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("no-op 后 reopen peer 标签应重新绑定到原 sent target", "", "peer:7534", shell.currentDetailPeerLabel())
        assertEqual("no-op 后 reopen 占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("其他 visible summary 在 reopen 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("其他 visible summary 在 reopen 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)
        assertEqual("warm-send -> back -> list-route send-noop -> reopen same target 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> list-route send-noop -> reopen same target 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackListRouteSendNoopThenReopenOtherVisibleConversationShouldPreserveBoundedStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7535)
        let teamPeer = PeerId(0, 7536)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.sendMessageToActiveConversation("should-not-send")

        let sentTargetAfterNoop = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterNoop = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("list route 上的 sendMessageToActiveConversation 应继续停在会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("原 sent target summary 不应被 list-route send 污染", "", "team-warm-send-3", sentTargetAfterNoop.previewText)
        assertEqual("原 sent target summary 的 messageCount 不应被 list-route send 污染", "", 3, sentTargetAfterNoop.messageCount)
        assertEqual("其他 visible summary 在 list-route send 后不应被污染", "", "alice-2", otherAfterNoop.previewText)
        assertEqual("其他 visible summary 在 list-route send 后消息数应保持为 2", "", 2, otherAfterNoop.messageCount)

        shell.openConversation(otherAfterNoop)

        let sentTargetAfterOtherReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOtherReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("no-op 后 reopen 另一条 visible conversation 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("no-op 后 reopen 另一条 visible conversation 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("no-op 后 reopen 标题应绑定到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("no-op 后 reopen peer 标签应绑定到另一条 visible conversation", "", "peer:7535", shell.currentDetailPeerLabel())
        assertEqual("no-op 后 reopen 占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在最终 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOtherReopen.previewText)
        assertEqual("原 sent target summary 在最终 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterOtherReopen.messageCount)
        assertEqual("另一条 visible conversation 在最终 reopen 后摘要不应被污染", "", "alice-2", otherAfterOtherReopen.previewText)
        assertEqual("另一条 visible conversation 在最终 reopen 后消息数应保持为 2", "", 2, otherAfterOtherReopen.messageCount)
        assertEqual("warm-send -> back -> list-route send-noop -> reopen other 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> list-route send-noop -> reopen other 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackListRouteSendNoopReopenSameSentTargetThenDirectRetargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7537)
        let teamPeer = PeerId(0, 7538)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.sendMessageToActiveConversation("should-not-send")

        let sentTargetAfterNoop = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterNoop = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("list route 上的 sendMessageToActiveConversation 应继续停在会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("原 sent target summary 不应被 list-route send 污染", "", "team-warm-send-3", sentTargetAfterNoop.previewText)
        assertEqual("原 sent target summary 的 messageCount 不应被 list-route send 污染", "", 3, sentTargetAfterNoop.messageCount)
        assertEqual("其他 visible summary 在 list-route send 后不应被污染", "", "alice-2", otherAfterNoop.previewText)
        assertEqual("其他 visible summary 在 list-route send 后消息数应保持为 2", "", 2, otherAfterNoop.messageCount)

        shell.openConversation(sentTargetAfterNoop)

        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("no-op 后 reopen 同一个 sent target 应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("no-op 后 reopen 同一个 sent target 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("no-op 后 reopen 标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("no-op 后 reopen peer 标签应重新绑定到原 sent target", "", "peer:7538", shell.currentDetailPeerLabel())
        assertEqual("no-op 后 reopen 占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("其他 visible summary 在 reopen 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("其他 visible summary 在 reopen 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)

        shell.openConversation(otherAfterReopen)

        let sentTargetAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen same sent target 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen same sent target 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到另一条 visible conversation", "", "peer:7537", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterRetarget.previewText)
        assertEqual("原 sent target summary 在 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterRetarget.messageCount)
        assertEqual("另一条 visible conversation 在 retarget 后摘要不应被污染", "", "alice-2", otherAfterRetarget.previewText)
        assertEqual("另一条 visible conversation 在 retarget 后消息数应保持为 2", "", 2, otherAfterRetarget.messageCount)
        assertEqual("warm-send -> back -> list-route send-noop -> reopen same -> direct retarget 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> list-route send-noop -> reopen same -> direct retarget 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendBackListRouteSendNoopReopenSameSentTargetBackThenReopenOtherVisibleConversationShouldPreserveAlternatingBoundedStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7539)
        let teamPeer = PeerId(0, 7540)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        shell.backFromDetail()

        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("warm-send 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("warm-send 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("warm-send 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("其他 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("其他 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.sendMessageToActiveConversation("should-not-send")

        let sentTargetAfterNoop = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterNoop = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("list route 上的 sendMessageToActiveConversation 应继续停在会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应重新激活 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("list route 上的 sendMessageToActiveConversation 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("原 sent target summary 不应被 list-route send 污染", "", "team-warm-send-3", sentTargetAfterNoop.previewText)
        assertEqual("原 sent target summary 的 messageCount 不应被 list-route send 污染", "", 3, sentTargetAfterNoop.messageCount)
        assertEqual("其他 visible summary 在 list-route send 后不应被污染", "", "alice-2", otherAfterNoop.previewText)
        assertEqual("其他 visible summary 在 list-route send 后消息数应保持为 2", "", 2, otherAfterNoop.messageCount)

        shell.openConversation(sentTargetAfterNoop)

        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("no-op 后 reopen 同一个 sent target 应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("no-op 后 reopen 同一个 sent target 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("no-op 后 reopen 标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("no-op 后 reopen peer 标签应重新绑定到原 sent target", "", "peer:7540", shell.currentDetailPeerLabel())
        assertEqual("no-op 后 reopen 占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("其他 visible summary 在 reopen 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("其他 visible summary 在 reopen 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)

        shell.backFromDetail()

        let sentTargetAfterSecondBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterSecondBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen same sent target 后第二次 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("reopen same sent target 后第二次 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("reopen same sent target 后第二次 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("reopen same sent target 后第二次 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("reopen same sent target 后第二次 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在第二次 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterSecondBack.previewText)
        assertEqual("原 sent target summary 在第二次 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterSecondBack.messageCount)
        assertEqual("另一条 visible summary 在第二次 back 后不应被污染", "", "alice-2", otherAfterSecondBack.previewText)
        assertEqual("另一条 visible summary 在第二次 back 后消息数应保持为 2", "", 2, otherAfterSecondBack.messageCount)

        shell.openConversation(otherAfterSecondBack)

        let sentTargetAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第二次 back 后最终 reopen 另一条 visible conversation 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("第二次 back 后最终 reopen 另一条 visible conversation 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("第二次 back 后最终 reopen 标题应绑定到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("第二次 back 后最终 reopen peer 标签应绑定到另一条 visible conversation", "", "peer:7539", shell.currentDetailPeerLabel())
        assertEqual("第二次 back 后最终 reopen 占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在最终 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterAlternatingReopen.previewText)
        assertEqual("原 sent target summary 在最终 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterAlternatingReopen.messageCount)
        assertEqual("另一条 visible conversation 在最终 reopen 后摘要不应被污染", "", "alice-2", otherAfterAlternatingReopen.previewText)
        assertEqual("另一条 visible conversation 在最终 reopen 后消息数应保持为 2", "", 2, otherAfterAlternatingReopen.messageCount)
        assertEqual("warm-send -> back -> list-route send-noop -> reopen same -> back -> reopen other 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> back -> list-route send-noop -> reopen same -> back -> reopen other 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendThenDirectRetargetShouldPreserveBoundedDetailAndListCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7523)
        let teamPeer = PeerId(0, 7524)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let targetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(targetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        let otherBeforeRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        let otherVisibleConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(otherVisibleConversation)

        let targetAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("warm-send 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到新目标会话", "", "Alice", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到新目标会话", "", "peer:7523", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 target summary 在 retarget 后仍应保留 sent text", "", "team-warm-send-3", targetAfterRetarget.previewText)
        assertEqual("原 target summary 在 retarget 后 messageCount 应保持为 3", "", 3, targetAfterRetarget.messageCount)
        assertEqual("新 retarget 目标在 retarget 前摘要不应被污染", "", "alice-2", otherBeforeRetarget.previewText)
        assertEqual("新 retarget 目标在 retarget 前消息数应保持为 2", "", 2, otherBeforeRetarget.messageCount)
        assertEqual("新 retarget 目标在 retarget 后摘要不应被污染", "", "alice-2", otherAfterRetarget.previewText)
        assertEqual("新 retarget 目标在 retarget 后消息数应保持为 2", "", 2, otherAfterRetarget.messageCount)
        assertEqual("warm-send -> retarget 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("warm-send -> retarget 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellWarmSendRetargetBackThenReopenOriginalSentTargetShouldPreserveBoundedRoundTripCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7525)
        let teamPeer = PeerId(0, 7526)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        let otherBeforeRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        let otherVisibleConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(otherVisibleConversation)

        let sentTargetAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("warm-send 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到新目标会话", "", "Alice", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到新目标会话", "", "peer:7525", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterRetarget.previewText)
        assertEqual("原 sent target summary 在 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterRetarget.messageCount)
        assertEqual("另一条 visible summary 在 retarget 前不应被污染", "", "alice-2", otherBeforeRetarget.previewText)
        assertEqual("另一条 visible summary 在 retarget 前消息数应保持为 2", "", 2, otherBeforeRetarget.messageCount)
        assertEqual("另一条 visible summary 在 retarget 后不应被污染", "", "alice-2", otherAfterRetarget.previewText)
        assertEqual("另一条 visible summary 在 retarget 后消息数应保持为 2", "", 2, otherAfterRetarget.messageCount)

        shell.backFromDetail()
        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("retarget 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("retarget 后 back 不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("retarget 后 back 不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("retarget 后 back 不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("retarget 后 back 仍应保持 bounded history 为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("另一条 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("另一条 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.openConversation(sentTargetAfterBack)
        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen 原 sent target 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 原 sent target 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 后标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("reopen 后 peer 标签应重新绑定到原 sent target", "", "peer:7526", shell.currentDetailPeerLabel())
        assertEqual("reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("另一条 visible summary 在 reopen 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("另一条 visible summary 在 reopen 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)
        assertEqual("warm-send -> retarget -> back -> reopen 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("warm-send -> retarget -> back -> reopen 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellWarmSendThenDirectRetargetOtherVisibleConversationThenDirectRetargetOriginalSentTargetBackThenReopenOtherVisibleConversationShouldPreserveBoundedStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7529)
        let teamPeer = PeerId(0, 7530)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        let sentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherBeforeRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("warm-send 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("warm-send 后标题应继续绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("warm-send 后 peer 标签应继续绑定到原 sent target", "", "peer:7530", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", sentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应保持为 3", "", 3, sentTargetAfterSend.messageCount)
        assertEqual("另一条 visible summary 在第一次 retarget 前不应被污染", "", "alice-2", otherBeforeRetarget.previewText)
        assertEqual("另一条 visible summary 在第一次 retarget 前消息数应保持为 2", "", 2, otherBeforeRetarget.messageCount)

        let otherVisibleConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(otherVisibleConversation)

        let sentTargetAfterOtherRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOtherRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第一次 direct retarget 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("第一次 direct retarget 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("第一次 direct retarget 后标题应切到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("第一次 direct retarget 后 peer 标签应切到另一条 visible conversation", "", "peer:7529", shell.currentDetailPeerLabel())
        assertEqual("第一次 direct retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在第一次 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOtherRetarget.previewText)
        assertEqual("原 sent target summary 在第一次 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterOtherRetarget.messageCount)
        assertEqual("另一条 visible summary 在第一次 retarget 后不应被污染", "", "alice-2", otherAfterOtherRetarget.previewText)
        assertEqual("另一条 visible summary 在第一次 retarget 后消息数应保持为 2", "", 2, otherAfterOtherRetarget.messageCount)

        shell.openConversation(sentTargetAfterOtherRetarget)

        let sentTargetAfterOriginalRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOriginalRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第二次 direct retarget 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("第二次 direct retarget 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("第二次 direct retarget 后标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("第二次 direct retarget 后 peer 标签应重新绑定到原 sent target", "", "peer:7530", shell.currentDetailPeerLabel())
        assertEqual("第二次 direct retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在第二次 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOriginalRetarget.previewText)
        assertEqual("原 sent target summary 在第二次 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterOriginalRetarget.messageCount)
        assertEqual("另一条 visible summary 在第二次 retarget 后不应被污染", "", "alice-2", otherAfterOriginalRetarget.previewText)
        assertEqual("另一条 visible summary 在第二次 retarget 后消息数应保持为 2", "", 2, otherAfterOriginalRetarget.messageCount)

        shell.backFromDetail()
        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherBeforeFinalReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第二次 direct retarget 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("back 后不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("back 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("另一条 visible summary 在最终 reopen 前不应被污染", "", "alice-2", otherBeforeFinalReopen.previewText)
        assertEqual("另一条 visible summary 在最终 reopen 前消息数应保持为 2", "", 2, otherBeforeFinalReopen.messageCount)

        shell.openConversation(otherBeforeFinalReopen)
        let sentTargetAfterFinalReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterFinalReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("最终 reopen 另一条 visible conversation 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("最终 reopen 另一条 visible conversation 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("最终 reopen 后标题应绑定到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("最终 reopen 后 peer 标签应绑定到另一条 visible conversation", "", "peer:7529", shell.currentDetailPeerLabel())
        assertEqual("最终 reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在最终 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterFinalReopen.previewText)
        assertEqual("原 sent target summary 在最终 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterFinalReopen.messageCount)
        assertEqual("另一条 visible summary 在最终 reopen 后不应被污染", "", "alice-2", otherAfterFinalReopen.previewText)
        assertEqual("另一条 visible summary 在最终 reopen 后消息数应保持为 2", "", 2, otherAfterFinalReopen.messageCount)
        assertEqual("warm-send -> direct retarget other -> direct retarget original -> back -> reopen other 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> direct retarget other -> direct retarget original -> back -> reopen other 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendThenDirectRetargetOtherVisibleConversationThenDirectRetargetOriginalSentTargetBackThenReopenOriginalSentTargetShouldPreserveBoundedCoherence(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7531)
        let teamPeer = PeerId(0, 7532)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        let sentTargetAfterSend = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherBeforeRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("warm-send 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("warm-send 后标题应继续绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("warm-send 后 peer 标签应继续绑定到原 sent target", "", "peer:7532", shell.currentDetailPeerLabel())
        assertEqual("warm-send 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 send 后应保留 sent text", "", "team-warm-send-3", sentTargetAfterSend.previewText)
        assertEqual("原 sent target summary 在 send 后 messageCount 应保持为 3", "", 3, sentTargetAfterSend.messageCount)
        assertEqual("另一条 visible summary 在第一次 retarget 前不应被污染", "", "alice-2", otherBeforeRetarget.previewText)
        assertEqual("另一条 visible summary 在第一次 retarget 前消息数应保持为 2", "", 2, otherBeforeRetarget.messageCount)

        let otherVisibleConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(otherVisibleConversation)

        let sentTargetAfterOtherRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOtherRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第一次 direct retarget 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("第一次 direct retarget 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("第一次 direct retarget 后标题应切到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("第一次 direct retarget 后 peer 标签应切到另一条 visible conversation", "", "peer:7531", shell.currentDetailPeerLabel())
        assertEqual("第一次 direct retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在第一次 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOtherRetarget.previewText)
        assertEqual("原 sent target summary 在第一次 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterOtherRetarget.messageCount)
        assertEqual("另一条 visible summary 在第一次 retarget 后不应被污染", "", "alice-2", otherAfterOtherRetarget.previewText)
        assertEqual("另一条 visible summary 在第一次 retarget 后消息数应保持为 2", "", 2, otherAfterOtherRetarget.messageCount)

        shell.openConversation(sentTargetAfterOtherRetarget)

        let sentTargetAfterOriginalRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOriginalRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第二次 direct retarget 后仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("第二次 direct retarget 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("第二次 direct retarget 后标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("第二次 direct retarget 后 peer 标签应重新绑定到原 sent target", "", "peer:7532", shell.currentDetailPeerLabel())
        assertEqual("第二次 direct retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在第二次 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOriginalRetarget.previewText)
        assertEqual("原 sent target summary 在第二次 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterOriginalRetarget.messageCount)
        assertEqual("另一条 visible summary 在第二次 retarget 后不应被污染", "", "alice-2", otherAfterOriginalRetarget.previewText)
        assertEqual("另一条 visible summary 在第二次 retarget 后消息数应保持为 2", "", 2, otherAfterOriginalRetarget.messageCount)

        shell.backFromDetail()
        let sentTargetAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第二次 direct retarget 后 back 应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("back 后不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("back 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterBack.previewText)
        assertEqual("原 sent target summary 在 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterBack.messageCount)
        assertEqual("另一条 visible summary 在 back 后不应被污染", "", "alice-2", otherAfterBack.previewText)
        assertEqual("另一条 visible summary 在 back 后消息数应保持为 2", "", 2, otherAfterBack.messageCount)

        shell.openConversation(sentTargetAfterBack)

        let sentTargetAfterReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("最终 reopen 原 sent target 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("最终 reopen 原 sent target 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("最终 reopen 后标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("最终 reopen 后 peer 标签应重新绑定到原 sent target", "", "peer:7532", shell.currentDetailPeerLabel())
        assertEqual("最终 reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在最终 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterReopen.previewText)
        assertEqual("原 sent target summary 在最终 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterReopen.messageCount)
        assertEqual("另一条 visible summary 在最终 reopen 原 sent target 后不应被污染", "", "alice-2", otherAfterReopen.previewText)
        assertEqual("另一条 visible summary 在最终 reopen 原 sent target 后消息数应保持为 2", "", 2, otherAfterReopen.messageCount)
        assertEqual("warm-send -> direct retarget other -> direct retarget original -> back -> reopen original 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
        assertEqual("warm-send -> direct retarget other -> direct retarget original -> back -> reopen original 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellWarmSendRetargetAlternatingReopenShouldKeepBoundedStableDetailOwnership(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7527)
        let teamPeer = PeerId(0, 7528)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let sentTargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(sentTargetConversation)

        shell.sendMessageToActiveConversation("team-warm-send-3")
        let otherBeforeRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        let otherVisibleConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(otherVisibleConversation)

        let sentTargetAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("warm-send 后直接 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("warm-send 后直接 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到另一条 visible conversation", "", "peer:7527", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 retarget 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterRetarget.previewText)
        assertEqual("原 sent target summary 在 retarget 后 messageCount 应保持为 3", "", 3, sentTargetAfterRetarget.messageCount)
        assertEqual("另一条 visible summary 在 retarget 前不应被污染", "", "alice-2", otherBeforeRetarget.previewText)
        assertEqual("另一条 visible summary 在 retarget 前消息数应保持为 2", "", 2, otherBeforeRetarget.messageCount)
        assertEqual("另一条 visible summary 在 retarget 后不应被污染", "", "alice-2", otherAfterRetarget.previewText)
        assertEqual("另一条 visible summary 在 retarget 后消息数应保持为 2", "", 2, otherAfterRetarget.messageCount)

        shell.backFromDetail()
        let sentTargetAfterFirstBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterFirstBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第一次 back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第一次 back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第一次 back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第一次 back 后不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("第一次 back 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在第一次 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterFirstBack.previewText)
        assertEqual("原 sent target summary 在第一次 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterFirstBack.messageCount)
        assertEqual("另一条 visible summary 在第一次 back 后不应被污染", "", "alice-2", otherAfterFirstBack.previewText)
        assertEqual("另一条 visible summary 在第一次 back 后消息数应保持为 2", "", 2, otherAfterFirstBack.messageCount)

        shell.openConversation(sentTargetAfterFirstBack)
        let sentTargetAfterOriginalReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterOriginalReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("reopen 原 sent target 后应重新回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("reopen 原 sent target 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("reopen 后标题应重新绑定到原 sent target", "", "Team", shell.currentDetailTitle())
        assertEqual("reopen 后 peer 标签应重新绑定到原 sent target", "", "peer:7528", shell.currentDetailPeerLabel())
        assertEqual("reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterOriginalReopen.previewText)
        assertEqual("原 sent target summary 在 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterOriginalReopen.messageCount)
        assertEqual("另一条 visible summary 在 reopen 原 sent target 后不应被污染", "", "alice-2", otherAfterOriginalReopen.previewText)
        assertEqual("另一条 visible summary 在 reopen 原 sent target 后消息数应保持为 2", "", 2, otherAfterOriginalReopen.messageCount)

        shell.backFromDetail()
        let sentTargetAfterSecondBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterSecondBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("第二次 back 后应再次回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第二次 back 后不应残留 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第二次 back 后不应残留 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第二次 back 后不应残留 detail 占位正文", "", "", shell.currentDetailBody())
        assertEqual("第二次 back 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("原 sent target summary 在第二次 back 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterSecondBack.previewText)
        assertEqual("原 sent target summary 在第二次 back 后 messageCount 应保持为 3", "", 3, sentTargetAfterSecondBack.messageCount)
        assertEqual("另一条 visible summary 在第二次 back 后不应被污染", "", "alice-2", otherAfterSecondBack.previewText)
        assertEqual("另一条 visible summary 在第二次 back 后消息数应保持为 2", "", 2, otherAfterSecondBack.messageCount)

        shell.openConversation(otherAfterSecondBack)
        let sentTargetAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        let otherAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)

        assertEqual("最终 reopen 另一条 visible conversation 后应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("最终 reopen 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("最终 reopen 后标题应绑定到另一条 visible conversation", "", "Alice", shell.currentDetailTitle())
        assertEqual("最终 reopen 后 peer 标签应绑定到另一条 visible conversation", "", "peer:7527", shell.currentDetailPeerLabel())
        assertEqual("最终 reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 sent target summary 在最终 reopen 后仍应保留 sent text", "", "team-warm-send-3", sentTargetAfterAlternatingReopen.previewText)
        assertEqual("原 sent target summary 在最终 reopen 后 messageCount 应保持为 3", "", 3, sentTargetAfterAlternatingReopen.messageCount)
        assertEqual("另一条 visible summary 在最终 reopen 前不应被污染", "", "alice-2", otherAfterSecondBack.previewText)
        assertEqual("另一条 visible summary 在最终 reopen 后不应被污染", "", "alice-2", otherAfterAlternatingReopen.previewText)
        assertEqual("另一条 visible summary 在最终 reopen 后消息数应保持为 2", "", 2, otherAfterAlternatingReopen.messageCount)
        assertEqual("warm-send -> retarget -> alternating-reopen 链路不应新增 service 历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("warm-send -> retarget -> alternating-reopen 链路应只触发一次 sendMessage", "", 1, adapter.sendMessageCallCount())
    }

    @TestCase
    public func appShellRefreshReopenThenRetargetShouldKeepDetailCoherenceAndListStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7495)
        let teamPeer = PeerId(0, 7496)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        let teamConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(teamConversation)
        shell.backFromDetail()
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(refreshedConversation)

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)

        let refreshedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let untouchedAfterRetarget = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("refresh 后 reopen 再 retarget 仍应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("refresh 后 reopen 再 retarget 不应让 history 膨胀到 3", "", 2, shell.historySize())
        assertEqual("retarget 后标题应切到新目标会话", "", "Team", shell.currentDetailTitle())
        assertEqual("retarget 后 peer 标签应切到新目标会话", "", "peer:7496", shell.currentDetailPeerLabel())
        assertEqual("retarget 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原目标的已刷新摘要在 retarget 后仍应保留在列表面", "", "alice-refresh-2", refreshedAfterRetarget.previewText)
        assertEqual("原目标的已刷新消息数在 retarget 后仍应保留在列表面", "", 2, refreshedAfterRetarget.messageCount)
        assertEqual("新目标摘要在 retarget 后不应被污染", "", "team-2", untouchedAfterRetarget.previewText)
        assertEqual("refresh + reopen + retarget 不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellRefreshReopenRetargetBackThenReopenShouldPreserveRoundTripStability(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7497)
        let teamPeer = PeerId(0, 7498)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(refreshedConversation)

        let retargetConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(retargetConversation)
        shell.backFromDetail()

        let refreshedAfterBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("retarget 后 back 应先回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())

        shell.openConversation(refreshedAfterBack)

        let refreshedAfterRoundTrip = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterRoundTrip = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("round-trip 后重新打开原 refreshed target 应回到详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("round-trip 后 history 不应膨胀到 3", "", 2, shell.historySize())
        assertEqual("round-trip 后标题应重新绑定到原 refreshed target", "", "Alice", shell.currentDetailTitle())
        assertEqual("round-trip 后 peer 标签应重新绑定到原 refreshed target", "", "peer:7497", shell.currentDetailPeerLabel())
        assertEqual("round-trip 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 的摘要在 back 后不应丢失", "", "alice-refresh-2", refreshedAfterBack.previewText)
        assertEqual("原 refreshed target 的摘要在 round-trip 后不应丢失", "", "alice-refresh-2", refreshedAfterRoundTrip.previewText)
        assertEqual("原 refreshed target 的消息数在 round-trip 后应保持为 2", "", 2, refreshedAfterRoundTrip.messageCount)
        assertEqual("retarget/back 后非目标摘要不应被污染", "", "team-2", otherAfterBack.previewText)
        assertEqual("重新打开原 refreshed target 后非目标摘要不应被污染", "", "team-2", otherAfterRoundTrip.previewText)
        assertEqual("round-trip 链路不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func appShellAlternatingReopenAfterRoundTripShouldKeepBoundedStableDetailOwnership(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7499)
        let teamPeer = PeerId(0, 7500)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let shell = buildTelegramAppShell(service, buildSessionSeeds(alicePeer, teamPeer))

        shell.loadInitialSessions(2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        shell.refreshConversation(alicePeer, 2)
        let refreshedConversation = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(refreshedConversation)

        let otherConversation = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(otherConversation)
        shell.backFromDetail()
        assertEqual("第一次 back 后应回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())

        let refreshedAfterFirstBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        shell.openConversation(refreshedAfterFirstBack)
        assertEqual("回环后重新打开原 refreshed target 应绑定 Alice", "", "Alice", shell.currentDetailTitle())
        assertEqual("回环后重新打开原 refreshed target 应绑定正确 peer", "", "peer:7499", shell.currentDetailPeerLabel())

        shell.backFromDetail()
        assertEqual("第二次 back 后应再次回到会话列表路由", "", "TelegramSessionListPage", shell.currentPageName())
        assertEqual("第二次 back 后不应残留旧 detail 标题", "", "", shell.currentDetailTitle())
        assertEqual("第二次 back 后不应残留旧 detail peer 标签", "", "", shell.currentDetailPeerLabel())
        assertEqual("第二次 back 后不应残留旧 detail 占位正文", "", "", shell.currentDetailBody())

        let refreshedAfterAlternatingBack = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterAlternatingBack = findSummaryByPeer(shell.visibleSessions(), teamPeer)
        shell.openConversation(otherAfterAlternatingBack)

        let refreshedAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), alicePeer)
        let otherAfterAlternatingReopen = findSummaryByPeer(shell.visibleSessions(), teamPeer)

        assertEqual("交替 reopen 后应停在详情页", "", "TelegramChatDetailPage", shell.currentPageName())
        assertEqual("交替 reopen 后 history 仍应保持为 2", "", 2, shell.historySize())
        assertEqual("交替 reopen 后标题应切到 other visible conversation", "", "Team", shell.currentDetailTitle())
        assertEqual("交替 reopen 后 peer 标签应切到 other visible conversation", "", "peer:7500", shell.currentDetailPeerLabel())
        assertEqual("交替 reopen 后占位正文合同不应漂移", "", "Chat detail placeholder", shell.currentDetailBody())
        assertEqual("原 refreshed target 摘要在交替 reopen 后不应丢失", "", "alice-refresh-2", refreshedAfterAlternatingReopen.previewText)
        assertEqual("原 refreshed target 消息数在交替 reopen 后应保持为 2", "", 2, refreshedAfterAlternatingReopen.messageCount)
        assertEqual("other visible conversation 摘要在交替 reopen 前不应被污染", "", "team-2", otherAfterAlternatingBack.previewText)
        assertEqual("other visible conversation 摘要在交替 reopen 后不应被污染", "", "team-2", otherAfterAlternatingReopen.previewText)
        assertEqual("原 refreshed target 摘要在第二次 back 后仍应保持稳定", "", "alice-refresh-2", refreshedAfterAlternatingBack.previewText)
        assertEqual("交替 reopen 链路不应新增额外 service 历史拉取", "", 3, adapter.getHistoryCallCount())
    }

    @TestCase
    public func sessionListShouldBuildSummariesFromRealMessageService(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7001)
        let teamPeer = PeerId(0, 7002)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let controller = TelegramSessionListController(service, buildSessionSeeds(alicePeer, teamPeer))
        let bridge = MainContextDatasetRefreshBridge(controller)
        controller.attachRefreshBridge(bridge)
        let router = SpyTelegramPageRouter()
        let page = TelegramSessionListPage(router, controller, bridge)

        page.loadInitialSessions(2)
        let sessions = page.visibleSessions()

        assertEqual("应暴露两个会话摘要", "", 2, sessions.size)
        assertEqual("第一个会话标题应来自 seed", "", "Alice", sessions[0].title)
        assertEqual("第一个会话尾消息应来自真实 service 历史", "", "alice-2", sessions[0].previewText)
        assertEqual("第二个会话标题应来自 seed", "", "Team", sessions[1].title)
        assertEqual("第二个会话尾消息应来自真实 service 历史", "", "team-2", sessions[1].previewText)
        assertEqual("初次加载必须触发两次历史拉取", "", 2, adapter.getHistoryCallCount())
        assertEqual("main drain 后不得残留 pending refresh", "", 0, page.pendingRefreshCount())
    }

    @TestCase
    public func tappingConversationShouldNavigateToDetailPlaceholder(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7101)
        let teamPeer = PeerId(0, 7102)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let controller = TelegramSessionListController(service, buildSessionSeeds(alicePeer, teamPeer))
        let bridge = MainContextDatasetRefreshBridge(controller)
        controller.attachRefreshBridge(bridge)
        let router = SpyTelegramPageRouter()
        let page = TelegramSessionListPage(router, controller, bridge)

        page.loadInitialSessions(2)
        let chosen = page.visibleSessions()[1]
        page.openConversation(chosen)

        assertEqual("列表点击后应路由到详情占位页", "", "TelegramChatDetailPage", router.lastPushedPage())
        assertEqual("路由历史应增加到 2", "", 2, router.historySize())

        let detailPage = TelegramChatDetailPage(router, controller)
        detailPage.aboutToAppear()
        let projectedMessages = detailPage.projectedMessages()
        assertEqual("详情页应读取选中会话标题", "", "Team", detailPage.currentTitle())
        assertEqual("详情页应保留会话 peer 标签", "", "peer:7102", detailPage.currentPeerLabel())
        assertEqual("详情页仍应保留占位正文合同", "", "Chat detail placeholder", detailPage.placeholderBody())
        assertEqual("详情页应投影两条真实线程消息", "", 2, projectedMessages.size)
        assertEqual("详情页应投影线程第一条真实消息", "", "team-1", projectedMessages[0].text)
        assertEqual("详情页应投影线程第二条真实消息", "", "team-2", projectedMessages[1].text)

        detailPage.tapBack()
        assertEqual("返回后应回到会话列表路由", "", "TelegramSessionListPage", router.current().pageName)
    }

    @TestCase
    public func refreshShouldReloadOnlyTheTargetConversationFromService(): Unit {
        setExecutionContext("main")
        let alicePeer = PeerId(0, 7201)
        let teamPeer = PeerId(0, 7202)
        let adapter = FakeMessageAdapter()
        adapter.seedHistory(alicePeer, buildRemoteHistory(alicePeer, "alice"))
        adapter.seedHistory(teamPeer, buildRemoteHistory(teamPeer, "team"))
        let service = RealMessageService(adapter)
        let controller = TelegramSessionListController(service, buildSessionSeeds(alicePeer, teamPeer))
        let bridge = MainContextDatasetRefreshBridge(controller)
        controller.attachRefreshBridge(bridge)
        let router = SpyTelegramPageRouter()
        let page = TelegramSessionListPage(router, controller, bridge)

        page.loadInitialSessions(2)
        adapter.seedHistory(alicePeer, buildUpdatedRemoteHistory(alicePeer))

        page.refreshConversation(alicePeer, 2)
        let refreshed = page.summaryFor(alicePeer)
        let unchanged = page.summaryFor(teamPeer)

        assertEqual("刷新目标会话后应看到新的尾消息", "", "alice-refresh-2", refreshed.previewText)
        assertEqual("刷新后会话消息数应保持为 2", "", 2, refreshed.messageCount)
        assertEqual("未刷新的会话摘要不应被污染", "", "team-2", unchanged.previewText)
        assertEqual("刷新必须新增一次 service 历史拉取", "", 3, adapter.getHistoryCallCount())
        assertEqual("刷新闭环后 pending refresh 应清空", "", 0, page.pendingRefreshCount())
    }
}

func buildSessionSeeds(alicePeer: PeerId, teamPeer: PeerId): Array<TelegramConversationSeed> {
    Array<TelegramConversationSeed>(2, { index: Int64 =>
        if (index == 0) {
            TelegramConversationSeed(alicePeer, "Alice")
        } else {
            TelegramConversationSeed(teamPeer, "Team")
        }
    })
}

func buildRemoteHistory(peerId: PeerId, prefix: String): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(Int32(1000 + index), "${prefix}-1", peerId)
        } else {
            DomainMessage(Int32(1000 + index), "${prefix}-2", peerId)
        }
    })
}

func buildUpdatedRemoteHistory(peerId: PeerId): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(Int32(2000 + index), "alice-refresh-1", peerId)
        } else {
            DomainMessage(Int32(2000 + index), "alice-refresh-2", peerId)
        }
    })
}

func findSummaryByPeer(source: Array<TelegramConversationSummary>, peerId: PeerId): TelegramConversationSummary {
    for (item in source) {
        if (item.peerId.namespace == peerId.namespace && item.peerId.id == peerId.id) {
            return item
        }
    }
    emptyConversationSummary()
}
