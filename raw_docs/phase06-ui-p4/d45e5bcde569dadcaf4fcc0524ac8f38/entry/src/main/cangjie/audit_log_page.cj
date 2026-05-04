package ohos_app_cangjie_entry

import std.collection.*

// ============================================================================
// AuditLogPage - 审计日志页
// 展示所有操作日志，体现安全合规能力
// ============================================================================

// 审计日志页状态
public class AuditLogPageState {
    // 日志列表
    public var logs: ArrayList<AuditLogEntry> = ArrayList<AuditLogEntry>()
    
    // 筛选条件
    public var filterMeetingId: String = ""
    public var filterEventType: String = "ALL"
    public var filterOnlyAlerts: Bool = false
    
    // 统计
    public var totalLogs: Int64 = 0
    public var viewCount: Int64 = 0
    public var exportCount: Int64 = 0
    public var alertCount: Int64 = 0
    
    public init() {
        refreshLogs()
    }
    
    // 刷新日志
    public func refreshLogs(): Unit {
        this.logs = getAllAuditLogs()
        this.totalLogs = this.logs.size
        
        // 统计各类型数量
        this.viewCount = 0
        this.exportCount = 0
        this.alertCount = 0
        
        for (log in this.logs) {
            match (log.eventType) {
                case MeetingViewed | OriginalViewed => this.viewCount = this.viewCount + 1
                case ExportOriginal | ExportMasked => this.exportCount = this.exportCount + 1
                case SecurityAlert => this.alertCount = this.alertCount + 1
                case _ => ()
            }
        }
    }
    
    // 获取筛选后的日志
    public func getFilteredLogs(): ArrayList<AuditLogEntry> {
        var result = ArrayList<AuditLogEntry>()
        
        for (log in this.logs) {
            var isMatch = true
            
            // 会议ID筛选
            if (this.filterMeetingId.size > 0 && log.meetingId != this.filterMeetingId) {
                isMatch = false
            }
            
            // 仅告警筛选
            if (this.filterOnlyAlerts) {
                let isAlert = isSecurityAlertEvent(log.eventType)
                if (!isAlert) {
                    isMatch = false
                }
            }
            
            if (isMatch) {
                result.append(log)
            }
        }
        
        return result
    }
    
    // 返回列表
    public func goBack(): Unit {
        getAppState().navigateToMeetingList()
    }
}

// 当前页面状态
var auditLogState: ?AuditLogPageState = None

public func getAuditLogState(): AuditLogPageState {
    match (auditLogState) {
        case Some(state) => 
            state.refreshLogs()
            state
        case None =>
            let state = AuditLogPageState()
            auditLogState = Some(state)
            state
    }
}

// ============================================================================
// 页面渲染函数
// ============================================================================

// 渲染审计日志页
public func renderAuditLogPage(): Unit {
    let state = getAuditLogState()
    
    renderPageTitle("审计日志 - 安全追踪")
    
    // 渲染统计卡片
    renderAuditStatisticsCard(state)
    
    // 渲染筛选栏
    renderAuditFilterBar(state)
    
    // 渲染日志列表
    renderAuditLogList(state)
    
    // 渲染操作菜单
    renderAuditLogMenu()
}

// 渲染统计卡片
func renderAuditStatisticsCard(state: AuditLogPageState): Unit {
    println("┌─────────────────────────────────────────────────────────────────────┐")
    println("│  📊 审计统计                                                         │")
    println("├─────────────────────────────────────────────────────────────────────┤")
    println("│  总日志数: ${padRight(state.totalLogs.toString(), 8)} 查看次数: ${padRight(state.viewCount.toString(), 8)} 导出次数: ${padRight(state.exportCount.toString(), 8)} │")
    
    let alertStr = if (state.alertCount > 0) {
        "🔴 ${state.alertCount}"
    } else {
        "✅ 0"
    }
    println("│  安全告警: ${padRight(alertStr, 56)} │")
    println("└─────────────────────────────────────────────────────────────────────┘")
    println("")
}

// 渲染筛选栏
func renderAuditFilterBar(state: AuditLogPageState): Unit {
    let meetingFilter = if (state.filterMeetingId.size > 0) { state.filterMeetingId } else { "全部" }
    let alertFilter = if (state.filterOnlyAlerts) { "是" } else { "否" }
    
    println("筛选: [会议: ${meetingFilter}] [仅告警: ${alertFilter}]")
    renderDivider()
}

// 渲染日志列表
func renderAuditLogList(state: AuditLogPageState): Unit {
    let logs = state.getFilteredLogs()
    
    if (logs.size == 0) {
        println("")
        println("  📭 暂无审计日志")
        println("")
        return
    }
    
    println("")
    println("最近操作记录：")
    println("")
    
    // 倒序显示，最新的在前面
    var i = logs.size - 1
    var count: Int64 = 0
    while (i >= 0 && count < 20) {
        let log = logs[i]
        renderAuditLogItem(log)
        i = i - 1
        count = count + 1
    }
    
    if (logs.size > 20) {
        println("  ... 还有 ${logs.size - 20} 条更早的记录")
    }
    println("")
}

// 渲染单条日志
func renderAuditLogItem(log: AuditLogEntry): Unit {
    // 事件类型图标
    let typeIcon = getEventTypeIcon(log.eventType)
    
    // 成功/失败标记
    let statusMark = if (log.success) { "✓" } else { "✗" }
    
    // 时间格式化（简化显示）
    let timeStr = formatTimestamp(log.timestamp)
    
    println("  ${typeIcon} [${timeStr}] ${log.action}")
    println("     用户: ${log.userName} | 会议: ${truncateText(log.meetingId, 20)} ${statusMark}")
    if (log.details.size > 0 && log.details != log.action) {
        println("     详情: ${truncateText(log.details, 50)}")
    }
    println("")
}

// 检查是否是安全告警事件
func isSecurityAlertEvent(eventType: AuditEventType): Bool {
    match (eventType) {
        case SecurityAlert => true
        case _ => false
    }
}

// 获取事件类型图标
func getEventTypeIcon(eventType: AuditEventType): String {
    match (eventType) {
        case MeetingCreated => "📝"
        case MeetingViewed => "[VIEW]"
        case MeetingEdited => "[EDIT]"
        case MeetingDeleted => "[DEL]"
        case NotesUpdated => "📋"
        case SummaryGenerated => "🤖"
        case AuditPerformed => "🔍"
        case ExportOriginal => "📤"
        case ExportMasked => "🔒"
        case OriginalAccessPublished => "🟢"
        case OriginalAccessRevoked => "⛔"
        case OriginalAccessRequested => "📝"
        case OriginalAccessSigned => "✅"
        case OriginalAccessOtpVerified => "🔐"
        case OriginalViewed => "📄"
        case Login => "🔑"
        case Logout => "🚪"
        case PermissionChanged => "[PERM]"
        case SecurityAlert => "🚨"
    }
}

// 格式化时间戳
func formatTimestamp(ts: Int64): String {
    // 简化处理：只显示最后几位
    let tsStr = ts.toString()
    if (tsStr.size > 6) {
        return "..." + substringFrom(tsStr, tsStr.size - 6)
    }
    return tsStr
}

// 渲染操作菜单
func renderAuditLogMenu(): Unit {
    renderDivider()
    println("")
    println("操作选项：")
    println("  [1] 🔍 按会议筛选")
    println("  [2] 🚨 只看告警")
    println("  [3] 🔄 刷新日志")
    println("  [4] 📊 生成合规报告")
    println("  [0] 返回会议列表")
    println("")
}

// ============================================================================
// 用户交互处理
// ============================================================================

// 处理审计日志页的用户输入
public func handleAuditLogInput(input: String): Bool {
    let state = getAuditLogState()
    
    if (input == "0") {
        state.goBack()
        return true
    }
    
    if (input == "1") {
        // 按会议筛选（重置）
        state.filterMeetingId = ""
        getAppState().showToastMessage("筛选已重置")
        return true
    }
    
    if (input == "2") {
        // 切换告警筛选
        state.filterOnlyAlerts = !state.filterOnlyAlerts
        let msg = if (state.filterOnlyAlerts) { "仅显示告警" } else { "显示全部" }
        getAppState().showToastMessage(msg)
        return true
    }
    
    if (input == "3") {
        state.refreshLogs()
        getAppState().showToastMessage("日志已刷新")
        return true
    }
    
    if (input == "4") {
        // 生成合规报告
        println("")
        println(generateComplianceReport())
        println("")
        return true
    }
    
    return true
}

