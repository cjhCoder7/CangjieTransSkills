package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*

// ============================================================================
// TranscriptionPage - 实时转写页面组件
// 会中实时语音转文字，并进行敏感信息检测
// ============================================================================

@Component
class TranscriptionPage {
    // 会议ID
    private var meetingId: String = ""
    
    // 回调
    private var onComplete: (String) -> Unit = { _ => () }
    private var onCancel: () -> Unit = { => () }
    
    @State var status: String = "准备就绪"
    @State var isRecording: Bool = false
    @State var isPaused: Bool = false
    @State var currentRiskScore: Int64 = 0
    @State var sensitiveCount: Int64 = 0
    @State var duration: Int64 = 0
    @State var segments: ArrayList<TranscriptSegment> = ArrayList<TranscriptSegment>()
    @State var showRiskAlert: Bool = false
    @State var riskAlertMessage: String = ""
    @State var manualInput: String = ""
    @State var showManualInput: Bool = false
    
    public func setMeetingId(id: String): TranscriptionPage {
        this.meetingId = id
        return this
    }
    
    public func setOnComplete(callback: (String) -> Unit): TranscriptionPage {
        this.onComplete = callback
        return this
    }
    
    public func setOnCancel(callback: () -> Unit): TranscriptionPage {
        this.onCancel = callback
        return this
    }
    
    func build() {
        Column {
            // 状态栏
            this.buildStatusBar()
            
            // 风险告警条
            if (this.showRiskAlert) {
                this.buildRiskAlertBar()
            }
            
            // 转写内容区域
            this.buildTranscriptArea()
            
            // 手动输入区域（用于演示）
            if (this.showManualInput) {
                this.buildManualInputArea()
            }
            
            // 控制按钮区域
            this.buildControlButtons()
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xF5F5F5)
        .onAppear {
            this.initTranscription()
        }
    }
    
    // 初始化转写
    func initTranscription(): Unit {
        // 设置回调
        setTranscriptionCallbacks(
            { segment => this.onNewSegment(segment) },
            { score, msg => this.onRiskDetected(score, msg) },
            { status => this.onStatusChange(status) }
        )
        
        // 初始化语音识别
        initSpeechRecognition()
        this.status = "准备就绪，点击开始录制"
    }
    
    func onNewSegment(segment: TranscriptSegment): Unit {
        this.segments.append(segment)
        this.currentRiskScore = this.currentRiskScore + segment.riskScore
        this.sensitiveCount = this.sensitiveCount + segment.sensitiveHits
    }
    
    func onRiskDetected(score: Int64, message: String): Unit {
        this.riskAlertMessage = message
        this.showRiskAlert = true
    }
    
    func onStatusChange(newStatus: TranscriptionStatus): Unit {
        this.status = match (newStatus) {
            case Idle => "空闲"
            case Preparing => "准备中..."
            case Recording => "录制中"
            case Paused => "已暂停"
            case Processing => "处理中..."
            case Completed => "已完成"
            case Error => "发生错误"
        }
    }
    
    // ========== 状态栏 ==========
    @Builder
    func buildStatusBar() {
        Column {
            Row {
                // 录制状态指示
                Column {
                    Text(if (this.isRecording && !this.isPaused) { "●" } else if (this.isPaused) { "||" } else { "○" })
                        .fontSize(24)
                }
                .width(40)
                
                Column {
                    Text(this.status)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                    
                    Text("时长: ${this.formatDuration(this.duration)}")
                        .fontSize(12)
                        .fontColor(0x666666)
                        .margin(top: 4)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                
                // 风险分显示
                Column {
                    Text("风险分")
                        .fontSize(12)
                        .fontColor(0x666666)
                    Text("${this.currentRiskScore}")
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.getRiskColor(this.currentRiskScore))
                }
                .width(80)
                .alignItems(HorizontalAlign.Center)
                
                // 敏感命中数
                Column {
                    Text("敏感项")
                        .fontSize(12)
                        .fontColor(0x666666)
                    Text("${this.sensitiveCount}")
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0xF44336)
                }
                .width(80)
                .alignItems(HorizontalAlign.Center)
            }
            .width(100.percent)
            .padding(16)
        }
        .width(100.percent)
        .backgroundColor(0xFFFFFF)
    }
    
    // ========== 风险告警条 ==========
    @Builder
    func buildRiskAlertBar() {
        Row {
            Text("[!]")
                .fontSize(20)
                .margin(right: 12)
            
            Text(this.riskAlertMessage)
                .fontSize(14)
                .fontColor(0xFFFFFF)
                .layoutWeight(1)
            
            Text("✕")
                .fontSize(18)
                .fontColor(0xFFFFFF)
                .onClick { evt =>
                    this.showRiskAlert = false
                }
        }
        .width(100.percent)
        .padding(12)
        .backgroundColor(0xF44336)
    }
    
    // ========== 转写内容区域 ==========
    @Builder
    func buildTranscriptArea() {
        Scroll {
            Column {
                // 空状态提示
                this.buildEmptyState()
                
                // 转写片段列表
                this.buildSegmentList()
            }
            .width(100.percent)
            .padding(16)
        }
        .width(100.percent)
        .layoutWeight(1)
    }
    
    @Builder
    func buildEmptyState() {
        if (this.segments.size == 0) {
            Column {
                Text("MIC")
                    .fontSize(48)
                    .margin(bottom: 16)
                Text("点击下方按钮开始录制")
                    .fontSize(16)
                    .fontColor(0x999999)
                Text("或使用手动输入模式进行演示")
                    .fontSize(14)
                    .fontColor(0xCCCCCC)
                    .margin(top: 8)
            }
            .width(100.percent)
            .padding(top: 60)
            .alignItems(HorizontalAlign.Center)
        }
    }
    
    @Builder
    func buildSegmentList() {
        // 转写内容展示区
        Column {
            if (this.segments.size > 0) {
                Text("已转写 ${this.segments.size} 个片段")
                    .fontSize(14)
                    .fontColor(0x666666)
            }
        }
        .width(100.percent)
    }
    
    // ========== 手动输入区域 ==========
    @Builder
    func buildManualInputArea() {
        Column {
            Text("手动输入（演示模式）")
                .fontSize(12)
                .fontColor(0x666666)
                .margin(bottom: 8)
            
            Row {
                TextInput(text: this.manualInput, placeholder: "输入测试文本...")
                    .layoutWeight(1)
                    .height(40)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(8)
                    .padding(left: 12, right: 12)
                    .onChange { value =>
                        this.manualInput = value
                    }
                
                Button("添加")
                    .width(60)
                    .height(40)
                    .margin(left: 8)
                    .backgroundColor(0x1976D2)
                    .fontColor(0xFFFFFF)
                    .onClick { evt =>
                        if (this.manualInput.size > 0) {
                            simulateTranscriptSegment(this.manualInput)
                            this.manualInput = ""
                        }
                    }
            }
            .width(100.percent)
            
            // 快速测试按钮
            Row {
                Button("测试手机号")
                    .height(32)
                    .margin(right: 8, top: 8)
                    .backgroundColor(0xEEEEEE)
                    .fontColor(0x666666)
                    .onClick { evt =>
                        simulateTranscriptSegment("请联系张三，手机号13812345678")
                    }
                
                Button("测试身份证")
                    .height(32)
                    .margin(right: 8, top: 8)
                    .backgroundColor(0xEEEEEE)
                    .fontColor(0x666666)
                    .onClick { evt =>
                        simulateTranscriptSegment("身份证号110101199001011234")
                    }
                
                Button("测试密钥")
                    .height(32)
                    .margin(top: 8)
                    .backgroundColor(0xEEEEEE)
                    .fontColor(0x666666)
                    .onClick { evt =>
                        simulateTranscriptSegment("API密钥: api_key=sk_test_12345")
                    }
            }
            .width(100.percent)
        }
        .width(100.percent)
        .padding(16)
        .backgroundColor(0xE8F5E9)
    }
    
    // ========== 控制按钮区域 ==========
    @Builder
    func buildControlButtons() {
        Column {
            // 主控制按钮
            Row {
                if (!this.isRecording) {
                    // 开始按钮
                    Button("🎤 开始录制")
                        .layoutWeight(1)
                        .height(56)
                        .backgroundColor(0xF44336)
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            this.startRecording()
                        }
                } else if (this.isPaused) {
                    // 继续按钮
                    Button("继续")
                        .layoutWeight(1)
                        .height(56)
                        .margin(right: 8)
                        .backgroundColor(0x4CAF50)
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            this.resumeRecording()
                        }
                    
                    Button("结束")
                        .layoutWeight(1)
                        .height(56)
                        .backgroundColor(0x1976D2)
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            this.stopRecording()
                        }
                } else {
                    // 暂停按钮
                    Button("暂停")
                        .layoutWeight(1)
                        .height(56)
                        .margin(right: 8)
                        .backgroundColor(0xFF9800)
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            this.pauseRecording()
                        }
                    
                    Button("结束")
                        .layoutWeight(1)
                        .height(56)
                        .backgroundColor(0x1976D2)
                        .fontColor(0xFFFFFF)
                        .onClick { evt =>
                            this.stopRecording()
                        }
                }
            }
            .width(100.percent)
            
            // 辅助按钮
            Row {
                Button("📌 打点")
                    .layoutWeight(1)
                    .height(44)
                    .margin(top: 12, right: 8)
                    .backgroundColor(0xEEEEEE)
                    .fontColor(0x666666)
                    .onClick { evt =>
                        addKeyMoment("用户标记")
                        this.status = "已添加关键点标记"
                    }
                
                Button(if (this.showManualInput) { "隐藏输入" } else { "手动输入" })
                    .layoutWeight(1)
                    .height(44)
                    .margin(top: 12)
                    .backgroundColor(0xEEEEEE)
                    .fontColor(0x666666)
                    .onClick { evt =>
                        this.showManualInput = !this.showManualInput
                    }
            }
            .width(100.percent)
        }
        .width(100.percent)
        .padding(16)
        .backgroundColor(0xFFFFFF)
    }
    
    // ========== 录制控制 ==========
    
    func startRecording(): Unit {
        startTranscription(this.meetingId)
        this.isRecording = true
        this.isPaused = false
        this.startDurationTimer()
    }
    
    func pauseRecording(): Unit {
        pauseTranscription()
        this.isPaused = true
    }
    
    func resumeRecording(): Unit {
        resumeTranscription()
        this.isPaused = false
    }
    
    func stopRecording(): Unit {
        let session = stopTranscription()
        this.isRecording = false
        this.isPaused = false
        
        // 生成完整转写文本
        let fullText = getFullTranscript()
        
        // 更新会议记录
        if (this.meetingId.size > 0) {
            updateRawNotes(this.meetingId, fullText)
        }
        
        // 回调
        this.onComplete(fullText)
    }
    
    func startDurationTimer(): Unit {
        // 简化实现：实际应使用定时器
        this.duration = 0
    }
    
    // ========== 辅助函数 ==========
    
    func formatDuration(ms: Int64): String {
        let totalSeconds = ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "${minutes}:${if (seconds < 10) { "0" } else { "" }}${seconds}"
    }
    
    func getRiskColor(score: Int64): UInt32 {
        if (score >= 60) {
            return 0xF44336
        } else if (score >= 30) {
            return 0xFF9800
        } else {
            return 0x4CAF50
        }
    }
}

