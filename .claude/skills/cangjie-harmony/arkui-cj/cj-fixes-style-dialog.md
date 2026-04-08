# 固定样式弹出框

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

固定样式弹出框采用固定的布局格式，这使得开发者无需关心具体的显示布局细节，只需输入所需显示的文本内容，从而简化了使用流程，提升了便捷性。

## 使用约束

- 操作菜单（showActionMenu）、对话框（showDialog）需先使用[getPromptAction](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#func-getpromptaction)方法获取到PromptAction对象，再通过该对象调用对应方法。

- 操作菜单（showActionMenu）、对话框（showDialog）、列表选择弹出框（ActionSheet）、警告弹出框（AlertDialog）可以设置isModal为false，变成非模态弹窗。

## 操作菜单（showActionMenu）

操作菜单通过[UIContext](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#class-uicontext)中的[getPromptAction](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#func-getpromptaction)方法获取到PromptAction对象，支持在回调或开发者自定义类中使用。

创建并显示操作菜单后，菜单的响应结果会异步返回选中按钮在buttons数组中的索引。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos.arkui.ui_context.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.*

@Entry
@Component
class EntryView {
    @State var index1: Int32 = 0
    func build() {
         Column {
            Button("showActionMenu").onClick(
                {
                    evt =>
                    let buttons: Array<ButtonInfo> = [ButtonInfo(text: "item1", color: Color.Gray), ButtonInfo(text: "item2", color: Color.Black)]
                    getUIContext().getPromptAction().showActionMenu(ActionMenuOptions(title: "showActionMenu Title Info", buttons: buttons),
                        callback: {
                            err: Option<BusinessException>, i: Option<Int32> => try {
                                match (err) {
                                    case Some(e) => Hilog.info(0, "cangjie", "error: errcode is ${e.code}")
                                    case _ => index1 = i.getOrThrow()
                                }
                            } catch (e: Exception) {
                                Hilog.info(0, "cangjie", e.toString())
                            }
                        })
                }
            )
        }.width(100.percent).padding(top: 5)
    }
}
```

![image](figures/UIContextShowMenu.gif)

## 对话框（showDialog）

对话框通过[getPromptAction](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#func-getpromptaction)方法获取到PromptAction对象，支持在回调或开发者自定义类中使用。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos.arkui.ui_context.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.*

@Entry
@Component
class EntryView {
    @State var index1: Int32 = 0
    func build() {
         Column {
            Button("showDialog").onClick(
                {
                    evt =>
                    getUIContext().getPromptAction().showDialog(
                        ShowDialogOptions(
                            title: "showDialog Title Info",
                            buttons: [
                                ButtonInfo(text: 'button1', color: Color(0X000000)),
                                ButtonInfo(text: 'button2', color: Color(0X000000))
                            ]
                        ),
                        callback: {
                            err: Option<BusinessException>, i: Option<Int32> => try {
                                match (err) {
                                    case Some(e) => Hilog.info(0, "cangjie", "error: errcode is ${e.code}")
                                    case _ => ()
                                }
                            } catch (e: Exception) {
                                Hilog.info(0, "cangjie", e.toString())
                            }
                        }
                    )
                }
            )
        }.width(100.percent).padding(top: 5)
    }
}
```

![showdialog](figures/showdialog.gif)

## 列表选择弹窗（ActionSheet）

列表选择器弹窗适用于呈现多个操作选项，尤其当界面中仅需展示操作列表而无其他内容时。

列表选择器弹窗通过[UIContext](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#class-uicontext)的[showActionSheet](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#func-showactionsheetactionsheetoptions)接口实现。

该示例通过配置width、height、transition等接口定义了弹窗的样式以及弹出动效。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Button('showActionSheet').onClick({ e =>
                let confirm: ActionSheetButtonOptions = ActionSheetButtonOptions(value: "Confirm button", action: {=> Hilog.info(0, "cangjie", "Get Alert Dialog handled")},
                    defaultFocus: true, style: DialogButtonStyle.Default)
                let sheets: Array<SheetInfo> = [
                    SheetInfo(title: "apple", action: {=> Hilog.info(0, "cangjie", "apple")}),
                    SheetInfo(title: "banana", action: {=> Hilog.info(0, "cangjie", "banana")}),
                    SheetInfo(title: "pears", action: {=> Hilog.info(0, "cangjie", "pears")})]
                getUIContext().showActionSheet(
                    ActionSheetOptions(
                        title: 'ActionSheet title',
                        message: 'message',
                        sheets: sheets,
                        autoCancel: false,
                        confirm: confirm,
                        width: 300,
                        height: 300,
                        cornerRadius: BorderRadiuses(topLeft: 20.vp, topRight: 20.vp, bottomLeft: 20.vp,
                            bottomRight: 20.vp),
                        borderWidth: 1.vp,
                        borderStyle: EdgeStyles(),
                        borderColor: Color.Blue,
                        backgroundColor: Color.White,
                        transition: TransitionEffect.asymmetric(
                            TransitionEffect
                                .OPACITY
                                .animation(AnimateParam(duration: 3000, curve: Curve.Sharp))
                                .combine(
                                    TransitionEffect
                                        .scale(ScaleOptions(x: 1.5, y: 1.5))
                                        .animation(AnimateParam(duration: 3000, curve: Curve.Sharp))),
                            TransitionEffect
                                .OPACITY
                                .animation(AnimateParam(duration: 100, curve: Curve.Smooth))
                                .combine(
                                    TransitionEffect
                                        .scale(ScaleOptions(x: 0.5, y: 0.5))
                                        .animation(AnimateParam(duration: 100, curve: Curve.Smooth)))
                        ),
                        alignment: DialogAlignment.Center,
                    )
                )
            })
        }.width(100.percent).margin(top: 5)
    }
}
```

![image](figures/UIContextShowactionSheet.gif)

## 警告弹窗（AlertDialog）

需要向用户提问或得到用户的许可时，可使用警告弹窗。

- 警告弹窗用来提示重要信息，但会中断当前任务，尽量提供必要的信息和有用的操作。
- 避免仅使用警告弹窗提供信息，用户不喜欢被信息丰富但不可操作的警告打断。

该示例通过配置width、height、transition等接口定义了多个按钮弹窗的样式以及弹出动效。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Button('showAlertDialog')
                .onClick({
                    evt =>
                    let primaryButton = AlertDialogButtonOptions(
                        value: 'cancel',
                        action: {
                            => Hilog.info(0, "cangjie", 'Callback when the first button is clicked')
                        }
                    )
                    let secondaryButton = AlertDialogButtonOptions(
                        enabled: true,
                        defaultFocus: true,
                        style: DialogButtonStyle.Highlight,
                        value: 'ok',
                        action: {
                            => Hilog.info(0, "cangjie", 'Callback when the second button is clicked')
                        }
                    )
                    getUIContext().showAlertDialog(
                        AlertDialogParamWithButtons(
                            message: 'text',
                            title: 'title',
                            autoCancel: true,
                            alignment: DialogAlignment.Center,
                            offset: Offset(0.0, -20.0),
                            gridCount: 3,
                            transition: TransitionEffect.asymmetric(
                                TransitionEffect
                                    .OPACITY
                                    .animation(AnimateParam(duration: 3000, curve: Curve.Sharp))
                                    .combine(TransitionEffect.scale(ScaleOptions(x: 1.5, y: 1.5)))
                                    .animation(AnimateParam(duration: 3000, curve: Curve.Sharp)),
                                TransitionEffect
                                    .OPACITY
                                    .animation(AnimateParam(duration: 100, curve: Curve.Smooth))
                                    .combine(
                                        TransitionEffect
                                            .scale(ScaleOptions(x: 0.5, y: 0.5))
                                            .animation(AnimateParam(duration: 100, curve: Curve.Smooth)))
                            ),
                            primaryButton: primaryButton,
                            secondaryButton: secondaryButton
                        )
                    )
                }).width(100.percent).margin(top: 5)
        }
    }
}
```

![image](figures/UIContextShowAlertDialog.gif)
