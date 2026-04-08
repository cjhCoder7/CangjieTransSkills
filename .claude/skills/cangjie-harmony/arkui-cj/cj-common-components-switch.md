# 切换按钮（Toggle）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Toggle组件提供状态按钮样式、勾选框样式和开关样式，一般用于两种状态之间的切换。具体用法请参见[Toggle](../reference/arkui-cj/cj-button-picker-toggle.md)。

## 创建切换按钮

Toggle通过调用接口来创建，接口调用形式如下：

```cangjie
Toggle(toggleType: ToggleType, isOn!: Bool = false)
```

其中，ToggleType为开关类型，包括Button、Checkbox和Switch，isOn为切换按钮的状态。

接口调用有以下两种形式：

- 创建不包含子组件的Toggle。
  当ToggleType为Checkbox或者Switch时，用于创建不包含子组件的Toggle：

  <!-- code_check_manual -->

  ```cangjie
  Toggle(ToggleType.Checkbox, isOn: false)
  Toggle(ToggleType.Checkbox, isOn: true)
  ```

  ![Toggle](figures/Toggle.png)

  <!-- code_check_manual -->

  ```cangjie
  Toggle(ToggleType.Switch, isOn: false)
  Toggle(ToggleType.Switch, isOn: true)
  ```

  ![Toggle1](figures/Toggle1.png)

- 创建包含子组件的Toggle。

  当ToggleType为Button时，只能包含一个子组件，如果子组件有文本设置，则相应的文本内容会显示在按钮上。

  <!-- code_check_manual -->

  ```cangjie
  Toggle(ToggleType.Button, false) {
      Text('status button')
          .fontColor(0x182431)
          .fontSize(12)
  }.width(100)
  Toggle(ToggleType.Button, true) {
      Text('status button')
          .fontColor(0x182431)
          .fontSize(12)
  }.width(100)
  ```

  ![Toggle2](figures/Toggle2.png)

## 自定义样式

- 通过selectedColor属性设置Toggle打开选中后的背景颜色。

  <!-- code_check_manual -->

  ```cangjie
  Toggle(ToggleType.Button, true) {
      Text('status button')
          .fontColor(0x182431)
          .fontSize(12)
  }
      .width(100)
      .selectedColor(0xFEC0CD)
  Toggle(ToggleType.Checkbox, isOn: true).selectedColor(0xFEC0CD)
  Toggle(ToggleType.Switch, isOn: true).selectedColor(0xFEC0CD)
  ```

  ![Toggle3](figures/Toggle3.png)

- 通过switchPointColor属性设置Switch类型的圆形滑块颜色，仅对toggleType为ToggleType.Switch生效。

  <!-- code_check_manual -->

  ```cangjie
  Toggle(ToggleType.Switch, isOn: false).switchPointColor(0xFEC0CD)
  Toggle(ToggleType.Switch, isOn: true).switchPointColor(0xFEC0CD)
  ```

  ![Toggle4](figures/Toggle4.png)

## 添加事件

除支持[通用事件](../reference/arkui-cj/cj-universal-events.md)外，Toggle还用于选中和取消选中后触发某些操作，可以绑定onChange事件来响应操作后的自定义行为。

<!-- code_check_manual -->

```cangjie
Toggle(ToggleType.Switch, isOn: false)
    .onChange ({
        isOn => if (isOn) {
            // 需要执行的操作
        }
    })
```

## 场景示例

Toggle用于切换蓝牙开关状态。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Row() {
                Text("Bluetooth Mode")
                    .height(50)
                    .fontSize(16)
            }
            Row() {
                Text("Bluetooth")
                    .height(50)
                    .padding(left: 10)
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .backgroundColor(0xFFFFFF)
                Toggle(ToggleType.Switch)
                    .margin(left: 200, right: 10)
                    .onChange ({
                        isOn => if (isOn) {
                            getUIContext().getPromptAction().showToast(ShowToastOptions(message: 'Bluetooth is on.'))
                        } else {
                            getUIContext().getPromptAction().showToast(ShowToastOptions(message: 'Bluetooth is off.'))
                        }
                    })
            }.backgroundColor(0xFFFFFF)
        }
            .padding(10)
            .backgroundColor(0xDCDCDC)
            .width(100.percent)
            .height(100.percent)
    }
}
```

![Toggle5](figures/Toggle5.gif)
