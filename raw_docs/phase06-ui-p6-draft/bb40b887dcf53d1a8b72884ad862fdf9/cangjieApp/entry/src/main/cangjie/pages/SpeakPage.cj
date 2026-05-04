package ohos_app_cangjie_entry.pages

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.services.TextToSpeechService
import ohos_app_cangjie_entry.services.SpeechRecognizerService
import ohos_app_cangjie_entry.services.PinyinService
import ohos_app_cangjie_entry.services.SpeechListener
import std.collection.ArrayList
import ohos_app_cangjie_entry.models.GameState
import std.sync.Timer
import std.random.Random
import ohos.resource.__GenerateResource__
import kit.PerformanceAnalysisKit.*

class SpeakItem {
    var text: String
    var translation: String
    var pinyin: String

    public init(text: String, translation: String, pinyin: String) {
        this.text = text
        this.translation = translation
        this.pinyin = pinyin
    }
}

class SpeakSpeechListener <: SpeechListener {
    let onStartCallback: () -> Unit
    let onResultCallback: (String, Bool) -> Unit
    let onCompleteCallback: (String) -> Unit
    let onErrorCallback: (Int64, String) -> Unit

    public init(onStartCallback!: () -> Unit,
                onResultCallback!: (String, Bool) -> Unit,
                onCompleteCallback!: (String) -> Unit,
                onErrorCallback!: (Int64, String) -> Unit) {
        this.onStartCallback = onStartCallback
        this.onResultCallback = onResultCallback
        this.onCompleteCallback = onCompleteCallback
        this.onErrorCallback = onErrorCallback
    }

    public func onStart(): Unit {
        onStartCallback()
    }

    public func onResult(text: String, isFinal: Bool): Unit {
        onResultCallback(text, isFinal)
    }

    public func onComplete(text: String): Unit {
        onCompleteCallback(text)
    }

    public func onError(code: Int64, message: String): Unit {
        onErrorCallback(code, message)
    }
}

enum SpeakScore {
    | None
    | Perfect
    | Good
    | TryAgain

    public operator func ==(right: SpeakScore): Bool {
        match (this) {
            case None => match (right) { case None => true case _ => false }
            case Perfect => match (right) { case Perfect => true case _ => false }
            case Good => match (right) { case Good => true case _ => false }
            case TryAgain => match (right) { case TryAgain => true case _ => false }
        }
    }

    public operator func !=(right: SpeakScore): Bool {
        return !(this == right)
    }
}

@Entry
@Component
class SpeakPage {
    @State var items: Array<SpeakItem> = []
    @State var currentIndex: Int64 = 0
    @State var isRecording: Bool = false
    @State var isScoring: Bool = false
    @State var recognizedText: String = ""
    @State var statusMessage: String = "长按墨砚开始朗读"
    @State var scoreState: SpeakScore = SpeakScore.None
    @State var highlightIndices: Array<Int64> = []
    @State var showParticles: Bool = false
    @State var isComplete: Bool = false

    // Animation States
    @State var rippleScale: Float32 = 1.0
    @State var rippleOpacity: Float64 = 0.0

    var speechService: SpeechRecognizerService = SpeechRecognizerService.getInstance()
    var ttsService: TextToSpeechService = TextToSpeechService.getInstance()
    
    private let INTRO_PROMPT = "欢迎跟随仓颉，一起开口说。点击墨砚麦克风，大声读出汉字。"

    protected override func aboutToAppear() {
        initItems()
        
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
        speechService.stopListening()
        ttsService.stop()
        isRecording = false
        isScoring = false
    }

    func initItems() {
        if (items.size > 0) {
            return
        }

        let levelChars = GameState.instance.currentLevelCharacters
        if (levelChars.size > 0) {
             var newItems = ArrayList<SpeakItem>()
             let random = Random()
             for (charInfo in levelChars) {
                 if (charInfo.words.size > 0) {
                     // Randomly select a word
                     let index = random.nextInt64(charInfo.words.size)
                     let word = charInfo.words[index]
                     let pinyin = PinyinService.getInstance().pinyin(word.cn)
                     newItems.add(SpeakItem(word.cn, word.en, pinyin))
                 } else {
                     // Fallback to character if no words
                     let pinyin = PinyinService.getInstance().pinyin(charInfo.character)
                     newItems.add(SpeakItem(charInfo.character, charInfo.meaning.en, pinyin))
                 }
             }
             items = newItems.toArray()
        } else {
            Hilog.error(0x0000, "CangjieApp", "SpeakPage: No level characters found in GameState")
        }
    }

    func getCurrentItem(): Option<SpeakItem> {
        Hilog.info(0x0000, "CangjieApp", "SpeakPage: getCurrentItem called. currentIndex=${currentIndex}, items.size=${items.size}")
        if (currentIndex < items.size) {
            return Some(items[currentIndex])
        }
        return None
    }

    // ==================== 数据访问器 ====================
    // 说明：@Builder 函数中不能使用 let 语句，需要通过辅助函数获取数据
    
    func getCurrentText(): String {
        if (let Some(item) <- getCurrentItem()) {
            return item.text
        }
        return ""
    }

    func getCurrentPinyin(): String {
        if (let Some(item) <- getCurrentItem()) {
            return item.pinyin
        }
        return ""
    }

    func getCurrentTranslation(): String {
        if (let Some(item) <- getCurrentItem()) {
            return item.translation
        }
        return ""
    }

    func restart() {
        currentIndex = 0
        isComplete = false
        resetPracticeState("长按墨砚开始朗读")
        // Optionally shuffle items here if desired
    }

    func resetPracticeState(message: String) {
        isRecording = false
        isScoring = false
        recognizedText = ""
        scoreState = SpeakScore.None
        highlightIndices = []
        showParticles = false
        statusMessage = message
        // Reset animation states
        rippleScale = 1.0
        rippleOpacity = 0.0
    }

    func startRecording() {
        Hilog.info(0x0000, "CangjieApp", "SpeakPage: startRecording called. isRecording=${isRecording}, isScoring=${isScoring}")
        if (isRecording) {
            return
        }

        resetPracticeState("正在启动语音识别...")
        isRecording = true
        startRippleAnimation()

        let listener = SpeakSpeechListener(
            onStartCallback: { =>
                this.isRecording = true
                this.statusMessage = "请开始朗读"
                Hilog.info(0x0000, "CangjieApp", "SpeakPage: SpeechListener onStart")
            },
            onResultCallback: { text: String, isFinal: Bool =>
                this.recognizedText = text
                if (!isFinal) {
                    this.statusMessage = "识别中: ${text}"
                }
                Hilog.info(0x0000, "CangjieApp", "SpeakPage: SpeechListener onResult: ${text}, isFinal=${isFinal}")
            },
            onCompleteCallback: { text: String =>
                this.isRecording = false
                this.isScoring = false
                this.handleRecognition(text)
                Hilog.info(0x0000, "CangjieApp", "SpeakPage: SpeechListener onComplete: ${text}")
            },
            onErrorCallback: { code: Int64, message: String =>
                this.isRecording = false
                this.isScoring = false
                this.statusMessage = "识别错误 (${code})"
                Hilog.info(0x0000, "CangjieApp", "SpeakPage: SpeechListener onError: ${code}, ${message}")
            }
        )

        speechService.startListening(listener)
    }

    func stopRecording() {
        Hilog.info(0x0000, "CangjieApp", "SpeakPage: stopRecording called. isRecording=${isRecording}")
        if (!isRecording) {
            return
        }

        isRecording = false
        isScoring = true
        statusMessage = "识别中..."
        speechService.stopListening()
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

    func playDemoAudio() {
        if (isRecording || isScoring) {
            return
        }

        if (let Some(item) <- getCurrentItem()) {
            statusMessage = "示范朗读中..."
            ttsService.speak(item.text)
        }
    }

    func replayRecognition() {
        if (recognizedText.isEmpty()) {
            statusMessage = "还没有可回放的内容"
            return
        }
        statusMessage = "回放识别结果..."
        ttsService.speak(recognizedText)
    }

    func goNextItem() {
        if (items.size == 0) {
            return
        }

        if (currentIndex + 1 < items.size) {
            Hilog.info(0x0000, "CangjieApp", "SpeakPage: goNextItem updating info. currentIndex from ${currentIndex} to ${currentIndex + 1}")
            currentIndex += 1
            resetPracticeState("长按墨砚开始朗读")
        } else {
            isComplete = true
            isRecording = false
            isScoring = false
            speechService.stopListening()
            ttsService.stop()
        }
    }

    func handleRecognition(text: String) {
        if (let Some(item) <- getCurrentItem()) {
            let expected = item.text
            if (text.isEmpty()) {
                scoreState = SpeakScore.TryAgain
                highlightIndices = buildMissingIndices(expected, text)
                statusMessage = "没有识别到内容，请再试一次"
                return
            }

            let missing = buildMissingIndices(expected, text)
            if (text == expected) {
                scoreState = SpeakScore.Perfect
                highlightIndices = []
                statusMessage = "发音评价：妙"
                showParticles = true
                Timer.after(1200 * Duration.millisecond, { =>
                    spawn(UIThread) {
                        this.showParticles = false
                        this.goNextItem()
                    }
                    return Option<Duration>.None
                })
            } else if (missing.size == 0 || text.contains(expected)) {
                scoreState = SpeakScore.Good
                highlightIndices = []
                statusMessage = "发音评价：优"
                Timer.after(1000 * Duration.millisecond, { =>
                    spawn(UIThread) {
                        this.goNextItem()
                    }
                     return Option<Duration>.None
                })
            } else {
                scoreState = SpeakScore.TryAgain
                highlightIndices = missing
                statusMessage = "注意红圈字，再试一次"
            }
        }
    }

    func buildMissingIndices(expected: String, actual: String): Array<Int64> {
        var highlights = ArrayList<Int64>()
        let chars = expected.toRuneArray()
        for (i in 0..chars.size) {
            let charStr = chars[i].toString()
            if (!actual.contains(charStr)) {
                highlights.add(i)
            }
        }
        return highlights.toArray()
    }

    func isIndexHighlighted(index: Int64): Bool {
        for (i in 0..highlightIndices.size) {
            if (highlightIndices[i] == index) {
                return true
            }
        }
        return false
    }

    func getStatusColor(): Int64 {
        match (scoreState) {
            case SpeakScore.TryAgain => return 0xFFBC412B // Updated Red
            case SpeakScore.Perfect | SpeakScore.Good => return 0xFF6B8E23
            case _ => return 0xFF6B6B6B
        }
    }

    @Builder
    func buildTopBar() {
        Row {
            Image(@r(app.media.ic_back_brush))
                .width(24.vp)
                .height(24.vp)
                .onClick ({ evt => getUIContext().getRouter().back() })

            Text("朗读练习")
                .fontSize(18.fp)
                .fontColor(0xFF2B2B2B)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
        }
        .width(100.percent)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
    }

    @Builder
    func buildCharacterRow() {
        Row {
            ForEach(getCurrentText().toRuneArray(), itemGeneratorFunc: { item: Rune, index: Int64 =>
                Stack(alignContent: Alignment.Center) {
                    if (isIndexHighlighted(index)) {
                        Image(@r(app.media.highlight_error_brush))
                            .width(60.vp) // Slightly larger for the circle stroke
                            .height(60.vp)
                            .objectFit(ImageFit.Contain)
                            .transition(TransitionEffect.OPACITY.animation(AnimateParam(duration: 300, curve: Curve.EaseIn)))
                    }

                    Text(item.toString())
                        .fontSize(42.fp)
                        .fontColor(0xFF2B2B2B)
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("STKaiti") // Use Kaiti font
                }
                .margin(left: 4.vp, right: 4.vp)
            }, keyGeneratorFunc: { item: Rune, index: Int64 => 
                "${index}_${item}_${currentIndex}" 
            })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
    }

    @Builder
    func buildStampOverlay() {
        if (scoreState == SpeakScore.Perfect) {
            Image(@r(app.media.stamp_perfect))
                .width(34.percent)
                .objectFit(ImageFit.Contain)
                .position(x: 72.percent, y: 76.percent)
                .markAnchor(x: 50.percent, y: 50.percent)
                .transition(TransitionEffect.scale(ScaleOptions(x: 2.0, y: 2.0)).combine(TransitionEffect.OPACITY)
                    .animation(AnimateParam(duration: 500, curve: Curve.Friction)))
        } else if (scoreState == SpeakScore.Good) {
            Image(@r(app.media.stamp_good))
                .width(34.percent)
                .objectFit(ImageFit.Contain)
                .position(x: 72.percent, y: 76.percent)
                .markAnchor(x: 50.percent, y: 50.percent)
                .transition(TransitionEffect.scale(ScaleOptions(x: 2.0, y: 2.0)).combine(TransitionEffect.OPACITY)
                    .animation(AnimateParam(duration: 500, curve: Curve.Friction)))
        } else if (scoreState == SpeakScore.TryAgain) {
            Image(@r(app.media.stamp_try_again))
                .width(34.percent)
                .objectFit(ImageFit.Contain)
                .position(x: 72.percent, y: 76.percent)
                .markAnchor(x: 50.percent, y: 50.percent)
                .transition(TransitionEffect.scale(ScaleOptions(x: 2.0, y: 2.0)).combine(TransitionEffect.OPACITY)
                    .animation(AnimateParam(duration: 500, curve: Curve.Friction)))
        }

        if (scoreState == SpeakScore.Perfect && showParticles) {
            Image(@r(app.media.particle_gold_dot))
                .width(12.vp)
                .height(12.vp)
                .position(x: 62.percent, y: 64.percent)
                .markAnchor(x: 50.percent, y: 50.percent)
                .transition(TransitionEffect.translate(TranslateOptions(y: 20.vp)).combine(TransitionEffect.OPACITY)
                     .animation(AnimateParam(duration: 800, curve: Curve.EaseOut)))

            Image(@r(app.media.particle_gold_dot))
                .width(10.vp)
                .height(10.vp)
                .position(x: 80.percent, y: 66.percent)
                .markAnchor(x: 50.percent, y: 50.percent)
                .transition(TransitionEffect.translate(TranslateOptions(y: 30.vp)).combine(TransitionEffect.OPACITY)
                     .animation(AnimateParam(duration: 1000, curve: Curve.EaseOut)))

            Image(@r(app.media.particle_gold_dot))
                .width(8.vp)
                .height(8.vp)
                .position(x: 74.percent, y: 58.percent)
                .markAnchor(x: 50.percent, y: 50.percent)
                .transition(TransitionEffect.translate(TranslateOptions(y: 15.vp)).combine(TransitionEffect.OPACITY)
                     .animation(AnimateParam(duration: 600, curve: Curve.EaseOut)))
        }
    }

    @Builder
    func buildScrollSection() {
        Stack(alignContent: Alignment.Center) {
            Image(@r(app.media.bg_text_scroll))
                .width(80.percent)
                .height(100.percent)
                .objectFit(ImageFit.Fill)

            Column {
                Row {
                    Image(@r(sys.media.ohos_ic_public_sound))
                        .width(20.vp)
                        .height(20.vp)
                        .margin(left: 8.vp)
                        .onClick ({ evt => playDemoAudio() })
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)

                Text(getCurrentPinyin())
                    .fontSize(20.fp)
                    .fontColor(0xFF7A7A7A)
                    .margin(top: 12.vp)
                    .textAlign(TextAlign.Center)

                buildCharacterRow()

                Text(getCurrentTranslation())
                    .fontSize(15.fp)
                    .fontColor(0xFF5A5A5A) // Design color
                    .margin(top: 24.vp) // Increased margin
                    .textAlign(TextAlign.Center)
                    .padding(left: 16.vp, right: 16.vp)
            }
            .width(70.percent)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(top: 40.vp, bottom: 40.vp)

            buildStampOverlay()
        }
        .width(100.percent)
        .height(44.percent) // Adjusted to prevent overflow
    }

    @Builder
    func buildProgressBar() {
        Row {
            ForEach(Array<Int64>(items.size, { i => i }), itemGeneratorFunc: { item: Int64, _: Int64 =>
                // 判断当前题目是否完成
                // item < currentIndex: 已经完成的题目（过去）
                // item == currentIndex && (scoreState == SpeakScore.Perfect || scoreState == SpeakScore.Good): 当前题目答对（现在）
                // isComplete: 全部完成
                Image(if (isComplete || item < currentIndex || (item == currentIndex && (scoreState == SpeakScore.Perfect || scoreState == SpeakScore.Good))) { @r(app.media.ic_progress_dot_active) } else { @r(app.media.ic_progress_dot_normal) })
                    .width(10.vp)
                    .height(10.vp)
                    .margin(left: 4.vp, right: 4.vp)
            }, keyGeneratorFunc: { item: Int64, _: Int64 => "${item}" })
        }
        .width(100.percent)
        .justifyContent(FlexAlign.Center)
        .margin(top: 20.vp)
    }

    @Builder
    func buildMicSection() {
        Column {
            Stack(alignContent: Alignment.Center) {
                // Ripple Effect
                if (isRecording) {
                    Image(@r(app.media.img_ripple_ring))
                        .width(200.vp) // Increased size
                        .height(200.vp)
                        .objectFit(ImageFit.Contain)
                        .scale(x: rippleScale, y: rippleScale)
                        .opacity(rippleOpacity)
                }

                Image(if (isRecording) { @r(app.media.btn_mic_inkstone_pressed) } else { @r(app.media.btn_mic_inkstone_idle) })
                    .width(110.vp)
                    .height(110.vp)
                    .objectFit(ImageFit.Contain)
//                    .hitTestBehavior(HitTestMode.None)   // TODO: 6.0.2升级适配 待修复
            }
            .width(200.vp)
            .height(200.vp)
//            .gesture(
//                LongPressGesture(repeat: false)
//                    .onAction({ _ =>
//                        Hilog.info(0x0000, "CangjieApp", "SpeakPage: LongPressGesture onAction")
//                        this.startRecording()
//                    })
//                    .onActionEnd({ _ =>
//                        Hilog.info(0x0000, "CangjieApp", "SpeakPage: LongPressGesture onActionEnd")
//                        this.stopRecording()
//                    })
//            )     // TODO: 6.0.2升级适配  待修复
            .onClick ({ evt =>
                Hilog.info(0x0000, "CangjieApp", "SpeakPage: onClick triggered")
                this.statusMessage = "请长按识别"
            })

            Text(statusMessage)
                .fontSize(14.fp)
                .fontColor(getStatusColor())
                .margin(top: 4.vp)
        }
        .width(100.percent)
        .alignItems(HorizontalAlign.Center)
    }

    @Builder
    func buildFooterActions() {
        Row {
            Column {
                Image(@r(app.media.ic_replay_brush))
                    .width(24.vp)
                    .height(24.vp)
                    .objectFit(ImageFit.Contain)
                    .opacity(0.7)

                Text("回放")
                    .fontSize(12.fp)
                    .fontColor(0xFF7A7A7A)
                    .margin(top: 6.vp)
            }
            .alignItems(HorizontalAlign.Center)
            .onClick ({ evt => replayRecognition() })
            .visibility(if (recognizedText.isEmpty()) {Visibility.Hidden} else {Visibility.Visible})
        }
        .width(100.percent)
        .justifyContent(FlexAlign.Center)
        .padding(left: 40.vp, right: 40.vp)
    }

    @Builder
    func buildCompleteView() {
        Column {
            Image(@r(app.media.stamp_perfect))
                .width(180.vp)
                .objectFit(ImageFit.Contain)
                .margin(bottom: 24.vp)

            Text("恭喜完成所有练习")
                .fontSize(24.fp)
                .fontColor(0xFF2B2B2B)
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

    func build() {
        Stack {
            Image(@r(app.media.bg_xuan_paper))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Cover)

            Column {
                buildTopBar()
                
                Blank().height(30.vp) 

                if (isComplete) {
                    buildCompleteView()
                } else {
                    if (let Some(_) <- getCurrentItem()) {
                        buildScrollSection()
                        buildProgressBar()
                    }

                    Blank().layoutWeight(1) // Push content up

                    buildMicSection()
                    
                    Blank().height(30.vp) // Space between mic and footer

                    buildFooterActions()
                }
                
                Blank().height(30.vp) // Bottom padding
            }
            .width(100.percent)
            .height(100.percent)
            .padding(left: 20.vp, right: 20.vp, top: 12.vp)
            .alignItems(HorizontalAlign.Center)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(Color(0xFFF2EFE6)) // Updated background color
    }
}
