package ohos_app_cangjie_entry

import std.collection.*

// ============================================================================
// MeetingListPage - 会议列表页
// 入口页面：展示所有会议，支持新建、筛选、跳转详情
// ============================================================================

// 会议列表页状态
public class MeetingListPageState {
    // 会议列表
    public var meetings: ArrayList<Meeting> = ArrayList<Meeting>()
    
    // 筛选条件
    public var filterSensitivity: String = "ALL"  // ALL, PUBLIC, INTERNAL, CONFIDENTIAL
    public var filterStatus: String = "ALL"       // ALL, DRAFT, IN_PROGRESS, COMPLETED
    public var searchKeyword: String = ""
    
    // 排序方式
    public var sortBy: String = "created_desc"    // created_desc, risk_desc, title_asc
    
    // 分页
    public var currentPage: Int64 = 1
    public var pageSize: Int64 = 10
    
    // 统计信息
    public var totalMeetings: Int64 = 0
    public var highRiskCount: Int64 = 0
    
    public init() {
        refreshMeetings()
    }
    
    // 刷新会议列表
    public func refreshMeetings(): Unit {
        this.meetings = listAllMeetings()
        this.totalMeetings = this.meetings.size
        
        // 统计高风险会议
        this.highRiskCount = 0
        for (m in this.meetings) {
            if (m.riskScore >= 60) {
                this.highRiskCount = this.highRiskCount + 1
            }
        }
    }
    
    // 获取筛选后的会议列表
    public func getFilteredMeetings(): ArrayList<Meeting> {
        var result = ArrayList<Meeting>()
        
        for (m in this.meetings) {
            var isMatch = true
            
            // 敏感等级筛选
            if (this.filterSensitivity != "ALL") {
                let levelStr = sensitivityToString(m.sensitivity)
                if (levelStr != this.filterSensitivity) {
                    isMatch = false
                }
            }
            
            // 状态筛选
            if (this.filterStatus != "ALL") {
                let statusStr = statusToString(m.status)
                if (statusStr != this.filterStatus) {
                    isMatch = false
                }
            }
            
            // 关键词搜索
            if (this.searchKeyword.size > 0) {
                if (!m.title.contains(this.searchKeyword) && !m.description.contains(this.searchKeyword)) {
                    isMatch = false
                }
            }
            
            if (isMatch) {
                result.append(m)
            }
        }
        
        return result
    }
    
    // 创建新会议
    public func createNewMeetingAndNavigate(title: String, sensitivity: SensitivityLevel): String {
        let organizer = createParticipant(
            getAppState().currentUserId,
            getAppState().currentUserName,
            "主持人",
            "user@company.com"
        )
        
        let meeting = createMeetingRecord(
            title,
            "",
            sensitivity,
            organizer,
            currentTimestamp()
        )
        
        // 刷新列表
        refreshMeetings()
        
        // 导航到详情页
        getAppState().navigateToMeetingDetail(meeting.id)
        getAppState().showToastMessage("会议创建成功")
        
        return meeting.id
    }
}

// 全局页面状态实例
var meetingListState: ?MeetingListPageState = None

public func getMeetingListState(): MeetingListPageState {
    match (meetingListState) {
        case Some(state) => state
        case None =>
            let state = MeetingListPageState()
            meetingListState = Some(state)
            state
    }
}

// ============================================================================
// 页面渲染函数
// ============================================================================

// 渲染会议列表页
public func renderMeetingListPage(): Unit {
    let state = getMeetingListState()
    state.refreshMeetings()
    
    renderPageTitle("SecureMeet Guardian - 会议列表")
    
    // 渲染统计卡片
    renderStatisticsCard(state)
    
    // 渲染筛选栏
    renderFilterBar(state)
    
    // 渲染会议列表
    renderMeetingList(state)
    
    // 渲染操作菜单
    renderMeetingListMenu()
}

// 渲染统计卡片
func renderStatisticsCard(state: MeetingListPageState): Unit {
    println("┌─────────────────────────────────────────────────────────────────────┐")
    println("│  📊 会议统计                                                         │")
    println("├─────────────────────────────────────────────────────────────────────┤")
    println("│  总会议数: ${padRight(state.totalMeetings.toString(), 10)}  高风险会议: ${padRight(state.highRiskCount.toString(), 10)}              │")
    println("└─────────────────────────────────────────────────────────────────────┘")
    println("")
}

// 渲染筛选栏
func renderFilterBar(state: MeetingListPageState): Unit {
    println("筛选: [敏感等级: ${state.filterSensitivity}] [状态: ${state.filterStatus}] [搜索: ${if (state.searchKeyword.size > 0) { state.searchKeyword } else { "无" }}]")
    renderDivider()
}

// 渲染会议列表
func renderMeetingList(state: MeetingListPageState): Unit {
    let meetings = state.getFilteredMeetings()
    
    if (meetings.size == 0) {
        println("")
        println("  📭 暂无会议记录")
        println("  点击 [1] 创建第一个会议")
        println("")
        return
    }
    
    println("")
    var i: Int64 = 1
    for (m in meetings) {
        renderMeetingListItem(i, m)
        i = i + 1
    }
    println("")
}

// 渲染单个会议项
func renderMeetingListItem(index: Int64, meeting: Meeting): Unit {
    // 敏感等级标签
    let sensitivityTag = match (meeting.sensitivity) {
        case Confidential => "🔴 机密"
        case Internal => "🟡 内部"
        case Public => "🟢 公开"
    }
    
    // 风险评分标签
    let riskTag = if (meeting.riskScore > 0) {
        let riskColor = if (meeting.riskScore >= 60) { "[!]" } else { "[OK]" }
        " ${riskColor} 风险:${meeting.riskScore}"
    } else {
        " ⏳ 未审计"
    }
    
    // 状态标签
    let statusTag = match (meeting.status) {
        case Draft => "📝 草稿"
        case Scheduled => "📅 已排期"
        case InProgress => "🔄 进行中"
        case Completed => "✅ 已完成"
        case Archived => "📦 已归档"
    }
    
    println("  ${index}. 【${meeting.title}】")
    println("     ${sensitivityTag}  ${statusTag}${riskTag}")
    println("     ID: ${meeting.id}")
    println("")
}

// 渲染操作菜单
func renderMeetingListMenu(): Unit {
    renderDivider()
    println("")
    println("操作选项：")
    println("  [1] ➕ 新建会议")
    println("  [2] 🔍 搜索会议")
    println("  [3] 🔧 筛选设置")
    println("  [4] 📋 审计日志")
    println("  [5] 🔄 刷新列表")
    println("  [n] 输入数字进入对应会议详情 (如输入 1 进入第一个会议)")
    println("  [0] 退出应用")
    println("")
}

// ============================================================================
// 用户交互处理
// ============================================================================

// 处理会议列表页的用户输入
public func handleMeetingListInput(input: String): Bool {
    let state = getMeetingListState()
    
    if (input == "0") {
        println("感谢使用 SecureMeet Guardian，再见！")
        return false
    }
    
    if (input == "1") {
        // 创建新会议
        handleCreateNewMeeting()
        return true
    }
    
    if (input == "2") {
        // 搜索
        handleSearchMeeting()
        return true
    }
    
    if (input == "3") {
        // 筛选设置
        handleFilterSettings()
        return true
    }
    
    if (input == "4") {
        // 审计日志
        getAppState().navigateToAuditLog()
        return true
    }
    
    if (input == "5") {
        // 刷新
        state.refreshMeetings()
        getAppState().showToastMessage("列表已刷新")
        return true
    }
    
    // 尝试解析为数字，进入对应会议
    let index = parseInt(input)
    if (index > 0) {
        let meetings = state.getFilteredMeetings()
        if (index <= meetings.size) {
            let selectedMeeting = meetings[index - 1]
            getAppState().navigateToMeetingDetail(selectedMeeting.id)
            return true
        } else {
            getAppState().showToastMessage("无效的会议序号")
        }
    }
    
    return true
}

// 处理创建新会议
func handleCreateNewMeeting(): Unit {
    println("")
    println("═══════════════════════════════════════════════════════════════════")
    println("                      创建新会议")
    println("═══════════════════════════════════════════════════════════════════")
    println("")
    
    // 使用默认值创建演示会议
    let state = getMeetingListState()
    let meetingId = state.createNewMeetingAndNavigate(
        "新建会议 - ${currentTimestamp()}",
        SensitivityLevel.Internal
    )
    
    println("✓ 已创建新会议，正在跳转到详情页...")
}

// 处理搜索会议
func handleSearchMeeting(): Unit {
    println("")
    println("请输入搜索关键词（输入空行清除搜索）：")
    
    // 在实际 ArkUI 中这会是一个 TextInput 组件
    // 这里使用模拟数据
    let state = getMeetingListState()
    state.searchKeyword = ""
    println("✓ 搜索已清除")
}

// 处理筛选设置
func handleFilterSettings(): Unit {
    println("")
    println("筛选设置：")
    println("  [1] 显示全部")
    println("  [2] 只看机密会议")
    println("  [3] 只看高风险会议")
    
    // 默认重置为全部
    let state = getMeetingListState()
    state.filterSensitivity = "ALL"
    state.filterStatus = "ALL"
    println("✓ 筛选已重置")
}

