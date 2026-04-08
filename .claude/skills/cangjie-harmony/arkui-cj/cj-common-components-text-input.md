# 文本输入（TextInput/TextArea）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

TextInput、TextArea是输入框组件，通常用于响应用户的输入操作，比如评论区的输入、聊天框的输入、表格的输入等，也可以结合其它组件构建功能页面，例如登录注册页面。具体用法请参见[TextInput](../reference/arkui-cj/cj-text-input-textinput.md)、[TextArea](../reference/arkui-cj/cj-text-input-textarea.md)。

## 创建输入框

TextInput为单行输入框、TextArea为多行输入框。通过以下接口来创建。

```cangjie
init(placeholder!: ?ResourceStr = None, text!: ?ResourceStr = None, controller!: ?TextInputController = None)
```

```cangjie
init(placeholder!: ?ResourceStr = None, text!: ?ResourceStr = None,controller!: ?TextAreaController = None)
```

- 单行输入框。

    ```cangjie
    TextInput()
    ```

    ![Text](figures/Text.png)

- 多行输入框。

    ```cangjie
    TextArea()
    ```

    ![Text1](figures/Text1.png)

- 多行输入框文字超出一行时会自动折行。

    ```cangjie
    TextArea(text: "我是TextArea我是TextArea我是TextArea我是TextArea" ).width(300)
    ```

    ![Text2](figures/Text2.png)

## 自定义样式

- 设置无输入时的提示文本。

    ```cangjie
    TextInput(placeholder: '我是提示文本')
    ```

    ![Text10](figures/Text10.png)

- 设置输入框当前的文本内容。

    ```cangjie
    TextInput( placeholder: '我是提示文本', text: '我是当前文本内容' )
    ```

    ![Text11](figures/Text11.png)

- 添加backgroundColor改变输入框的背景颜色。

    ```cangjie
    TextInput( placeholder: '我是提示文本', text: '我是当前文本内容' )
    .backgroundColor(0x4D0A59F7)
    ```

    ![Text12](figures/Text12.png)

    更丰富的样式可以结合[通用属性](../reference/arkui-cj/cj-universal-attributes.md)实现。

## 选中菜单

输入框中的文字被选中时会弹出包含剪切、复制、翻译的菜单。

TextInput:

```cangjie
TextInput( text: '这是一段文本，用来展示选中菜单')
```

![Text13](figures/Text13.png)

TextArea:

```cangjie
TextArea( text: '这是一段文本，用来展示选中菜单')
```

![Text13](figures/Text13.png)

## 键盘避让

键盘抬起后，具有滚动能力的容器组件在横竖屏切换时，才会生效键盘避让，若希望无滚动能力的容器组件也生效键盘避让，建议在组件外嵌套一层具有滚动能力的容器组件，比如[Scroll](../reference/arkui-cj/cj-scroll-swipe-scroll.md)、[List](../reference/arkui-cj/cj-scroll-swipe-list.md)、[Grid](../reference/arkui-cj/cj-scroll-swipe-grid.md)。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    var placeHolderArr: Array<String> = ["1", "2", "3", "4", "5", "6", "7"];
    func build() {
        Scroll() {
            Column {
                ForEach(this.placeHolderArr, itemGeneratorFunc: {placeholder: String, _: Int64 =>
                TextInput( placeholder: 'TextInput ' + placeholder )
                .margin(30)}
                )
            }
        }
        .height(100.percent)
        .width(100.percent)
    }
}
```

![textinputkeyboardavoid](figures/TextInputKeyboardAvoid.gif)
