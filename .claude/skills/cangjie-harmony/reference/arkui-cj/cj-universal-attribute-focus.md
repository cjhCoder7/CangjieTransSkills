# 焦点控制

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

自定义组件的走焦效果，可设置组件是否走焦和具体的走焦顺序，Tab键或者方向键切换焦点。

> **说明：**
>
> - 自定义组件无获焦能力，当设置[focusable](./cj-universal-attribute-focus.md#func-focusablebool)、[enabled](./cj-universal-attribute-enable.md#func-enabledbool)等属性为false，或者设置[visibility](./cj-universal-attribute-visibility.md#func-visibilityvisibility)属性为Hidden、None时，也不影响其子组件的获焦。
> - 组件主动获取焦点不受窗口焦点的控制。
> - 焦点开发参考[焦点开发指南](./cj-universal-event-focus.md)。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func defaultFocus(?Bool)

```cangjie
func defaultFocus(value: ?Bool): T
```

**功能：** 设置当前组件是否为当前页面上的默认焦点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| value | ?Bool |是|-| 设置当前组件是否为当前页面上的默认焦点，仅在初次创建的页面第一次进入时生效。 <br/>初始值：false。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func focusable(?Bool)

```cangjie
func focusable(value: ?Bool): T
```

**功能：** 设置当前组件是否可以获焦。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| value | ?Bool | 是 | - | 当前组件是否可以获焦。true表示组件可以获焦，false表示组件不可获焦。 <br/>初始值：true。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func focusOnTouch(?Bool)

```cangjie
func focusOnTouch(value: ?Bool): T
```

**功能：** 设置当前组件是否支持点击获焦能力。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| value | ?Bool |是|-| 当前组件是否支持点击获焦能力。true表示组件支持点击获焦，false表示不支持点击获焦。 <br/>初始值：false。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func groupDefaultFocus(?Bool)

```cangjie
func groupDefaultFocus(value: ?Bool): T
```

**功能：** 设置当前组件是否为当前组件所在容器获焦时的默认焦点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| value | ?Bool |是|-| 当前组件是否为当前组件所在容器获焦时的默认焦点，仅在初次创建容器节点第一次获焦时生效。true表示当前组件为所在容器获焦时的默认焦点，false表示当前组件不是所在容器获焦时的默认焦点。 <br/>初始值：false。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func tabIndex(?Int32)

```cangjie
func tabIndex(index: ?Int32): T
```

**功能：** 自定义组件tab键走焦能力。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| index | ?Int32 |是|-| 自定义组件tab键走焦能力。若有配置了tabIndex大于0的组件，则tab键走焦只会在tabIndex大于0的组件内按照tabIndex的值从小到大并循环依次走焦。若没有配置tabIndex大于0的组件，则tabIndex等于0的组件按照组件预设的走焦规则走焦。 <br/>初始值：0。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## class FocusControl

```cangjie
public class FocusControl {}
```

**功能：** 焦点控制模块。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static func requestFocus(?String)

```cangjie
public static func requestFocus(value: ?String): Bool
```

**功能：** 方法语句中可使用的全局接口，调用此接口可以主动让焦点转移至参数指定的组件上。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| value | ?String | 是 | - | 目标组件使用接口key(value: string)或id(value: string)绑定的字符串。<br>返回是否成功给目标组件申请到焦点。若参数指向的目标组件存在，且目标组件可获焦，则返回true，否则返回false。 |

**返回值：**

|类型|说明|
| :-------   | :---------- |
| Bool | 返回是否成功给目标组件申请到焦点。若参数指向的目标组件存在，且目标组件可获焦，则返回true，否则返回false。|
