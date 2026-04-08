# 组件可见区域变化事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

组件可见区域变化事件是组件在屏幕中的显示区域面积变化时触发的事件，提供了判断组件是否完全或部分显示在屏幕中的能力，适用于广告曝光埋点之类的场景。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onVisibleAreaChange(?Array\<Float64>, ?(Bool, Float64) -> Unit)

```cangjie
func onVisibleAreaChange(ratios: ?Array<Float64>, event: ?(Bool, Float64) -> Unit): T
```

**功能：** 组件可见区域变化时触发的事件。

> **说明：**
>
> - 仅提供自身节点相对于所有祖先节点（直到window边界）的相对裁切面积与自身面积的比值及其变化趋势。
> - 不支持兄弟组件对自身节点的遮挡计算，不支持所有祖先的兄弟节点对自身节点的遮挡计算，如[Stack](../../arkui-cj/cj-layout-development-stack-layout.md)、[Z序控制](../../arkui-cj/cj-layout-development-stack-layout.md#z序控制)等。
> - 不支持非挂树节点的可见面积变化计算。例如，预加载的节点、通过[overlay](./cj-universal-attribute-overlay.md#func-overlaystring-alignment-overlayoffset)能力挂载的自定义节点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|ratios|?Array\<Float64>|是|-|阈值数组。其中，每个阈值代表组件可见面积（即组件在屏幕显示区的面积，只计算父组件内的面积，超出父组件部分不会计算）与组件自身面积的比值。当组件可见面积与自身面积的比值接近阈值时，均会触发该回调。每个阈值的取值范围为[0.0, 1.0]，如果开发者设置的阈值超出该范围，则会实际取值0.0或1.0。**说明：** 当数值接近边界0和1时，将会按照误差不超过0.001的规则进行舍入。例如，0.9997会被近似为1。<br>初始值：[0.0]。|
|event|?(Bool, Float64) -> Unit|是|-|组件可见区域变化事件的回调。参数一：表示组件的可见面积与自身面积的比值与上一次变化相比的情况，比值变大为true，比值变小为false。参数二：触发回调时，组件可见面积与自身面积的比值。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.hi_trace_meter.*
import ohos.hiviewdfx.hi_app_event.*
import ohos.hilog.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList

@Entry
@Component
class EntryView {
    @State var testTextStr: String = "test"
    @State var testRowStr: String = "test"
    @State var sizeValue: String = ""
    let scroller = Scroller()
    var arr: ArrayList<String> = ArrayList(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])

    func build() {
    Stack(alignContent: Alignment.TopStart) {
        Column {
            Column() {
                Text(this.testTextStr)
                .fontSize(20)

                Text(this.testRowStr)
                .fontSize(20)
            }
            .height(100)
            .backgroundColor(Color.Gray)
            .opacity(0.3)
        }
        Scroll(this.scroller) {
            Column() {
                Text("Test Text Visible Change")
                .fontSize(20)
                .height(200)
                .margin(20)
                .backgroundColor(Color(0xED6F21))
                // 通过设置ratios为[0.0, 1.0]，实现当组件完全显示或完全消失在屏幕中时触发回调
                .onVisibleAreaChange([0.0, 1.0], {isVisible, currentRatio =>
                this.sizeValue = isVisible.toString() + ", currentRatio:" + currentRatio.toString()
                if (isVisible && currentRatio >= 1.0) {
                    this.testTextStr = "Test Text is fully visible"
                    Text("Test Text is fully visible. currentRatio:" + currentRatio.toString())
                }

                if (!isVisible && currentRatio <= 0.0) {
                    this.testTextStr = "Test Text is completely invisible"
                    Text("Test Text is completely invisible.")
                }
                })
                Text("Test Text isVisible: " + this.sizeValue)

                ForEach(this.arr, itemGeneratorFunc: {item: String, idx: Int64 =>
                    Text(item.toString())
                    .width(60.percent)
                    .height(150)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(15)
                    .fontSize(16)
                    .textAlign(TextAlign.Center)
                    .margin(top: 10)
                })
            }
        }
        .backgroundColor(0x317aff)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.On)
        .scrollBarColor(Color.Gray)
        .scrollBarWidth(10)
        .onScrollEdge({ edge =>
            match(edge) {
                case Edge.Top => Hilog.info(0, "cangjie", "Top")
                case Edge.Bottom => Hilog.info(0, "cangjie", "Bottom")
                case _ => Hilog.info(0, "cangjie", "None")
             }
         })
    }
}
}
```

![uni_visible_area_change](figures/uni_visible_area_change.gif)