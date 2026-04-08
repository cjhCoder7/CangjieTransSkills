# RowSplit

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

将子组件横向布局，并在每个子组件之间插入一根纵向的分割线。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

可以包含子组件。

RowSplit通过分割线限制子组件的宽度。初始化时，分割线位置根据子组件的宽度来计算。初始化后，后续动态修改子组件的宽度则不生效，分割线位置保持不变，子组件宽度可以通过拖动相邻分割线进行改变。

初始化后，动态修改[margin](../arkui-cj/cj-universal-attribute-size.md#func-marginlength)、[border](../arkui-cj/cj-universal-attribute-border.md#func-borderlength-resourcecolor-length-borderstyle)、[padding](../arkui-cj/cj-universal-attribute-size.md#func-paddinglength)通用属性导致子组件宽度大于相邻分割线间距的异常情况下，不支持拖动分割线改变子组件的宽度。

## 创建组件

### init(() -> Unit)

```cangjie
public init(child: () -> Unit)
```

**功能：** 创建一个可包含子组件的RowSplit容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|是|-|声明容器内的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func resizeable(?Bool)

```cangjie
public func resizeable(value: ?Bool): This
```

**功能：** 设置分割线是否可拖拽。

> **说明：**
>
> - RowSplit的分割线可以改变左右两边子组件的宽度，子组件可改变宽度的范围取决于子组件的最大最小宽度。
> - 支持[clip](../arkui-cj/cj-universal-attribute-shapclip.md#func-clipbool)、[margin](../arkui-cj/cj-universal-attribute-size.md#func-marginlength)等通用属性，clip不设置的时候默认值为true。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|分割线是否可拖拽。<br>初始值：false。|

## 示例代码

RowSplit的基本用法。设置可拖动的、横向布局的子组件。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Text("The second line can be dragged")
                .fontSize(9)
                .fontColor(0xCCCCCC)
                .width(90.percent)
            RowSplit() {
                Text("1")
                    .width(10.percent)
                    .height(100)
                    .backgroundColor(0xF5DEB3)
                    .textAlign(TextAlign.Center)
                Text("2")
                    .width(10.percent)
                    .height(100)
                    .backgroundColor(0xD2B48C)
                    .textAlign(TextAlign.Center)
                Text("3")
                    .width(10.percent)
                    .height(100)
                    .backgroundColor(0xF5DEB3)
                    .textAlign(TextAlign.Center)
                Text("4")
                    .width(10.percent)
                    .height(100)
                    .backgroundColor(0xD2B48C)
                    .textAlign(TextAlign.Center)
                Text("5")
                    .width(10.percent)
                    .height(100)
                    .backgroundColor(0xF5DEB3)
                    .textAlign(TextAlign.Center)
            }
            .resizeable(true) // 可拖动
            .width(90.percent).height(100)
        }
        .width(100.percent)
        .padding(top: 5)
    }
}
```

![row_split](figures/row_split.gif)
