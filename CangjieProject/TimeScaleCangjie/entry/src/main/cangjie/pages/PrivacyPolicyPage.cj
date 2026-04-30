package ohos_app_cangjie_entry.pages

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.theme.*

@Entry
@Component
public class PrivacyPolicyPage {
    public func build(): Unit {
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
                    Text("隐私政策")
                        .fontSize(AppTheme.FONT_PAGE_TITLE)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                        .textAlign(TextAlign.Center)
                }.width(100.percent)
            }.width(100.percent)
                .padding(top: 50, left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 14)

            // 内容区域
            Scroll {
                Column(space: 16) {
                    Column(space: 16) {
                        this.PolicySection("一、我们处理的信息",
                            "时光刻度用于记录纪念日、倒数日、生日等重要日期。您在应用中主动填写的标题、备注、日期、重复方式、提醒方式等信息，仅用于事件记录、展示、排序、统计与提醒。")
                        this.PolicySection("二、信息存储方式",
                            "应用会将相关事件数据保存在当前设备本地，用于完成倒数日展示、提醒安排、桌面卡片和统计分析等功能。当前版本不提供账号登录、云同步或开发者服务器存储。")
                        this.PolicySection("三、权限使用说明",
                            "当您主动开启提醒功能时，应用可能申请读取日历和写入日历权限，用于将事件提醒同步到系统日历。如果您拒绝授权，您仍可使用记录和查看功能，但系统日历提醒可能无法正常使用。")
                        this.PolicySection("四、第三方共享说明",
                            "当前版本未接入第三方广告 SDK、统计 SDK 或登录 SDK。除将您主动设置提醒的必要信息写入设备系统日历外，我们不会向第三方共享您的事件数据。")
                        this.PolicySection("五、您的选择权利",
                            "您可以在应用内新增、编辑或删除事件数据。删除事件后，应用会尝试同步清理其对应的系统提醒。")

                        Column(space: 6) {
                            Text("开发者：Ying Studio")
                                .fontSize(AppTheme.FONT_BODY_SMALL)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                .width(100.percent)
                            Text("应用包名：com.example.timescalecangjie")
                                .fontSize(AppTheme.FONT_CAPTION)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .width(100.percent)
                            Text("完整隐私政策网址请以应用市场展示信息为准。")
                                .fontSize(AppTheme.FONT_CAPTION)
                                .lineHeight(18.0)
                                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                .width(100.percent)
                        }.width(100.percent)
                            .padding(left: 14, right: 14, top: 14, bottom: 14)
                            .backgroundColor(AppTheme.COLOR_SURFACE_SOFT)
                            .borderRadius(16.0)
                    }.width(100.percent)
                        .padding(left: 18, right: 18, top: 18, bottom: 18)
                        .backgroundColor(AppTheme.COLOR_SURFACE)
                        .borderRadius(AppTheme.CARD_RADIUS)
                        .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                        .shadow(radius: 14.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)
                }.width(100.percent)
                    .padding(left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, top: 6, bottom: 28)
            }.layoutWeight(1).scrollBar(BarState.Off)
        }.width(100.percent).height(100.percent)
            .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_BG_TOP, 0.0), (AppTheme.COLOR_SURFACE_SOFT, 0.42), (AppTheme.COLOR_BG_BOTTOM, 1.0)])
    }

    @Builder
    func PolicySection(heading: String, desc: String): Unit {
        Column(space: 8) {
            Text(heading)
                .fontSize(AppTheme.FONT_CARD_TITLE)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                .width(100.percent)
            Text(desc)
                .fontSize(AppTheme.FONT_BODY_SMALL)
                .lineHeight(22.0)
                .fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                .width(100.percent)
        }.width(100.percent).alignItems(HorizontalAlign.Start)
    }
}
