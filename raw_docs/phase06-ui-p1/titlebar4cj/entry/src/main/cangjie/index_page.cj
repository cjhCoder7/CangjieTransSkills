/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import titlebar.*
import titlebar.models.*
import std.collection.ArrayList

/**
 * TitleBar 示例应用主页面
 */
@Entry
@Component
class IndexPage {
    @State var titleBarModel: TitleBarModel = TitleBarModel()

    protected override func aboutToAppear(): Unit {
        let newModel = TitleBarModel()
        newModel.setTitleName("日间样式")
               .setTitleBarStyle(TitleBarStyle.LIGHT)
               .setLeftTitleName("返回")
               .setRightTitleName("更多")
        this.titleBarModel = newModel
    }

    @Builder
    func build() {
        Column() {
            // 标题栏
            TitleBar(model: this.titleBarModel)

            // 内容区域
            Column() {
                Text("TitleBar 示例应用")
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .margin(top: 50)

                Text("请点击下方按钮切换不同样式")
                    .fontSize(16)
                    .fontColor(0xFF999999)
                    .margin(top: 20)

                // 样式切换按钮
                Button("切换到日间样式")
                    .width(200)
                    .height(40)
                    .margin(top: 30)
                    .onClick({ evt =>
                        this.titleBarModel.setTitleBarStyle(TitleBarStyle.LIGHT)
                        this.titleBarModel.setTitleName("日间样式")
                    })

                Button("切换到夜间样式")
                    .width(200)
                    .height(40)
                    .margin(top: 10)
                    .onClick({ evt =>
                        this.titleBarModel.setTitleBarStyle(TitleBarStyle.NIGHT)
                        this.titleBarModel.setTitleName("夜间样式")
                    })

                Button("切换到透明样式")
                    .width(200)
                    .height(40)
                    .margin(top: 10)
                    .onClick({ evt =>
                        this.titleBarModel.setTitleBarStyle(TitleBarStyle.TRANSPARENT)
                        this.titleBarModel.setTitleName("透明样式")
                    })

                Button("显示副标题")
                    .width(200)
                    .height(40)
                    .margin(top: 20)
                    .onClick({ evt =>
                        this.titleBarModel.setSubTitleName("这是副标题")
                    })

                Button("隐藏副标题")
                    .width(200)
                    .height(40)
                    .margin(top: 10)
                    .onClick({ evt =>
                        this.titleBarModel.setSubTitleName("")
                    })
            }
            .width(100.percent)
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
        }
        .width(100.percent)
        .height(100.percent)
    }
}
