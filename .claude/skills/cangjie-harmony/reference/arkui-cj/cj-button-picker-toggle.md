# Toggle

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

组件提供勾选框样式、状态按钮样式及开关样式。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

仅当ToggleType为Button时可包含子组件。

## 创建组件

### init(?ToggleType, ?Bool)

```cangjie
public init(toggleType: ?ToggleType, isOn!: ?Bool = None)
```

**功能：** 创建一个Toggle类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|toggleType|?[ToggleType](./cj-common-types.md#enum-toggletype)|是|-|开关类型。<br>初始值：ToggleType.Switch。|
|isOn|?Bool|否|None| **命名参数。** 开关是否打开。true：打开，false：关闭。<br>初始值：false。|

### init(?ToggleType, ?Bool, () -> Unit)

```cangjie
public init(toggleType: ?ToggleType, isOn: ?Bool, subcomponent: () -> Unit)
```

**功能：** 创建一个Toggle类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|toggleType|?[ToggleType](./cj-common-types.md#enum-toggletype)|是|-|开关类型。<br>初始值：ToggleType.Switch。|
|isOn|?Bool|是|-|开关是否打开。true：打开，false：关闭。<br>初始值：false。|
|subcomponent|() -> Unit|是|-|声明子组件。|

## 通用属性/通用事件

通用属性：全部支持

通用事件：全部支持。

## 组件属性

### func selectedColor(?ResourceColor)

```cangjie
public func selectedColor(value: ?ResourceColor): This
```

**功能：** 设置组件打开状态的背景颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](cj-common-types.md#interface-resourcecolor)|是|-|设置组件打开状态的背景颜色。|

### func switchPointColor(?ResourceColor)

```cangjie
public func switchPointColor(color: ?ResourceColor): This
```

**功能：** 设置Switch类型的圆形滑块颜色。仅对type为ToggleType.Switch生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|color|?[ResourceColor](cj-common-types.md#interface-resourcecolor)|是|-|Switch类型的圆形滑块颜色。|

## 组件事件

### func onChange(?(Bool) -> Unit)

```cangjie
public func onChange(callback: ?(Bool) -> Unit): This
```

**功能：** 组件选中状态发生变化时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Bool) -> Unit|是|-|组件选中状态变化时的回调函数。<br>初始值：{ _ => }。|

## 示例代码

### 示例1（设置开关的样式）

该示例通过配置ToggleType设置Toggle的勾选框样式、状态按钮样式及开关样式。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hilog.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 15) {
            Text("type: Switch")
            .fontSize(12)
            .fontColor(0xcccccc)
            .width(90.percent)
            Flex(justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center) {
                Toggle(ToggleType.Switch, isOn: false)
                .selectedColor(0xed6f21)
                .switchPointColor(0xe5ffffff)
                .onChange({isOn: Bool =>
                    loggerInfo("Component status: ${isOn}")
                })

                Toggle(ToggleType.Switch, isOn: true)
                .selectedColor(0x39a2db)
                .switchPointColor(0xe5ffffff)
                .onChange({isOn: Bool =>
                    loggerInfo("Component status: ${isOn}")
                })
            }

            Text("type: Checkbox")
            .fontSize(12)
            .fontColor(0xcccccc)
            .width(90.percent)
            Flex(justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center) {
                Toggle(ToggleType.Checkbox, isOn: false)
                .size(width: 28, height: 28)
                .selectedColor(0xed6f21)
                .onChange({isOn: Bool =>
                    loggerInfo("Component status: ${isOn}")
                })

                Toggle(ToggleType.Checkbox, isOn: true)
                .size(width: 28, height: 28)
                .selectedColor(0x39a2db)
                .onChange({isOn: Bool =>
                    loggerInfo("Component status: ${isOn}")
                })
            }

            Text("type: Button")
            .fontSize(12)
            .fontColor(0xcccccc)
            .width(90.percent)
            Flex(justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center) {
                Toggle(ToggleType.Button, false) {
                    Text("status")
                    .padding(left:12, right: 12)
                }
                .selectedColor(0xed6f21)
                .onChange({isOn: Bool =>
                    loggerInfo("Component status: ${isOn}")
                })

                Toggle(ToggleType.Button, true) {
                    Text("status")
                    .padding(left:12, right: 12)
                }
                .selectedColor(0x39a2db)
                .onChange({isOn: Bool =>
                    loggerInfo("Component status: ${isOn}")
                })
            }
        }
    }
}
```

![toggle](figures/toggle.gif)
