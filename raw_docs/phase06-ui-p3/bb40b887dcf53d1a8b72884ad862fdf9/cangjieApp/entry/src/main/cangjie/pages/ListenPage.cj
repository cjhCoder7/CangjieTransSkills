package ohos_app_cangjie_entry.pages

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.services.TextToSpeechService
import std.sync.Timer
import ohos_app_cangjie_entry.models.GameState
import std.collection.ArrayList
import std.random.Random
import ohos_app_cangjie_entry.models.CharacterInfo
import ohos.resource.__GenerateResource__
import kit.PerformanceAnalysisKit.*

enum AnswerStatus <: Equatable<AnswerStatus> {
    None | Correct | Wrong

    public operator func ==(right: AnswerStatus): Bool {
        match (this) {
            case None => match (right) { case None => true case _ => false }
            case Correct => match (right) { case Correct => true case _ => false }
            case Wrong => match (right) { case Wrong => true case _ => false }
        }
    }

    public operator func !=(right: AnswerStatus): Bool {
        return !(this == right)
    }
}

/**
 * 听力选项模型
 */
class ListenOption {
    var hanzi: String
    var pinyin: String

    public init(hanzi: String, pinyin: String) {
        this.hanzi = hanzi
        this.pinyin = pinyin
    }
}

/**
 * 听力测验题目模型
 * @param options 选项列表（包含汉字和拼音）
 * @param answerIndex 正确答案在 options 中的索引
 */
class ListenQuestion {
    var options: Array<ListenOption>
    var answerIndex: Int64

    public init(options: Array<ListenOption>, answerIndex: Int64) {
        this.options = options
        this.answerIndex = answerIndex
    }

    public func getPrompt(): String {
        if (answerIndex >= 0 && answerIndex < options.size) {
            return options[answerIndex].hanzi
        }
        return ""
    }
}

@Entry
@Component
class ListenPage {
    // ==================== 常量定义 ====================
    // ==================== 状态变量 ====================
    @State var questions: Array<ListenQuestion> = []
    @State var totalProgress: Int64 = 5
    @State var currentIndex: Int64 = 0
    @State var selectedIndex: Int64 = -1
    @State var answerStatus: AnswerStatus = AnswerStatus.None
    @State var showHint: Bool = false
    @State var isPlaying: Bool = false
    @State var isComplete: Bool = false

    // Animation States
    @State var rippleScale: Float32 = 1.0
    @State var rippleOpacity: Float64 = 0.0

    var ttsService: TextToSpeechService = TextToSpeechService.getInstance()

    private let INTRO_PROMPT = "欢迎跟随仓颉，一起听音辨形。点击风铃听读音，选择正确的汉字。"

    // ==================== 生命周期 ====================
    protected override func aboutToAppear() {
        initQuestions()
        ttsService.setOnPlaybackStart({ => 
            this.isPlaying = true 
            this.startRippleAnimation()
        })
        ttsService.setOnPlaybackComplete({ => this.isPlaying = false })
        
        // 播放欢迎语
        let _ = Timer.after(500 * Duration.millisecond, { =>
            if (!this.isComplete) {
                spawn(UIThread) {
                    ttsService.speak(INTRO_PROMPT)
                }
            }
            return Option<Duration>.None
        })
    }

    protected override func aboutToDisappear() {
        ttsService.stop()
        isPlaying = false
    }

    // ==================== 数据初始化 ====================
    func initQuestions() {
        if (questions.size > 0) { return }

        let levelChars = GameState.instance.currentLevelCharacters
        if (levelChars.size > 0) {
            questions = buildQuestionsFromLevel(levelChars)
        } else {
            Hilog.error(0x0000, "CangjieApp", "ListenPage: No character data available in GameState")
        }
    }

    func buildQuestionsFromLevel(levelChars: Array<CharacterInfo>): Array<ListenQuestion> {
        let count = levelChars.size / 3
        this.totalProgress = count

        var result = ArrayList<ListenQuestion>()
        
        if (count == 0) {
            Hilog.warn(0x0000, "CangjieApp", "ListenPage: Not enough characters for even one question (need at least 3)")
            return result.toArray()
        }

        let rnd = Random()
        
        // Copy and shuffle
        var pool = ArrayList<CharacterInfo>()
        pool.add(all: levelChars)
        
        // Fisher-Yates shuffle
        for (i in 0..pool.size) {
             let j = Int64(rnd.nextUInt64() % UInt64(pool.size))
             let temp = pool[i]
             pool[i] = pool[j]
             pool[j] = temp
        }

        // Generate questions from chunks
        for (i in 0..count) {
            let start = i * 3
            let c1 = pool[start]
            let c2 = pool[start+1]
            let c3 = pool[start+2]
            
            let opts = [
                 ListenOption(c1.character, c1.pinyin),
                 ListenOption(c2.character, c2.pinyin),
                 ListenOption(c3.character, c3.pinyin)
            ]
            
            let ansIdx = Int64(rnd.nextUInt64() % 3)
            result.add(ListenQuestion(opts, ansIdx))
        }

        return result.toArray()
    }



    // ==================== 业务逻辑 ====================
    func getCurrentQuestion(): Option<ListenQuestion> {
        if (currentIndex < questions.size) {
            return Some(questions[currentIndex])
        }
        return None
    }

    func playPrompt() {
        if (let Some(q) <- getCurrentQuestion()) {
            isPlaying = true
            ttsService.speak(q.getPrompt())
        }
    }

    func handleOptionSelect(index: Int64) {
        if (answerStatus != AnswerStatus.None) { return }
        Hilog.info(0x0000, "CangjieApp", "ListenPage: handleOptionSelect index=${index}, currentIndex=${currentIndex}")

        
        if (let Some(q) <- getCurrentQuestion()) {
            selectedIndex = index
            if (index == q.answerIndex) {
                answerStatus = AnswerStatus.Correct
                Hilog.info(0x0000, "CangjieApp", "ListenPage: Correct answer! scheduling advanceQuestion")
                Timer.after(700 * Duration.millisecond, { =>
                    Hilog.info(0x0000, "CangjieApp", "ListenPage: Timer triggered, calling advanceQuestion")
                    spawn(UIThread) {
                        this.advanceQuestion()
                    }
                    return Option<Duration>.None
                })
            } else {
                answerStatus = AnswerStatus.Wrong
                Timer.after(600 * Duration.millisecond, { =>
                    spawn(UIThread) {
                        this.answerStatus = AnswerStatus.None
                        this.selectedIndex = -1
                    }
                    return Option<Duration>.None
                })
            }
        }
    }

    func advanceQuestion() {
        Hilog.info(0x0000, "CangjieApp", "ListenPage: advanceQuestion called. Current index: ${currentIndex}, Total questions: ${questions.size}")
        answerStatus = AnswerStatus.None
        selectedIndex = -1
        showHint = false

        if (questions.size == 0) { 
            Hilog.warn(0x0000, "CangjieApp", "ListenPage: No questions loaded")
            return 
        }

        if (currentIndex + 1 < questions.size) {
            currentIndex += 1
            Hilog.info(0x0000, "CangjieApp", "ListenPage: Moved to next question. New index: ${currentIndex}")
        } else {
            Hilog.info(0x0000, "CangjieApp", "ListenPage: All questions completed")
            isComplete = true
            // 完成后停止播放
            ttsService.stop()
            isPlaying = false
        }
    }

    func restart() {
        currentIndex = 0
        isComplete = false
        answerStatus = AnswerStatus.None
        selectedIndex = -1
        showHint = false
        questions = [] // 清空以触发重新生成和洗牌
        initQuestions()
    }

    func startRippleAnimation() {
        rippleScale = 0.8
        rippleOpacity = 0.8
        
        // Create a breathing/pulsing effect
        getUIContext().animateTo(AnimateParam(duration: 1500, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Normal), { =>
            this.rippleScale = 1.4
            this.rippleOpacity = 0.0
        })
    }

    func toggleHint() {
        showHint = !showHint
    }

    // ==================== 选项数据访问器 ====================
    // 说明：@Builder 函数中不能使用 let 语句，需要通过辅助函数获取数据
    
    func getOptionAt(optIdx: Int64): String {
        if (let Some(q) <- getCurrentQuestion()) {
            if (optIdx < q.options.size) {
                return q.options[optIdx].hanzi
            }
        }
        return ""
    }

    func getPinyinAt(optIdx: Int64): String {
        if (let Some(q) <- getCurrentQuestion()) {
            if (optIdx < q.options.size) {
                return q.options[optIdx].pinyin
            }
        }
        return ""
    }

    func getOptionKey(optIdx: Int64): String {
        if (let Some(q) <- getCurrentQuestion()) {
            return "${q.options[optIdx].hanzi}_${optIdx}_${currentIndex}"
        }
        return "empty_${optIdx}_${currentIndex}"
    }

    // ==================== UI 构建器 ====================
    @Builder
    func buildTopBar() {
        Row {
            Image(@r(app.media.ic_nav_back_ink))
                .width(24.vp)
                .height(24.vp)
                .onClick ({ _ => getUIContext().getRouter().back() })

            Text("听音辨形")
                .fontSize(18.fp)
                .fontColor(0xFF2B2B2B)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .margin(right: 24.vp) // Balance the back button spacing
        }
        .width(100.percent)
        .padding(top: 12.vp, bottom: 12.vp)
        .alignItems(VerticalAlign.Center)
    }

    @Builder
    func buildProgressBar() {
        Row {
            ForEach(Array<Int64>(totalProgress, { i => i }), itemGenerator: { item: Int64, _: Int64 =>
                // 判断当前题目是否完成
                // item < currentIndex: 已经完成的题目（过去）
                // item == currentIndex && answerStatus == AnswerStatus.Correct: 当前题目答对（现在）
                // isComplete: 全部完成
                Image(if (isComplete || item < currentIndex || (item == currentIndex && answerStatus == AnswerStatus.Correct)) { @r(app.media.ic_progress_dot_active) } else { @r(app.media.ic_progress_dot_normal) })
                    .width(10.vp)
                    .height(10.vp)
                    .margin(left: 4.vp, right: 4.vp)
            })
        }
        .width(100.percent)
        .justifyContent(FlexAlign.Center)
        .margin(top: 20.vp)
    }

    @Builder
    func buildWindChime() {
        Column {
            Stack(alignContent: Alignment.Center) {
                if (isPlaying) {
                    Image(@r(app.media.img_ripple_ring))
                        .width(260.vp)
                        .height(260.vp)
                        .objectFit(ImageFit.Contain)
                        .offset(x: 0.vp, y: 40.vp)
                        .scale(x: rippleScale, y: rippleScale)
                        .opacity(rippleOpacity)
                }

                Image(@r(app.media.audio_bell))
                    .width(160.vp) 
                    .height(260.vp)
                    .objectFit(ImageFit.Contain)
            }
            .width(100.percent)
            .onClick ({ _ => playPrompt() })
        }
        .width(100.percent)
        .alignItems(HorizontalAlign.Center)
        .margin(top: 0.vp, bottom: 10.vp)
    }

    @Builder
    func buildOptionCard(text: String, pinyin!: String, index!: Int64) {
        Stack(alignContent: Alignment.Center) {
            Image(@r(app.media.card_frame_wood))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Fill)

            Column {
                if (showHint) {
                    Text(pinyin)
                        .fontSize(12.fp)
                        .fontColor(0xFF999999)
                        .margin(bottom: 4.vp)
                }

                Text(text)
                    .fontSize(32.fp)
                    .fontColor(0xFF1A1A1A)
                    .fontWeight(FontWeight.Bold)
                    .fontFamily("HarmonyOS Sans SC")
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(10.vp)

            if (answerStatus == AnswerStatus.Correct && selectedIndex == index) {
                Image(@r(app.media.img_stamp_excellent))
                    .width(60.percent)
                    .objectFit(ImageFit.Contain)
                    .position(x: 60.percent, y: 60.percent)
                    .markAnchor(x: 50.percent, y: 50.percent)
            }

            if (answerStatus == AnswerStatus.Wrong && selectedIndex == index) {
                Image(@r(app.media.img_ink_smudge))
                    .width(80.percent)
                    .objectFit(ImageFit.Contain)
                    .opacity(0.8)
            }
        }
        .width(28.percent)
        .aspectRatio(0.7)
        .onClick ({ _ => handleOptionSelect(index) })
    }

    @Builder
    func buildOptions() {
        Row {
            ForEach([0, 1, 2], itemGeneratorFunc: { optIdx: Int64, _: Int64 =>
                buildOptionCard(getOptionAt(optIdx), pinyin: getPinyinAt(optIdx), index: optIdx)
            }, keyGeneratorFunc: { optIdx: Int64, _: Int64 =>
                getOptionKey(optIdx)
            })
        }
        .width(100.percent)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin(bottom: 40.vp)
        .padding(left: 16.vp, right: 16.vp)
    }

    @Builder
    func buildHintButton() {
        Column {
            Image(@r(app.media.ic_hint_lantern))
                .width(40.vp)
                .height(40.vp)
                .objectFit(ImageFit.Contain)
                .margin(right: 8.vp)

            Text(if (showHint) { "已提示" } else { "点亮提示" })
                .fontSize(14.fp)
                .fontColor(if (showHint) { 0xFFC4362E } else { 0xFF5D4037 })
        }
        .padding(top: 10.vp, bottom: 10.vp, left: 20.vp, right: 20.vp)
        .onClick ({ _ => toggleHint() })
        .margin(bottom: 30.vp)
    }

    @Builder
    func buildCompleteView() {
        Column {
            Image(@r(app.media.img_stamp_excellent))
                .width(150.vp)
                .height(150.vp)
                .objectFit(ImageFit.Contain)
                .margin(bottom: 20.vp)

            Text("恭喜全部答对")
                .fontSize(24.fp)
                .fontColor(0xFF8B4513)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 40.vp)

            Button("再练一次")
                .onClick ({ _ => this.restart() })
                .width(160.vp)
                .height(48.vp)
                .fontSize(18.fp)
                .backgroundColor(0xFF8B4513)
                .fontColor(Color.White)
                .borderRadius(24.vp)
        }
        .width(100.percent)
        .height(100.percent)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
    }

    // ==================== 主布局 ====================
    func build() {
        Stack {
            Image(@r(app.media.bg_listen_page))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Cover)

            Column {
                buildTopBar()

                if (isComplete) {
                     buildCompleteView()
                } else if (let Some(_) <- getCurrentQuestion()) {
                    Column {
                        buildWindChime()
                        buildOptions()
                        buildProgressBar()
                    }
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Start)
                    .padding(top: 20.vp)
                    
                    buildHintButton()
                }
            }
            .width(100.percent)
            .height(100.percent)
            .padding(left: 20.vp, right: 20.vp)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(Color(0xF7F4ED))
    }
}
