# Menu

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

以垂直列表形式显示的菜单。

> **说明：**
>
> Menu组件需配合[bindMenu](cj-universal-attribute-menu.md#func-bindmenuarraymenuelement)或[bindContextMenu](cj-universal-attribute-menu.md#func-bindcontextmenucustombuilder-responsetype-contextmenuoptions)方法使用，不支持作为普通组件单独使用。

## 导入模块

```cangjie
import ohos.arkui.component.menu
```

## 子组件

包含[MenuItem](cj-menu-menuitem.md)、[MenuItemGroup](cj-menu-menuitemgroup.md)子组件。

## 创建组件

### init(() -> Unit)

```cangjie
public init(child!: () -> Unit = {=>})
```

**功能：** 创建一个存在子组件的菜单。

> **说明：**
>
> 菜单和菜单项宽度计算规则：<br/>布局过程中，期望每个菜单项的宽度一致。若子组件设置了宽度，则以[尺寸计算规则](./cj-universal-attribute-layoutconstraints.md#func-constraintsizelength-length-length-length)为准。<br/>不设置宽度的情况：菜单组件会对子组件MenuItem、MenuItemGroup设置默认2栅格的宽度，若菜单项内容区比2栅格宽，则会自适应撑开。<br/>设置宽度的情况：菜单组件会对子组件MenuItem、MenuItemGroup设置减去padding后的固定宽度。<br/>设置Menu边框[width](./cj-universal-attribute-size.md#func-widthoptionlength)时，支持设置的最小宽度为64vp。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|否|{=>}|**命名参数。** 声明容器内的子组件。|

## 通用属性/通用事件

通用属性：除[shadow](./cj-universal-attribute-imageeffect.md#func-shadowfloat64-resourcecolor-float64-float64)外，其余全部支持。

通用事件：全部支持。

## 组件属性

### func font(?Length, ?FontWeight, ?ResourceStr, ?FontStyle)

```cangjie
public func font(
    size!: ?Length = None,
    weight!: ?FontWeight = None,
    family!: ?ResourceStr = None,
    style!: ?FontStyle = None
): This
```

**功能：** 设置Menu中所有文本的尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置文本尺寸，Length为Int64、Float64类型时，使用fp单位。不支持百分比设置。初始值：16.vp。|
|weight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None|**命名参数。** 设置文本的字体粗细。初始值：FontWeight.Normal。|
|family|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 设置文本的字体列表。使用多个字体，使用','进行分割，优先级按顺序生效。例如：'Arial, HarmonyOS Sans'。当前支持'HarmonyOS Sans'字体和[注册自定义字体](./cj-apis-uicontext-font.md)。初始值："HarmonyOS Sans"。|
|style|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None|**命名参数。** 设置文本的字体样式。初始值：FontStyle.Normal。|

### func fontColor(?ResourceColor)

```cangjie
public func fontColor(value: ?ResourceColor): This
```

**功能：** 统一设置Menu中所有文本的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|Menu中所有文本的颜色。初始值：0x99000000。|

### func radius(?BorderRadiuses)

```cangjie
public func radius(value: ?BorderRadiuses): This
```

**功能：** 设置Menu边框圆角半径。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[BorderRadiuses](./cj-common-types.md#class-borderradiuses)|是|-|Menu边框圆角半径。|

### func radius(?Length)

```cangjie
public func radius(value: ?Length): This
```

**功能：** 设置Menu边框圆角半径。

> **说明：**
>
> 水平方向两个圆角半径之和的最大值大于菜单宽度，或垂直方向两个圆角半径之和的最大值大于菜单高度时，菜单四个圆角均采用菜单默认圆角半径值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|Menu边框圆角半径。|

## 示例代码

该示例通过配置MenuItem中的builder参数实现多级菜单。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource_manager.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    @State
    var select: Bool = true
    let iconStr: AppResource = @r(app.media.startIcon)
    var iconStr2: AppResource = @r(app.media.right)

    @Builder
    func SubMenu() {
        Menu() {
            MenuItem(startIcon: "", content: "复制", endIcon: "", labelInfo: "Ctrl+C")
            MenuItem(startIcon: "", content: "粘贴", endIcon: "", labelInfo: "Ctrl+V")
        }
    }

    @Builder
    func MyMenu() {
        Menu() {
            MenuItem(startIcon: @r(app.media.startIcon), content: @r(app.string.contentName),
                endIcon: @r(app.media.blank), labelInfo: @r(app.string.emptyName))
            MenuItem(startIcon: @r(app.media.startIcon), content: @r(app.string.contentName),
                endIcon: @r(app.media.blank), labelInfo: @r(app.string.emptyName)).enabled(false)
            MenuItem(
                startIcon: this.iconStr,
                content: @r(app.string.contentName),
                endIcon: this.iconStr,
                labelInfo: @r(app.string.emptyName),
                builder: this.SubMenu
            )
            MenuItemGroup(header: "小标题", footer: "") {
                =>
                MenuItem(
                    startIcon: this.iconStr,
                    content: @r(app.string.contentName),
                    endIcon: @r(app.string.emptyName),
                    labelInfo: @r(app.string.emptyName),
                    builder: this.SubMenu
                    )
                MenuItem(
                    startIcon: @r(app.media.startIcon),
                    content: @r(app.string.contentName),
                    endIcon: @r(app.media.right),
                    labelInfo: @r(app.string.emptyName),
                    builder: this.SubMenu
                )
                MenuItem(
                startIcon: "",
                content: "菜单选项",
                endIcon: "",
                labelInfo: "",
                ).selectIcon(true).selected(
                    select).onChange({
                    selected => iconStr2 = @r(app.media.foreground)
                })
            }

        }
    }

    func build() {
        Row() {
            Column() {
                Text("click to show menu")
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
            }.bindMenu(builder: this.MyMenu).width(50.percent)
        }.height(100.percent)
    }
}
```

![menu](./figures/menu.gif)