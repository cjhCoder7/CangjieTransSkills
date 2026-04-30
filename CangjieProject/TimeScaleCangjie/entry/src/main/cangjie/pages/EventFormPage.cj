package ohos_app_cangjie_entry.pages

import kit.AbilityKit.UIAbilityContext
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.helpers.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.services.*
import ohos_app_cangjie_entry.theme.*
import ohos_app_cangjie_entry.utils.*
import std.collection.ArrayList
import std.convert.*
import std.time.*

@Entry
@Component
public class EventFormPage {
    @State
    var selectedColor: UInt32 = AppTheme.COLOR_PRIMARY
    @State
    var title: String = ""
    @State
    var note: String = ""
    @State
    var selectedDate: DateTime = DateTime.now()
    @State
    var isLunarDate: Bool = false
    @State
    var reminderType: ReminderType = ReminderType.Off
    @State
    var reminderHour: Int64 = 12
    @State
    var reminderMinute: Int64 = 0
    @State
    var reminderDisplayText: String = "不提醒"
    @State
    var eventDateDisplayText: String = ""
    @State
    var repeatDisplayText: String = "不重复"
    @State
    var repeatType: RepeatType = RepeatType.Once
    @State
    var isEditing: Bool = false
    @State
    var eventId: Int64 = 0
    @State
    var showColorPicker: Bool = false
    @State
    var showDatePickerPanel: Bool = false
    @State
    var isSaving: Bool = false
    @State
    var paletteColors: Array<UInt32> = []

    private var paletteHues: Array<Int64> = [225, 255, 285, 315, 345, 15, 40, 55, 85, 135, 175, 200]
    private var paletteLevels: Int64 = 8
    private var paletteSaturation: Int64 = 78
    private var paletteLightStart: Int64 = 82
    private var paletteLightEnd: Int64 = 28

    private var currentSortIndex: Int64 = 0
    private var currentCreateTime: Int64 = 0
    private var currentCalendarEventId: ?Int64 = None
    private var currentAgentReminderId: ?Int64 = None
    private var hasInitialized: Bool = false
    private var saveInProgress: Bool = false

    protected override func aboutToAppear(): Unit {
        if (hasInitialized) {
            return
        }
        hasInitialized = true
        paletteColors = generatePalette()

        let params = this.getUIContext().getRouter().getParams()
        match (params) {
            case Some(paramStr) =>
                if (paramStr.size > 0) {
                    tryLoadEventForEdit(paramStr)
                    return
                }
            case _ => ()
        }
        resetForm()
    }

    private func tryLoadEventForEdit(paramStr: String): Unit {
        try {
            let id = Int64.parse(paramStr)
            let eventOpt = EventRepository.getEventById(getDataContext(), id)
            match (eventOpt) {
                case Some(event) =>
                    applyFormState(EventFormMapper.fromEvent(event, AppTheme.COLOR_PRIMARY))
                    syncDisplayTexts()
                case _ => resetForm()
            }
        } catch (_: Exception) {
            AppLogger.error("EventFormPage", "Failed to parse event id from params")
            resetForm()
        }
    }

    private func getDataContext(): UIAbilityContext {
        AppContext.get()
    }

    private func applyFormState(state: EventFormStateData): Unit {
        this.isEditing = state.isEditing
        this.eventId = state.eventId
        this.currentSortIndex = state.currentSortIndex
        this.currentCreateTime = state.currentCreateTime
        this.currentCalendarEventId = state.currentCalendarEventId
        this.currentAgentReminderId = state.currentAgentReminderId
        this.selectedColor = state.selectedColor
        this.isLunarDate = state.isLunarDate
        this.title = state.title
        this.note = state.note
        this.selectedDate = state.selectedDate
        this.repeatType = state.repeatType
        this.reminderType = state.reminderType
        this.reminderHour = state.reminderHour
        this.reminderMinute = state.reminderMinute
    }

    private func resetForm(): Unit {
        applyFormState(EventFormMapper.createEmpty(AppTheme.COLOR_PRIMARY))
        syncDisplayTexts()
    }

    private func syncDisplayTexts(): Unit {
        syncEventDateDisplayText()
        repeatDisplayText = EventFormDisplayHelper.buildRepeatDisplayText(repeatType)
        reminderDisplayText = EventFormDisplayHelper.buildReminderDisplayText(reminderType, reminderHour, reminderMinute)
    }

    private func syncEventDateDisplayText(): Unit {
        eventDateDisplayText = EventFormDisplayHelper.buildEventDateDisplayText(selectedDate, isLunarDate)
    }

    private func showToast(message: String): Unit {
        try {
            this.getUIContext().getPromptAction().showToast(ShowToastOptions(message: message))
        } catch (_: Exception) {
            AppLogger.error("EventFormPage", "Failed to show toast")
        }
    }

    private func reloadCards(): Unit {
        try {
            CardRefreshService.refreshAll(getDataContext())
        } catch (_: Exception) {
            AppLogger.error("EventFormPage", "Failed to reload cards")
        }
    }

    private func chooseDateModeAndShowPicker(): Unit {
        this.getUIContext().getPromptAction().showDialog(ShowDialogOptions(
            title: "选择日期类型",
            buttons: [
                ButtonInfo(text: "公历日期", color: AppTheme.COLOR_PRIMARY),
                ButtonInfo(text: "农历日期", color: AppTheme.COLOR_PRIMARY)
            ]
        ), callback: {
            _: Option<BusinessException>, result: Option<Int32> =>
                match (result) {
                    case Some(0) =>
                        this.isLunarDate = false
                        this.showDatePickerPanel = true
                    case Some(1) =>
                        this.isLunarDate = true
                        this.showDatePickerPanel = true
                    case _ => ()
                }
        })
    }

    private func onDateSelected(date: DateTime): Unit {
        this.selectedDate = date
        this.showDatePickerPanel = false
        syncEventDateDisplayText()
    }

    private func selectRepeat(): Unit {
        this.getUIContext().getPromptAction().showDialog(ShowDialogOptions(
            title: "重复方式",
            buttons: [
                ButtonInfo(text: "不重复", color: AppTheme.COLOR_TEXT_MUTED),
                ButtonInfo(text: "每年", color: AppTheme.COLOR_PRIMARY),
                ButtonInfo(text: "每月", color: AppTheme.COLOR_PRIMARY)
            ]
        ), callback: {
            _: Option<BusinessException>, result: Option<Int32> =>
                match (result) {
                    case Some(0) => this.repeatType = RepeatType.Once
                    case Some(1) => this.repeatType = RepeatType.Yearly
                    case Some(2) => this.repeatType = RepeatType.Monthly
                    case _ => ()
                }
                this.repeatDisplayText = EventFormDisplayHelper.buildRepeatDisplayText(this.repeatType)
        })
    }

    private func selectReminder(): Unit {
        this.getUIContext().getPromptAction().showDialog(ShowDialogOptions(
            title: "提醒方式",
            buttons: [
                ButtonInfo(text: "不提醒", color: AppTheme.COLOR_TEXT_MUTED),
                ButtonInfo(text: "提前一天", color: AppTheme.COLOR_PRIMARY),
                ButtonInfo(text: "当天", color: AppTheme.COLOR_PRIMARY)
            ]
        ), callback: {
            _: Option<BusinessException>, result: Option<Int32> =>
                match (result) {
                    case Some(0) =>
                        this.reminderType = ReminderType.Off
                    case Some(1) =>
                        this.reminderType = ReminderType.OneDayBefore
                    case Some(2) =>
                        this.reminderType = ReminderType.OnDay
                    case _ => ()
                }
                this.reminderDisplayText = EventFormDisplayHelper.buildReminderDisplayText(this.reminderType, this.reminderHour, this.reminderMinute)
                match (result) {
                    case Some(1) => this.selectReminderTime()
                    case Some(2) => this.selectReminderTime()
                    case _ => ()
                }
        })
    }

    private func selectReminderTime(): Unit {
        let minuteStr = if (this.reminderMinute < 10) { "0${this.reminderMinute}" } else { "${this.reminderMinute}" }
        this.getUIContext().getPromptAction().showDialog(ShowDialogOptions(
            title: "提醒时间",
            message: "当前 ${this.reminderHour}:${minuteStr}",
            buttons: [
                ButtonInfo(text: "7:00", color: AppTheme.COLOR_PRIMARY),
                ButtonInfo(text: "9:00", color: AppTheme.COLOR_PRIMARY),
                ButtonInfo(text: "12:00", color: AppTheme.COLOR_PRIMARY)
            ]
        ), callback: {
            _: Option<BusinessException>, result: Option<Int32> =>
                match (result) {
                    case Some(0) =>
                        this.reminderHour = 7
                        this.reminderMinute = 0
                    case Some(1) =>
                        this.reminderHour = 9
                        this.reminderMinute = 0
                    case Some(2) =>
                        this.reminderHour = 12
                        this.reminderMinute = 0
                    case _ => ()
                }
                this.reminderDisplayText = EventFormDisplayHelper.buildReminderDisplayText(this.reminderType, this.reminderHour, this.reminderMinute)
        })
    }

    private func buildEventItem(id: Int64, calendarEventId: ?Int64): EventItem {
        let params = BuildEventRecordParams()
        params.id = id
        params.title = this.title
        params.selectedDate = this.selectedDate
        params.sortIndex = if (this.isEditing) { this.currentSortIndex } else { 0 }
        params.selectedColor = this.selectedColor
        params.isLunarDate = this.isLunarDate
        params.note = this.note
        params.reminderType = this.reminderType
        params.reminderHour = this.reminderHour
        params.reminderMinute = this.reminderMinute
        params.createTime = if (this.isEditing) { this.currentCreateTime } else { DateTime.now().toUnixTimeStamp().toMilliseconds() }
        params.repeatType = this.repeatType
        params.calendarEventId = calendarEventId
        params.agentReminderId = this.currentAgentReminderId
        EventFormMapper.buildEventRecord(params)
    }

    private func buildSaveToastMessage(reminderState: ReminderSyncState): String {
        let baseText = if (this.isEditing) { "更新成功" } else { "保存成功" }
        if (this.reminderType == ReminderType.Off) {
            return baseText
        }
        if (let Some(reason) <- reminderState.reason) {
            if (reason == "disabled") {
                return baseText
            }
            if (reason == "permission_denied") {
                return "${baseText}，但日历权限未开启"
            }
            if (reason == "past") {
                return "${baseText}，但提醒时间已过"
            }
        }
        if (reminderState.calendarSuccessCount > 0 || reminderState.calendarScheduled) {
            if (this.repeatType == RepeatType.Monthly || this.repeatType == RepeatType.Yearly) {
                return "${baseText}，已创建未来提醒"
            }
            return "${baseText}，提醒已设置"
        }
        if (reminderState.failedCount > 0 || reminderState.partialCount > 0) {
            return "${baseText}，但部分提醒创建失败"
        }
        if (reminderState.scheduled) {
            if (this.repeatType == RepeatType.Monthly || this.repeatType == RepeatType.Yearly) {
                return "${baseText}，已创建未来提醒"
            }
            return "${baseText}，提醒已设置"
        }
        "${baseText}，但部分提醒创建失败"
    }

    private func saveEvent(): Unit {
        if (this.saveInProgress) {
            return
        }

        let trimmedTitle = this.title.trimAscii()
        if (trimmedTitle.size == 0) {
            showToast("请输入事件标题")
            return
        }

        this.saveInProgress = true
        this.isSaving = true

        let draftEvent = buildEventItem(if (this.isEditing) { this.eventId } else { DateTime.now().toUnixTimeStamp().toMilliseconds() }, this.currentCalendarEventId)

        try {
            let request = EventSaveRequest()
            request.isEditing = this.isEditing
            request.eventId = this.eventId
            request.draftEvent = draftEvent
            let reminderState = EventSaveService.saveEvent(getDataContext(), request)

            reloadCards()
            showToast(buildSaveToastMessage(reminderState))
            navigateBackToList()
        } catch (_: Exception) {
            showToast("保存失败")
            this.saveInProgress = false
            this.isSaving = false
        }
    }

    private func navigateBackToList(): Unit {
        this.getUIContext().getRouter().back()
    }

    private func generatePalette(): Array<UInt32> {
        let list = ArrayList<UInt32>()
        for (row in 0..paletteLevels) {
            let lightness = if (paletteLevels == 1) {
                paletteLightStart
            } else {
                paletteLightStart + row * (paletteLightEnd - paletteLightStart) / (paletteLevels - 1)
            }
            for (i in 0..Int64(paletteHues.size)) {
                let hue = paletteHues[i]
                list.add(hslToHex(hue, paletteSaturation, lightness))
            }
        }
        list.toArray()
    }

    private func hslToHex(hue: Int64, saturation: Int64, lightness: Int64): UInt32 {
        let normSat = Float64(saturation) / 100.0
        let normLit = Float64(lightness) / 100.0
        let (r, g, b) = hslToRgb(Float64(hue), normSat, normLit)
        UInt32(0xFF000000 | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF))
    }

    private func hslToRgb(hue: Float64, saturation: Float64, lightness: Float64): (Int64, Int64, Int64) {
        if (saturation == 0.0) {
            let v = Int64(lightness * 255.0 + 0.5)
            return (v, v, v)
        }
        let brightness = if (lightness < 0.5) {
            lightness * (1.0 + saturation)
        } else {
            lightness + saturation - lightness * saturation
        }
        let base = 2.0 * lightness - brightness
        let r = Int64(convertHue(base, brightness, hue / 360.0 + 1.0 / 3.0) * 255.0 + 0.5)
        let g = Int64(convertHue(base, brightness, hue / 360.0) * 255.0 + 0.5)
        let b = Int64(convertHue(base, brightness, hue / 360.0 - 1.0 / 3.0) * 255.0 + 0.5)
        (r, g, b)
    }

    private func convertHue(base: Float64, brightness: Float64, fraction: Float64): Float64 {
        var h = fraction
        if (h < 0.0) { h = h + 1.0 }
        if (h > 1.0) { h = h - 1.0 }
        if (h < 1.0 / 6.0) { return base + (brightness - base) * 6.0 * h }
        if (h < 1.0 / 2.0) { return brightness }
        if (h < 2.0 / 3.0) { return base + (brightness - base) * (2.0 / 3.0 - h) * 6.0 }
        base
    }

    private func paletteColumnsTemplate(): String {
        let sb = StringBuilder()
        for (i in 0..Int64(paletteHues.size)) {
            if (i > 0) { sb.append(" ") }
            sb.append("1fr")
        }
        sb.toString()
    }

    private func paletteRowsTemplate(): String {
        let sb = StringBuilder()
        for (i in 0..paletteLevels) {
            if (i > 0) { sb.append(" ") }
            sb.append("1fr")
        }
        sb.toString()
    }

    public func build(): Unit {
        Stack(alignContent: Alignment.Bottom) {
            Column {
                // 页面头部
                Column(space: 8) {
                    Stack {
                        Row {
                            Button {
                                Image(@r(app.media.back))
                                    .width(16).height(16)
                                    .fillColor(AppTheme.COLOR_PRIMARY_DARK)
                            }.shape(ButtonType.Normal)
                                .width(28).height(28)
                                .backgroundColor(Color.Transparent)
                                .borderWidth(0)
                                .onClick({
                                    _ => this.getUIContext().getRouter().back()
                                })
                            Blank()
                        }.width(100.percent)

                        Text(if (isEditing) { "编辑事件" } else { "新建事件" })
                            .fontSize(AppTheme.FONT_PAGE_TITLE)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                            .textAlign(TextAlign.Center)
                    }.width(100.percent)
                }.width(100.percent)
                    .padding(top: 50, left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 16)

                // 表单区域
                Scroll {
                    Column(space: 18) {
                        // 基础信息
                        Column(space: 12) {
                            Text("基础信息")
                                .fontSize(AppTheme.FONT_HINT)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .width(100.percent)

                            Column(space: 12) {
                                TextInput(placeholder: "请输入事件名称", text: this.title)
                                    .onChange({
                                        value => this.title = value
                                    })
                                    .height(56).width(100.percent)
                                    .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                                    .fontSize(AppTheme.FONT_BODY)
                                    .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                    .placeholderColor(AppTheme.COLOR_PLACEHOLDER)
                                    .borderRadius(18.0)
                                    .padding(left: 16, right: 16)

                                TextArea(placeholder: "请输入备注（可选）", text: this.note)
                                    .onChange({
                                        value => this.note = value
                                    })
                                    .height(132).width(100.percent)
                                    .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                                    .fontSize(AppTheme.FONT_BODY)
                                    .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                    .placeholderColor(AppTheme.COLOR_PLACEHOLDER)
                                    .borderRadius(18.0)
                                    .padding(left: 16, right: 16, top: 14, bottom: 14)

                                // 颜色选择行
                                Row {
                                    Text("事件颜色").fontSize(AppTheme.FONT_BODY).fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                    Blank()
                                    Row(space: 10) {
                                        Row().width(20).height(20).borderRadius(10.0).backgroundColor(this.selectedColor)
                                            .borderWidth(2).borderColor(0xFFFFFFFF)
                                            .shadow(radius: 10.0, color: AppTheme.PRIMARY_SHADOW_COLOR, offsetX: 0.0, offsetY: 4.0)
                                        Text("更换").fontSize(AppTheme.FONT_BODY_SMALL).fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_PRIMARY)
                                    }
                                }.width(100.percent).height(56)
                                    .padding(left: 18, right: 18)
                                    .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                                    .borderRadius(18.0)
                                    .onClick({
                                        _ => this.showColorPicker = true
                                    })
                            }.width(100.percent)
                                .padding(left: 18, right: 18, top: 18, bottom: 20)
                                .backgroundColor(AppTheme.COLOR_SURFACE)
                                .borderRadius(AppTheme.CARD_RADIUS)
                                .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                                .shadow(radius: 16.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)
                        }.width(100.percent)

                        // 时间设置
                        Column(space: 12) {
                            Text("时间设置")
                                .fontSize(AppTheme.FONT_HINT)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .width(100.percent)

                            Column(space: 12) {
                                // 事件日期
                                Row {
                                    Text("事件日期")
                                        .fontSize(AppTheme.FONT_BODY).fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                    Blank()
                                    Text(this.eventDateDisplayText)
                                        .fontSize(AppTheme.FONT_BODY).fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                        .maxLines(1)
                                        .textOverflow(TextOverflow.Ellipsis)
                                        .constraintSize(maxWidth: 70.percent)
                                }.width(100.percent).height(56)
                                    .padding(left: 18, right: 18)
                                    .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                                    .borderRadius(18.0)
                                    .onClick({
                                        _ => this.chooseDateModeAndShowPicker()
                                    })

                                // 重复方式
                                Row {
                                    Text("重复方式")
                                        .fontSize(AppTheme.FONT_BODY).fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                    Blank()
                                    Text(this.repeatDisplayText)
                                        .fontSize(AppTheme.FONT_BODY).fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                        .maxLines(1)
                                        .textOverflow(TextOverflow.Ellipsis)
                                        .constraintSize(maxWidth: 60.percent)
                                }.width(100.percent).height(56)
                                    .padding(left: 18, right: 18)
                                    .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                                    .borderRadius(18.0)
                                    .onClick({
                                        _ => this.selectRepeat()
                                    })

                                // 提醒方式
                                Row {
                                    Text("提醒方式")
                                        .fontSize(AppTheme.FONT_BODY).fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                    Blank()
                                    Text(this.reminderDisplayText)
                                        .fontSize(AppTheme.FONT_BODY).fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                        .maxLines(1)
                                        .textOverflow(TextOverflow.Ellipsis)
                                        .constraintSize(maxWidth: 60.percent)
                                }.width(100.percent).height(56)
                                    .padding(left: 18, right: 18)
                                    .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                                    .borderRadius(18.0)
                                    .onClick({
                                        _ => this.selectReminder()
                                    })
                            }.width(100.percent)
                                .padding(left: 18, right: 18, top: 18, bottom: 20)
                                .backgroundColor(AppTheme.COLOR_SURFACE)
                                .borderRadius(AppTheme.CARD_RADIUS)
                                .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                                .shadow(radius: 16.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)
                        }.width(100.percent)

                        // 提交按钮
                        Column(space: 14) {
                            Button(if (this.isSaving) { if (this.isEditing) { "更新中..." } else { "保存中..." } } else if (this.isEditing) { "更新事件" } else { "保存事件" })
                                .width(100.percent).height(52)
                                .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_PRIMARY, 0.0), (AppTheme.COLOR_PRIMARY_DARK, 1.0)])
                                .fontColor(Color.White)
                                .fontSize(AppTheme.FONT_CARD_TITLE)
                                .fontWeight(FontWeight.Bold)
                                .borderRadius(52.0)
                                .enabled(!this.isSaving)
                                .opacity(if (this.isSaving) { 0.72 } else { 1.0 })
                                .shadow(radius: 52.0, color: AppTheme.PRIMARY_SHADOW_COLOR, offsetX: 0.0, offsetY: 10.0)
                                .onClick({
                                    _ => this.saveEvent()
                                })
                        }.width(100.percent).alignItems(HorizontalAlign.Center)
                    }.width(100.percent)
                        .padding(left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 32)
                }.width(100.percent).layoutWeight(1).scrollBar(BarState.Off)
            }.width(100.percent).height(100.percent)

            // 颜色选择器叠加层
            if (this.showColorPicker) {
                this.ColorPickerOverlay()
            }

            // 日期选择器叠加层
            if (this.showDatePickerPanel) {
                this.DatePickerOverlay()
            }
        }.width(100.percent).height(100.percent)
            .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_BG_TOP, 0.0), (AppTheme.COLOR_SURFACE_SOFT, 0.42), (AppTheme.COLOR_BG_BOTTOM, 1.0)])
    }

    @Builder
    func ColorPickerOverlay(): Unit {
        Stack(alignContent: Alignment.Bottom) {
            Column().width(100.percent).height(100.percent)
                .backgroundColor(AppTheme.COLOR_OVERLAY)
                .onClick({
                    _ => this.showColorPicker = false
                })

            Column(space: 16) {
                Row {
                    Text("选择事件颜色").fontSize(AppTheme.FONT_EMPTY_TITLE)
                        .fontWeight(FontWeight.Bold).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                    Blank()
                    Button("完成")
                        .shape(ButtonType.Capsule).height(32)
                        .padding(left: 14, right: 14)
                        .fontSize(AppTheme.FONT_BODY_SMALL)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(AppTheme.COLOR_PRIMARY)
                        .backgroundColor(AppTheme.COLOR_PRIMARY_LIGHT)
                        .onClick({
                            _ => this.showColorPicker = false
                        })
                }.width(100.percent)

                // 颜色预览行
                Row(space: 12) {
                    Row().width(20).height(20).borderRadius(10.0)
                        .backgroundColor(this.selectedColor)
                        .borderWidth(2).borderColor(0xFFFFFFFF)
                        .shadow(radius: 10.0, color: AppTheme.PRIMARY_SHADOW_COLOR, offsetX: 0.0, offsetY: 4.0)
                    Column(space: 4) {
                        Text("事件颜色").fontSize(AppTheme.FONT_BODY).fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                        Text("点按色板中的任意位置即可选择颜色").fontSize(AppTheme.FONT_CAPTION).fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                    }.alignItems(HorizontalAlign.Start)
                }.width(100.percent)

                // 色板网格
                Grid() {
                    ForEach(this.paletteColors, itemGenerator: {
                        color: UInt32, _: Int64 => GridItem {
                            Stack(alignContent: Alignment.Center) {
                                Row().width(100.percent).height(100.percent).borderRadius(10.0)
                                    .backgroundColor(color)
                                    .borderWidth(if (this.selectedColor == color) { 2.5 } else { 0.5 })
                                    .borderColor(if (this.selectedColor == color) { 0xFFFFFFFF } else { 0xFFFFFF88 })
                                if (this.selectedColor == color) {
                                    Text("✓").fontSize(AppTheme.FONT_BODY).fontWeight(FontWeight.Bold).fontColor(Color.White)
                                }
                            }
                        }.width(100.percent).height(100.percent)
                            .onClick({
                                _ => this.selectedColor = color
                            })
                    }, keyGenerator: {
                        color: UInt32, _: Int64 => color.toString()
                    })
                }.columnsTemplate(this.paletteColumnsTemplate())
                    .rowsTemplate(this.paletteRowsTemplate())
                    .columnsGap(8.0)
                    .rowsGap(8.0)
                    .width(100.percent)
                    .height(264)
            }.width(100.percent)
                .padding(top: 20, left: 20, right: 20, bottom: 28)
                .backgroundColor(AppTheme.COLOR_SURFACE)
                .borderRadius(topLeft: 24.0, topRight: 24.0)
                .shadow(radius: 20.0, color: AppTheme.COLOR_SHEET_SHADOW, offsetX: 0.0, offsetY: -6.0)
        }.width(100.percent).height(100.percent)
    }

    @Builder
    func DatePickerOverlay(): Unit {
        Stack(alignContent: Alignment.Bottom) {
            Column().width(100.percent).height(100.percent)
                .backgroundColor(AppTheme.COLOR_OVERLAY)
                .onClick({
                    _ => this.showDatePickerPanel = false
                })

            Column(space: 16) {
                Row {
                    Text(if (this.isLunarDate) { "选择农历日期" } else { "选择公历日期" })
                        .fontSize(AppTheme.FONT_EMPTY_TITLE)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                    Blank()
                    Button("完成")
                        .shape(ButtonType.Capsule).height(32)
                        .padding(left: 14, right: 14)
                        .fontSize(AppTheme.FONT_BODY_SMALL)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(AppTheme.COLOR_PRIMARY)
                        .backgroundColor(AppTheme.COLOR_PRIMARY_LIGHT)
                        .onClick({
                            _ => this.showDatePickerPanel = false
                        })
                }.width(100.percent)

                DatePicker(selected: this.selectedDate)
                    .lunar(this.isLunarDate)
                    .onDateChange({
                        date: DateTime => this.onDateSelected(date)
                    })
            }.width(100.percent)
                .padding(top: 20, left: 20, right: 20, bottom: 28)
                .backgroundColor(AppTheme.COLOR_SURFACE)
                .borderRadius(topLeft: 24.0, topRight: 24.0)
                .shadow(radius: 20.0, color: AppTheme.COLOR_SHEET_SHADOW, offsetX: 0.0, offsetY: -6.0)
        }.width(100.percent).height(100.percent)
    }
}
