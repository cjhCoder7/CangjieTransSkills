# 形状裁剪

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用于对组件进行裁剪、遮罩处理。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func clip(?Bool)

```cangjie
func clip(value: ?Bool): T
```

**功能：** 是否对子组件超出当前组件范围外的区域进行裁剪。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | ?Bool | 是 | - | 是否按照父容器边缘轮廓进行裁剪。 |

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func clipShape(?BaseShape)

```cangjie
func clipShape(value: ?BaseShape): T
```

**功能：** 按指定形状对当前组件进行裁剪。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | ?[BaseShape](./cj-apis-shape.md#class-baseshape) | 是 | - | 对当前组件进行裁剪的指定形状。 |

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func maskShape(BaseShape)

```cangjie
func maskShape(value: BaseShape): T
```

**功能：** 为组件上添加指定形状的遮罩。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| value | [BaseShape](./cj-apis-shape.md#class-baseshape) | 是 | - | 对当前组件进行遮罩指定的形状。 |

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
