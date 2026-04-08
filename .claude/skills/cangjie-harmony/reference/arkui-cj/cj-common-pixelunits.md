# 像素单位

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

仓颉提供4种像素单位，采用vp为基准数据单位。

|名称|描述|
|:---|:---|
| px | 屏幕物理像素单位。|
| vp | 屏幕密度相关像素，根据屏幕像素密度转换为屏幕物理像素，当数值不带单位时，默认单位vp。在实际宽度为1440物理像素的屏幕上，1vp约等于3px。<br/>**说明：** <br/> vp与px的比例与屏幕像素密度有关。|
| fp | 字体像素，与vp类似适用屏幕密度变化，随系统字体大小设置变化。 |
| lpx | 视窗逻辑像素单位，lpx单位为实际屏幕宽度与逻辑宽度（通过designWidth配置）的比值，designWidth默认值为720。当designWidth为720时，在实际宽度为1440物理像素的屏幕上，1lpx为2px大小。 |

> **说明：**
>
> 使用[getUIContext()](./cj-ui-framework.md#func-getuicontext)获取[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)实例，再使用[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)下的[vp2px](./cj-apis-uicontext-uicontext.md#func-vp2pxlength)/[px2vp](./cj-apis-uicontext-uicontext.md#func-px2vplength)/[fp2px](./cj-apis-uicontext-uicontext.md#func-fp2pxlength)/[px2fp](./cj-apis-uicontext-uicontext.md#func-px2fplength)/[lpx2px](./cj-apis-uicontext-uicontext.md#func-lpx2pxlength)/[px2lpx](./cj-apis-uicontext-uicontext.md#func-px2lpxlength)调用绑定实例的接口。

## 示例代码

<!-- run -->

```cangjie

package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var isShow: Bool = false
    func build() {
        Column() {
            Flex(wrap: FlexWrap.Wrap) {
                Column() {
                    Text("width(180)")
                        .width(180)
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(22.vp)
                }.margin(5)

                Column() {
                    Text("width('180px')")
                        .width(180.px)
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                }.margin(5)

                Column() {
                    Text("width('180vp')")
                        .width(180.vp)
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(22.vp)
                }.margin(5)

                Column() {
                    Text("width('180lpx') designWidth:720")
                        .width(180.lpx)
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(22.vp)
                }.margin(5)

                Column() {
                    Text("width(vp2px(180) + 'px')")
                        .width(getUIContext().vp2px(180.vp) ?? 180.vp)
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(22.vp)
                }.margin(5)

                Column() {
                    Text("fontSize('22fp')")
                        .width(180)
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(22.fp)
                }.margin(5)

                Column() {
                    Text("width(px2vp(180))")
                        .width(getUIContext().px2vp(180.px) ?? 180.px )
                        .height(40)
                        .backgroundColor(0xF9CF93)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(22.fp)
                }.margin(5)
            }.width(100.percent)
        }
    }
}

```

![pixelUnits](./figures/pixelUnits.png)