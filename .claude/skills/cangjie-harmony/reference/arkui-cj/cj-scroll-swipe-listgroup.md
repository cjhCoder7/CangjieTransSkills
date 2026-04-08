# ListItemGroup

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

该组件用来展示列表item分组，宽度默认充满[List](cj-scroll-swipe-list.md)组件，必须配合List组件来使用。

> **说明：**
>
> - 该组件的父组件只能是[List](cj-scroll-swipe-list.md)。
> - ListItemGroup组件不支持设置[通用属性aspectRatio](./cj-universal-attribute-size.md#func-aspectratiofloat64)。
> - 当ListItemGroup的父组件List的listDirection属性为Axis.Vertical时，设置[通用属性height](cj-universal-attribute-size.md#func-heightoptionlength)属性不生效。ListItemGroup的高度为header高度、footer高度和所有ListItem布局后总高度之和。
> - 当父组件List的listDirection属性为Axis.Horizontal时，设置[通用属性width](cj-universal-attribute-size.md#func-widthoptionlength)属性不生效。ListItemGroup的宽度为header宽度、footer宽度和所有ListItem布局后总宽度之和。
> - 当前ListItemGroup内部的ListItem组件不支持编辑、拖拽功能，即ListItem组件的editable属性不生效。
> - ListItemGroup使用direction属性设置布局方向不生效，ListItemGroup组件布局方向跟随父容器List组件的布局方向。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

包含[ListItem](./cj-scroll-swipe-listitem.md)子组件。

## 创建组件

### init(?CustomBuilder, ?CustomBuilder, ?Length, ?ListItemGroupStyle, () -> Unit)

```cangjie
public init(
    header!: ?CustomBuilder = None,
    footer!: ?CustomBuilder = None,
    space!: ?Length = None,
    style!: ?ListItemGroupStyle = Option.None,
    child!: () -> Unit
)
```

**功能：**  创建ListItemGroup组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名    | 类型              | 必填  | 默认值        | 说明                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|:------ |:--------------- |:--- |:---------- |:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| header | ?[CustomBuilder](./cj-common-types.md#type-custombuilder)  | 否   | None       | **命名参数。** 设置ListItemGroup头部组件。                                                                                                                                                                                                                                                                                                                                                                                                                        |
| footer | ?[CustomBuilder](./cj-common-types.md#type-custombuilder)  | 否   | None       | **命名参数。** 设置ListItemGroup尾部组件。                                                                                                                                                                                                                                                                                                                                                                                                                        |
| space  | ?[Length](./cj-common-types.md#interface-length)         | 否   | None       | **命名参数。** 列表项间距。只作用于ListItem与ListItem之间，不作用于header与ListItem、footer与ListItem之间。                                                                                                                                                                                                                                                                                                                                                   |
| style  | ?[ListItemGroupStyle](#enum-listitemgroupstyle) | 否   | Option.None | **命名参数。** 设置List组件卡片样式。                                                                                                                                                                                                                                                                                                                                                                                                                      |
| child  | ()->Unit        | 是   | -          | 声明容器子组件。                                                                                                                                                                                                                                                                                                                                                                                                                             |

## 通用属性/通用事件

通用属性：全部支持。

> **说明：**
>
> 不支持[设置通用属性aspectRatio](./cj-universal-attribute-size.md#func-aspectratiofloat64)。

通用事件：全部支持。

## 组件属性

### func divider(Option\<ListDividerOptions>)

```cangjie
public func divider(value: Option<ListDividerOptions>): This
```

**功能：** 设置ListItem分割线样式，默认无分割线。strokeWidth，startMargin和endMargin不支持设置百分比。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Option<[ListDividerOptions](#class-listdivideroptions)>|是|-|ListItem分割线样式。设置为Option.None时表示无分割线。|

## 基础类型定义

### class ListDividerOptions

```cangjie
public class ListDividerOptions {
    public var strokeWidth: ?Length
    public var color: ?ResourceColor
    public var startMargin: ?Length
    public var endMargin: ?Length
    public init(
        strokeWidth!: ?Length,
        color!: ?ResourceColor = None,
        startMargin!: ?Length = None,
        endMargin!: ?Length = None
    )
}
```

**功能：** ListItem分割线样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var color

```cangjie
public var color: ?ResourceColor
```

**功能：** 设置分割线的颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var endMargin

```cangjie
public var endMargin: ?Length
```

**功能：** 设置分割线距离列表侧边结束端的距离。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var startMargin

```cangjie
public var startMargin: ?Length
```

**功能：** 设置分割线距离列表侧边起始端的距离。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var strokeWidth

```cangjie
public var strokeWidth: ?Length
```

**功能：** 设置分割线的线宽。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Length, ?ResourceColor, ?Length, ?Length)

```cangjie
public init(
    strokeWidth!: ?Length,
    color!: ?ResourceColor = None,
    startMargin!: ?Length = None,
    endMargin!: ?Length = None
)
```

**功能：** 构造ListItem分割线样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名         | 类型            | 必填  | 默认值 | 说明               |
|:----------- |:------------- |:--- |:--- |:---------------- |
| strokeWidth | ?[Length](./cj-common-types.md#interface-length)       | 是   | -   | 分割线的线宽。          |
| color       | ?[ResourceColor](./cj-common-types.md#interface-resourcecolor) | 否   | None | 分割线的颜色。          |
| startMargin | ?[Length](./cj-common-types.md#interface-length)       | 否   | None | 分割线距离列表侧边起始端的距离。 |
| endMargin   | ?[Length](./cj-common-types.md#interface-length)       | 否   | None | 分割线距离列表侧边结束端的距离。 |

### enum ListItemGroupStyle

```cangjie
public enum ListItemGroupStyle <: Equatable<ListItemGroupStyle> {
    | None
    | Card
    | ...
}
```

**功能：** 设置List组件卡片样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：** Equatable\<[ListItemGroupStyle](#enum-listitemgroupstyle)>

#### Card

```cangjie
Card
```

**功能：** 显示默认卡片样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### None

```cangjie
None
```

**功能：** 无样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### operator func !=(ListItemGroupStyle)

```cangjie
public operator func !=(other: ListItemGroupStyle): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ListItemGroupStyle](#enum-listitemgroupstyle)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

#### operator func ==(ListItemGroupStyle)

```cangjie
public operator func ==(other: ListItemGroupStyle): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ListItemGroupStyle](#enum-listitemgroupstyle)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

## 示例代码

### 示例1（设置吸顶/吸底）

该示例实现了Header吸顶和Footer吸底的效果。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

class TimeTable {
  let title: String
  let projects: Array<String>

    public init(title:String,projects: Array<String>){
        this.title = title
        this.projects = projects
    }
}

@Entry
@Component

class EntryView {
     let timeTable = [
        TimeTable("Monday", ["Chinese", "Math", "English"]),
        TimeTable("Tuesday", ["Physics", "Chemistry", "Biology"]),
        TimeTable("Wednesday", ["History", "Geography", "Politics"]),
        TimeTable("Thursday", ["Art", "Music", "PE"])]

      @Builder func itemHead(text:String) {
        Text(text)
        .fontSize(20)
        .backgroundColor(0xAABBCC)
        .width(100.percent)
        .padding(20)
    }

    @Builder func itemFoot(num:Int64) {
        Text("Total ${num} classes")
        .fontSize(16)
        .backgroundColor(0xAABBCC)
        .width(100.percent)
        .padding(20)
  }

    func build() {
        Column() {
            List(space: 20) {
                ForEach(this.timeTable, itemGeneratorFunc: {item:TimeTable ,_:Int64 =>
                        ListItemGroup(header: this.itemHead(item.title), footer: this.itemFoot(item.projects.size)){
                            ForEach(item.projects,itemGeneratorFunc: {project:String,_:Int64=>
                                    ListItem(){
                                        Text(project)
                                        .width(100.percent)
                                        .height(100)
                                        .fontSize(20)
                                        .textAlign(TextAlign.Center)
                                        .backgroundColor(0xFFFFFF)
                                    }})
                        }
                        })
             }
        }
        .height(800.vp)
        .backgroundColor(Color(0XD3D3D3))
    }
}
```

![list_item_group](figures/listitem_group1.gif)
