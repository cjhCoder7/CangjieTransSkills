# 不依赖UI组件的全局自定义弹出框（openCustomDialog）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

由于[CustomDialogController](../reference/arkui-cj/cj-dialog-customdialog.md#class-customdialogcontroller)在使用上存在诸多限制，不支持动态创建也不支持动态刷新。

> **说明：**
>
> 弹出框（[openCustomDialog](../reference/arkui-cj/cj-apis-uicontext-promptaction.md#func-opencustomdialogcustomdialogoptions-int32---unit)）存在两种入参方式创建自定义弹出框：
>
> - openCustomDialog（传参为CustomDialogOptions形式）：通过CustomDialogOptions封装内容可以与UI界面解耦，调用更加灵活，可以满足开发者的封装诉求。拥有更强的灵活性，弹出框样式是完全自定义的，且在弹出框打开之后可以使用updateCustomDialog方法动态更新弹出框的一些参数。
>
> - openCustomDialog（传lambda表达式形式）：传入lambda表达式即用户可以在openCustomDialog中加入回调，或其他组件方法。

## 生命周期

弹出框提供了生命周期函数用于通知用户该弹出框的生命周期。生命周期的触发时序依次为：onWillAppear -> onDidAppear -> onWillDisappear -> onDidDisappear。

| 名称            |类型| 说明                       |
| :----------------- | :------ | :---------------------------- |
| onDidAppear    | () -> Unit  | 弹出框弹出时的事件回调。    |
| onDidDisappear |() -> Unit  | 弹出框消失时的事件回调。    |
| onWillAppear    | () -> Unit | 弹出框显示动效前的事件回调。 |
| onWillDisappear | () -> Unit | 弹出框退出动效前的事件回调。 |

## 自定义弹出框的打开与关闭

> **说明：**
>
> 详细变量定义请参考[完整示例](#完整示例)。

- 创建CustomDialog。

   CustomDialog用于定义自定义弹出框的内容。

    ```cangjie
    @Builder
    func CustomDialog() {
        Column() {
            Text("Hello").height(50.vp)
            Button("Close").onClick({
                evt => getUIContext().getPromptAction().closeCustomDialog(customdialogId)
            })
        }.margin(10.vp)
    }
    ```

- 打开自定义弹出框。

   通过调用openCustomDialog接口打开的弹出框，弹出框内容为CustomDialogOptions类型，其中this.CustomDialog为自定义弹出框的内容。

    <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry

    import ohos.base.*
    import ohos.arkui.component.*
    import ohos.arkui.ui_context.*
    import ohos.arkui.state_management.*
    import ohos.arkui.state_macro_manage.*

    var customdialogId: Int32 = 0

    @Entry
    @Component
    class EntryView {

        @Builder
        func CustomDialog() {
            Column() {
                Text("Hello Content").height(60.vp)
                Button("Close").onClick({
                    evt => getUIContext().getPromptAction().closeCustomDialog(customdialogId)
                })
            }.margin(10.vp)
        }

        func build(){
            Button("open dialog and options")
                .margin(top: 50)
                .onClick({
                    evt => getUIContext().getPromptAction().openCustomDialog(
                        CustomDialogOptions(builder: this.CustomDialog),
                        {
                            id => customdialogId = id
                        }
                    )
                })
        }
    }
    ```

- 关闭自定义弹出框。

    closeCustomDialog接口需要传入待关闭弹出框对应的CustomDialogId。

    <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry

    import ohos.base.*
    import ohos.arkui.component.*
    import ohos.arkui.ui_context.*
    import ohos.arkui.state_management.*
    import ohos.arkui.state_macro_manage.*

    var customdialogId: Int32 = 0

    @Entry
    @Component
    public class EntryView {
        @Builder
        func CustomDialog() {
            Column() {
                Text("Hello Content").height(60.vp)
                Button("Close").onClick({
                    evt => getUIContext().getPromptAction().closeCustomDialog(customdialogId)
                })
            }.margin(10.vp)
        }
        func build() {
            Column() {
                Button("open dialog and update content")
                    .margin(top: 50)
                    .onClick(
                        {
                            evt => getUIContext().getPromptAction().openCustomDialog(
                                CustomDialogOptions(builder: this.CustomDialog),
                                {
                                    id => customdialogId = id
                                }
                            )
                        })
            }
        }
    }
    ```

## 完整示例

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*

var customdialogId: Int32 = 0

@Entry
@Component
public class EntryView {
    @Builder
    func CustomDialog() {
        Column() {
            Text("Hello ").height(70.vp)
            Button("Close").onClick({
                evt => getUIContext().getPromptAction().closeCustomDialog(customdialogId)
            })
        }.margin(15.vp)
    }
    @Builder
    func CustomDialog1() {
        Column() {
            Text("Hello Content").height(60.vp)
            Button("Close").onClick({
               evt => getUIContext().getPromptAction().closeCustomDialog(customdialogId)
            })
        }.margin(10.vp)
    }
    func build() {
        Flex(justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center) {
            Column(){
            Button("open dialog and options")
                .margin(top: 50)
                .onClick({
                        evt => getUIContext().getPromptAction().openCustomDialog(
                            CustomDialogOptions(builder: this.CustomDialog),
                            {
                                id => customdialogId = id
                            }
                        )
                    })
            Button("open dialog and content")
                .margin(top: 50)
                .onClick({
                        evt => getUIContext().getPromptAction().openCustomDialog(
                            CustomDialogOptions(builder: this.CustomDialog1),
                            {
                                id => customdialogId = id
                            }
                        )
                    })
        }.width(100.percent).padding(top:5)}
    }
}
```

![UIContextPromptAction](figures/UIContextPromptAction.gif)
