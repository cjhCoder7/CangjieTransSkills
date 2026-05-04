package editor_kit

from ohos import base.*
from ohos import concurrency.*
from ohos import component.*
from ohos import measure.*
from ohos import pasteboard.*
from ohos import state_manage.*
from ohos import state_macro_manage.*
from std import collection.*
from std import math.*
from std import time.*
import editor_kit.widget.*
import editor_kit.editorKitUtils.*
import treesitter.*

public class EditorKitController {

    public EditorKitController(
        private var width!: Float64,
        private var height!: Float64,
        private var language!: LANGUAGETYPE = LANGUAGETYPE.C,
        private var text!: String = "",
        private var fontSize!: Int64 = 16,
        private var theme!: THEMENAMETYPE = THEMENAMETYPE.DARCULA,
        private var tabLen!: Int64 = 4,
        private var lineColor!: UInt32 = 0X808080,
        private var lineBGColor!: UInt32 = 0xFAFAFA
    ) {}

    private var TOKEN = "!@#$%^&*()_+-={}|[]:;'<>/<.? \r\n\t"
    // 创建editorKit 实例
    private var editorKit: ?EditorKit = None
    // 创建高亮实例
    var editor: SyntaxHighlightEditText = SyntaxHighlightEditText()
    // 创建自动补全实例
    var autoComplete: AutoCompletePlugin = AutoCompletePlugin()

    // 对应 editorKit 中状态变量
    private var textCompWidth = 0.0
    private var textCompHeight = 0.0
    private var valid: Bool = false
    private var suggestionList: ObservedArrayList<String> = ObservedArrayList<String>()
    private var lineHeightArray: ObservedArrayList<Int64> = ObservedArrayList<Int64>()

    private var spanHeight = 0.0
    private let padLen = 3.0
    private let dividerCompWidth = 1.0
    private var position: Int64 = 0
    private var tempIndex: Int32 =0
    private var lineCount = 0
    private var lines: ArrayList<LineInfo> = ArrayList<LineInfo>()
    private var suffix = ""

    // 绑定 editorKit
    func bindEditorKit(editorKit: EditorKit) {
        this.editorKit = editorKit
        this.editorKit.getOrThrow().setHeight(this.height)
        this.editorKit.getOrThrow().setWidth(this.width)
        this.editorKit.getOrThrow().setLineColor(this.lineColor)
        this.editorKit.getOrThrow().setLineBGColor(this.lineBGColor)
    }

    func initRichEditor() {
        if (this.editorKit.isNone()) {
            return
        }

        this.editorKit.getOrThrow().controller.addTextSpan(
            value: this.text,
        )
        updateDisplay()
        this.editorKit.getOrThrow().setValid(this.valid)
        this.editorKit.getOrThrow().setSuggestionList(this.suggestionList)
    }

    // 设置语言和文本内容
    public func setLanguageAndText(language: LANGUAGETYPE, text: String) {
        setPopWindowHidden()
        if (this.editorKit.isNone()) {
            return
        }

        this.language = language
        this.text = text
        this.editorKit.getOrThrow().controller.deleteSpans()
        this.editorKit.getOrThrow().controller.addTextSpan(
            value: this.text,
        )
        updateDisplay()
    }

    private func updateDisplay() {
        getLines()
        updateEditorSpanStyle()
        updateAutoComplete()
    }

    // 设置文本内容
    public func setText(text: String):Unit {
        setPopWindowHidden()
        if (this.editorKit.isNone()) {
            return
        }
        this.text = text
        this.editorKit.getOrThrow().controller.deleteSpans()
        this.editorKit.getOrThrow().controller.addTextSpan(
            value: this.text,
        )
        updateDisplay()
    }

    // 设置缩进长度
    public func setTabLen(tabLen: Int64): Unit {
        setPopWindowHidden()
        this.tabLen = tabLen
    }

    // 设置字体
    public func setFontSize(fontSize: Int64): Unit {
        setPopWindowHidden()
        this.fontSize = fontSize
        getLines()
        updateEditorSpanStyle()
    }

    // 设置主题
    public func setTheme(theme: THEMENAMETYPE): Unit {
        setPopWindowHidden()
        this.theme = theme
        updateEditorSpanStyle()
    }

    // 设置宽度
    public func setWidth(width: Float64): Unit {
        setPopWindowHidden()
        this.width = width
        getLines()
    }

    // 设置高度
    public func setHeight(height: Float64): Unit {
        setPopWindowHidden()
        if (this.editorKit.isNone()) {
            return
        }

        this.height = height
        getHeight()
        this.textCompHeight = getCompHeight(this.textCompHeight, this.height)
        this.editorKit.getOrThrow().setTextCompHeight(this.textCompHeight)
        this.editorKit.getOrThrow().setHeight(this.height)
    }

    private func getCompHeight(flexHeight: Float64, scrollHeight: Float64): Float64 {
        if(flexHeight < scrollHeight) {
            return scrollHeight
        } else {
            return flexHeight
        }
    }

    func setPopWindowHidden() {
        if (this.editorKit.isNone()) {
            return
        }
        this.editorKit.getOrThrow().setValid(false)
    }


    // 计算当前文本编辑器内文本的行信息（行起始位置，value）
    func getLines() {
        if (this.editorKit.isNone()) {
            return
        }

        var array = text.split("\n")
        var count = 0
        this.lines.clear()
        this.lineHeightArray.clear()
        calcTextHeight()
        if (array.size == 0) {
            this.lineCount = 1
            getTextCompWidth()
            this.lines.append(LineInfo(0))
            this.lines[0].setValue("")
            this.lines[0].setLineNo(1)
            this.lines[0].setHeight(this.spanHeight / 3.25)
            this.lineHeightArray.append(1)
            getHeight()
            this.editorKit.getOrThrow().setTextCompHeight(this.textCompHeight)
            this.editorKit.getOrThrow().setTextCompWidth(this.textCompWidth)
            this.editorKit.getOrThrow().setlineHeightArray(this.lineHeightArray)
            return
        }
        this.lineCount = array.size
        getTextCompWidth()
        for (i in 0..array.size) {
            this.lines.append(LineInfo(count))
            if (array.size == i + 1 ) {
                this.lines[i].setValue(array[i])
                count += array[i].size
            } else {
                this.lines[i].setValue(array[i] + "\n")
                count += (array[i].size + 1)
            }
            let res = calcTextSize(array[i])
            this.lines[i].setLineNo(res[0])
            this.lineHeightArray.append(res[0])
            if (i == 0) {
                this.lines[i].setHeight(res[1])
            } else {
                this.lines[i].setHeight(res[1] + lines[i-1].getHeight())
            }
        }
        getHeight()
        this.editorKit.getOrThrow().setTextCompHeight(this.textCompHeight)
        this.editorKit.getOrThrow().setTextCompWidth(this.textCompWidth)
        this.editorKit.getOrThrow().setlineHeightArray(this.lineHeightArray)
    }

    // 计算单行文本高度
    private func calcTextHeight() {
        let context: CJMeasureContext = CJMeasureContext(textContent: "hello",
                                                        fontFamily: "HarmonyOS Sans", constraintWidth: this.width.vp,
                                                        fontSize: this.fontSize.vp, lineHeight: 0.vp,
                                                        baselineOffset: 0.vp, letterSpacing: 0.vp)
        this.spanHeight = Measure.MeasureTextSize(context).height
    }

    // 获取行号宽度
    private func getTextCompWidth() {
        var digitCount = 3
        var widestNumber = 0
        var widestWidth = 0.0

        if (lineCount > 999) {
            digitCount = 4
        }

        for (i in 0..10) {
            let context: CJMeasureContext = CJMeasureContext(textContent: i.toString(),
                                                            fontFamily: "HarmonyOS Sans", constraintWidth: 0.vp,
                                                            fontSize: this.fontSize.vp, lineHeight: 0.vp,
                                                            baselineOffset: 0.vp, letterSpacing: 0.vp)
            let contextWidth = Measure.MeasureText(context)
            if (contextWidth > widestWidth) {
                widestWidth = contextWidth
                widestNumber = i
            }
        }
        let widestNumberContext: CJMeasureContext = CJMeasureContext(textContent: widestNumber.toString() * digitCount,
                                                        fontFamily: "HarmonyOS Sans", constraintWidth: 0.vp,
                                                        fontSize: this.fontSize.vp, lineHeight: 0.vp,
                                                        baselineOffset: 0.vp, letterSpacing: 0.vp)
        this.textCompWidth = ceil(Measure.MeasureText(widestNumberContext) / 3.25)
    }


    // 设置 editorKit 高度
    private func getHeight() {
        var tempHeight = this.lines[lineCount-1].getHeight()
        if (tempHeight < this.height) {
            this.textCompHeight = this.height
        } else {
            this.textCompHeight = tempHeight
        }
    }

    // 用户输入完成后调用此方法，刷新组件
    func updateEditorSpanStyle(index!: Int32 = -1): Unit {
        if (this.editorKit.isNone()) {
            return
        }

        var lineRange = (0, this.text.toRuneArray().size)
        if (index > -1) {
            lineRange = getLineInfo(this.text, index)
        }
        editor.syntaxHighlight(this.text, convertLanguage(this.language), convertTheme(this.theme), this.fontSize.vp, this.editorKit.getOrThrow().controller, (lineRange[0], lineRange[1]))
    }

    // get the start and end position of lines need to be updated.
    private func getLineInfo(text: String, index: Int32): (Int64, Int64) {
        var id: Int32 = 0
        let runeArr = text.toRuneArray()
        var start = 0
        var end = runeArr.size

        for (rune in runeArr) {
            if (id < index) {
                if (rune == '\n') {
                    start = Int64(id) + 1
                }
            } else if (id >= index) {
                if (rune == '\n') {
                    end = Int64(id)
                    break
                }
            }

            id = id + 1
        }
        return (start, end)
    }

    func updateAutoComplete(popup!:Bool = false, index!: Int32 = -1, suffix!: String = "", scrollY!: Float64 = 0.0): Unit {
        if (this.editorKit.isNone()) {
            return
        }

        var lineRange = (0, this.text.size)
        var lineNumber = 0
        if (index > -1) {
            lineRange = getLineInfo(this.text, index)
            lineNumber = getLineForIndex()
        }

        let completeLists: HashSet<String> = autoComplete.autoComplete(popup, this.text, convertLanguage(this.language), lineRange[0], lineRange[1], this.suffix, this.lines, lineNumber)
        if (completeLists.size > 0) {
            this.suggestionList = ObservedArrayList<String>(completeLists.toArray())
            this.editorKit.getOrThrow().setPopPosition(calcPopPosition(scrollY))
            this.valid = true
            this.editorKit.getOrThrow().setValid(this.valid)
            this.editorKit.getOrThrow().setSuggestionList(this.suggestionList)
        }
    }

    // 获取当前用户输入数据的行号
    private func getLineForIndex(pos!: Int64 = -1): Int64 {
        var index = 0
        if (pos != -1) {
            index = convertCharToByte(pos)
        } else {
            index = convertCharToByte(this.position)
        }
        var first = 0
        var last = this.lineCount - 1
        while (first < last) {
            var mid = (first + last) / 2
            if (index < getIndexForIndex(mid)) {
                last = mid
            } else if (index >= getIndexForIndex(mid) && index < getIndexForIndex(mid + 1)) {
                return mid
            } else {
                first = mid + 1
            }
        }
        return this.lineCount - 1
    }

    // 字符转换字节方法
    private func convertCharToByte(charIndex: Int64): Int64 {
        var idx: Int64 = 0   // char index
        var index: Int64 = 0    // byte index
        let runeArr = this.text.toRuneArray()   // char array

        for (rune in runeArr) {
            if (idx == charIndex) {
                return index
            }
            index += rune.toString().size
            idx = idx + 1
        }
        return this.text.size
    }

    // 获取当前用户输入数据的行号起始位置
    private func getIndexForIndex(line: Int64): Int64 {
        if (line >= this.lineCount) {
            return -1
        } else {
            return this.lines[line].getStart()
        }
    }

    // 计算自动补全框出现位置信息
    private func calcPopPosition(scrollY: Float64): (Float64, Float64) {
        let curLine = getLineForIndex()
        let str = this.text[this.lines[curLine].getStart()..convertCharToByte(this.position)]
        let ans = calcTextSize(str)
        var tempHeight = 0.0
        if (curLine > 0) {
            tempHeight = ans[1] + this.lines[curLine-1].getHeight()
        } else {
            tempHeight = ans[1]
        }
        var popX = calcWidth(str) + getCompWidth() + padLen + 5.0
        if (popX > this.width / 2.0 - getCompWidth()) {
            popX = this.width / 2.0
        }
        var popY = tempHeight
        var popWindowHeight = (55.0 / 3.25 + 6.0) * Float64(this.suggestionList.size) + 8.0 * 2.0 - 6.0
        if (popWindowHeight > 340.0/3.25) {
            popWindowHeight = 340.0/3.25
        }
        if ((popY + popWindowHeight) > this.height + scrollY) {
            popY = this.height + scrollY - popWindowHeight
        }
        return (popX, popY)
    }

    // 计算文本高度，占用行数
    private func calcTextSize(str: String): (Int64, Float64) {
        if (str == "") {
            return (1, this.spanHeight / 3.25)
        }
        let context: CJMeasureContext = CJMeasureContext(textContent: str,
                                                        fontFamily: "HarmonyOS Sans", constraintWidth: (this.width - getCompWidth() - this.padLen).vp,
                                                        fontSize: this.fontSize.vp, lineHeight: 0.vp,
                                                        baselineOffset: 0.vp, letterSpacing: 0.vp)
        let contextHeight = Measure.MeasureTextSize(context).height
        let num = Int64(contextHeight / this.spanHeight)
        if (num == 0) {
            return (1, contextHeight / 3.25)
        } else {
            return (num, contextHeight / 3.25)
        }
    }

    func getCompWidth(): Float64  {
        return this.textCompWidth + this.dividerCompWidth + this.padLen
    }

    func getFontSize(): Int64  {
        return this.fontSize
    }

    // 计算部分文本的宽度
    private func calcWidth(str: String): Float64 {
        if (str == "") {
            return 0.0
        }
        let context: CJMeasureContext = CJMeasureContext(textContent: str,
                                                        fontFamily: "HarmonyOS Sans", constraintWidth: 0.vp,
                                                        fontSize: this.fontSize.vp, lineHeight: 0.vp,
                                                        baselineOffset: 0.vp, letterSpacing: 0.vp)
        return Float64(Int64(Measure.MeasureText(context) / 3.25) % Int64(this.width - getCompWidth() - this.padLen))
    }

    public func getText(): String {
        return text
    }

    // 获取全量文本
    func getFullText(spanResult!: Option<RichEditorTextSpanResult> = None) {
        if (this.editorKit.isNone()) {
            return
        }

        let spansValue = this.editorKit.getOrThrow().controller.getSpans()
        var curText = ""
        for(i in 0..spansValue.size) {
            match(spansValue[i].spanType) {
                case TEXT =>
                    curText += spansValue[i].textResult.getOrThrow().value
                case IMAGE => ()
            }
        }
        if (let Some(span) <- spanResult) {
            if(span.value == "\n" && Int64(span.spanPosition.spanRange[0]) < curText.size) {
                curText = curText[0..convertCharToByte(Int64(span.spanPosition.spanRange[0]))] + "\n" + curText[convertCharToByte(Int64(span.spanPosition.spanRange[0]))..]
            }
        }
        this.text = curText
    }

    func findSuffix(){
        if (this.editorKit.isNone()) {
            return
        }

        // 通过SymbolsTokenizer获取suffix. insertOffset是字符数，string[a,b]中参数需要字节数
        var lineArrays = this.lines[getLineForIndex()].getValue().toRuneArray() //按字符拆分

        var suffixStart = 0
        var charList = ArrayList<Char>()
        suffixStart = findTokenStart(this.position, lineArrays)
        for(i in suffixStart..=(this.position - convertByteToChar(this.lines[getLineForIndex()].getStart()))) {
            charList.append(lineArrays[i])
        }
        this.suffix = String(charList)
        this.editorKit.getOrThrow().setSuffix(this.suffix)
    }

    private func findTokenStart(offset: Int64, lineChar: Array<Rune>): Int64 {
        var i = offset - convertByteToChar(this.lines[getLineForIndex()].getStart())
        while (i >= 0 && i < lineChar.size && !TOKEN.contains(lineChar[i].toString()) && lineChar[i].toString() != " ") {
            i--
        }
        i++
        return i
    }

    // 字节转换字符方法
    private func convertByteToChar(byteIndex: Int64): Int64 {
        var idx: Int64 = 0   // char index
        var index: Int64 = 0    // byte index
        let runeArr = this.text.toRuneArray()   // char array

        for (rune in runeArr) {
            if (index == byteIndex) {
                return idx
            }
            index += rune.toString().size
            idx = idx + 1
        }
        return runeArr.size
    }

    func insertSuggestWord(item: String) {
        if (this.editorKit.isNone()) {
            return
        }

        let tempOffset = Int32(this.position) + 1
        this.editorKit.getOrThrow().controller.addTextSpan(
            value: item,
            options: RichEditorTextSpanOptions(
                offset: tempOffset - Int32(this.suffix.size),
                style: RichEditorTextStyle(
                    fontColor: Color(0X000000),
                    fontSize: this.fontSize.vp,
                )
            )
        )
        this.editorKit.getOrThrow().controller.deleteSpans(
            start: tempOffset - Int32(this.suffix.size) + Int32(item.size),
            end: tempOffset + Int32(item.size)
        )
        getFullText()
        getLines()
        updateEditorSpanStyle(index: this.tempIndex)
        updateAutoComplete(index: this.tempIndex)
        this.editorKit.getOrThrow().controller.setCaretOffset(Int64(tempOffset) + item.size - this.suffix.size)
        setPopWindowHidden()
    }

    func setPosition(pos: Int32) {
        this.position = Int64(pos)
    }

    func setTempIndex(pos: Int32) {
        this.tempIndex = pos
    }


    // 实现自动缩进功能
    func completeIndentation(insertOffset: Int32, insertValue: String) {
        if (this.editorKit.isNone()) {
            return
        }

        var result = excuteIndentation(insertOffset, insertValue)
        var replacementValue = ""
        var newCursorPosition: Int32
        if (result[0] == "") {
            return
        } else {
            replacementValue = result[0]
        }
        if (result[1] == -1) {
            return
        } else {
            newCursorPosition = result[1]
        }
        this.editorKit.getOrThrow().controller.addTextSpan(
            value: replacementValue,
            options: RichEditorTextSpanOptions(
                offset: insertOffset + 1,
                style: RichEditorTextStyle(
                    fontColor: Color(0X000000),
                    fontSize: this.fontSize.vp,
                    ),
                )
        )
        this.editorKit.getOrThrow().controller.setCaretOffset(Int64(newCursorPosition))
        getFullText()
        getLines()
    }

    // 生成新的插入文本以及鼠标位置
    private func excuteIndentation(insertOffset: Int32, insertValue: String): (String, Int32) {
        var start = Int64(insertOffset)
        let runeArr = this.text.toRuneArray()
        var newIndent: String = ""
        var newCursorPosition = insertOffset
        if (insertValue == "\n") {
            var preLineIndentation = getIndentationForOffset()
            newIndent = preLineIndentation
            newCursorPosition = insertOffset + Int32(preLineIndentation.size) + 1
            var lang = convertLanguage(this.language) == "Python" || convertLanguage(this.language) == "Python3"
            if (!lang && start > 0 && start <= runeArr.size && "{" == runeArr[start-1].toString()) {
                newIndent += (" " * this.tabLen)
                newCursorPosition = insertOffset + Int32(newIndent.size) + 1
            }
            if (!lang && start + 1 < runeArr.size && runeArr[start + 1].toString() == "}") {
                newIndent += ("\n" + preLineIndentation)
            }
            if (lang && start > 0 && start <= runeArr.size && ":" == runeArr[start-1].toString()) {
                newIndent += (" " * this.tabLen)
                newCursorPosition = insertOffset + Int32(newIndent.size) + 1
            }
            return (newIndent.toString(), newCursorPosition)
        }
        return ("", -1)
    }

    // 获取上一行的缩进数量
    private func getIndentationForOffset(): String {
        return getIndentationForLine(getLineForIndex())
    }

    //获取当前用户输入的行上一行的缩进值
    private func getIndentationForLine(line: Int64): String {
        var realLine = getLine(line)
        var start = convertByteToChar(realLine.getStart())
        var i = start
        let runeArr = this.text.toRuneArray()
        while (i < runeArr.size) {
            if (runeArr[i].toString() != " " || runeArr[i].toString() == "\n") {
                break
            }
            i++
        }
        return " " * (i - start)
    }

    // 获取当前用户输入的行的信息
    private func getLine(line: Int64): LineInfo {
        if (line > -1 && line < lineCount) {
            return lines[line]
        }
        return LineInfo(0)
    }

    func manualPasteProcess(start: Int32, end: Int32, event: PasteEvent) {
        setPopWindowHidden()
        if (this.editorKit.isNone()) {
            return false
        }

        event.preventDefault()
        let systemPasteboard: SystemPasteboard = getSystemPasteboard()
        let pasteData = systemPasteboard.getData()
        let count: UIntNative  = pasteData.getRecordCount();
        var textAll: String = ""
        for (i in 0..count) {
            textAll += pasteData.getRecord(Int32(i)).toPlainText()
        }

        let copy_start = start
        this.editorKit.getOrThrow().controller.deleteSpans(
          start: start,
          end: end
        )

        this.editorKit.getOrThrow().controller.addTextSpan(
            value: textAll,
            options: RichEditorTextSpanOptions(
                offset: copy_start,
            )

        )

        getFullText()
        updateDisplay()
        this.editorKit.getOrThrow().controller.setCaretOffset(Int64(copy_start))
    }

    func getCaretHeight(): (Float64, Float64) {
        if (this.editorKit.isNone()) {
            return (0.0, this.spanHeight)
        }

        let cursorOffset = this.editorKit.getOrThrow().controller.getCaretOffset()
        let curLine = getLineForIndex(pos: cursorOffset)
        let str = this.text[lines[curLine].getStart()..convertCharToByte(Int64(cursorOffset))]
        let ans = calcTextSize(str)
        var caretHeight = 0.0
        if (curLine > 0) {
            caretHeight = ans[1] + this.lines[curLine-1].getHeight()
        } else {
            caretHeight = ans[1]
        }
        return (caretHeight, this.spanHeight)
    }


}


@Component
public class EditorKit {
    var editorKitController: EditorKitController = EditorKitController(width: 0.0, height: 0.0)

    // 初始化 richEditor 控制器
    let controller = RichEditorController()

    // 初始化 scroll 控制器
    private let scroller = Scroller()

    // editorKit 组件高度
    @State var subHeight: Float64 = 0.0

    // editorKit 组件宽度
    @State var subWidth: Float64 = 0.0

    // 行号区域宽度
    @State var textCompWidth = 0.0

    // 行号区域高度
    @State var textCompHeight = 0.0

    // 记录文本真实占据行数信息
    @State var lineHeightArray: ObservedArrayList<Int64> = ObservedArrayList<Int64>()

    @State var valid = false

    @State var suggestionList: ObservedArrayList<String> = ObservedArrayList<String>()

    @State var lineColor: UInt32 = 0X808080

    @State var lineBGColor: UInt32 = 0XFAFAFA

    private var deleteoffset: Int32 = 0
    private var insertValue: String = ""
    private var insertOffset: Int32 = 0
    private var start: Int32 = 0
    private var end: Int32 = 0
    private var originTime: Duration = DateTime.now().toUnixTimeStamp()
    private var suffix = ""
    private var scrollY: Float64 = 0.0
    private var popX = 0.0
    private var popY = 0.0

    // 获取长度是 num，元素为 0 的数组
    private func createArray(num: Int64) {
        return ArrayList<Int64>(Array(num, item: 0))
    }

    protected func onAppear() {
        editorKitController.bindEditorKit(this)
    }

    public func render() {
        Scroll(this.scroller) {
            Flex(FlexParams(alignItems: ItemAlign.Start)) {
                if (valid) {
                    List() {
                        ForEach(suggestionList, itemGeneratorFunc: {item: String, index: Int64 =>
                            ListItem(){
                                Text(item)
                                    .fontSize(14.vp)
                                    .width(100.percent)
                                    .maxLines(1)
                                    .textOverflow(TextOverflow.Ellipsis)
                                    .textAlign(TextAlign.Start)
                                    .onClick({ event =>
                                        editorKitController.insertSuggestWord(item)
                                    })
                            }.editable(false)
                        })
                    }
                        .position(x: popX, y: popY)
                        .constraintSize(maxHeight: 340.px)
                        .padding(8.0)
                        .width(subWidth / 2.0)
                        .zIndex(999)
                        .shadow(radius: 30)
                        .borderRadius(10)
                        .backgroundColor(Color.WHITE)
                        .divider(strokeWidth: 6.vp, color: Color.WHITE)
                        .listDirection(Axis.Vertical)
                        .chainAnimation(false)
                        .editMode(false)
                }
                Text("") {
                    ForEach(lineHeightArray, itemGeneratorFunc: {item: Int64, idx: Int64 =>
                        Span("${idx + 1}\n")
                            .fontColor(Color(lineColor))
                        ForEach(createArray(item-1), itemGeneratorFunc: {item1: Int64, idx1: Int64 =>
                            Span(" \n")
                        })
                    })
                }
                    .width(textCompWidth)
                    .height(textCompHeight)
                    .padding(top: 0.0, left: 0.0, right: 3.0, bottom: 0.0)
                    .fontSize(editorKitController.getFontSize().vp)
                    .textAlign(TextAlign.End)
                    .align(Alignment.Top)
                    .backgroundColor(lineBGColor)
                    .onTouch( {event =>
                        editorKitController.setPopWindowHidden()
                    })
                Divider()
                    .height(textCompHeight)
                    .width(1.0)
                    .vertical(true)
                    .color(Color.GRAY)
                    .opacity(0)
                    .onTouch({ event =>
                        editorKitController.setPopWindowHidden()
                    })
                RichEditor(controller)
                    .onTouch({ event =>
                        editorKitController.setPopWindowHidden()
                    })
                    .padding(top: 0.0, left: 3.0, right: 0.0, bottom: 0.0)
                    .width(subWidth - editorKitController.getCompWidth())
                    .height(textCompHeight)
                    .onReady({ =>
                        editorKitController.initRichEditor()
                    })
                    .onSelect({value: RichEditorSelection =>
                        editorKitController.setPopWindowHidden()
                        start = value.selection[0]
                        end = value.selection[1]
                    })
                    .aboutToIMEInput({value: RichEditorInsertValue =>
                        editorKitController.setPopWindowHidden()
                        insertValue = value.insertValue
                        insertOffset = value.insertOffset
                        return true
                    })
                    .onIMEInputComplete({ value: RichEditorTextSpanResult =>
                        inputComplete(value)
                    })
                    .aboutToDelete({ value: RichEditorDeleteValue =>
                        editorKitController.setPopWindowHidden()
                        deleteoffset = value.offset
                        return true
                    })
                    .onDeleteComplete({  =>
                        deleteComplete()
                    })
                    .onPaste({ event: PasteEvent =>
                        editorKitController.manualPasteProcess(start, end, event)
                })
            }

        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.On)
        .height(subHeight)
        .width(subWidth)
        .onScroll({ offset =>
            editorKitController.setPopWindowHidden()
            scrollY = scroller.currentOffset().yOffset
        })
    }

    func setHeight(h: Float64) {
        subHeight = h
    }

    func setWidth(w: Float64) {
        subWidth = w
    }

    func setTextCompHeight(h: Float64) {
        textCompHeight = h
    }

    func setTextCompWidth(w: Float64) {
        textCompWidth = w + 3.0
    }

    func setValid(v: Bool) {
        valid = v
    }

    func setSuggestionList(arr: ObservedArrayList<String>) {
        suggestionList.clear()
        suggestionList = arr
    }

    func setlineHeightArray(arr: ObservedArrayList<Int64>) {
        lineHeightArray = arr
    }

    func setPopPosition(pos: (Float64, Float64)) {
        popX = pos[0]
        popY = pos[1]
    }

    func setSuffix(str: String) {
        this.suffix = str
    }

    func setLineColor(color: UInt32) {
        this.lineColor = color
    }

    func setLineBGColor(color: UInt32) {
        this.lineBGColor = color
    }

    private func inputComplete(value: RichEditorTextSpanResult) {
        editorKitController.getFullText(spanResult: value)
        editorKitController.getLines()
        editorKitController.setPosition(insertOffset)
        editorKitController.setTempIndex(insertOffset)
        if (insertValue == "\n") {
            editorKitController.completeIndentation(insertOffset, insertValue)
        }

        if (value.value != "\n") {
            editorKitController.updateEditorSpanStyle(index: insertOffset)
        }

        editorKitController.findSuffix()
        if (suffix != "") {
            editorKitController.updateAutoComplete(popup: true, index: insertOffset, suffix: suffix, scrollY: scrollY)
        }
        let caretHeight = editorKitController.getCaretHeight()[0]
        if (caretHeight > subHeight + scrollY) {
            scroller.scrollTo(xOffset: 0.0, yOffset: caretHeight - subHeight)
        }
    }

    private func deleteComplete() {
        var newTime = DateTime.now().toUnixTimeStamp()
        if (newTime-originTime < 50 * Duration.millisecond) {
            originTime = newTime
            editorKitController.getFullText()
            editorKitController.getLines()
            var caretHeight: Float64
            var spanHeight: Float64
            (caretHeight, spanHeight) = editorKitController.getCaretHeight()
            if (caretHeight < scrollY + spanHeight / 3.25) {
                scroller.scrollTo(xOffset: 0.0, yOffset: caretHeight - spanHeight / 3.25)
            }
            return
        }
        originTime = newTime

        editorKitController.getFullText()
        editorKitController.getLines()
        editorKitController.updateEditorSpanStyle(index: deleteoffset)

        editorKitController.setPosition(deleteoffset - 1)
        editorKitController.setTempIndex(deleteoffset)
        editorKitController.findSuffix()

        if (suffix != "") {
            editorKitController.updateAutoComplete(popup: true, index: deleteoffset, suffix: suffix, scrollY: scrollY)
        }

        var caretHeight: Float64
        var spanHeight: Float64
        (caretHeight, spanHeight) = editorKitController.getCaretHeight()
        if (caretHeight < scrollY + spanHeight / 3.25) {
            scroller.scrollTo(xOffset: 0.0, yOffset: caretHeight - spanHeight / 3.25)
        }
    }

}
