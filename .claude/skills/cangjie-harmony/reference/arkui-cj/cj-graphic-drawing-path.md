# Path

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

路径绘制组件，根据绘制路径生成封闭的自定义形状。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?ResourceStr)

```cangjie
public init(commands!: ?ResourceStr = None)
```

**功能：** 根据绘制路径命令字符串创建一个路径绘制组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|commands|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 路径绘制的命令字符串。|

### init(?Length, ?Length, ?ResourceStr)

```cangjie
public init(width!: ?Length, height!: ?Length, commands!: ?ResourceStr = None)
```

**功能：** 根据路径所在的矩形宽度、高度创建一个路径绘制组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 路径所在矩形的宽度，取值范围≥0。默认单位：vp。值为异常值或缺省时按照自身内容需要的宽度处理。|
|height|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 路径所在矩形的高度，取值范围≥0。默认单位：vp。值为异常值或缺省时按照自身内容需要的高度处理。|
|commands|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 路径绘制的命令字符串。|

## 通用属性/通用事件

通用属性：除了支持通用属性外，还支持[图形绘制通用属性](./cj-graphic-drawing-common.md#组件属性)。

通用事件：全部支持。

## 组件属性

### func commands(?ResourceStr)

```cangjie
public func commands(value: ?ResourceStr): This
```

**功能：** 设置符合[SVG路径描述规范](#svg路径描述规范)的命令字符串，单位为px。像素单位转换方法请参考[像素单位转换](./cj-common-pixelunits.md)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|路径绘制的命令字符串。初始值：""，异常值按照初始值处理。|

## SVG路径描述规范

SVG路径描述规范支持的命令如下：

|命令|名称|参数|说明|
|:---|:---|:---|:---|
|M|moveto|(x y)|在给定的(x,y)坐标处开始一个新的子路径。例如，`M 0 0`表示将（0,0）点作为新子路径的起始点。|
|L|lineto|(x y)|从当前点到给定的(x,y)坐标画一条线，该坐标成为新的当前点。例如，`L 50 50`表示绘制当前点到(50,50)点的直线，并将(50,50)点作为新子路径的起始点。|
|H|horizontallineto|x|从当前点绘制一条水平线，等效于将y坐标指定为0的L命令。例如，`H 50`表示绘制当前点到(50,0)点的直线，并将(50,0)点作为新子路径的起始点。|
|V|verticallineto|y|从当前点绘制一条垂直线，等效于将x坐标指定为0的L命令。例如，`V 50`表示绘制当前点到(0,50)点的直线，并将(0,50)点作为新子路径的起始点。|
|C|curveto|(x1 y1 x2 y2 x y)|使用(x1,y1)作为曲线起点的控制点，(x2,y2)作为曲线终点的控制点，从当前点到(x,y)绘制三次贝塞尔曲线。例如，`C100 100 250 100 250 200`表示绘制当前点到(250,200)点的三次贝塞尔曲线，并将(250,200)点作为新子路径的起始点。|
|S|smoothcurveto|(x2 y2 x y)|(x2,y2)作为曲线终点的控制点，绘制从当前点到(x,y)绘制三次贝塞尔曲线。若前一个命令是C或S，则起点控制点是上一个命令的终点控制点相对于起点的映射。例如，`C100 100 250 100 250 200 S400 300 400 200`第二段贝塞尔曲线的起点控制点为(250,300)。如果没有前一个命令或者前一个命令不是C或S，则第一个控制点与当前点重合。|
|Q|quadraticBelziercurve|(x1 y1 x y)|使用(x1,y1)作为控制点，从当前点到(x,y)绘制二次贝塞尔曲线。例如，`Q400 50 600 300`表示绘制当前点到(600,300)点的二次贝塞尔曲线，并将(600,300)点作为新子路径的起始点。|
|T|smoothquadraticBelziercurveto|(x y)|绘制从当前点到(x,y)绘制二次贝塞尔曲线。若前一个命令是Q或T，则控制点是上一个命令的终点控制点相对于起点的映射。例如，`Q400 50 600 300 T1000 300`第二段贝塞尔曲线的控制点为(800,350)。如果没有前一个命令或者前一个命令不是Q或T，则第一个控制点与当前点重合。|
|A|ellipticalArc|(rx ry x-axis-rotation large-arc-flag sweep-flag x y)|从当前点到(x,y)绘制一条椭圆弧。椭圆的大小和方向由两个半径(rx,ry)和x-axis-rotation定义，指示整个椭圆相对于当前坐标系如何旋转（以度为单位）。large-arc-flag和sweep-flag确定弧的绘制方式。|
|Z|closepath|none|通过将当前路径连接回当前子路径的初始点来关闭当前子路径。|

例如： commands("M0 20 L50 50 L50 100 Z")定义了一个三角形，起始于位置(0,20)，接着绘制点(0,20)到点(50,50)的直线，再绘制点(50,50)到点(50,100)的直线，最后绘制点(50,100)到(0,20)的直线关闭路径，形成封闭三角形。

## 示例代码

绘制直线，直线图形和弧线图形的示例。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column {
            Text("Straight line")
                .size(width: 50.percent, height: 25.vp)
                .fontSize(20)
                .margin(10.vp)
            // 绘制一条长600px，宽3vp的直线
            Path()
                .width(600.px)
                .height(10.px)
                .commands("M0 0 L600 0")
                .stroke(Color.Black)
                .strokeWidth(3)

            Text('Straight line graph')
                .fontSize(20)
                .size(width: 50.percent, height: 25.vp)
                .margin(10.vp)
            // 绘制直线图形
            Flex(direction: FlexDirection.Row, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap) {
                Path()
                    .width(210.px)
                    .height(310.px)
                    .commands("M100 0 L200 240 L0 240 Z")
                    .fillOpacity(0.0)
                    .stroke(Color.Black)
                    .strokeWidth(3)

                Path()
                    .width(210.px)
                    .height(310.px)
                    .commands("M0 0 H200 V200 H0 Z")
                    .fillOpacity(0.0)
                    .stroke(Color.Black)
                    .strokeWidth(3)

                Path()
                    .width(210.px)
                    .height(310.px)
                    .commands("M100 0 L0 100 L50 200 L150 200 L200 100 Z")
                    .fillOpacity(0.0)
                    .stroke(Color.Black)
                    .strokeWidth(3)
            }.width(90.percent)

            Text('Curve graphics')
                .fontSize(20)
                .size(width: 50.percent, height: 25.vp)
                .margin(10.vp)
            Flex(direction: FlexDirection.Row, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap) {
                Path()
                    .width(210.px)
                    .height(310.px)
                    .commands("M0 300 S100 0 240 300 Z")
                    .fillOpacity(0.0)
                    .stroke(Color.Black)
                    .strokeWidth(3)

                Path()
                    .width(210.px)
                    .height(310.px)
                    .commands("M0 150 C0 100 140 0 200 150 L100 300 Z")
                    .fillOpacity(0.0)
                    .stroke(Color.Black)
                    .strokeWidth(3)

                Path()
                    .width(210.px)
                    .height(310.px)
                    .commands("M0 100 A30 20 20 0 0 200 100 Z")
                    .fillOpacity(0.0)
                    .stroke(Color.Black)
                    .strokeWidth(3)
            }.width(90.percent)
        }.width(100.percent)
    }
}
```

![path](./figures/path.png)
