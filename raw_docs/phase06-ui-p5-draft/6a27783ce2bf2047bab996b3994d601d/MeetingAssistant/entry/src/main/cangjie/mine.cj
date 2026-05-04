package ohos_app_cangjie_entry

import ohos.component.Text
import ohos.component.Button
import ohos.component.Column
import ohos.component.CustomView
import ohos.state_manage.LocalStorage
import ohos.state_manage.ObservedProperty
import ohos.state_manage.SubscriberManager
import ohos.state_manage.ViewStackProcessor
import ohos.state_macro_manage.State
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.HybridComponentEntry
import ohos.hybrid_base.CJPageEntry
import ohos.hybrid_base.HybridComponentBase
import cj_res_entry.app

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.collection.*

class AppColors {
    static let PRIMARY_BLACK: UInt32 = 0xFF000000
    static let WHITE: UInt32 = 0xFFFFFFFF
    static let NEUTRAL_50: UInt32 = 0xFFFAFAFA
    static let NEUTRAL_100: UInt32 = 0xFFF5F5F5
    static let NEUTRAL_200: UInt32 = 0xFFE5E5E5
    static let NEUTRAL_300: UInt32 = 0xFFD4D4D4
    static let NEUTRAL_400: UInt32 = 0xFFA3A3A3
    static let NEUTRAL_500: UInt32 = 0xFF737373
    static let NEUTRAL_600: UInt32 = 0xFF525252
    static let NEUTRAL_700: UInt32 = 0xFF404040
    static let RED_500: UInt32 = 0xFFEF4444
}

class AppSizes {
    static let RADIUS_SM: Length = 8.vp
    static let RADIUS_LG: Length = 16.vp
    static let RADIUS_2XL: Length = 24.vp
}

class MenuItem {
    var icon: CJResource
    var label: String
    var subtitle: String
    var badge: String

    init(icon: CJResource, label: String, subtitle: String, badge: String) {
        this.icon = icon
        this.label = label
        this.subtitle = subtitle
        this.badge = badge
    }
}

class SupportItem {
    var icon: CJResource
    var label: String

    init(icon: CJResource, label: String) {
        this.icon = icon
        this.label = label
    }
}

class StatItem {
    var value: String
    var label: String

    init(value: String, label: String) {
        this.value = value
        this.label = label
    }
}

@HybridComponentEntry
@Component
class Mine {
    @State
    var userInfoName: String = "你看我叫666"
    @State
    var userInfoEmail: String = "1079088598@qq.com"

    let stats = ArrayList<StatItem>([
        StatItem("23", "总会议"),
        StatItem("18.5h", "转写时长"),
        StatItem("15", "纪要生成")
    ])

    let menuItems = ArrayList<MenuItem>([
        MenuItem(@r(app.media.ic_crown), "会员中心", "升级享更多权益", "PRO"),
        MenuItem(@r(app.media.ic_cloud), "云端同步", "已开启自动同步", ''),
        MenuItem(@r(app.media.ic_bell), "消息通知", "管理推送设置", ''),
        MenuItem(@r(app.media.ic_moon), "深色模式", "已关闭", ''),
        MenuItem(@r(app.media.ic_shield), "隐私设置", "数据安全保护", '')
    ])

    let supportItems = ArrayList<SupportItem>([
        SupportItem(@r(app.media.ic_help), "帮助与反馈"),
        SupportItem(@r(app.media.ic_file_text), "使用教程"),
        SupportItem(@r(app.media.ic_settings), "通用设置")
    ])

    func build() {
        Stack(Alignment.Bottom) {
            Scroll() {
                Column() {
                    // 用户信息卡片
                    Column() {
                        Row() {
                            // 头像
                            Row() {
                                Image(@r(app.media.touxiang))
                                    .borderRadius(100)
                            }
                            .width(64)
                            .height(64)
                            .borderRadius(32)
                            .justifyContent(FlexAlign.Center)

                            Column() {
                                Text(userInfoName)
                                    .fontSize(18)
                                    .fontWeight(FontWeight.Bold)
                                    .fontColor(AppColors.PRIMARY_BLACK)
                                Text(userInfoEmail)
                                    .fontSize(14)
                                    .fontColor(AppColors.NEUTRAL_500)
                                    .margin(top: 4)
                            }
                            .alignItems(HorizontalAlign.Start)
                            .margin(left: 16)
                            .layoutWeight(1)

                            Image(@r(app.media.ic_chevron_right))
                                .width(20)
                                .height(20)
                                .fillColor(AppColors.NEUTRAL_400)
                        }
                        .width(100.percent)

                        // 统计数据
                        Row() {
                            ForEach(stats, { item: StatItem, index: Int64 =>
                                Column() {
                                    Text(item.value)
                                        .fontSize(20)
                                        .fontWeight(FontWeight.Bold)
                                        .fontColor(AppColors.PRIMARY_BLACK)
                                    Text(item.label)
                                        .fontSize(12)
                                        .fontColor(AppColors.NEUTRAL_500)
                                        .margin(top: 4)
                                }
                                .layoutWeight(1)
                            })
                        }
                        .width(100.percent)
                        .margin(top: 20)
                        .padding(top: 20)
                    }
                    .width(93.percent)
                    .padding(20)
                    .margin(left: 20, right: 20, top: 16)
                    .backgroundColor(AppColors.NEUTRAL_100)
                    .borderRadius(28.vp) // RADIUS_2XL + 4

                    // 功能菜单
                    Text("功能设置")
                        .fontSize(12)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(AppColors.NEUTRAL_500)
                        .width(100.percent)
                        .padding(left: 24, top: 24)

                    Column() {
                        ForEach(menuItems, { item: MenuItem, index: Int64 =>
                            Row() {
                                Row() {
                                    Image(item.icon)
                                        .width(20)
                                        .height(20)
                                        .fillColor(AppColors.NEUTRAL_600)
                                }
                                .width(40)
                                .height(40)
                                .borderRadius(AppSizes.RADIUS_LG)
                                .backgroundColor(AppColors.NEUTRAL_200)
                                .justifyContent(FlexAlign.Center)

                                Column() {
                                    Text(item.label)
                                        .fontSize(14)
                                        .fontWeight(FontWeight.Medium)
                                        .fontColor(AppColors.PRIMARY_BLACK)
                                    Text(item.subtitle)
                                        .fontSize(12)
                                        .fontColor(AppColors.NEUTRAL_500)
                                        .margin(top: 2)
                                }
                                .alignItems(HorizontalAlign.Start)
                                .margin(left: 12)
                                .layoutWeight(1)

                                if (item.badge != "") {
                                    Text(item.badge)
                                        .fontSize(12)
                                        .fontWeight(FontWeight.Bold)
                                        .fontColor(AppColors.WHITE)
                                        .padding(left: 8, right: 8, top: 4, bottom: 4)
                                        .backgroundColor(AppColors.PRIMARY_BLACK)
                                        .borderRadius(AppSizes.RADIUS_SM)
                                }

                                Image(@r(app.media.ic_chevron_right))
                                    .width(16)
                                    .height(16)
                                    .fillColor(AppColors.NEUTRAL_400)
                                    .margin(left: 8)
                            }
                            .width(100.percent)
                            .padding(16)
                        })
                    }
                    .width(93.percent)
                    .margin(left: 20, right: 20, top: 12)
                    .backgroundColor(AppColors.NEUTRAL_50)
                    .borderRadius(AppSizes.RADIUS_2XL)

                    // 支持菜单
                    Text("支持与帮助")
                        .fontSize(12)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(AppColors.NEUTRAL_500)
                        .width(100.percent)
                        .padding(left: 24, top: 24)

                    Column() {
                        ForEach(supportItems, { item: SupportItem, index: Int64 =>
                            Row() {
                                Row() {
                                    Image(item.icon)
                                        .width(20)
                                        .height(20)
                                        .fillColor(AppColors.NEUTRAL_600)
                                }
                                .width(40)
                                .height(40)
                                .borderRadius(AppSizes.RADIUS_LG)
                                .backgroundColor(AppColors.NEUTRAL_200)
                                .justifyContent(FlexAlign.Center)

                                Text(item.label)
                                    .fontSize(14)
                                    .fontWeight(FontWeight.Medium)
                                    .fontColor(AppColors.PRIMARY_BLACK)
                                    .margin(left: 12)
                                    .layoutWeight(1)

                                Image(@r(app.media.ic_chevron_right))
                                    .width(16)
                                    .height(16)
                                    .fillColor(AppColors.NEUTRAL_400)
                            }
                            .width(100.percent)
                            .padding(16)
                        })
                    }
                    .width(93.percent)
                    .margin(left: 20, right: 20, top: 12)
                    .backgroundColor(AppColors.NEUTRAL_50)
                    .borderRadius(AppSizes.RADIUS_2XL)

                    // 退出登录
                    Button {
                        Row() {
                            Image(@r(app.media.ic_logout))
                                .width(20)
                                .height(20)
                                .fillColor(AppColors.RED_500)
                            Text("退出登录")
                                .fontSize(14)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(AppColors.RED_500)
                                .margin(left: 8)
                        }
                    }
                    .width(93.percent)
                    .height(56)
                    .backgroundColor(AppColors.NEUTRAL_50)
                    .borderRadius(AppSizes.RADIUS_2XL)
                    .margin(left: 20, right: 20, top: 24)

                    // 版本信息
                    Text("智能会议助手 v1.0.0")
                        .fontSize(12)
                        .fontColor(AppColors.NEUTRAL_400)
                        .margin(top: 24, bottom: 100)
                }
            }
            .scrollBar(BarState.Off)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(AppColors.WHITE)
    }
}
