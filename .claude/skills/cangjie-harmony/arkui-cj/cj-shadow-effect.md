# 阴影

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

阴影接口[shadow](../reference/arkui-cj/cj-universal-attribute-imageeffect.md#func-shadowfloat64-resourcecolor-float64-float64)可以为当前组件添加阴影效果，开发者可配置[ShadowOptions](../reference/arkui-cj/cj-common-types.md#class-shadowoptions)自定义阴影效果。API version 26之前，当radius小于等于0或者color的透明度为0时，无阴影效果；从API version 26开始，当radius小于0或者color的透明度为0时，无阴影效果。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Row() {
            Column() {
                Column() {
                    Text('shadowOption').fontSize(12)
                }
                .width(100)
                .aspectRatio(1.0)
                .margin(10)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Color.White)
                .borderRadius(20)
                .shadow(radius: 10.0, color: Color.Gray)

                Column() {
                    Text('shadowOption').fontSize(12)
                }
                .width(100)
                .aspectRatio(1.0)
                .margin(10)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(0xF48899)
                .borderRadius(20)
                .shadow(radius: 10.0, color: Color.Gray, offsetX: 20.0, offsetY: 20.0)
            }
            .width(100.percent)
            .height(100.percent)
            .justifyContent(FlexAlign.Center)
        }
        .height(100.percent)
    }
}
```

![shadow](./figures/shadow.png)
