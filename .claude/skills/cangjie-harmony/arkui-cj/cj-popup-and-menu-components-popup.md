# 气泡提示（Popup）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Popup属性可绑定在组件上显示气泡弹窗提示，设置弹窗内容、交互逻辑和显示状态。主要用于屏幕录制、信息弹出提醒等显示状态。

气泡分为两种类型，一种是系统提供的气泡[PopupOptions](../reference/arkui-cj/cj-common-types.md#class-popupoptions)，一种是开发者可以自定义的气泡[CustomPopupOptions](../reference/arkui-cj/cj-common-types.md#class-custompopupoptions)。其中，PopupOptions通过配置primaryButton和secondaryButton来设置带按钮的气泡，CustomPopupOptions通过配置builder来设置自定义的气泡。

气泡可以通过配置[mask](../reference/arkui-cj/cj-common-types.md#var-mask)来实现模态和非模态窗口，mask为true或者颜色值的时候，气泡为模态窗口，mask为false时，气泡为非模态窗口。

## 文本提示气泡

文本提示气泡常用于只展示带有文本的信息提示，不带有任何交互的场景。Popup属性需绑定组件，当bindPopup属性中参数show为true时会弹出气泡提示。

在Button组件上绑定Popup属性，每次点击Button按钮，handlePopup会切换布尔值，当值为true时，触发bindPopup弹出气泡。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var handlePopup: Bool = false
    func build() {
        Column {
            Button('PopupOptions')
                .onClick ({
                    e => this.handlePopup = !this.handlePopup
                })
                .bindPopup(
                    this.handlePopup,
                    PopupOptions(message: 'This is a popup with PopupOptions', placement: Placement.Bottom)
                )
        }.width(100.percent).padding(top: 5)
    }
}
```

![气泡提示（Popup）](figures/popup.gif)

## 添加气泡状态变化的事件

通过onStateChange参数为气泡添加状态变化的事件回调，可以判断当前气泡的显示状态。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var handlePopup: Bool = false
    func build() {
        Column {
            Button('PopupOptions')
                .onClick ({
                    e => this.handlePopup = !this.handlePopup
                })
                .bindPopup(
                    this.handlePopup,
                    PopupOptions(
                        message: 'This is a popup with PopupOptions',
                        placement: Placement.Bottom,
                        onStateChange: {
                            e =>
                            if (!e.isVisible) {
                                this.handlePopup = false
                            }
                        }
                    )
                )
        }.width(100.percent).padding(top: 5)
    }
}
```

![PopupOnStateChange](figures/popupOption.gif)

## 带按钮的提示气泡

通过primaryButton、secondaryButton属性为气泡最多设置两个Button按钮，通过此按钮进行简单的交互，开发者可以通过配置action参数来设置想要触发的操作。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hilog.*

@Entry
@Component
class EntryView {
    @State var handlePopup: Bool = false
    func build() {
        Column() {
            Button('PopupOptions')
                .margin(top: 200)
                .onClick ({
                    e => this.handlePopup = !this.handlePopup
                })
                .bindPopup(
                    this.handlePopup,
                    PopupOptions(
                        message: 'This is a popup with PopupOptions',
                        placement: Placement.Bottom,
                        primaryButton: PopupButton(
                            value: "Confirm",
                            action: { => Hilog.info(0, 'cangjie', 'Confirm')}
                        ),
                        secondaryButton: PopupButton(
                            value: "Cancel",
                            action: { => Hilog.info(0, 'cangjie', 'Cancel')}
                        )
                    )
                )
        }.width(100.percent).padding(top: 5)
    }
}
```

![popup2](figures/popup2.gif)

## 气泡的动画

气泡通过定义transition控制气泡的进场和出场动画效果。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var handlePopup: Bool = false
    @State var customPopup: Bool = false
    @State var popup: Bool = false
    @State var custom: String = "Custom Wait"
    // Popup builder defines popup content
    @Builder
    func popupBuilder() {
        Row() {
            Text('Custom Popup with transitionEffect').fontSize(10)
        }
        .height(50)
        .padding(5)
    }

    func build() {
        Flex(direction: FlexDirection.Column) {
            // 类型设置弹框内容
            Button('PopupOptions')
                .position(x: 100, y: 150)
                .onClick ({
                    e => this.popup = !this.popup
                })
                .bindPopup(
                    this.popup,
                    PopupOptions(
                        message: "This is popup with transitionEffect",
                        placement: Placement.Top,
                        showInSubWindow: false,
                        onStateChange: {
                            e =>
                            custom = "stateChange: ${e.isVisible}"
                            if (!e.isVisible) {
                                this.popup = true
                            }
                        },
                        // 设置弹窗显示动效与退出动效为平移动效
                        transition: TransitionEffect.asymmetric(
                            TransitionEffect
                            .OPACITY
                            .animation(AnimateParam(duration: 1000, curve: Curve.Ease))
                            .combine(
                                TransitionEffect.translate(TranslateOptions(x: 50, y: 50))
                            ),
                            TransitionEffect.IDENTITY
                        )
                    )
                )

            // CustomPopupOptions 类型设置弹框内容
            Button('CustomPopupOptions')
                .position(x: 80, y: 300)
                .onClick ({
                    e => this.customPopup = !this.customPopup
                })
                .bindPopup(
                    this.customPopup,
                    CustomPopupOptions(
                        builder: popupBuilder,
                        placement: Placement.Top,
                        showInSubWindow: false,
                        onStateChange: {
                            e =>
                            custom = "stateChange: ${e.isVisible}"
                            if (!e.isVisible) {
                                this.customPopup = true
                            }
                        },
                        // 设置弹窗显示动效与退出动效为缩放动效
                        transition: TransitionEffect
                            .scale(ScaleOptions(x: 1.0, y: 0.0))
                            .animation(AnimateParam(duration: 500, curve: Curve.Ease))
                    )
                )
        }.width(100.percent).padding(top: 5)
    }
}
```

![popup_transition](figures/popup_transition.gif)

## 自定义气泡

开发者可以使用CustomPopupOptions的builder创建自定义气泡，\@Builder中可以放自定义的内容。除此之外，还可以通过popupColor等参数控制气泡样式。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    @State var customPopup: Bool = false
    @State var custom: String = "Custom Wait"
    // popup构造器定义弹框内容
    @Builder
    func popupBuilder() {
        Row(space: 2) {
            Image(@r(app.media.startIcon))
                .width(24)
                .height(24)
                .margin(left: 5)
            Text('This is Custom Popup').fontSize(15)
        }
        .width(200)
        .height(50)
        .padding(5)
    }
    func build() {
        Column() {
            Button('CustomPopupOptions')
                .position(x: 100, y: 200)
                .onClick ({
                    e => this.customPopup = !this.customPopup
                })
                .bindPopup(
                    this.customPopup,
                    CustomPopupOptions(
                        builder: popupBuilder, // 气泡的内容
                        placement: Placement.Bottom, // 气泡的弹出位置
                        popupColor: Color.Red, // 气泡的背景色
                        showInSubWindow: false,
                        onStateChange: {
                            evt =>
                            custom = "stateChange: ${evt.isVisible}"
                            if (!evt.isVisible) {
                                customPopup = true
                            }
                        }
                    )
                )
        }.height(100.percent)
    }
}
```

使用者通过配置placement参数将弹出的气泡放到需要提示的位置。弹窗构造器会触发弹出提示信息，来引导使用者完成操作，也让使用者有更好的UI体验。

![popup3](figures/popup3.gif)

## 气泡样式

气泡除了可以通过builder实现自定义气泡，还可以通过接口设置气泡的样式和显示效果。

背景颜色：气泡的背景色默认为透明，但是会有一个默认的模糊效果，终端上为COMPONENT\_ULTRA\_THICK。

蒙层样式：气泡默认有蒙层，且蒙层的颜色为透明。

显示大小：气泡大小由内部的builder大小或者message的长度决定的。

显示位置：气泡默认显示在宿主组件的下方，可以通过Placement接口来配置其显示位置以及对齐方向。

以下示例通过设置popupColor（背景颜色）、mask（蒙层样式）、width（气泡宽度）、placement（显示位置）实现气泡的样式。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var handlePopup: Bool = false

    func build() {
        Column(space: 100) {
            Button('PopupOptions')
                .onClick({
                    e => this.handlePopup = !this.handlePopup
                })
                .bindPopup(
                    this.handlePopup,
                    PopupOptions(
                        message: "This is a popup",
                        width: 200,
                        popupColor: Color.Red,
                        mask: Color(0x33d9d9d9), // 设置气泡的背景色
                        placement: Placement.Top,
                        showInSubWindow: false,
                        backgroundBlurStyle: BlurStyle.None
                    )
                    // 去除背景模糊效果需要关闭气泡的模糊背景
                )
        }.width(100.percent)
    }
}
```

![image](figures/UIpopupStyle.gif)
