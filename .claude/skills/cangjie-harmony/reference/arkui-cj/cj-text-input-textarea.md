# TextArea

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

多行文本输入框组件，当输入的文本内容超过组件宽度时会自动换行显示。高度未设置时，组件无默认高度，自适应内容高度。宽度未设置时，默认撑满最大宽度。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?ResourceStr, ?ResourceStr, ?TextAreaController)

```cangjie
public init(placeholder!: ?ResourceStr = None, text!: ?ResourceStr = None,
    controller!: ?TextAreaController = None)
```

**功能：** 创建一个包含占位符文本、当前文本内容和控制器的TextArea对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|placeholder|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** 占位符文本，无输入时显示的文本。|
|text|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** TextArea的当前值。|
|controller|?[TextAreaController](#class-textareacontroller)|否|None| **命名参数。** TextArea组件的控制器。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func caretColor(?ResourceColor)

```cangjie
public func caretColor(value: ?ResourceColor): This
```

**功能：** 设置光标的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|光标的颜色。<br>初始值：0xFF007DFF。|

### func enterKeyType(?EnterKeyType)

```cangjie
public func enterKeyType(value: ?EnterKeyType): This
```

**功能：** 设置软键盘输入按钮的类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[EnterKeyType](./cj-common-types.md#enum-enterkeytype)|是|-|软键盘输入按钮的类型。<br>初始值：EnterKeyType.NewLine。|

### func fontFamily(?ResourceStr)

```cangjie
public func fontFamily(value: ?ResourceStr): This
```

**功能：** 设置文本的字体族。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|文本的字体族。<br>初始值："HarmonyOS Sans"。|

### func fontColor(?ResourceColor)

```cangjie
public func fontColor(value: ?ResourceColor): This
```

**功能：** 设置文本的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|文本的颜色。|

### func fontSize(?Length)

```cangjie
public func fontSize(value: ?Length): This
```

**功能：** 设置文本的字体大小。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|文本的字体大小。<br>初始值：16.fp。|

### func fontStyle(?FontStyle)

```cangjie
public func fontStyle(value: ?FontStyle): This
```

**功能：** 设置文本的字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[FontStyle](./cj-common-types.md#enum-fontstyle)|是|-|文本的字体样式。<br>初始值：FontStyle.Normal。|

### func fontWeight(?FontWeight)

```cangjie
public func fontWeight(value: ?FontWeight): This
```

**功能：** 设置文本的字体粗细。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[FontWeight](./cj-common-types.md#enum-fontweight)|是|-|文本的字体粗细。<br>初始值：FontWeight.Normal。|

### func inputFilter(?ResourceStr, ?(String) -> Unit)

```cangjie
public func inputFilter(value!: ?ResourceStr, error!: ?(String) -> Unit = None): This
```

**功能：** 设置文本的输入过滤规则。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** 输入过滤规则。<br>初始值：""。|
|error|?(String) -> Unit|否|None| **命名参数。** 输入错误时的回调函数。|

### func maxLength(?UInt32)

```cangjie
public func maxLength(value: ?UInt32): This
```

**功能：** 设置文本的最大长度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?UInt32|是|-|文本的最大长度。|

### func placeholderColor(?ResourceColor)

```cangjie
public func placeholderColor(value: ?ResourceColor): This
```

**功能：** 设置占位符文本的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|占位符文本的颜色。|

### func placeholderFont(?Length, ?FontWeight, ?String, ?FontStyle)

```cangjie
public func placeholderFont(size!: ?Length, weight!: ?FontWeight = None, family!: ?String = None,
    style!: ?FontStyle = None): This
```

**功能：** 设置占位符文本的字体属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?[Length](./cj-common-types.md#interface-length)|是|-| **命名参数。** 占位符文本的字体大小。<br>初始值：16.0.fp。|
|weight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None| **命名参数。** 占位符文本的字体粗细。<br>初始值：FontWeight.W400。|
|family|?String|否|None| **命名参数。** 占位符文本的字体族。<br>初始值：""。|
|style|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None| **命名参数。** 占位符文本的字体样式。<br>初始值：FontStyle.Normal。|

### func textAlign(?TextAlign)

```cangjie
public func textAlign(value: ?TextAlign): This
```

**功能：** 设置文本的水平对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[TextAlign](./cj-common-types.md#enum-textalign)|是|-|文本的水平对齐方式。<br>初始值：TextAlign.Start。|

## 组件事件

### func onChange(?(String) -> Unit)

```cangjie
public func onChange(callback: ?(String) -> Unit): This
```

**功能：** 输入框内容发生变化时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(String) -> Unit|是|-|输入框内容发生变化时的回调函数。<br>初始值：{ _ => }。|

### func onCopy(?(String) -> Unit)

```cangjie
public func onCopy(callback: ?(String) -> Unit): This
```

**功能：** 使用剪贴板菜单时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(String) -> Unit|是|-|复制操作时的回调函数。<br>初始值：{ _ => }。|

### func onCut(?(String) -> Unit)

```cangjie
public func onCut(callback: ?(String) -> Unit): This
```

**功能：** 使用剪贴板菜单时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(String) -> Unit|是|-|剪切操作时的回调函数。<br>初始值：{ _ => }。|

### func onEditChange(?(Bool) -> Unit)

```cangjie
public func onEditChange(callback: ?(Bool) -> Unit): This
```

**功能：** 判断文本编辑状态是否发生变化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Bool) -> Unit|是|-|文本区域状态变化时触发的回调函数。<br>初始值：{ _ => }。|

### func onPaste(?(String) -> Unit)

```cangjie
public func onPaste(callback: ?(String) -> Unit): This
```

**功能：** 使用剪贴板菜单时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(String) -> Unit|是|-|粘贴操作时的回调函数。<br>初始值：{ _ => }。|

### func onSubmit(?(EnterKeyType) -> Unit)

```cangjie
public func onSubmit(callback: ?(EnterKeyType) -> Unit): This
```

**功能：** 提交时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?([EnterKeyType](./cj-common-types.md#enum-enterkeytype)) -> Unit|是|-|提交时的回调函数。<br>初始值：{ _ => }。|

## 基础类型定义

### class TextAreaController

```cangjie
public class TextAreaController {
    public init()
}
```

**功能：** TextAreaController是TextArea组件的控制器，可以定义该类型的对象并绑定至TextArea组件，实现对TextArea组件的控制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init()

```cangjie
public init()
```

**功能：** TextAreaController的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func caretPosition(?Int32)

```cangjie
public func caretPosition(value: ?Int32): Unit
```

**功能：** 设置插入光标的位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|从字符串开始到光标位置的长度。|

## 示例代码

<!--run-->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.hilog.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var placeholder: String = "please input your name"
    @State var name: String = "AAA"
    var controller: TextAreaController = TextAreaController()
    var scroller: Scroller = Scroller()
    func build() {
        Scroll(this.scroller) {
            Column(space: 10.px){
                Button("caretposition  3").onClick({
                    evt => controller.caretPosition(3)
                })

                TextArea(placeholder: this.placeholder, text: this.name, controller: controller)
                .textAlign(TextAlign.Center)

                TextArea(text: "size")
                .size(width: 100.vp, height: 50.vp).borderRadius(100.vp)

                TextArea(text: "border")
                .border(width: 1.vp, color: Color(0XFFFF0011), radius: 5.vp, style: BorderStyle.Dashed )

                TextArea(text: "padding")
                .padding(40.vp)

                TextArea(text: "font color")
                .fontColor(0x8A2BE2)

                TextArea(text: "font size 60")
                .fontSize(60)

                TextArea(text: "font weight 900")
                .fontWeight(FontWeight.W900)

                TextArea(text: "font style Italic")
                .fontStyle(FontStyle.Italic)

                TextArea(placeholder: "placeholder font")
                .placeholderColor(Color(0x8A2BE2))
                .placeholderFont(size:60.0, weight: FontWeight.W900, family:"Georgia", style:FontStyle.Italic)

                TextArea(placeholder: "textAlign")
                .textAlign(TextAlign.Start)

                TextArea(placeholder: "caretColor")
                .caretColor(Color.Red)

                TextArea(placeholder: "inputfilter only a")
                .inputFilter(value: "a" , error: { val => Hilog.info(0, "cangjie",  "TextArea OnError:" + val) })

                TextArea(placeholder: "TextArea callback")
                .onChange ({ val =>
                Hilog.info(0, "cangjie", "TextArea onChange:" + val)
                })
                .onPaste ({ val =>
                    Hilog.info(0, "cangjie", "TextArea onPaste:" + val)
                })
                .onCut ({ val =>
                    Hilog.info(0, "cangjie", "TextArea onCut:" + val)
                })
                .onCopy ({ val =>
                    Hilog.info(0, "cangjie", "TextArea onCopy:" + val)
                })
                .onSubmit ({ val =>
                    Hilog.info(0, "cangjie", "TextArea onSubmit")
                })
            }
            .height(100.percent)
            .width(100.percent)
        }
    }
}
```

![textarea](figures/textarea.png)
