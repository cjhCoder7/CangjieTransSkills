# LoadingProgress

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用于显示加载动效的组件。

加载动效在组件不可见时停止，组件的可见状态基于[onVisibleAreaChange](./cj-universal-event-visibleareachange.md#func-onvisibleareachangearrayfloat64-bool-float64---unit)处理，可见阈值ratios大于0即视为可见状态。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init()

```cangjie
public init()
```

**功能：** 创建加载进展组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## 通用属性/通用事件

通用属性：全部支持。

> **说明：**
>
> 组件应设置合理的宽高，当组件宽高设置过大时加载动效可能不符合预期效果。

通用事件：全部支持。

## 组件属性

### func color(?ResourceColor)

```cangjie
public func color(value: ?ResourceColor): This
```

**功能：** 设置当前加载进度条的前景色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|初始值: 0xFF666666，默认加载进度条的前景色。|

## 示例代码

### 示例1

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 5) {
            Text("Orbital LoadingProgress")
                .fontSize(9)
                .fontColor(0xCCCCCC)
                .width(90.percent)
            LoadingProgress()
            .color(Color.Blue)
        }.width(100.percent).margin(top: 5)
    }
}
```

![loading_progress_1](figures/Loadingprogress_1.gif)