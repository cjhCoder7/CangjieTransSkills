# MenuItem

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用来展示菜单Menu中具体的item菜单项。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(() -> Unit)

```cangjie
public init(child!: () -> Unit = {=>}) 
```

**功能：** 构造一个有二级菜单的 item 菜单项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|否|{=>}|**命名参数。** 自定义UI描述。使用时结合[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)和[bind](cj-ui-framework.md#func-bindcustomview---viewbuilder-customview)方法使用。|

### init(?ResourceStr, ?ResourceStr, ?ResourceStr, ?ResourceStr, Option\<() -> Unit>)

```cangjie
public init(startIcon!: ?ResourceStr, content!: ?ResourceStr, endIcon!: ?ResourceStr, labelInfo!: ?ResourceStr,
    builder!: Option<() -> Unit> = None)
```

**功能：**构造一个有二级菜单的 item 菜单项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|startIcon|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** item中显示在左侧的图标信息路径。初始值：""。|
|content|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** item的内容信息。初始值：""。|
|endIcon|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** item中显示在右侧的图标信息路径。初始值：""。|
|labelInfo|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 定义结束标签信息，如快捷方式Ctrl+C等。初始值：""。|
|builder|Option\<() -> Unit>|否|None|**命名参数。** 自定义UI描述。使用时结合[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func contentFont(?Length, ?FontWeight, ?ResourceStr, ?FontStyle)

```cangjie
public func contentFont(
    size!: ?Length = None,
    weight!: ?FontWeight = None,
    family!: ?ResourceStr = None,
    style!: ?FontStyle = None
): This
```

**功能：**设置菜单项中内容信息的字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置文本尺寸，Length为Int64、Float64类型时，使用fp单位。不支持百分比设置。初始值：16.vp。|
|weight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None|**命名参数。** 设置文本的字体粗细。初始值：FontWeight.Normal。|
|family|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 设置文本的字体列表。使用多个字体，使用','进行分割，优先级按顺序生效。例如：'Arial, HarmonyOS Sans'。当前支持'HarmonyOS Sans'字体和[注册自定义字体](./cj-apis-uicontext-font.md)。初始值："HarmonyOS Sans"。|
|style|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None|**命名参数。** 设置文本的字体样式。初始值：FontStyle.Normal。|

### func contentFontColor(?ResourceColor)

```cangjie
public func contentFontColor(value: ?ResourceColor): This
```

**功能：** 设置菜单项中内容信息的字体颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|菜单项中内容信息的字体颜色。初始值：0xE5000000。|

### func labelFont(?Length, ?FontWeight, ?ResourceStr, ?FontStyle)

```cangjie
public func labelFont(
    size!: ?Length = None,
    weight!: ?FontWeight = None,
    family!: ?ResourceStr = None,
    style!: ?FontStyle = None
): This
```

**功能：**设置菜单项中标签信息的字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置文本尺寸，Length为Int64、Float64类型时，使用fp单位。不支持百分比设置。初始值：16.vp。|
|weight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None|**命名参数。** 设置文本的字体粗细。初始值：FontWeight.Normal。|
|family|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 设置文本的字体列表。使用多个字体，使用','进行分割，优先级按顺序生效。例如：'Arial, HarmonyOS Sans'。初始值："HarmonyOS Sans"。|
|style|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None|**命名参数。**  设置文本的字体样式。初始值：FontStyle.Normal。|

### func labelFontColor(?ResourceColor)

```cangjie
public func labelFontColor(value: ?ResourceColor): This
```

**功能：** 设置菜单项中标签信息的字体颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|菜单项中标签信息的字体颜色。初始值：0x99000000。|

### func selected(?Bool)

```cangjie
public func selected(value: ?Bool): This
```

**功能：** 设置菜单项是否选中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|菜单项是否选中。初始值：false。|

### func selectIcon(?Bool)

```cangjie
public func selectIcon(value: ?Bool): This
```

**功能：** 设置当菜单项被选中时，是否显示被选中的图标。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|菜单项被选中时，是否显示被选中的图标。初始值：false。|

### func selectIcon(?ResourceStr)

```cangjie
public func selectIcon(value: ?ResourceStr): This
```

**功能：** 设置当菜单项被选中时，是否显示被选中的图标。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|菜单项被选中时，显示指定的图标。初始值：""。|

## 组件事件

### func onChange(?(Bool) -> Unit)

```cangjie
public func onChange(callback: ?(Bool) -> Unit): This
```

**功能：** 当选中状态发生变化时，触发该事件。只有手动触发且MenuItem状态改变时才会触发onChange事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Bool) -> Unit|是|-|选中状态发生变化时，触发该回调。初始值：{ res: Bool => }。|

## 示例代码

详见[Menu](cj-menu-menu.md#示例代码)组件示例。