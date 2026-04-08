# Divider

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供分隔器组件，分隔不同内容块/内容元素。

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

**功能：** 创建一个分隔器组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func color(?ResourceColor)

```cangjie
public func color(value: ?ResourceColor): This
```

**功能：** 设置分割线的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | ?[ResourceColor](./cj-common-types.md#interface-resourcecolor) | 是   | -   | 分割线颜色。初始值: 0x33182431 |

### func lineCap(?LineCapStyle)

```cangjie
public func lineCap(value: ?LineCapStyle): This
```

**功能：** 设置当前在容器中的分割线端点样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | ?[LineCapStyle](./cj-common-types.md#enum-linecapstyle) | 是  | - | 分割线条的端点样式。初始值: LineCapStyle.Butt |

### func strokeWidth(?Length)

```cangjie
public func strokeWidth(value: ?Length): This
```

**功能：** 设置当前在容器中的分割线宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | ?[Length](./cj-common-types.md#interface-length)| 是 | - | 分割线宽度。不指定像素单位时，默认单位vp。不支持百分比设置。不支持百分比设置。优先级低于通用属性[height](./cj-universal-attribute-size.md#func-heightoptionlength)，超过通用属性设置大小时，按照通用属性进行裁切。部分设备硬件中存在1像素取整后分割线不显示问题，建议使用2像素。初始值: 1.0.px |

### func vertical(?Bool)

```cangjie
public func vertical(value: ?Bool): This
```

**功能：** 设置分割线的方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | ?Bool | 是   | -   | 设置分割线的方向。初始值: false |

## 示例代码

### 示例1（使用横向与纵向分割线场景）

定义了Divider的样式，如方向、颜色及宽度。

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
            // 使用横向分割线场景
            Text("Horizontal divider")
                .fontSize(9)
                .fontColor(0xCCCCCC)
            List() {
                ForEach(
                    [1, 2, 3],
                    itemGeneratorFunc: {
                        item: Int64, idx: Int64 => ListItem() {
                            Text("list" + item.toString())
                                .width(100.percent)
                                .fontSize(14)
                                .fontColor(0x182431)
                                .textAlign(TextAlign.Start)
                        }
                        .width(244)
                        .height(48)
                    }
                )
            }.padding(left: 24, bottom: 8)

            Divider()
                .strokeWidth(8)
                .color(0xF1F3F5)
            List() {
                ForEach(
                    [4, 5],
                    itemGeneratorFunc: {
                        item: Int64, idx: Int64 => ListItem() {
                            Text("list" + item.toString())
                                .width(100.percent)
                                .fontSize(14)
                                .fontColor(0x182431)
                                .textAlign(TextAlign.Start)
                        }
                        .width(244)
                        .height(48)
                    }
                )
            }.padding(left: 24, top: 8)

            // 使用纵向分割线场景
            Text("Vertical divider")
                .fontSize(9)
                .fontColor(0xCCCCCC)
            Column() {
                Column() {
                    Row()
                        .width(288)
                        .height(64)
                        .backgroundColor(0x30C9F0)
                        .opacity(0.3)
                    Row() {
                        Button("Button")
                            .width(136)
                            .height(22)
                            .fontSize(16)
                            .fontColor(0x007DFF)
                            .fontWeight(FontWeight.W500)
                            .backgroundColor(Color.Transparent)
                        Divider()
                            .vertical(true)
                            .height(22)
                            .color(0x182431)
                            .opacity(0.6)
                            .margin(left: 8, right: 8)
                        Button("Button")
                            .width(136)
                            .height(22)
                            .fontSize(16)
                            .fontColor(0x007DFF)
                            .fontWeight(FontWeight.W500)
                            .backgroundColor(Color.Transparent)
                    }.margin(top: 17)
                }
                .width(336)
                .height(152)
                .backgroundColor(0xFFFFFF)
                .borderRadius(24)
                .padding(24)
            }
            .width(100.percent)
            .height(168)
            .backgroundColor(0xF1F3F5)
            .justifyContent(FlexAlign.Center)
            .margin(top: 8)
        }
        .width(100.percent)
        .padding(top: 24)
    }
}
```

![divider1](figures/divider.png)
