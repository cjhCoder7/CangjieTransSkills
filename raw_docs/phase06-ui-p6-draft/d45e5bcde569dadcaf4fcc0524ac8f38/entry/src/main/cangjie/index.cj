package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*

// ============================================================================
// SecureMeet Guardian - 安全会议助手
// ============================================================================

var isUserLoggedIn: Bool = false
var isUsersInitialized: Bool = false

// 辅助函数 - 计算统计数据
func getMeetingStats(): (Int64, Int64, Int64) {
    let meetings = listAllMeetings()
    var highRisk: Int64 = 0
    var completed: Int64 = 0
    for (m in meetings) {
        if (m.riskScore >= 60) { highRisk = highRisk + 1 }
        match (m.status) {
            case Completed | Archived => completed = completed + 1
            case _ => ()
        }
    }
    return (meetings.size, highRisk, completed)
}

func getLogStats(): (Int64, Int64, Int64) {
    let logs = getAllAuditLogs()
    var exportCount: Int64 = 0
    var alertCount: Int64 = 0
    for (log in logs) {
        match (log.eventType) {
            case ExportOriginal | ExportMasked => exportCount = exportCount + 1
            case SecurityAlert => alertCount = alertCount + 1
            case _ => ()
        }
    }
    return (logs.size, exportCount, alertCount)
}

@Entry
@Component
class SecureMeetApp {
    @State var isLoggedIn: Bool = false
    @State var currentUserName: String = ""
    @State var currentUserRole: String = ""
    @State var currentPage: Int64 = 0
    @State var selectedMeetingId: String = ""
    @State var toastMessage: String = ""
    @State var showToast: Bool = false
    @State var isLoading: Bool = false
    @State var loadingMessage: String = ""
    @State var pendingSummary: Bool = false
    @State var detailTitle: String = ""
    @State var detailDescription: String = ""
    @State var detailSensitivity: String = ""
    @State var detailStatus: String = ""
    @State var detailCreatedTime: String = ""
    @State var detailOrganizer: String = ""
    @State var detailNotes: String = ""
    @State var detailSummary: String = ""
    @State var detailRiskScore: Int64 = 0
    @State var detailSensitiveCount: Int64 = 0
    @State var detailMaskedContent: String = ""
    @State var isAudited: Bool = false
    @State var totalMeetings: Int64 = 0
    @State var highRiskCount: Int64 = 0
    @State var completedCount: Int64 = 0
    @State var totalLogs: Int64 = 0
    @State var exportLogCount: Int64 = 0
    @State var alertLogCount: Int64 = 0
    
    // 审计日志列表（最多显示20条）
    @State var logTimes: ArrayList<String> = ArrayList<String>()
    @State var logActions: ArrayList<String> = ArrayList<String>()
    @State var logDetails: ArrayList<String> = ArrayList<String>()
    @State var logMeetings: ArrayList<String> = ArrayList<String>()
    @State var logUsers: ArrayList<String> = ArrayList<String>()
    @State var logCount: Int64 = 0

    // 转写页状态
    @State var transStatus: String = "准备就绪"
    @State var transIsRecording: Bool = false
    @State var transIsPaused: Bool = false
    @State var transRiskScore: Int64 = 0
    @State var transSensitiveCount: Int64 = 0
    @State var transSegments: ArrayList<TranscriptSegment> = ArrayList<TranscriptSegment>()
    @State var transManualInput: String = ""
    @State var transShowManualInput: Bool = false
    
    // 动态会议列表（最多显示10个）
    @State var meetingIds: ArrayList<String> = ArrayList<String>()
    @State var meetingTitles: ArrayList<String> = ArrayList<String>()
    @State var meetingRisks: ArrayList<Int64> = ArrayList<Int64>()
    @State var meetingSensitivities: ArrayList<String> = ArrayList<String>()
    @State var meetingCount: Int64 = 0
    
    // 会议编辑表单状态
    @State var showMeetingForm: Bool = false
    @State var editingMeetingId: String = ""
    @State var formTitle: String = ""
    @State var formDescription: String = ""
    @State var formSensitivity: Int64 = 1
    @State var formNotes: String = ""
    // 搜索状态
    @State var searchKeyword: String = ""
    @State var isSearching: Bool = false
    
    // PIN 登录状态
    @State var showPinInput: Bool = false
    @State var selectedLoginUserId: String = ""
    @State var selectedLoginUserName: String = ""
    @State var pinInput: String = ""
    @State var loginErrorMsg: String = ""

    // 成员查看页状态（脱敏/原文）
    @State var memberViewIsOriginal: Bool = false
    @State var memberShowReceipt: Bool = false
    @State var memberAccepted: Bool = false
    @State var memberOtpInput: String = ""
    @State var memberViewRefresh: Int64 = 0
    
    func build() {
        Stack {
            if (!this.isLoggedIn) {
                // 显示登录页面
                this.buildLoginPage()
            } else {
                // 显示主应用
                this.buildMainApp()
            }
            
            // Toast 提示框（优化版）
            if (this.showToast) {
                Column {
                    Text(this.toastMessage)
                        .fontSize(14)
                        .fontColor(0xFFFFFF)
                        .backgroundColor(0xCC333333)
                        .padding(left: 24, right: 24, top: 12, bottom: 12)
                        .borderRadius(24)
                        .onClick { evt => this.showToast = false }
                    TextTimer(isCountDown: true, count: 2000)
                        .onTimer { _, elapsedTime =>
                            if (elapsedTime >= 2000) {
                                this.showToast = false
                            }
                        }
                        .opacity(0.0)
                        .width(0)
                        .height(0)
                }
                .width(100.percent)
                .alignItems(HorizontalAlign.Center)
                .padding(bottom: 120)
                .align(Alignment.Bottom)
            }

            // AI 纪要生成延迟触发器（隐藏）
            if (this.pendingSummary) {
                TextTimer(isCountDown: true, count: 1600)
                    .onTimer { _, elapsedTime =>
                        if (this.pendingSummary && elapsedTime >= 1600) {
                            this.pendingSummary = false
                            this.finishAISummary()
                        }
                    }
                    .opacity(0.0)
                    .width(0)
                    .height(0)
            }

            // 加载状态指示器
            if (this.isLoading) {
                Column {
                    Column {
                        LoadingProgress()
                            .color(0x1976D2)
                            .width(48)
                            .height(48)

                        Text(if (this.loadingMessage.size > 0) { this.loadingMessage } else { "加载中..." })
                            .fontSize(14)
                            .fontColor(0x666666)
                            .margin(top: 12)
                    }
                    .padding(24)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(16)
                }
                .width(100.percent)
                .height(100.percent)
                .backgroundColor(0x33000000)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xF6F7FB)
        .onAppear {
            if (!isUsersInitialized) {
                initializeUsers()
                isUsersInitialized = true
            }
        }
    }
    
    // ========== 登录页面（优化版 - 修复布局问题） ==========
    @Builder
    func buildLoginPage() {
        Scroll {
            Column {
                // Logo 和标题区域（紧凑版）
                Column {
                    // Logo 圆形背景
                    Column {
                        Text("🔒")
                            .fontSize(40)
                    }
                    .width(80)
                    .height(80)
                    .backgroundColor(0xE3F2FD)
                    .borderRadius(40)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .margin(bottom: 16)

                    Text("SecureMeet Guardian")
                        .fontSize(22)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0x1976D2)

                    Text("企业级安全会议助手")
                        .fontSize(13)
                        .fontColor(0x757575)
                        .margin(top: 6)

                    // 品牌标语
                    Text("保护您的会议安全")
                        .fontSize(11)
                        .fontColor(0x1976D2)
                        .margin(top: 10)
                        .padding(left: 10, right: 10, top: 5, bottom: 5)
                        .backgroundColor(0xE3F2FD)
                        .borderRadius(10)
                }
                .margin(top: 30, bottom: 20)
                .alignItems(HorizontalAlign.Center)

            if (!this.showPinInput) {
                // 用户选择区域（紧凑版）
                Column {
                    Text("选择用户身份")
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x212121)
                        .margin(bottom: 12)

                    // 管理员
                    this.buildLoginUserCard("👑", "管理员", "系统管理员", "完全权限", 0xFFF5F5, 0xF44336, "admin-001", "管理员")

                    // 安全专员
                    this.buildLoginUserCard("🔐", "安全专员", "安全审计员", "管理权限", 0xFFF8E1, 0xFF9800, "sec-001", "安全专员")

                    // 普通成员
                    this.buildLoginUserCard("👤", "普通成员", "张三", "基本权限", 0xF1F8F4, 0x4CAF50, "mem-001", "普通成员")

                    // 访客（直接登录）
                    Row {
                        Column {
                            Text("G")
                                .fontSize(24)
                        }
                        .width(45)
                        .height(45)
                        .backgroundColor(0xECEFF1)
                        .borderRadius(22)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)

                        Column {
                            Text("访客")
                                .fontSize(15)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(0x333333)
                            Text("访客用户 · 只读权限")
                                .fontSize(12)
                                .fontColor(0x666666)
                                .margin(top: 2)
                        }
                        .layoutWeight(1)
                        .margin(left: 12)
                        .alignItems(HorizontalAlign.Start)

                        Text("免密")
                            .fontSize(11)
                            .fontColor(0x4CAF50)
                    }
                    .width(100.percent)
                    .padding(12)
                    .margin(bottom: 8)
                    .backgroundColor(0xFAFAFA)
                    .borderRadius(12)
                    .onClick { evt =>
                        let result = quickLogin("guest-001")
                        match (result) {
                            case Some(user) =>
                                this.isLoggedIn = true
                                this.currentUserName = user.displayName
                                this.currentUserRole = getRoleName(user.baseUser.role)
                                this.refreshMeetingStats()
                                this.showToastMsg("欢迎，访客！")
                            case None =>
                                this.showToastMsg("登录失败")
                        }
                    }
                }
                .width(92.percent)
                .padding(16)
                .backgroundColor(0xFFFFFF)
                .borderRadius(14)

                // 提示信息（紧凑版）
                Row {
                    Text("💡")
                        .fontSize(13)
                        .margin(right: 5)
                    Text("管理员/安全专员/普通成员需输入PIN")
                        .fontSize(11)
                        .fontColor(0x757575)
                }
                .margin(top: 12)
                .padding(left: 10, right: 10, top: 6, bottom: 6)
                .backgroundColor(0xFFFBE6)
                .borderRadius(8)
            } else {
                // PIN 输入区域
                this.buildPinInputSection()
            }

            // 底部品牌信息（紧凑版）
            Column {
                Row {
                    Text("🚀")
                        .fontSize(11)
                        .margin(right: 3)
                    Text("基于仓颉语言开发")
                        .fontSize(10)
                        .fontColor(0xBDBDBD)
                }

                Text("HarmonyOS NEXT · v1.0.0")
                    .fontSize(9)
                    .fontColor(0xBDBDBD)
                    .margin(top: 3)

                Text("© 2024 SecureMeet Technologies")
                    .fontSize(8)
                    .fontColor(0xD0D0D0)
                    .margin(top: 3)
            }
            .margin(top: 20, bottom: 20)
            .alignItems(HorizontalAlign.Center)
        }
        .padding(left: 16, right: 16)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xFAFAFA)
        .align(Alignment.Top)
    }
    
    // PIN 输入区域
    @Builder
    func buildPinInputSection() {
        Column {
            // 返回按钮
            Row {
                Text("<- 返回选择用户")
                    .fontSize(14)
                    .fontColor(0x1976D2)
                    .onClick { evt =>
                        this.showPinInput = false
                        this.pinInput = ""
                        this.loginErrorMsg = ""
                    }
                Blank()
            }
            .width(100.percent)
            .margin(bottom: 20)
            
            // 用户信息
            Text(this.selectedLoginUserName)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(0x333333)
                .margin(bottom: 24)
            
            // PIN 输入提示
            Text("请输入 4 位 PIN 码")
                .fontSize(16)
                .fontColor(0x666666)
                .margin(bottom: 16)
            
            // PIN 输入框
            TextInput(text: this.pinInput, placeholder: "输入4位PIN")
                .width(200)
                .height(50)
                .fontSize(24)
                .textAlign(TextAlign.Center)
                .backgroundColor(0xF0F0F0)
                .borderRadius(8)
                .onChange { value =>
                    this.pinInput = value
                    if (value.size > 0) {
                        this.loginErrorMsg = ""
                    }
                }
            
            // 错误提示
            if (this.loginErrorMsg.size > 0) {
                Text(this.loginErrorMsg)
                    .fontSize(14)
                    .fontColor(0xF44336)
                    .margin(top: 12)
            }
            
            // 登录按钮
            Button("登录")
                .width(200)
                .height(44)
                .margin(top: 24)
                .backgroundColor(0x1976D2)
                .fontColor(0xFFFFFF)
                .onClick { evt =>
                    this.tryLoginWithPin()
                }
            
            // 默认 PIN 提示
            Text("提示：默认PIN为 1234 / 2345 / 3456")
                .fontSize(12)
                .fontColor(0x999999)
                .margin(top: 20)
        }
        .width(90.percent)
        .padding(24)
        .backgroundColor(0xFFFFFF)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)
    }
    
    // 尝试 PIN 登录
    func tryLoginWithPin(): Unit {
        if (this.pinInput.size != 4) {
            this.loginErrorMsg = "请输入4位PIN码"
            return
        }
        
        // 使用 loginWithCredentials 验证
        let result = loginWithCredentials(this.selectedLoginUserName, this.pinInput)
        match (result) {
            case Some(user) =>
                this.isLoggedIn = true
                this.currentUserName = user.displayName
                this.currentUserRole = getRoleName(user.baseUser.role)
                this.showPinInput = false
                this.pinInput = ""
                this.loginErrorMsg = ""
                this.refreshMeetingStats()
                this.showToastMsg("欢迎，${user.displayName}！")
            case None =>
                this.loginErrorMsg = "PIN码错误，请重试"
                this.pinInput = ""
        }
    }
    
    @Builder
    func buildLoginUserCard(emoji: String, title: String, name: String, permission: String, bgColor: UInt32, accentColor: UInt32, userId: String, displayName: String) {
        Row {
            Column {
                Text(emoji)
                    .fontSize(28)
            }
            .width(50)
            .height(50)
            .backgroundColor(bgColor)
            .borderRadius(25)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            
            Column {
                Text(title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0x333333)
                Text(name)
                    .fontSize(13)
                    .fontColor(0x666666)
                    .margin(top: 2)
                Text(permission)
                    .fontSize(12)
                    .fontColor(accentColor)
                    .margin(top: 2)
            }
            .layoutWeight(1)
            .margin(left: 16)
            .alignItems(HorizontalAlign.Start)
            
            Text("PIN")
                .fontSize(12)
                .fontColor(0x999999)
        }
        .width(100.percent)
        .padding(14)
        .margin(bottom: 10)
        .backgroundColor(0xFAFAFA)
        .borderRadius(12)
        .onClick { evt =>
            // 显示 PIN 输入界面
            this.selectedLoginUserId = userId
            this.selectedLoginUserName = displayName
            this.pinInput = ""
            this.loginErrorMsg = ""
            this.showPinInput = true
        }
    }
    
    // ========== 主应用界面 ==========
    @Builder
    func buildMainApp() {
        Column {
            // 顶部导航栏
            Row {
                if (this.currentPage != 0 || this.showMeetingForm) {
                    Text("←")
                        .fontSize(24)
                        .fontColor(0xFFFFFF)
                        .width(40)
                        .onClick { evt =>
                            if (this.showMeetingForm) {
                                this.showMeetingForm = false
                                this.clearForm()
                            } else if (this.currentPage == 4 || this.currentPage == 5) {
                                this.currentPage = 1
                            } else {
                                this.currentPage = 0
                            }
                            this.showToast = false
                        }
                }
                
                Text(this.getPageTitle())
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFFFFFF)
                    .layoutWeight(1)
                
                if (this.currentPage == 0 && !this.showMeetingForm) {
                    Text("日志")
                        .fontSize(14)
                        .fontColor(0xFFFFFF)
                        .padding(right: 12)
                        .onClick { evt =>
                            this.refreshLogStats()
                            this.currentPage = 2
                            this.showToast = false
                        }
                    
                    Text("退出")
                        .fontSize(14)
                        .fontColor(0xFFCDD2)
                        .onClick { evt =>
                            logoutCurrentUser()
                            this.isLoggedIn = false
                            this.currentPage = 0
                            this.showToastMsg("已退出登录")
                        }
                }
            }
            .width(100.percent)
            .height(56)
            .padding(left: 16, right: 16)
            .backgroundColor(0x1976D2)
            .alignItems(VerticalAlign.Center)
            
            // 用户信息栏
            if (this.currentPage == 0 && !this.showMeetingForm) {
                Row {
                    Text("👤 ${this.currentUserName}")
                        .fontSize(13)
                        .fontColor(0x666666)
                    Blank()
                    Text(this.currentUserRole)
                        .fontSize(12)
                        .fontColor(0x1976D2)
                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                        .backgroundColor(0xE3F2FD)
                        .borderRadius(4)
                }
                .width(100.percent)
                .padding(left: 16, right: 16, top: 8, bottom: 8)
                .backgroundColor(0xFFFFFF)
            }
            
            // 页面内容
            if (this.showMeetingForm) {
                this.buildMeetingForm()
            } else if (this.currentPage == 0) {
                this.buildListPage()
            } else if (this.currentPage == 1) {
                this.buildDetailPage()
            } else if (this.currentPage == 2) {
                this.buildLogPage()
            } else if (this.currentPage == 4) {
                this.buildTranscriptionPage()
            } else if (this.currentPage == 5) {
                this.buildMemberViewPage()
            } else {
                this.buildListPage()
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
    
    func getPageTitle(): String {
        if (this.showMeetingForm) {
            return if (this.editingMeetingId.size > 0) { "编辑会议" } else { "创建会议" }
        }
        if (this.currentPage == 0) { return "安全会议助手" }
        else if (this.currentPage == 1) { return "会议详情" }
        else if (this.currentPage == 2) { return "审计日志" }
        else if (this.currentPage == 4) { return "语音转写" }
        else if (this.currentPage == 5) { return "成员查看" }
        else { return "安全会议助手" }
    }
    
    func clearForm(): Unit {
        this.editingMeetingId = ""
        this.formTitle = ""
        this.formDescription = ""
        this.formSensitivity = 1
        this.formNotes = ""
    }
    
    func refreshMeetingStats(): Unit {
        let (total, high, done) = getMeetingStats()
        this.totalMeetings = total
        this.highRiskCount = high
        this.completedCount = done
        
        // 刷新会议列表
        this.refreshMeetingList()
    }

    func refreshMeetingList(): Unit {
        let meetings = listAllMeetings()
        var ids = ArrayList<String>()
        var titles = ArrayList<String>()
        var risks = ArrayList<Int64>()
        var sensitivities = ArrayList<String>()
        var count: Int64 = 0
        let keyword = this.searchKeyword
        for (m in meetings) {
            if (count >= 10) { break }
            if (keyword.size > 0) {
                if (!m.title.contains(keyword) && !m.description.contains(keyword)) {
                    continue
                }
            }
            ids.append(m.id)
            titles.append(m.title)
            risks.append(m.riskScore)
            let sensStr = match (m.sensitivity) {
                case Public => "公开"
                case Internal => "内部"
                case Confidential => "机密"
                case Secret => "绝密"
            }
            sensitivities.append(sensStr)
            count = count + 1
        }
        this.meetingIds = ids
        this.meetingTitles = titles
        this.meetingRisks = risks
        this.meetingSensitivities = sensitivities
        this.meetingCount = count
        this.isSearching = keyword.size > 0
    }
    
    func refreshLogStats(): Unit {
        let (total, exports, alerts) = getLogStats()
        this.totalLogs = total
        this.exportLogCount = exports
        this.alertLogCount = alerts

        // 刷新日志列表（最近20条）
        let logs = getAllAuditLogs()
        var times = ArrayList<String>()
        var actions = ArrayList<String>()
        var details = ArrayList<String>()
        var meetings = ArrayList<String>()
        var users = ArrayList<String>()
        var count: Int64 = 0

        var i: Int64 = logs.size - 1
        while (i >= 0 && count < 20) {
            let log = logs[i]
            times.append(formatDateTime(log.timestamp))
            actions.append(log.action)
            details.append(log.details)
            meetings.append(log.meetingId)
            users.append(log.userName)
            count = count + 1
            i = i - 1
        }

        this.logTimes = times
        this.logActions = actions
        this.logDetails = details
        this.logMeetings = meetings
        this.logUsers = users
        this.logCount = count
    }
    
    // ========== 会议编辑表单 ==========
    @Builder
    func buildMeetingForm() {
        Scroll {
            Column {
                // 表单标题
                Text(if (this.editingMeetingId.size > 0) { "编辑会议信息" } else { "创建新会议" })
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0x333333)
                    .margin(bottom: 20)
                
                // 会议标题
                Column {
                    Text("会议标题 *")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(bottom: 8)
                    TextInput(text: this.formTitle, placeholder: "请输入会议标题")
                        .width(100.percent)
                        .height(48)
                        .backgroundColor(0xF5F5F5)
                        .borderRadius(8)
                        .padding(left: 12, right: 12)
                        .onChange { value =>
                            this.formTitle = value
                        }
                }
                .width(100.percent)
                .margin(bottom: 16)
                .alignItems(HorizontalAlign.Start)
                
                // 会议描述
                Column {
                    Text("会议描述")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(bottom: 8)
                    TextArea(text: this.formDescription, placeholder: "请输入会议描述（可选）")
                        .width(100.percent)
                        .height(80)
                        .backgroundColor(0xF5F5F5)
                        .borderRadius(8)
                        .padding(12)
                        .onChange { value =>
                            this.formDescription = value
                        }
                }
                .width(100.percent)
                .margin(bottom: 16)
                .alignItems(HorizontalAlign.Start)
                
                // 敏感等级
                Column {
                    Text("敏感等级")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(bottom: 8)
                    
                    Row {
                        this.buildSensitivityOption("公开", 0, 0x4CAF50)
                        this.buildSensitivityOption("内部", 1, 0xFF9800)
                        this.buildSensitivityOption("机密", 2, 0xF44336)
                    }
                    .width(100.percent)
                    .justifyContent(FlexAlign.SpaceBetween)
                }
                .width(100.percent)
                .margin(bottom: 16)
                .alignItems(HorizontalAlign.Start)
                
                // 会议记录/笔记
                Column {
                    Text("会议记录")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(bottom: 8)
                    TextArea(text: this.formNotes, placeholder: "请输入会议记录内容...")
                        .width(100.percent)
                        .height(150)
                        .backgroundColor(0xF5F5F5)
                        .borderRadius(8)
                        .padding(12)
                        .onChange { value =>
                            this.formNotes = value
                        }
                }
                .width(100.percent)
                .margin(bottom: 24)
                .alignItems(HorizontalAlign.Start)

                // 保存按钮
                Button(if (this.editingMeetingId.size > 0) { "保存修改" } else { "创建会议" })
                    .width(100.percent)
                    .height(50)
                    .backgroundColor(0x1976D2)
                    .fontColor(0xFFFFFF)
                    .onClick { evt =>
                        this.saveMeeting()
                    }
                
                // 取消按钮
                Button("取消")
                    .width(100.percent)
                    .height(50)
                    .margin(top: 12)
                    .backgroundColor(0xEEEEEE)
                    .fontColor(0x666666)
                    .onClick { evt =>
                        this.showMeetingForm = false
                        this.clearForm()
                    }
            }
            .width(100.percent)
            .padding(20)
            .margin(16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)
        }
        .width(100.percent)
        .layoutWeight(1)
    }
    
    @Builder
    func buildSensitivityOption(label: String, value: Int64, color: UInt32) {
        Column {
            Text(label)
                .fontSize(14)
                .fontColor(if (this.formSensitivity == value) { 0xFFFFFF } else { color })
        }
        .width(30.percent)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(if (this.formSensitivity == value) { color } else { 0xF5F5F5 })
        .borderRadius(8)
        .onClick { evt =>
            this.formSensitivity = value
        }
    }
    
    func saveMeeting(): Unit {
        if (this.formTitle.size == 0) {
            this.showToastMsg("请输入会议标题")
            return
        }
        
        let sensitivity = match (this.formSensitivity) {
            case 0 => SensitivityLevel.Public
            case 2 => SensitivityLevel.Confidential
            case _ => SensitivityLevel.Internal
        }
        
        if (this.editingMeetingId.size > 0) {
            // 编辑现有会议
            updateMeetingInfo(this.editingMeetingId, this.formTitle, this.formDescription, sensitivity)
            if (this.formNotes.size > 0) {
                updateRawNotes(this.editingMeetingId, this.formNotes)
            }
            this.showToastMsg("会议已更新")
        } else {
            // 创建新会议
            let currentU = getCurrentUser()
            let org = createParticipant(currentU.id, currentU.name, "主持人", currentU.email)
            let meeting = createMeetingRecord(this.formTitle, this.formDescription, sensitivity, org, currentTimestamp())
            if (this.formNotes.size > 0) {
                updateRawNotes(meeting.id, this.formNotes)
            }
            this.showToastMsg("会议创建成功")
        }
        
        this.showMeetingForm = false
        this.clearForm()
        this.refreshMeetingStats()
    }

    // ========== 会议列表页 ==========
    @Builder
    func buildListPage() {
        Scroll {
            Column {
                // 搜索栏
                Row {
                    TextInput(text: this.searchKeyword, placeholder: "搜索会议...")
                        .layoutWeight(1)
                        .height(40)
                        .backgroundColor(0xFFFFFF)
                        .borderRadius(8)
                        .padding(left: 12, right: 12)
                        .onChange { value =>
                            this.searchKeyword = value
                            this.refreshMeetingList()
                        }
                    
                    if (this.searchKeyword.size > 0) {
                        Text("✕")
                            .fontSize(18)
                            .fontColor(0x999999)
                            .margin(left: 8)
                            .onClick { evt =>
                                this.searchKeyword = ""
                                this.refreshMeetingList()
                            }
                        Button("确认")
                            .height(32)
                            .margin(left: 8)
                            .backgroundColor(0x1976D2)
                            .fontColor(0xFFFFFF)
                            .onClick { evt =>
                                this.refreshMeetingList()
                            }
                    }
                }
                .width(100.percent)
                .padding(left: 16, right: 16, top: 12, bottom: 4)

                if (this.searchKeyword.size > 0) {
                    Row {
                        Text("搜索结果: ${this.meetingCount} 条")
                            .fontSize(12)
                            .fontColor(0x666666)
                        Blank()
                        Text("关键词: ${this.searchKeyword}")
                            .fontSize(12)
                            .fontColor(0x1976D2)
                    }
                    .width(100.percent)
                    .padding(left: 16, right: 16, bottom: 4)
                }
                
                // 统计卡片
                Row {
                    Column {
                        Text("${this.totalMeetings}")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x1976D2)
                        Text("会议总数")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }.layoutWeight(1)
                    
                    Column {
                        Text("${this.highRiskCount}")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0xF44336)
                        Text("高风险")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }.layoutWeight(1)
                    
                    Column {
                        Text("${this.completedCount}")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x4CAF50)
                        Text("已完成")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }.layoutWeight(1)
                }
                .width(100.percent)
                .padding(16)
                .margin(top: 8, left: 16, right: 16)
                .backgroundColor(0xFFFFFF)
                .borderRadius(12)
                
                // 动态会议卡片列表
                this.buildMeetingList()
                
                // 新建会议按钮
                Button("+ 新建会议")
                    .width(90.percent)
                    .height(48)
                    .margin(top: 20, bottom: 24)
                    .backgroundColor(0x1976D2)
                    .fontColor(0xFFFFFF)
                    .onClick { evt =>
                        this.clearForm()
                        this.showMeetingForm = true
                    }
            }.width(100.percent)
        }
        .width(100.percent)
        .layoutWeight(1)
    }
    
    // 辅助函数获取会议信息
    func getMeetingTitle(index: Int64): String {
        if (index < this.meetingTitles.size) { return this.meetingTitles[index] }
        return "未知会议"
    }
    
    func getMeetingRisk(index: Int64): Int64 {
        if (index < this.meetingRisks.size) { return this.meetingRisks[index] }
        return 0
    }
    
    func getMeetingSens(index: Int64): String {
        if (index < this.meetingSensitivities.size) { return this.meetingSensitivities[index] }
        return "内部"
    }
    
    func getRiskColor(risk: Int64): UInt32 {
        if (risk >= 60) { return 0xF44336 }
        if (risk >= 40) { return 0xFF9800 }
        return 0x4CAF50
    }
    
    func getSensColor(sens: String): UInt32 {
        if (sens == "机密" || sens == "绝密") { return 0xF44336 }
        return 0xFF9800
    }
    
    @Builder
    func buildMeetingList() {
        Column {
            Text("点击会议查看详情")
                .fontSize(14)
                .fontColor(0x666666)
                .margin(top: 8, bottom: 8, left: 16)
            
            // 会议卡片0
            Column {
                Row {
                    Column {
                        Text(this.getMeetingTitle(0))
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0x333333)
                        Text("风险: ${this.getMeetingRisk(0)}/100")
                            .fontSize(13)
                            .fontColor(this.getRiskColor(this.getMeetingRisk(0)))
                            .margin(top: 6)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(this.getMeetingSens(0))
                        .fontSize(11)
                        .fontColor(0xFFFFFF)
                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                        .backgroundColor(this.getSensColor(this.getMeetingSens(0)))
                        .borderRadius(4)
                }
                .width(100.percent)
            }
            .width(100.percent)
            .padding(16)
            .margin(top: 10, left: 16, right: 16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(8)
            .visibility(if (this.meetingCount >= 1) { Visibility.Visible } else { Visibility.None })
            .onClick { evt => this.loadMeetingByIndex(0) }
            
            // 会议卡片1
            Column {
                Row {
                    Column {
                        Text(this.getMeetingTitle(1))
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0x333333)
                        Text("风险: ${this.getMeetingRisk(1)}/100")
                            .fontSize(13)
                            .fontColor(this.getRiskColor(this.getMeetingRisk(1)))
                            .margin(top: 6)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(this.getMeetingSens(1))
                        .fontSize(11)
                        .fontColor(0xFFFFFF)
                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                        .backgroundColor(this.getSensColor(this.getMeetingSens(1)))
                        .borderRadius(4)
                }
                .width(100.percent)
            }
            .width(100.percent)
            .padding(16)
            .margin(top: 10, left: 16, right: 16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(8)
            .visibility(if (this.meetingCount >= 2) { Visibility.Visible } else { Visibility.None })
            .onClick { evt => this.loadMeetingByIndex(1) }
            
            // 会议卡片2
            Column {
                Row {
                    Column {
                        Text(this.getMeetingTitle(2))
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0x333333)
                        Text("风险: ${this.getMeetingRisk(2)}/100")
                            .fontSize(13)
                            .fontColor(this.getRiskColor(this.getMeetingRisk(2)))
                            .margin(top: 6)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(this.getMeetingSens(2))
                        .fontSize(11)
                        .fontColor(0xFFFFFF)
                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                        .backgroundColor(this.getSensColor(this.getMeetingSens(2)))
                        .borderRadius(4)
                }
                .width(100.percent)
            }
            .width(100.percent)
            .padding(16)
            .margin(top: 10, left: 16, right: 16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(8)
            .visibility(if (this.meetingCount >= 3) { Visibility.Visible } else { Visibility.None })
            .onClick { evt => this.loadMeetingByIndex(2) }
            
            // 会议卡片3
            Column {
                Row {
                    Column {
                        Text(this.getMeetingTitle(3))
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0x333333)
                        Text("风险: ${this.getMeetingRisk(3)}/100")
                            .fontSize(13)
                            .fontColor(this.getRiskColor(this.getMeetingRisk(3)))
                            .margin(top: 6)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(this.getMeetingSens(3))
                        .fontSize(11)
                        .fontColor(0xFFFFFF)
                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                        .backgroundColor(this.getSensColor(this.getMeetingSens(3)))
                        .borderRadius(4)
                }
                .width(100.percent)
            }
            .width(100.percent)
            .padding(16)
            .margin(top: 10, left: 16, right: 16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(8)
            .visibility(if (this.meetingCount >= 4) { Visibility.Visible } else { Visibility.None })
            .onClick { evt => this.loadMeetingByIndex(3) }
            
            // 会议卡片4
            Column {
                Row {
                    Column {
                        Text(this.getMeetingTitle(4))
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0x333333)
                        Text("风险: ${this.getMeetingRisk(4)}/100")
                            .fontSize(13)
                            .fontColor(this.getRiskColor(this.getMeetingRisk(4)))
                            .margin(top: 6)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(this.getMeetingSens(4))
                        .fontSize(11)
                        .fontColor(0xFFFFFF)
                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                        .backgroundColor(this.getSensColor(this.getMeetingSens(4)))
                        .borderRadius(4)
                }
                .width(100.percent)
            }
            .width(100.percent)
            .padding(16)
            .margin(top: 10, left: 16, right: 16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(8)
            .visibility(if (this.meetingCount >= 5) { Visibility.Visible } else { Visibility.None })
            .onClick { evt => this.loadMeetingByIndex(4) }
            
            // 无会议提示
            Text("暂无会议，点击下方按钮创建")
                .fontSize(14)
                .fontColor(0x999999)
                .margin(top: 40, bottom: 40)
                .visibility(if (this.meetingCount == 0) { Visibility.Visible } else { Visibility.None })
        }
        .width(100.percent)
    }
    
    func loadMeetingByIndex(index: Int64): Unit {
        if (index < this.meetingIds.size) {
            let meetingId = this.meetingIds[index]
            this.selectedMeetingId = meetingId
            this.loadMeetingDetail(meetingId)
            this.currentPage = 1
        }
    }
    
    func loadMeetingForEdit(meetingId: String): Unit {
        let meeting = getMeeting(meetingId)
        this.editingMeetingId = meetingId
        this.formTitle = meeting.title
        this.formDescription = meeting.description
        this.formSensitivity = match (meeting.sensitivity) {
            case Public => 0
            case Confidential => 2
            case _ => 1
        }
        this.formNotes = meeting.rawNotes
        this.showMeetingForm = true
    }
    
    func getSensitivityColor(sensitivity: SensitivityLevel): UInt32 {
        match (sensitivity) {
            case Public => 0x4CAF50
            case Internal => 0xFF9800
            case Confidential => 0xF44336
        }
    }
    
    func getStatusText(status: MeetingStatus): String {
        match (status) {
            case Draft => "草稿"
            case Scheduled => "已排期"
            case InProgress => "进行中"
            case Completed => "已完成"
            case Archived => "已归档"
        }
    }
    
    
    // ========== 会议详情页 ==========
    func loadMeetingDetail(meetingId: String): Unit {
        let m = getMeeting(meetingId)
        this.detailTitle = m.title
        this.detailDescription = if (m.description.size > 0) { m.description } else { "无" }
        this.detailSensitivity = match (m.sensitivity) {
            case Public => "公开"
            case Internal => "内部"
            case Confidential => "机密"
            case Secret => "绝密"
        }
        this.detailStatus = getStatusText(m.status)
        this.detailCreatedTime = if (m.createdTime > 0) { formatDateTime(m.createdTime) } else { "-" }
        this.detailOrganizer = if (m.organizer.name.size > 0) { m.organizer.name } else { "未知" }
        this.detailNotes = m.rawNotes
        this.detailSummary = m.aiSummary
        this.detailRiskScore = m.riskScore
        this.isAudited = !m.requiresAudit
        this.detailMaskedContent = this.getLatestMaskedContentForMeeting(m)
        this.detailSensitiveCount = 0
    }

    func refreshDetailAndStats(): Unit {
        if (this.selectedMeetingId.size > 0) {
            this.loadMeetingDetail(this.selectedMeetingId)
        }
        this.refreshMeetingStats()
    }

    func saveDetailNotes(): Unit {
        if (this.selectedMeetingId.size == 0) {
            return
        }
        updateRawNotes(this.selectedMeetingId, this.detailNotes)
        this.showToastMsg("记录已保存，需重新审计")
        this.refreshDetailAndStats()
    }

    func startSelectedMeeting(): Unit {
        if (startMeeting(this.selectedMeetingId)) {
            this.showToastMsg("会议已开始")
            this.refreshDetailAndStats()
        } else {
            this.showToastMsg("开始会议失败")
        }
    }

    func endSelectedMeeting(): Unit {
        if (endMeeting(this.selectedMeetingId)) {
            this.showToastMsg("会议已结束")
            this.refreshDetailAndStats()
        } else {
            this.showToastMsg("结束会议失败")
        }
    }

    func archiveSelectedMeeting(): Unit {
        if (archiveMeeting(this.selectedMeetingId)) {
            this.showToastMsg("会议已归档")
            this.refreshDetailAndStats()
        } else {
            this.showToastMsg("归档失败")
        }
    }

    func resetTranscriptionState(): Unit {
        this.transStatus = "准备就绪"
        this.transIsRecording = false
        this.transIsPaused = false
        this.transRiskScore = 0
        this.transSensitiveCount = 0
        this.transSegments = ArrayList<TranscriptSegment>()
        this.transManualInput = ""
        this.transShowManualInput = false
    }

    func initTranscriptionUI(): Unit {
        setTranscriptionCallbacks(
            { segment => this.onTranscriptionSegment(segment) },
            { score, msg => this.onTranscriptionRisk(score, msg) },
            { status => this.onTranscriptionStatus(status) }
        )
        initSpeechRecognition()
        this.transStatus = "准备就绪，点击开始录制"
    }

    func onTranscriptionSegment(segment: TranscriptSegment): Unit {
        this.transSegments.append(segment)
        this.transRiskScore = this.transRiskScore + segment.riskScore
        this.transSensitiveCount = this.transSensitiveCount + segment.sensitiveHits
    }

    func onTranscriptionRisk(score: Int64, message: String): Unit {
        this.showToastMsg(message)
    }

    func onTranscriptionStatus(status: TranscriptionStatus): Unit {
        this.transStatus = match (status) {
            case Idle => "空闲"
            case Preparing => "准备中..."
            case Recording => "录制中"
            case Paused => "已暂停"
            case Processing => "处理中..."
            case Completed => "已完成"
            case Error => "发生错误"
        }
    }

    func startTranscriptionSession(): Unit {
        startTranscription(this.selectedMeetingId)
        this.transIsRecording = true
        this.transIsPaused = false
    }

    func pauseTranscriptionSession(): Unit {
        pauseTranscription()
        this.transIsPaused = true
    }

    func resumeTranscriptionSession(): Unit {
        resumeTranscription()
        this.transIsPaused = false
    }

    func stopTranscriptionSession(): Unit {
        let _ = stopTranscription()
        this.transIsRecording = false
        this.transIsPaused = false
        let fullText = getFullTranscript()
        if (this.selectedMeetingId.size > 0) {
            updateRawNotes(this.selectedMeetingId, fullText)
            this.detailNotes = fullText
            this.isAudited = false
        }
        this.showToastMsg("转写已保存")
    }

    func getLastTranscriptionText(): String {
        if (this.transSegments.size == 0) {
            return "暂无转写内容"
        }
        let last = this.transSegments[this.transSegments.size - 1]
        return last.text
    }

    func openTranscription(): Unit {
        if (this.selectedMeetingId.size == 0) {
            this.showToastMsg("请选择会议")
            return
        }
        this.resetTranscriptionState()
        this.initTranscriptionUI()
        this.currentPage = 4
    }

    func openMemberView(): Unit {
        if (this.selectedMeetingId.size == 0) {
            this.showToastMsg("请选择会议")
            return
        }
        this.initMemberView()
        this.currentPage = 5
    }

    func initMemberView(): Unit {
        this.memberViewIsOriginal = false
        this.memberShowReceipt = false
        this.memberAccepted = isSignedConfidentiality(this.selectedMeetingId, getCurrentUser().id)
        this.memberOtpInput = ""
        this.memberViewRefresh = this.memberViewRefresh + 1
    }

    func generateOtp(): String {
        let base = (currentTimestamp() / 1000) % 900000
        let otpVal = 100000 + base
        return "${otpVal}"
    }

    func publishOriginalAccessAction(): Unit {
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.requiresAudit) {
            this.showToastMsg("需重新审计，暂不可发布原文")
            return
        }
        let otp = this.generateOtp()
        let expiresAt = currentTimestamp() + 10 * 60 * 1000
        if (publishOriginalAccess(this.selectedMeetingId, otp, expiresAt)) {
            this.showToastMsg("原文访问已发布，OTP 有效 10 分钟")
            this.refreshDetailAndStats()
            this.memberViewRefresh = this.memberViewRefresh + 1
        } else {
            this.showToastMsg("发布失败")
        }
    }

    func revokeOriginalAccessAction(): Unit {
        if (revokeOriginalAccess(this.selectedMeetingId)) {
            this.memberViewIsOriginal = false
            this.memberShowReceipt = false
            this.memberAccepted = false
            this.showToastMsg("原文访问已撤回")
            this.refreshDetailAndStats()
            this.memberViewRefresh = this.memberViewRefresh + 1
        } else {
            this.showToastMsg("撤回失败")
        }
    }

    func requestOriginalAccess(): Unit {
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.requiresAudit) {
            this.showToastMsg("需重新审计，暂不可申请原文")
            return
        }
        if (!meeting.originalAccessPublished || meeting.originalAccessRevoked) {
            this.showToastMsg("原文访问未发布或已撤回")
            return
        }
        this.memberShowReceipt = true
        this.memberAccepted = isSignedConfidentiality(this.selectedMeetingId, getCurrentUser().id)
        this.memberOtpInput = ""
        logDetailedEvent(AuditEventType.OriginalAccessRequested, this.selectedMeetingId, "REQUEST_ORIGINAL", "成员申请原文", true)
    }

    func signConfidentialityAction(): Unit {
        let userId = getCurrentUser().id
        signConfidentiality(this.selectedMeetingId, userId)
        this.memberAccepted = true
        this.memberViewRefresh = this.memberViewRefresh + 1
    }

    func verifyOtpAndShowOriginal(): Unit {
        if (!this.memberAccepted) {
            this.showToastMsg("请先签署保密承诺")
            return
        }
        let userId = getCurrentUser().id
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.requiresAudit) {
            this.showToastMsg("需重新审计，暂不可查看原文")
            return
        }
        if (authorizeOriginalAccess(this.selectedMeetingId, userId, this.memberOtpInput)) {
            this.memberViewIsOriginal = true
            this.memberShowReceipt = false
            logDetailedEvent(AuditEventType.OriginalViewed, this.selectedMeetingId, "VIEW_ORIGINAL", "成员查看原文", true)
            this.showToastMsg("验证通过，已切换原文")
            this.memberViewRefresh = this.memberViewRefresh + 1
        } else {
            this.showToastMsg("OTP 验证失败")
        }
    }

    func backToMaskedView(): Unit {
        this.memberViewIsOriginal = false
        this.showToastMsg("已返回脱敏版")
    }

    func showOriginalIfAuthorized(): Unit {
        let userId = getCurrentUser().id
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.requiresAudit) {
            this.showToastMsg("需重新审计，暂不可查看原文")
            return
        }
        if (!meeting.originalAccessPublished || meeting.originalAccessRevoked) {
            this.showToastMsg("原文访问未发布或已撤回")
            return
        }
        if (isAuthorizedOriginal(this.selectedMeetingId, userId)) {
            this.memberViewIsOriginal = true
            logDetailedEvent(AuditEventType.OriginalViewed, this.selectedMeetingId, "VIEW_ORIGINAL", "成员查看原文", true)
            this.showToastMsg("已切换原文")
            this.memberViewRefresh = this.memberViewRefresh + 1
        } else {
            this.requestOriginalAccess()
        }
    }

    func getMemberOriginalContent(): String {
        if (this.selectedMeetingId.size > 0) {
            let meeting = getMeeting(this.selectedMeetingId)
            if (meeting.rawNotes.size > 0) { return meeting.rawNotes }
        }
        return "暂无内容，请先填写会议记录"
    }

    func getMemberMaskedContent(): String {
        let meeting = getMeeting(this.selectedMeetingId)
        let latestMasked = this.getLatestMaskedContentForMeeting(meeting)
        if (latestMasked.size > 0) { return latestMasked }
        if (meeting.rawNotes.size == 0) { return "暂无内容，请先填写会议记录" }
        let content = meeting.rawNotes
        let hits = sensitiveScan(content)
        var masked = content
        for (hit in hits) {
            let replacement = if (hit.typ == "PHONE") { maskPhone(hit.value) } else { getMaskPattern(hit.typ) }
            masked = replaceAll(masked, hit.value, replacement)
        }
        return masked
    }

    func getLatestMaskedContentForMeeting(meeting: Meeting): String {
        var latest = ""
        var latestTime: Int64 = -1
        for (version in meeting.minutesVersions) {
            if (version.versionType == "masked") {
                if (version.createdTime >= latestTime) {
                    latestTime = version.createdTime
                    latest = version.content
                }
            }
        }
        return latest
    }

    func getWatermarkText(isOriginal: Bool): String {
        let base = "${this.currentUserName} ${formatDateTime(currentTimestamp())}"
        return if (isOriginal) { "[原文] ${base}" } else { base }
    }

    func getMemberPhoneHit(): String {
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.rawNotes.size == 0) { return "" }
        let hits = sensitiveScan(meeting.rawNotes)
        for (hit in hits) {
            if (hit.typ == "PHONE") { return hit.value }
        }
        return ""
    }

    func getMemberPhoneBadge(isOriginal: Bool): String {
        let phone = this.getMemberPhoneHit()
        if (phone.size == 0) { return "" }
        return if (isOriginal) { phone } else { maskPhone(phone) }
    }

    func isAdminOrManager(): Bool {
        let role = getCurrentUser().role
        match (role) {
            case Admin | Manager => return true
            case _ => return false
        }
    }

    func isAuditRequiredForSelected(): Bool {
        if (this.selectedMeetingId.size == 0) { return false }
        return getMeeting(this.selectedMeetingId).requiresAudit
    }

    func getOriginalAccessStatusText(): String {
        if (this.selectedMeetingId.size == 0) { return "-" }
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.originalAccessRevoked) { return "已撤回" }
        if (meeting.originalAccessPublished) {
            if (meeting.originalAccessOtpExpires > 0 && currentTimestamp() > meeting.originalAccessOtpExpires) {
                return "已过期"
            }
            return "已发布"
        }
        return "未发布"
    }

    func getOriginalAccessStatusColor(): UInt32 {
        if (this.selectedMeetingId.size == 0) { return 0x999999 }
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.originalAccessRevoked) { return 0xD32F2F }
        if (meeting.originalAccessPublished) {
            if (meeting.originalAccessOtpExpires > 0 && currentTimestamp() > meeting.originalAccessOtpExpires) {
                return 0xFF9800
            }
            return 0x2E7D32
        }
        return 0x999999
    }

    func getOriginalAccessExpireText(): String {
        if (this.selectedMeetingId.size == 0) { return "-" }
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.originalAccessPublished && meeting.originalAccessOtpExpires > 0) {
            if (currentTimestamp() > meeting.originalAccessOtpExpires) {
                return "已过期"
            }
            return formatDateTime(meeting.originalAccessOtpExpires)
        }
        return "-"
    }

    func getOriginalAccessOtpText(): String {
        if (this.selectedMeetingId.size == 0) { return "" }
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.originalAccessPublished && !meeting.originalAccessRevoked) {
            return meeting.originalAccessOtp
        }
        return ""
    }

    func canMemberViewOriginal(): Bool {
        if (this.selectedMeetingId.size == 0) { return false }
        let meeting = getMeeting(this.selectedMeetingId)
        let userId = getCurrentUser().id
        return isAuthorizedOriginal(this.selectedMeetingId, userId)
            && meeting.originalAccessPublished
            && !meeting.originalAccessRevoked
            && !meeting.requiresAudit
    }

    // ========== 语音转写页 ==========
    @Builder
    func buildTranscriptionPage() {
        Column {
            // 状态栏
            Row {
                Column {
                    Text(if (this.transIsRecording && !this.transIsPaused) { "●" } else if (this.transIsPaused) { "||" } else { "○" })
                        .fontSize(24)
                }
                .width(40)
                
                Column {
                    Text(this.transStatus)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                    Text("已转写: ${this.transSegments.size} 段")
                        .fontSize(12)
                        .fontColor(0x666666)
                        .margin(top: 4)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                
                Column {
                    Text("风险分")
                        .fontSize(12)
                        .fontColor(0x666666)
                    Text("${this.transRiskScore}")
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.getRiskColor(this.transRiskScore))
                }
                .width(80)
                .alignItems(HorizontalAlign.Center)
                
                Column {
                    Text("敏感项")
                        .fontSize(12)
                        .fontColor(0x666666)
                    Text("${this.transSensitiveCount}")
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0xF44336)
                }
                .width(80)
                .alignItems(HorizontalAlign.Center)
            }
            .width(100.percent)
            .padding(16)
            .backgroundColor(0xFFFFFF)

            // 最近转写片段
            Column {
                Text("最近片段")
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0x333333)
                Text(this.getLastTranscriptionText())
                    .fontSize(13)
                    .fontColor(0x666666)
                    .margin(top: 8)
                    .lineHeight(18)
            }
            .width(100.percent)
            .padding(16)
            .margin(16)
            .backgroundColor(0xFFFFFF)
            .borderRadius(8)

            // 手动输入
            if (this.transShowManualInput) {
                Column {
                    Text("手动输入")
                        .fontSize(12)
                        .fontColor(0x666666)
                        .margin(bottom: 8)
                    
                    Row {
                        TextInput(text: this.transManualInput, placeholder: "输入测试文本...")
                            .layoutWeight(1)
                            .height(40)
                            .backgroundColor(0xFFFFFF)
                            .borderRadius(8)
                            .padding(left: 12, right: 12)
                            .onChange { value =>
                                this.transManualInput = value
                            }
                        
                        Button("添加")
                            .width(60)
                            .height(40)
                            .margin(left: 8)
                            .backgroundColor(0x1976D2)
                            .fontColor(0xFFFFFF)
                            .onClick { evt =>
                                if (this.transManualInput.size > 0) {
                                    simulateTranscriptSegment(this.transManualInput)
                                    this.transManualInput = ""
                                }
                            }
                    }
                    .width(100.percent)
                }
                .width(100.percent)
                .padding(16)
                .margin(left: 16, right: 16)
                .backgroundColor(0xE8F5E9)
                .borderRadius(8)
            }

            // 控制按钮
            Column {
                Row {
                    if (!this.transIsRecording) {
                        Button("🎤 开始录制")
                            .layoutWeight(1)
                            .height(50)
                            .backgroundColor(0xF44336)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.startTranscriptionSession() }
                    } else if (this.transIsPaused) {
                        Button("继续")
                            .layoutWeight(1)
                            .height(50)
                            .margin(right: 8)
                            .backgroundColor(0x4CAF50)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.resumeTranscriptionSession() }
                        Button("结束")
                            .layoutWeight(1)
                            .height(50)
                            .backgroundColor(0x1976D2)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.stopTranscriptionSession() }
                    } else {
                        Button("暂停")
                            .layoutWeight(1)
                            .height(50)
                            .margin(right: 8)
                            .backgroundColor(0xFF9800)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.pauseTranscriptionSession() }
                        Button("结束")
                            .layoutWeight(1)
                            .height(50)
                            .backgroundColor(0x1976D2)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.stopTranscriptionSession() }
                    }
                }
                .width(100.percent)
                
                Row {
                    Button(if (this.transShowManualInput) { "隐藏输入" } else { "手动输入" })
                        .layoutWeight(1)
                        .height(44)
                        .margin(top: 12, right: 8)
                        .backgroundColor(0xEEEEEE)
                        .fontColor(0x666666)
                        .onClick { evt =>
                            this.transShowManualInput = !this.transShowManualInput
                        }
                    Button("完成并返回详情")
                        .layoutWeight(1)
                        .height(44)
                        .margin(top: 12)
                        .backgroundColor(0x607D8B)
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            this.currentPage = 1
                        }
                }
                .width(100.percent)
            }
            .width(100.percent)
            .padding(16)
            .backgroundColor(0xFFFFFF)
        }
        .width(100.percent)
        .height(100.percent)
    }

    // ========== 成员查看页 ==========
    @Builder
    func buildMemberViewPage() {
        Scroll {
            Column {
                Text("${this.memberViewRefresh}")
                    .opacity(0.0)
                    .width(0)
                    .height(0)

                Column {
                    Text("成员查看页面")
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0x333333)
                    Text(if (this.detailTitle.size > 0) { this.detailTitle } else { "未命名会议" })
                        .fontSize(13)
                        .fontColor(0x666666)
                        .margin(top: 6)
                    Text("原文访问: ${this.getOriginalAccessStatusText()}")
                        .fontSize(12)
                        .fontColor(this.getOriginalAccessStatusColor())
                        .margin(top: 6)
                    if (this.isAuditRequiredForSelected()) {
                        Text("需重新审计，原文访问暂不可用")
                            .fontSize(12)
                            .fontColor(0xFF9800)
                            .margin(top: 4)
                    }
                }
                .width(100.percent)
                .padding(16)
                .backgroundColor(0xFFFFFF)

                // 顶部操作
                Row {
                    Button(if (this.memberViewIsOriginal) { "返回脱敏版" } else if (this.canMemberViewOriginal()) { "查看原文" } else { "申请原文" })
                        .layoutWeight(1)
                        .height(44)
                        .backgroundColor(if (this.memberViewIsOriginal) { 0x9E9E9E } else { 0x1976D2 })
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            if (this.memberViewIsOriginal) {
                                this.backToMaskedView()
                            } else if (this.canMemberViewOriginal()) {
                                this.showOriginalIfAuthorized()
                            } else {
                                this.requestOriginalAccess()
                            }
                        }
                }
                .width(100.percent)
                .padding(left: 16, right: 16, top: 12, bottom: 8)

                // 管理员发布/撤回
                    if (this.isAdminOrManager()) {
                        Column {
                            Text("管理员发布/撤回")
                                .fontSize(13)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(0xFF9800)
                                .margin(bottom: 8)
                        Row {
                            Button("发布并生成 OTP")
                                .layoutWeight(1)
                                .height(36)
                                .margin(right: 8)
                                .backgroundColor(0xFF9800)
                                .fontColor(0xFFFFFF)
                                .onClick { => this.publishOriginalAccessAction() }
                            Button("撤回访问")
                                .layoutWeight(1)
                                .height(36)
                                .backgroundColor(0x757575)
                                .fontColor(0xFFFFFF)
                                .onClick { => this.revokeOriginalAccessAction() }
                        }
                        .width(100.percent)
                        Text("当前 OTP: ${if (this.getOriginalAccessOtpText().size > 0) { this.getOriginalAccessOtpText() } else { "未发布" }}")
                            .fontSize(12)
                            .fontColor(0x666666)
                            .margin(top: 6)
                        }
                        .width(100.percent)
                        .padding(16)
                        .margin(left: 16, right: 16, top: 8)
                        .backgroundColor(0xFFF8E1)
                        .borderRadius(8)
                        .alignItems(HorizontalAlign.Start)
                    }

                // 内容区（脱敏/原文）
                Column {
                    Text(if (this.memberViewIsOriginal) { "原文版（已授权）" } else { "脱敏版（默认可看）" })
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(if (this.memberViewIsOriginal) { 0x2E7D32 } else { 0xF9A825 })

                    Text(if (this.memberViewIsOriginal) { this.getMemberOriginalContent() } else { this.getMemberMaskedContent() })
                        .fontSize(13)
                        .fontColor(0x666666)
                        .margin(top: 8)

                    Row {
                        Text("敏感信息:")
                            .fontSize(12)
                            .fontColor(0x666666)
                            .margin(right: 8)
                        if (this.getMemberPhoneBadge(true).size > 0) {
                            Text(this.getMemberPhoneBadge(this.memberViewIsOriginal))
                                .fontSize(12)
                                .fontColor(0x212121)
                                .padding(left: 6, right: 6, top: 2, bottom: 2)
                                .backgroundColor(if (this.memberViewIsOriginal) { 0xC8E6C9 } else { 0xFFF9C4 })
                                .borderRadius(4)
                        } else {
                            Text("未检测到手机号")
                                .fontSize(12)
                                .fontColor(0x999999)
                        }
                    }
                    .margin(top: 10)

                    Text("水印: ${this.getWatermarkText(this.memberViewIsOriginal)}")
                        .fontSize(if (this.memberViewIsOriginal) { 12 } else { 11 })
                        .fontColor(if (this.memberViewIsOriginal) { 0xD32F2F } else { 0x999999 })
                        .margin(top: 12)
                        .fontWeight(if (this.memberViewIsOriginal) { FontWeight.Bold } else { FontWeight.Medium })
                }
                .width(100.percent)
                .padding(16)
                .margin(left: 16, right: 16, top: 12)
                .backgroundColor(if (this.memberViewIsOriginal) { 0xE8F5E9 } else { 0xFFFDE7 })
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)

                // 签收流程
                if (this.memberShowReceipt) {
                    Column {
                        Text("签收保密承诺")
                            .fontSize(14)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x1976D2)
                        Text("我已阅读并同意保密承诺，仅用于本次会议审阅。")
                            .fontSize(12)
                            .fontColor(0x666666)
                            .margin(top: 6)
                        Button(if (this.memberAccepted) { "已签署" } else { "签署保密承诺" })
                            .width(100.percent)
                            .height(36)
                            .margin(top: 8)
                            .backgroundColor(if (this.memberAccepted) { 0x4CAF50 } else { 0x1976D2 })
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.signConfidentialityAction() }
                        TextInput(text: this.memberOtpInput, placeholder: "输入 OTP")
                            .width(100.percent)
                            .height(40)
                            .margin(top: 10)
                            .backgroundColor(0xFFFFFF)
                            .borderRadius(8)
                            .padding(left: 12, right: 12)
                            .onChange { value => this.memberOtpInput = value }
                        Button("验证并查看原文")
                            .width(100.percent)
                            .height(40)
                            .margin(top: 10)
                            .backgroundColor(0x2E7D32)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.verifyOtpAndShowOriginal() }
                    }
                    .width(100.percent)
                    .padding(16)
                    .margin(left: 16, right: 16, top: 12)
                    .backgroundColor(0xE3F2FD)
                    .borderRadius(8)
                    .alignItems(HorizontalAlign.Start)
                }

            }
            .width(100.percent)
        }
        .width(100.percent)
        .layoutWeight(1)
    }
    
    @Builder
    func buildDetailPage() {
        Scroll {
            Column {
                Column {
                    Text("会议详情")
                        .fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0x333333)
                    Text(if (this.detailTitle.size > 0) { this.detailTitle } else { "未命名会议" })
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x212121)
                        .margin(top: 8)
                    Text(this.detailDescription)
                        .fontSize(12)
                        .fontColor(0x757575)
                        .margin(top: 6)
                    Row {
                        Text("敏感等级: ${this.detailSensitivity}")
                            .fontSize(12)
                            .fontColor(0x666666)
                        Blank()
                        Text("状态: ${this.detailStatus}")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }
                    .width(100.percent)
                    .margin(top: 8)
                    Row {
                        Text("创建时间: ${this.detailCreatedTime}")
                            .fontSize(12)
                            .fontColor(0x666666)
                        Blank()
                        Text("主持人: ${this.detailOrganizer}")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }
                    .width(100.percent)
                    .margin(top: 6)
                    Row {
                        Text("风险评分: ${this.detailRiskScore}/100")
                            .fontSize(14)
                            .fontColor(if (this.detailRiskScore >= 60) { 0xF44336 } else if (this.detailRiskScore >= 30) { 0xFF9800 } else { 0x4CAF50 })
                        Blank()
                        Text(if (this.isAudited) { "已审计" } else { "需重新审计" })
                            .fontSize(12)
                            .fontColor(if (this.isAudited) { 0x4CAF50 } else { 0xFF9800 })
                    }
                    .width(100.percent)
                    .margin(top: 8)
                    if (this.detailSensitiveCount > 0) {
                        Text("发现 ${this.detailSensitiveCount} 处敏感信息")
                            .fontSize(12)
                            .fontColor(0xF44336)
                            .margin(top: 4)
                    }
                }
                .width(100.percent)
                .padding(16)
                .margin(16)
                .backgroundColor(0xFFFFFF)
                .borderRadius(12)

                // 原文授权入口（统一流程）
                Column {
                    Row {
                        Text("原文授权")
                            .fontSize(14)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x333333)
                        Blank()
                        Text(this.getOriginalAccessStatusText())
                            .fontSize(12)
                            .fontColor(this.getOriginalAccessStatusColor())
                            .padding(left: 8, right: 8, top: 4, bottom: 4)
                            .backgroundColor(0xF5F5F5)
                            .borderRadius(6)
                    }
                    .width(100.percent)
                    .margin(bottom: 8)

                    Row {
                        Text("OTP有效期:")
                            .fontSize(12)
                            .fontColor(0x666666)
                        Text(this.getOriginalAccessExpireText())
                            .fontSize(12)
                            .fontColor(0x333333)
                            .margin(left: 6)
                        Blank()
                        if (this.isAdminOrManager() && this.getOriginalAccessOtpText().size > 0) {
                            Text("当前OTP: ${this.getOriginalAccessOtpText()}")
                                .fontSize(11)
                                .fontColor(0x999999)
                        }
                    }
                    .width(100.percent)

                    if (this.isAuditRequiredForSelected()) {
                        Text("需重新审计，原文授权与导出已暂停")
                            .fontSize(12)
                            .fontColor(0xFF9800)
                            .margin(top: 6)
                    }

                    Row {
                        Button("成员查看")
                            .layoutWeight(1)
                            .height(40)
                            .margin(right: 8, top: 10)
                            .backgroundColor(0x00ACC1)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.openMemberView() }

                        if (this.isAdminOrManager()) {
                            Button("发布原文")
                                .layoutWeight(1)
                                .height(40)
                                .margin(top: 10, right: 8)
                                .backgroundColor(0xFF9800)
                                .fontColor(0xFFFFFF)
                                .onClick { evt => this.publishOriginalAccessAction() }
                            Button("撤回原文")
                                .layoutWeight(1)
                                .height(40)
                                .margin(top: 10)
                                .backgroundColor(0x757575)
                                .fontColor(0xFFFFFF)
                                .onClick { evt => this.revokeOriginalAccessAction() }
                        }
                    }
                    .width(100.percent)
                }
                .width(100.percent)
                .padding(16)
                .margin(left: 16, right: 16, bottom: 8)
                .backgroundColor(0xFFFFFF)
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)

                if (this.detailStatus != "已归档") {
                    Row {
                        if (this.detailStatus == "草稿" || this.detailStatus == "已排期") {
                            Button("开始会议")
                                .layoutWeight(1)
                                .height(44)
                                .backgroundColor(0x4CAF50)
                                .fontColor(0xFFFFFF)
                                .onClick { evt => this.startSelectedMeeting() }
                        }
                        if (this.detailStatus == "进行中") {
                            Button("结束会议")
                                .layoutWeight(1)
                                .height(44)
                                .backgroundColor(0xFF9800)
                                .fontColor(0xFFFFFF)
                                .onClick { evt => this.endSelectedMeeting() }
                        }
                        if (this.detailStatus == "已完成") {
                            Button("归档会议")
                                .layoutWeight(1)
                                .height(44)
                                .backgroundColor(0x607D8B)
                                .fontColor(0xFFFFFF)
                                .onClick { evt => this.archiveSelectedMeeting() }
                        }
                    }
                    .width(100.percent)
                    .padding(16)
                    .margin(left: 16, right: 16, bottom: 8)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(8)
                }
                
                Column {
                    Text("会议记录")
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0x333333)
                    TextArea(text: this.detailNotes, placeholder: "请输入会议记录内容...")
                        .width(100.percent)
                        .height(150)
                        .backgroundColor(0xF5F5F5)
                        .borderRadius(8)
                        .padding(12)
                        .margin(top: 8, bottom: 12)
                        .onChange { value =>
                            this.detailNotes = value
                        }
                    Button("保存记录")
                        .width(100.percent)
                        .height(40)
                        .backgroundColor(0x1976D2)
                        .fontColor(0xFFFFFF)
                        .onClick { evt => this.saveDetailNotes() }
                    if (!this.isAudited) {
                        Text("提示：内容变更后需重新审计")
                            .fontSize(12)
                            .fontColor(0xFF9800)
                            .margin(top: 8)
                    }
                }
                .width(100.percent)
                .padding(16)
                .margin(left: 16, right: 16, bottom: 8)
                .backgroundColor(0xFFFFFF)
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)

                if (this.detailSummary.size > 0) {
                    Column {
                        Text("AI 纪要")
                            .fontSize(14)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x2196F3)
                        Text(this.detailSummary)
                            .fontSize(13)
                            .fontColor(0x666666)
                            .margin(top: 8)
                    }
                    .width(100.percent)
                    .padding(16)
                    .margin(left: 16, right: 16, bottom: 8)
                    .backgroundColor(0xE3F2FD)
                    .borderRadius(8)
                    .alignItems(HorizontalAlign.Start)
                }
                
                if (this.detailMaskedContent.size > 0) {
                    Column {
                        Text("脱敏版本")
                            .fontSize(14)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x4CAF50)
                        Text(this.detailMaskedContent)
                            .fontSize(13)
                            .fontColor(0x666666)
                            .margin(top: 8)
                    }
                    .width(100.percent)
                    .padding(16)
                    .margin(left: 16, right: 16, bottom: 8)
                    .backgroundColor(0xE8F5E9)
                    .borderRadius(8)
                    .alignItems(HorizontalAlign.Start)
                }
                
                // 行动项列表
                this.buildActionItemsSection()
                
                Column {
                    Button("进入语音转写")
                        .width(100.percent)
                        .height(48)
                        .margin(bottom: 12)
                        .backgroundColor(0x607D8B)
                        .fontColor(0xFFFFFF)
                        .onClick { evt => this.openTranscription() }

                    Button("AI 智能纪要")
                        .width(100.percent)
                        .height(48)
                        .margin(bottom: 12)
                        .backgroundColor(0x2196F3)
                        .fontColor(0xFFFFFF)
                        .onClick { evt => this.generateAISummary() }
                    
                    Button("提取行动项")
                        .width(100.percent)
                        .height(48)
                        .margin(bottom: 12)
                        .backgroundColor(0x9C27B0)
                        .fontColor(0xFFFFFF)
                        .onClick { evt => this.extractActionItems() }
                    
                    Button("敏感信息审计")
                        .width(100.percent)
                        .height(48)
                        .margin(bottom: 12)
                        .backgroundColor(0xFF9800)
                        .fontColor(0xFFFFFF)
                        .onClick { evt => this.performSensitiveAudit() }
                    
                    Button("生成脱敏版本")
                        .width(100.percent)
                        .height(48)
                        .margin(bottom: 12)
                        .backgroundColor(0x4CAF50)
                        .fontColor(0xFFFFFF)
                        .onClick { evt => this.generateMaskedVersion() }
                    
                    Row {
                        Button("导出原始版")
                            .layoutWeight(1)
                            .height(48)
                            .margin(right: 8)
                            .backgroundColor(0x9E9E9E)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.exportOriginal() }
                        
                        Button("导出脱敏版")
                            .layoutWeight(1)
                            .height(48)
                            .backgroundColor(0x1976D2)
                            .fontColor(0xFFFFFF)
                            .onClick { evt => this.exportMasked() }
                    }.width(100.percent)
                }
                .width(100.percent)
                .padding(16)
            }.width(100.percent)
        }
        .width(100.percent)
        .layoutWeight(1)
    }
    
    // ========== 行动项区域 ==========
    @Builder
    func buildActionItemsSection() {
        Column {
            // 行动项头部
            Row {
                Text("行动项")
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0x9C27B0)
                Blank()
            }
            .width(100.percent)
            .margin(bottom: 12)
            
            // 行动项列表 - 内联渲染
            this.buildActionItemsList()
        }
        .width(100.percent)
        .padding(16)
        .margin(left: 16, right: 16, bottom: 8)
        .backgroundColor(0xF3E5F5)
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)
    }
    
    @Builder
    func buildActionItemsList() {
        // 静态行动项展示
        Column {
            Text("暂无行动项")
                .fontSize(14)
                .fontColor(0x666666)
        }
        .width(100.percent)
    }
    
    func getActionStatusIcon(status: ActionStatus): String {
        match (status) {
            case Pending => "⏳"
            case InProgress => "🔄"
            case Completed => "✅"
            case Cancelled => "❌"
            case Overdue => "!"
        }
    }
    
    func getActionStatusText(status: ActionStatus): String {
        match (status) {
            case Pending => "待处理"
            case InProgress => "进行中"
            case Completed => "已完成"
            case Cancelled => "已取消"
            case Overdue => "已逾期"
        }
    }
    
    func getActionStatusColor(status: ActionStatus): UInt32 {
        match (status) {
            case Pending => 0x9E9E9E
            case InProgress => 0x2196F3
            case Completed => 0x4CAF50
            case Cancelled => 0x757575
            case Overdue => 0xF44336
        }
    }
    
    func toggleActionItemStatus(itemId: String): Unit {
        let item = getActionItem(itemId)
        match (item.status) {
            case Pending => 
                startActionItem(itemId)
                this.showToastMsg("行动项已开始")
            case InProgress =>
                completeActionItem(itemId)
                this.showToastMsg("行动项已完成")
            case _ => ()
        }
    }
    
    func extractActionItems(): Unit {
        let content = if (this.detailSummary.size > 0) { this.detailSummary } else { this.detailNotes }
        if (content.size == 0) {
            this.showToastMsg("请先添加会议内容")
            return
        }
        
        let items = generateAndSaveActionItems(this.selectedMeetingId, content)
        saveActionItems(items)
        this.showToastMsg("已提取 ${items.size} 个行动项")
    }
    
    func generateAISummary(): Unit {
        if (this.detailNotes.size == 0) {
            this.showToastMsg("请先添加会议记录")
            return
        }
        this.showLoadingWith("AI 纪要生成中...")
        this.pendingSummary = false
        this.pendingSummary = true
    }

    func finishAISummary(): Unit {
        let summary = summarize(this.detailNotes)
        this.detailSummary = summary
        updateAISummary(this.selectedMeetingId, summary)
        logDetailedEvent(AuditEventType.SummaryGenerated, this.selectedMeetingId, "AI_SUMMARY", "生成AI纪要", true)
        this.hideLoading()
        this.showToastMsg("AI 纪要生成完成，需重新审计")
        this.refreshDetailAndStats()
    }
    
    func performSensitiveAudit(): Unit {
        let content = if (this.detailSummary.size > 0) { this.detailSummary } else { this.detailNotes }
        if (content.size == 0) {
            this.showToastMsg("请先添加内容")
            return
        }
        let hits = sensitiveScan(content)
        let riskScore = computeRiskScore(hits)
        this.detailSensitiveCount = hits.size
        this.detailRiskScore = riskScore
        this.isAudited = true
        updateMeetingAuditInfo(this.selectedMeetingId, riskScore)
        logDetailedEvent(AuditEventType.AuditPerformed, this.selectedMeetingId, "AUDIT", "敏感审计完成", true)
        this.showToastMsg("审计完成: 发现 ${hits.size} 处敏感信息，风险 ${riskScore}/100")
        this.refreshDetailAndStats()
    }
    
    func generateMaskedVersion(): Unit {
        let content = if (this.detailSummary.size > 0) { this.detailSummary } else { this.detailNotes }
        if (content.size == 0) {
            this.showToastMsg("请先添加内容")
            return
        }
        let hits = sensitiveScan(content)
        var masked = content
        for (hit in hits) {
            let replacement = getMaskPattern(hit.typ)
            masked = replaceAll(masked, hit.value, replacement)
        }
        this.detailMaskedContent = masked
        this.detailRiskScore = computeRiskScore(hits)
        this.detailSensitiveCount = hits.size
        let versionId = "MASK-${currentTimestamp()}"
        let version = MinutesVersion(versionId, "masked", masked, currentTimestamp(), this.detailRiskScore)
        addMinutesVersion(this.selectedMeetingId, version)
        logDetailedEvent(AuditEventType.AuditPerformed, this.selectedMeetingId, "MASK", "生成脱敏版本", true)
        this.showToastMsg("脱敏版本已生成，需重新审计")
        this.refreshDetailAndStats()
    }
    
    func exportOriginal(): Unit {
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.requiresAudit) {
            this.showToastMsg("需重新审计，暂不可导出原文")
            return
        }
        let options = defaultExportOptions()
        let result = exportMeetingMinutes(this.selectedMeetingId, false, options)
        if (result.success) {
            this.showToastMsg("原始版已导出: ${result.fileName}")
        } else {
            this.showToastMsg("[!] ${result.error}")
        }
    }
    
    func exportMasked(): Unit {
        let meeting = getMeeting(this.selectedMeetingId)
        if (meeting.requiresAudit) {
            this.showToastMsg("需重新审计，暂不可导出")
            return
        }
        let options = defaultExportOptions()
        let result = exportMeetingMinutes(this.selectedMeetingId, true, options)
        if (result.success) {
            this.showToastMsg("脱敏版已导出: ${result.fileName}")
        } else {
            this.showToastMsg("[!] ${result.error}")
        }
    }

    func exportJsonData(): Unit {
        let json = exportAllDataToJSON()
        println("=== JSON 导出（全量）===")
        println(json)
        println("========================")
        this.showToastMsg("JSON 已生成并输出到控制台")
    }
    
    // ========== 审计日志页 ==========
    @Builder
    func buildLogPage() {
        Scroll {
            Column {
                Row {
                    Column {
                        Text("${this.totalLogs}")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x1976D2)
                        Text("日志总数")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }.layoutWeight(1)
                    
                    Column {
                        Text("${this.exportLogCount}")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0xFF9800)
                        Text("导出次数")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }.layoutWeight(1)
                    
                    Column {
                        Text("${this.alertLogCount}")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0xF44336)
                        Text("安全告警")
                            .fontSize(12)
                            .fontColor(0x666666)
                    }.layoutWeight(1)
                }
                .width(100.percent)
                .padding(16)
                .margin(16)
                .backgroundColor(0xFFFFFF)
                .borderRadius(12)
                
                Text("操作日志记录")
                    .fontSize(16)
                    .fontColor(0x333333)
                    .margin(left: 16, bottom: 8)
                
                Column {
                    Text("所有操作均已记录到审计日志中")
                        .fontSize(14)
                        .fontColor(0x666666)
                    Text("包括：会议创建、AI纪要生成、敏感审计、脱敏处理、导出操作等")
                        .fontSize(12)
                        .fontColor(0x999999)
                        .margin(top: 8)
                }
                .width(100.percent)
                .padding(16)
                .margin(left: 16, right: 16)
                .backgroundColor(0xFFFFFF)
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)

                // 导出 JSON
                Button("导出JSON（控制台输出）")
                    .width(90.percent)
                    .height(44)
                    .margin(top: 16)
                    .backgroundColor(0x1976D2)
                    .fontColor(0xFFFFFF)
                    .onClick { evt => this.exportJsonData() }

                // 日志列表
                Column {
                    Text("最新操作记录")
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                        .margin(bottom: 8)

                    this.buildAuditLogList()
                }
                .width(100.percent)
                .padding(16)
                .margin(16)
                .backgroundColor(0xFFFFFF)
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)
            }.width(100.percent)
        }
        .width(100.percent)
        .layoutWeight(1)
    }

    func getLogTime(index: Int64): String {
        if (index < this.logTimes.size) { return this.logTimes[index] }
        return ""
    }

    func getLogAction(index: Int64): String {
        if (index < this.logActions.size) { return this.logActions[index] }
        return ""
    }

    func getLogDetail(index: Int64): String {
        if (index < this.logDetails.size) { return this.logDetails[index] }
        return ""
    }

    func getLogMeeting(index: Int64): String {
        if (index < this.logMeetings.size) { return this.logMeetings[index] }
        return ""
    }

    func getLogUser(index: Int64): String {
        if (index < this.logUsers.size) { return this.logUsers[index] }
        return ""
    }

    @Builder
    func buildAuditLogList() {
        if (this.logCount == 0) {
            Text("暂无日志记录")
                .fontSize(13)
                .fontColor(0x999999)
        } else {
            this.buildAuditLogItem(0)
            this.buildAuditLogItem(1)
            this.buildAuditLogItem(2)
            this.buildAuditLogItem(3)
            this.buildAuditLogItem(4)
            this.buildAuditLogItem(5)
            this.buildAuditLogItem(6)
            this.buildAuditLogItem(7)
            this.buildAuditLogItem(8)
            this.buildAuditLogItem(9)
        }
    }

    @Builder
    func buildAuditLogItem(index: Int64) {
        Column {
            Text("${this.getLogTime(index)}  ${this.getLogUser(index)}")
                .fontSize(12)
                .fontColor(0x666666)
            Text(this.getLogAction(index))
                .fontSize(13)
                .fontColor(0x333333)
                .margin(top: 2)
            Text("会议ID: ${if (this.getLogMeeting(index).size > 0) { this.getLogMeeting(index) } else { "-" }}")
                .fontSize(11)
                .fontColor(0x999999)
                .margin(top: 2)
            if (this.getLogDetail(index).size > 0) {
                Text(this.getLogDetail(index))
                    .fontSize(11)
                    .fontColor(0x777777)
                    .margin(top: 2)
            }
        }
        .width(100.percent)
        .padding(top: 8, bottom: 8)
        .visibility(if (index < this.logCount) { Visibility.Visible } else { Visibility.None })
    }
    
    // 显示 Toast 提示
    func showToastMsg(msg: String): Unit {
        this.toastMessage = msg
        this.showToast = false
        this.showToast = true
    }

    // 显示加载状态
    func showLoading(): Unit {
        this.isLoading = true
        this.loadingMessage = "加载中..."
    }

    // 隐藏加载状态
    func hideLoading(): Unit {
        this.isLoading = false
        this.loadingMessage = ""
    }

    // 显示加载状态（自定义文案）
    func showLoadingWith(message: String): Unit {
        this.isLoading = true
        this.loadingMessage = message
    }
    
}

// ========== 辅助函数 ==========

func getMaskPattern(hitType: String): String {
    match (hitType) {
        case "PHONE" => "1**********"
        case "EMAIL" => "***@***.com"
        case "ID" => "******************"
        case "BANKCARD" => "****-****-****-****"
        case "IP" => "***.***.***.***"
        case "URL" => "https://***.***"
        case "SECRET" => "[REDACTED]"
        case "CUSTOMER" => "[客户名称]"
        case _ => "***"
    }
}

// replaceAll 使用 string_utils.cj 中的定义
