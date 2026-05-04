package ohos_app_cangjie_entry.pages

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.models.*
import ohos_app_cangjie_entry.components.*
import kit.PerformanceAnalysisKit.Hilog

/**
 * Unified Practice Page - Supports both offline and CDN modes.
 * 
 * MVP implementation for Hanzi writing practice demonstrating:
 * - Character loading (offline/CDN)
 * - Stroke detection and feedback
 * - Quiz completion tracking
 * - Mode switching
 */
@Entry
@Component
public class PrototypePage {
    // ============ State Variables ============
    @State var currentChar: String = "永"
    @State var inputChar: String = "永"
    @State var statusMessage: String = "请开始书写"
    @State var isLoading: Bool = true
    @State var useCDN: Bool = true  // Toggle for CDN mode

    // Canvas reference
    var canvasRef: Option<HanziWriterCanvas> = Option<HanziWriterCanvas>.None
    
    // ============ Configuration ============
    let CANVAS_SIZE: Int64 = 300
    
    /**
     * Get WriterConfig based on current mode.
     */
    func getConfig(): WriterConfig {
        var cfg = WriterConfig()
        cfg.width = CANVAS_SIZE
        cfg.height = CANVAS_SIZE
        cfg.strokeColor = "#2B2B2B"
        cfg.outlineColor = "#E0E0E0"
        cfg.drawingWidth = 20
        cfg.showOutline = true
        cfg.strokeAnimationSpeed = 1
        cfg.delayBetweenStrokes = 200
        
        // Add radical color for CDN mode (more characters have radical data)
        if (useCDN) {
            cfg.radicalColor = Some("#6B8E23")  // Bamboo Green
        }
        
        return cfg
    }
    
    /**
     * Get QuizOptions based on current mode.
     */
    func getQuizOptions(): QuizOptions {
        var opts = QuizOptions()
        
        if (useCDN) {
            opts.showHintAfterMisses = 2
            opts.leniency = 0.9
        } else {
            opts.showHintAfterMisses = 3
            opts.leniency = 1.0
        }
        
        opts.highlightOnComplete = true
        
        return opts
    }
    
    // ============ Utility Methods ============
    
    /**
     * Extract the first character from a string.
     * Uses toRuneArray() to correctly handle multi-byte Unicode characters like Chinese characters.
     * 
     * @param str - Input string
     * @return First character as String, or empty string if input is empty
     */
    func getFirstCharacter(str: String): String {
        if (str.isEmpty()) {
            return ""
        }
        
        // Convert string to Rune array
        let runeArray = str.toRuneArray()
        if (runeArray.size == 0) {
            return ""
        }
        
        // Extract first character and convert back to String
        return runeArray[0].toString()
    }
    
    // ============ Event Handlers ============
    
    func handleLoad() {
        isLoading = false
        statusMessage = "请书写 \"${currentChar}\""
        Hilog.info(0x0000, "CangjieApp", "[PrototypePage] Character loaded successfully")
    }
    
    func handleError(error: String) {
        isLoading = false
        statusMessage = "加载失败: ${error}"
        Hilog.error(0x0000, "CangjieApp", "[PrototypePage] Load error: ${error}")
    }
    
    func handleCorrectStroke(data: String) {
        // Parse stroke data (simplified for MVP)
        // In production, properly parse JSON
        statusMessage = "笔画正确!"
        Hilog.info(0x0000, "CangjieApp", "[PrototypePage] Correct stroke: ${data}")
        
        // TODO: 6.0.2升级适配  Add vibration feedback
        // vibrator.startVibration({ type: 'time', duration: 50 }, { usage: 'touch' })
    }
    
    func handleMistake(data: String) {
        statusMessage = "笔画错误，请重试"
        Hilog.warn(0x0000, "CangjieApp", "[PrototypePage] Mistake: ${data}")
    }
    
    func handleComplete(summary: String) {
        Hilog.info(0x0000, "CangjieApp", "[PrototypePage] Quiz complete: ${summary}")
        
        // Simple completion message
        statusMessage = "🎉 练习完成!"
        
        // In production, parse summary JSON to show detailed stats
    }
    
    func reloadCharacter() {
        if (currentChar.isEmpty()) {
            return
        }
        
        isLoading = true
        statusMessage = "加载中..."
        
        // Force rebuild by temporarily clearing
        let temp = currentChar
        currentChar = ""
        
        // Use setTimeout equivalent - for now, directly reload
        // In production, use proper async delay
        currentChar = temp
    }
    
    func loadNewCharacter() {
        if (inputChar.isEmpty()) {
            return
        }
        
        // Extract only the first character using utility method
        var newChar = getFirstCharacter(inputChar)
        Hilog.info(0x0000, "CangjieApp", "[PrototypePage] Load new character: ${newChar}")

        if (newChar == currentChar) {
            reloadCharacter()
        } else {
            isLoading = true
            statusMessage = "加载中..."
            currentChar = newChar
        }
    }
    
    // ============ UI Build ============
    
    public func build() {
        Column {
            // Title
            Text("汉字书写练习")
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .margin(top: 20.vp, bottom: 10.vp)
            
            // Mode Toggle Row
            Row {
                Text("离线模式")
                    .fontSize(14)
                    .fontColor( if (useCDN) { Color.Gray } else { Color(0x2B2B2B) })
                
                Toggle(ToggleType.Switch, isOn: useCDN)
                    .margin(left: 8.vp, right: 8.vp)
                    .onChange({ isOn =>
                        useCDN = isOn
                        reloadCharacter()
                    })
                
                Text("在线模式")
                    .fontSize(14)
                    .fontColor( if (useCDN) { Color(0x2B2B2B) } else { Color.Gray })
            }
            .margin(bottom: 10.vp)
            
            // Loading Indicator
            if (isLoading) {
                LoadingProgress()
                    .width(40.vp)
                    .height(40.vp)
                    .margin(bottom: 10.vp)
            }

            // 仓颉鸿蒙自定义组件不支持设置宽高等属性，因此这里使用Column来包裹
            Column {
                // Hanzi Writer Canvas
                HanziWriterCanvas (
                    char: currentChar,
                    useCDN: useCDN,
                    config: getConfig(),
                    quizOptions: getQuizOptions(),
                    onReady: { ref: HanziWriterCanvas => this.canvasRef = Some(ref) },
                    onLoad: { => handleLoad() },
                    onError: { error => handleError(error) },
                    onCorrectStroke: { data => handleCorrectStroke(data) },
                    onMistake: { data => handleMistake(data) },
                    onComplete: { summary => handleComplete(summary) }
                )
            }
            .width(CANVAS_SIZE.vp)
            .height(CANVAS_SIZE.vp)
            .margin(bottom: 15.vp)
            .backgroundColor(Color.White)
            .border(width: 1.vp, color: Color(0xE0E0E0))
            .borderRadius(8.vp)
            
            // Status Message
            Text(statusMessage)
                .fontSize(16)
                .fontColor(
                    if (statusMessage.contains("错误") || statusMessage.contains("失败")) {
                        Color(0xC4362E)
                    } else {
                        Color(0x6B8E23)
                    }
                )
                .margin(bottom: 15.vp)
            
            // Character Input (shown in CDN mode)
            if (useCDN) {
                Row {
                    TextInput(placeholder: "输入汉字", text: inputChar)
                        .width(120.vp)
                        .onChange({ value =>
                            if (!value.isEmpty()) {
                                inputChar = value
                            }
                        })
                    
                    Button("加载")
                        .margin(left: 10.vp)
                        .onClick({ evt =>
                            loadNewCharacter()
                        })
                }
                .margin(bottom: 15.vp)
            }
            
            // Action Buttons
            Row {
                Button("重新练习")
                    .onClick({ evt =>
                        reloadCharacter()
                    })
            }
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(Color(0xF7F4ED))  // Rice Paper
    }
}
