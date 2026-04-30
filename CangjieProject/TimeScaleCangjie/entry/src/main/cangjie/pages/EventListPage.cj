package ohos_app_cangjie_entry.pages

import kit.AbilityKit.UIAbilityContext
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.helpers.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.services.*
import ohos_app_cangjie_entry.store.*
import ohos_app_cangjie_entry.theme.*
import ohos_app_cangjie_entry.utils.*
import std.collection.ArrayList

@Entry
@Component
public class EventListPage {
    @State
    var eventList: ArrayList<EventItem> = ArrayList<EventItem>()
    @State
    var filteredList: ArrayList<EventItem> = ArrayList<EventItem>()
    @State
    var searchKeyword: String = ""
    @State
    var isSaving: Bool = false

    private var hasCheckedPrivacy: Bool = false

    protected override func aboutToAppear(): Unit {
        refreshPageState()
    }

    protected override func onPageShow(): Unit {
        refreshPageState()
    }

    private func getDataContext(): UIAbilityContext {
        AppContext.get()
    }

    private func refreshPageState(): Unit {
        loadEvents()
        if (!hasCheckedPrivacy) {
            hasCheckedPrivacy = true
            ensurePrivacyConsent()
        }
        openPendingEventIfNeeded()
    }

    private func loadEvents(): Unit {
        try {
            eventList = EventRepository.getAllEvents(getDataContext())
            applyFilter()
            reloadCards()
        } catch (_: Exception) {
            AppLogger.error("EventListPage", "Failed to load events")
        }
    }

    private func applyFilter(): Unit {
        filteredList = EventListViewHelper.filterEvents(eventList, searchKeyword)
    }

    private func onSearchChanged(value: String): Unit {
        this.searchKeyword = value
        this.applyFilter()
    }

    private func clearSearch(): Unit {
        this.searchKeyword = ""
        this.applyFilter()
    }

    private func ensurePrivacyConsent(): Unit {
        if (PrivacyConsentService.hasAgreed(getDataContext())) {
            return
        }
        this.getUIContext().getPromptAction().showDialog(ShowDialogOptions(
            title: "隐私政策",
            message: "欢迎使用时光刻度。为保障您的合法权益，请先阅读并同意《隐私政策》后继续使用应用。",
            buttons: [
                ButtonInfo(text: "查看隐私政策", color: AppTheme.COLOR_PRIMARY),
                ButtonInfo(text: "不同意", color: AppTheme.COLOR_DANGER),
                ButtonInfo(text: "同意并继续", color: AppTheme.COLOR_PRIMARY)
            ]
        ), callback: {
            _: Option<BusinessException>, result: Option<Int32> =>
                match (result) {
                    case Some(0) => this.getUIContext().getRouter().pushUrl(url: "PrivacyPolicyPage")
                    case Some(2) => PrivacyConsentService.markAgreed(getDataContext())
                    case _ => ()
                }
        })
    }

    private func openPendingEventIfNeeded(): Unit {
        let pendingEventId = NotificationNavigationState.consumePendingEventId()
        if (let Some(eventId) <- pendingEventId) {
            for (item in eventList) {
                if (item.id == eventId) {
                    this.getUIContext().getRouter().pushUrl(url: "EventFormPage")
                    return
                }
            }
        }
    }

    private func reloadCards(): Unit {
        try {
            CardRefreshService.refreshAll(getDataContext())
        } catch (_: Exception) {
            AppLogger.error("EventListPage", "Failed to reload cards")
        }
    }

    private func confirmDelete(item: EventItem): Unit {
        this.getUIContext().getPromptAction().showDialog(ShowDialogOptions(
            title: "删除事件",
            message: "确定要删除\"${item.title}\"吗？此操作不可恢复。",
            buttons: [
                ButtonInfo(text: "取消", color: AppTheme.COLOR_TEXT_MUTED),
                ButtonInfo(text: "删除", color: AppTheme.COLOR_DANGER)
            ]
        ), callback: {
            _: Option<BusinessException>, result: Option<Int32> =>
                match (result) {
                    case Some(1) => this.doDelete(item)
                    case _ => ()
                }
        })
    }

    private func doDelete(item: EventItem): Unit {
        try {
            let store = EventStore()
            store.delete(item)
            loadEvents()
        } catch (_: Exception) {
            AppLogger.error("EventListPage", "Failed to delete item")
        }
    }

    private func navigateToEdit(item: EventItem): Unit {
        this.getUIContext().getRouter().pushUrl(url: "EventFormPage", params: "${item.id}")
    }

    public func build(): Unit {
        Stack(alignContent: Alignment.BottomEnd) {
            Column {
                Column(space: 14) {
                    Row {
                        Column(space: 6) {
                            Text("时光刻度")
                                .fontSize(AppTheme.FONT_PAGE_TITLE)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                            Text("每一个重要的日子，都在这里记录。")
                                .fontSize(AppTheme.FONT_BODY_SMALL)
                                .lineHeight(21.0)
                                .fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                .width(88.percent)
                        }.layoutWeight(1).alignItems(HorizontalAlign.Start)

                        Button {
                            Image(@r(app.media.statistics))
                                .width(20)
                                .height(20)
                                .fillColor(AppTheme.COLOR_PRIMARY_DARK)
                        }.shape(ButtonType.Capsule)
                            .width(42)
                            .height(42)
                            .backgroundColor(AppTheme.COLOR_SURFACE)
                            .borderWidth(1)
                            .borderColor(AppTheme.COLOR_BORDER)
                            .onClick({
                                _ => this.getUIContext().getRouter().pushUrl(url: "StatisticsPage")
                            })
                    }.width(100.percent).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Top)

                    if (eventList.size > 0) {
                        Row(space: 8) {
                            Image(@r(app.media.search))
                                .width(20).height(20)
                                .fillColor(AppTheme.COLOR_PRIMARY_DARK).opacity(0.72)
                            Text("|")
                                .fontSize(AppTheme.FONT_BODY)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY).opacity(0.5)
                            TextInput(placeholder: "搜索标题 / 备注", text: this.searchKeyword)
                                .layoutWeight(1)
                                .height(48)
                                .backgroundColor(Color.Transparent)
                                .fontSize(AppTheme.FONT_BODY)
                                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                .placeholderColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .onChange({
                                    value => this.onSearchChanged(value)
                                })
                            if (this.searchKeyword.size > 0) {
                                Image(@r(app.media.clear))
                                    .width(20).height(20)
                                    .fillColor(AppTheme.COLOR_TEXT_TERTIARY)
                                    .onClick({
                                        _ => this.clearSearch()
                                    })
                            }
                        }.width(100.percent).height(50)
                            .padding(left: 16, right: 12)
                            .backgroundColor(AppTheme.COLOR_SURFACE)
                            .borderRadius(18.0)
                            .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                    }

                    if (eventList.size > 0 && searchKeyword.trimAscii().size > 0) {
                        Row {
                            Text("找到 ${filteredList.size} 条相关事件")
                                .fontSize(AppTheme.FONT_BODY_SMALL)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .opacity(0.78)
                        }.width(100.percent).margin(top: -2.0)
                    }
                }.width(100.percent)
                    .padding(top: 66, left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 10)

                if (filteredList.size == 0) {
                    Column(space: 0) {
                        Image(@r(app.media.icon_empty))
                            .width(210).height(210).opacity(0.84)
                            .margin(top: 8, bottom: 16)
                        Column(space: 10) {
                            Text(if (searchKeyword.trimAscii().size > 0) { "没有匹配结果" } else { "这里还没有记录" })
                                .fontSize(AppTheme.FONT_EMPTY_TITLE)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                            Text(if (searchKeyword.trimAscii().size > 0) { "没有找到相关记录，试试其他关键词。" } else { "赶快添加您的第一个重要日子吧！" })
                                .fontSize(AppTheme.FONT_BODY_SMALL)
                                .lineHeight(22.0)
                                .fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                .textAlign(TextAlign.Center)
                                .width(84.percent)
                        }
                    }.width(100.percent).height(70.percent)
                        .justifyContent(FlexAlign.Center)
                        .padding(left: 16, right: 16, bottom: 42)
                } else {
                    List(space: 14) {
                        ForEach(filteredList, itemGenerator: {
                            item: EventItem, _: Int64 => ListItem {
                                this.EventCard(item)
                            }.swipeAction(end: {
                                => Button("删除")
                                    .shape(ButtonType.Normal)
                                    .width(100)
                                    .height(100.percent)
                                    .backgroundColor(AppTheme.COLOR_DANGER)
                                    .fontColor(Color.White)
                                    .fontSize(AppTheme.FONT_BODY)
                                    .fontWeight(FontWeight.Medium)
                                    .borderRadius(topLeft: 0.0, bottomLeft: 0.0, topRight: AppTheme.CARD_RADIUS, bottomRight: AppTheme.CARD_RADIUS)
                                    .onClick({
                                        _ => this.confirmDelete(item)
                                    })
                            })
                        }, keyGenerator: {
                            item: EventItem, _: Int64 => item.id.toString()
                        })
                    }.width(100.percent).layoutWeight(1)
                        .padding(left: 12, right: 12, top: 8, bottom: 20)
                        .scrollBar(BarState.Off)
                        .edgeEffect(EdgeEffect.Spring)
                }
            }.width(100.percent).height(100.percent)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Start)
                .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_BG_TOP, 0.0), (AppTheme.COLOR_SURFACE_SOFT, 0.42), (AppTheme.COLOR_BG_BOTTOM, 1.0)])
                .zIndex(1)

            Button {
                Text("+")
                    .fontSize(AppTheme.FONT_PAGE_TITLE)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
            }.width(64).height(64)
                .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_PRIMARY, 0.0), (AppTheme.COLOR_PRIMARY_DARK, 1.0)])
                .borderRadius(32.0)
                .shadow(radius: 22.0, color: AppTheme.PRIMARY_SHADOW_COLOR, offsetX: 0.0, offsetY: 12.0)
                .margin(right: 24, bottom: 28)
                .zIndex(20)
                .onClick({
                    _ => this.getUIContext().getRouter().pushUrl(url: "EventFormPage")
                })
        }
    }

    @Builder
    func EventCard(item: EventItem): Unit {
        Row(space: 14) {
            Column {
                Row(space: 8) {
                    Row {
                        if (EventListViewHelper.isToday(item)) {
                            Image(@r(app.media.ringDot))
                                .width(14).height(14)
                                .fillColor(this.eventThemeColor(item))
                        } else if (EventListViewHelper.isPast(item)) {
                            Image(@r(app.media.ring))
                                .width(14).height(14)
                                .fillColor(this.eventThemeColor(item))
                        } else {
                            Image(@r(app.media.dot))
                                .width(14).height(14)
                                .fillColor(this.eventThemeColor(item))
                        }
                    }.width(16).height(16)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(VerticalAlign.Center)

                    Text(item.title)
                        .layoutWeight(1)
                        .fontSize(AppTheme.FONT_CARD_TITLE)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                        .maxLines(1)
                        .textOverflow(TextOverflow.Ellipsis)
                }.width(100.percent).alignItems(VerticalAlign.Center).margin(bottom: 10)

                Column(space: 4) {
                    Text(EventListViewHelper.primaryDateText(item))
                        .fontSize(AppTheme.FONT_BODY_SMALL)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(AppTheme.COLOR_TEXT_MUTED)
                        .width(100.percent)

                    if (EventListViewHelper.secondaryDateText(item).size > 0) {
                        Text(EventListViewHelper.secondaryDateText(item))
                            .fontSize(AppTheme.FONT_HINT)
                            .fontColor(AppTheme.COLOR_PLACEHOLDER)
                            .width(100.percent)
                    }
                }.width(100.percent).alignItems(HorizontalAlign.Start)
                    .margin(bottom: if (this.hasNote(item)) { 7 } else { 12 })

                if (this.hasNote(item)) {
                    Text(item.note ?? "")
                        .fontSize(AppTheme.FONT_CAPTION)
                        .lineHeight(18.0)
                        .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                        .maxLines(1)
                        .textOverflow(TextOverflow.Ellipsis)
                        .width(100.percent)
                        .margin(bottom: 10)
                }

                Row(space: 6) {
                    if (EventListViewHelper.isLunarEvent(item)) {
                        this.Tag("农历事件", AppTheme.COLOR_TAG_BG, AppTheme.COLOR_TAG_TEXT)
                    }
                    this.Tag(EventListViewHelper.reminderLabel(item), AppTheme.COLOR_TAG_BG, AppTheme.COLOR_TAG_TEXT)
                    this.Tag(EventListViewHelper.repeatLabel(item), AppTheme.COLOR_TAG_BG, AppTheme.COLOR_TAG_TEXT)
                }
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)

            Column(space: 5) {
                if (EventListViewHelper.isToday(item)) {
                    Column(space: 5) {
                        Text("就是")
                            .fontSize(AppTheme.FONT_HINT)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                        Text("今天")
                            .fontSize(AppTheme.FONT_NUMBER_SMALL)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(this.eventThemeColor(item))
                            .textAlign(TextAlign.Center)
                    }.alignItems(HorizontalAlign.End)
                } else {
                    Column(space: 5) {
                        Text(EventListViewHelper.statusPrefix(item))
                            .fontSize(AppTheme.FONT_HINT)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                        Row(space: 2) {
                            Text(EventListViewHelper.statusNumber(item))
                                .fontSize(AppTheme.FONT_NUMBER)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(this.eventThemeColor(item))
                            Text(EventListViewHelper.statusUnit(item))
                                .fontSize(AppTheme.FONT_TAG)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .margin(top: 7)
                        }.alignItems(VerticalAlign.Bottom)
                    }.alignItems(HorizontalAlign.Center)
                }
            }.width(68).height(100.percent)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .padding(left: 4, right: 2)
        }.width(100.percent).height(146)
            .padding(left: 18, right: 18, top: 16, bottom: 16)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(AppTheme.COLOR_SURFACE)
            .borderRadius(AppTheme.CARD_RADIUS)
            .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
            .shadow(radius: 14.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)
            .clip(true)
            .onClick({
                _ => this.navigateToEdit(item)
            })
    }

    @Builder
    func Tag(label: String, bgColor: UInt32, textColor: UInt32): Unit {
        Text(label)
            .fontSize(AppTheme.FONT_TAG)
            .fontWeight(FontWeight.Medium)
            .fontColor(textColor)
            .padding(left: 8, right: 8, top: 4, bottom: 4)
            .backgroundColor(bgColor)
            .borderRadius(999.0)
    }

    private func eventThemeColor(item: EventItem): UInt32 {
        EventListViewHelper.eventThemeColor(item, AppTheme.COLOR_PRIMARY)
    }

    private func hasNote(item: EventItem): Bool {
        if (let Some(note) <- item.note) {
            note.trimAscii().size > 0
        } else {
            false
        }
    }
}
