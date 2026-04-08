# 单选框（Radio）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Radio是单选框组件，通常用于提供相应的用户交互选择项，同一组的Radio中只有一个可以被选中。具体用法请参见[Radio](../reference/arkui-cj/cj-button-picker-radio.md)。

## 创建单选框

Radio通过调用接口来创建，接口调用形式如下：

```cangjie
init(value!: String, group!: String, indicatorType!: RadioIndicatorType = RadioIndicatorType.TICK,
indicatorBuilder!: Option<() -> Unit> = Option.None)
```

其中，value是单选框的名称，group是单选框的所属群组名称，indicatorType是单选框的选中样式，indicatorBuilder表示配置单选框的选中样式为自定义组件。
checked属性可以设置单选框的状态，状态分别为false和true，设置为true时表示单选框被选中。

Radio支持设置选中状态和非选中状态的样式。

<!-- code_check_manual -->

```cangjie
Radio(value: 'Radio1', group: 'radioGroup')
    .checked(false)
Radio(value: 'Radio2', group: 'radioGroup')
    .checked(true)
```

![Radio](figures/Radio.png)

## 添加事件

除支持[通用事件](../reference/arkui-cj/cj-universal-event-click.md)外，Radio还用于选中后触发某些操作，可以绑定onChange事件来响应选中操作后的自定义行为。

<!-- code_check_manual -->

```cangjie
Radio(value: 'Radio1', group: 'radioGroup')
    .onChange({ isChecked =>
        if(isChecked) {
        //需要执行的操作
        }
    })
Radio(value: 'Radio2', group: 'radioGroup')
    .onChange({ isChecked =>
        if(isChecked) {
        //需要执行的操作
        }
    })
```

## 场景示例

通过点击Radio切换声音模式。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.ui_context.*

@Entry
@Component
class EntryView {
    func build() {
        Row() {
            Column() {
                Radio(value: 'Radio1', group: 'radioGroup')
                    .checked(true)
                    .height(50)
                    .width(50)
                    .onChange ({
                        isChecked => if (isChecked) {
                            // 切换为响铃模式
                            getUIContext().getPromptAction().showToast(ShowToastOptions(message: 'Ringing mode.'))
                        }
                    })
                Text('Ringing')
            }
            Column() {
                Radio(value: 'Radio2', group: 'radioGroup')
                    .height(50)
                    .width(50)
                    .onChange ({
                        isChecked => if (isChecked) {
                            // 切换为振动模式
                            getUIContext().getPromptAction().showToast(ShowToastOptions(message: 'Vibration mode.'))
                        }
                    })
                Text('Vibration')
            }
            Column() {
                Radio(value: 'Radio3', group: 'radioGroup')
                    .height(50)
                    .width(50)
                    .onChange ({
                        isChecked => if (isChecked) {
                            // 切换为静音模式
                            getUIContext().getPromptAction().showToast(ShowToastOptions(message: 'Silent mode.'))
                        }
                    })
                Text('Silent')
            }
        }
        .height(100.percent)
        .width(100.percent)
        .justifyContent(FlexAlign.Center)
    }
}

```

![Radio1](figures/Radio1.gif)
