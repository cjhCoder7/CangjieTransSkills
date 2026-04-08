# Flex布局

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

> **说明：**
>
> 仅当父组件是 [Flex](./cj-row-column-stack-flex.md)、[Column](./cj-row-column-stack-column.md)、[Row](./cj-row-column-stack-row.md)、[GridRow](./cj-grid-layout-gridrow.md)（仅针对[alignSelf](./cj-universal-attribute-flexlayout.md#func-alignselfitemalign)）时生效。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func alignSelf(?ItemAlign)

```cangjie
func alignSelf(value: ?ItemAlign): T
```

**功能：** 子组件在父容器交叉轴的对齐格式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ItemAlign](./cj-common-types.md#enum-itemalign)|是|-|子组件在父容器交叉轴的对齐格式，会覆盖Flex、Column、Row、GridRow布局容器中的alignItems设置。<br> GridCol可以绑定alignSelf属性来改变它自身在交叉轴方向上的布局。<br>初始值：ItemAlign.Auto。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func flexBasis(?Length)

```cangjie
func flexBasis(value: ?Length): T
```

**功能：** 设置组件的基准尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|组件在父容器主轴方向上的基准尺寸。<br>初始值：'auto'（表示组件在主轴方向上的基准尺寸为组件原本的大小）。<br>不支持设置percent。<br>取值范围(0,+∞)，默认单位为vp。<br>异常值：实际布局效果均与'auto'一致。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func flexGrow(?Float64)

```cangjie
func flexGrow(value: ?Float64): T
```

**功能：** 设置组件在父容器的剩余空间所占比例。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|父容器在主轴方向上的剩余空间分配给此属性所在组件的比例。<br>取值范围(0,+∞)，初始值：0.0。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func flexGrow(?Int64)

```cangjie
func flexGrow(value: ?Int64): T
```

**功能：** 设置组件在父容器的剩余空间所占比例。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int64|是|-|父容器在主轴方向上的剩余空间分配给此属性所在组件的比例。<br>取值范围(0,+∞)，初始值：0。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func flexShrink(?Float64)

```cangjie
func flexShrink(value: ?Float64): T
```

**功能：** 设置父容器压缩尺寸分配给此属性所在组件的比例。当父容器为Column、Row时，需设置主轴方向的尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|父容器压缩尺寸分配给此属性所在组件的比例。<br> 父容器为[Column](./cj-row-column-stack-column.md)、[Row](./cj-row-column-stack-row.md)时，取值范围(0,+∞)，初始值为0.0。 <br>父容器为[Flex](./cj-row-column-stack-flex.md)时，初始值：1.0。<br>[constraintSize](./cj-universal-attribute-layoutconstraints.md#func-constraintsizelength-length-length-length)限制组件的尺寸范围，[Column](./cj-row-column-stack-column.md)和[Row](./cj-row-column-stack-row.md)即使设置了[constraintSize](./cj-universal-attribute-layoutconstraints.md#func-constraintsizelength-length-length-length)，在未设置主轴尺寸（[width](./cj-universal-attribute-size.md#func-widthoptionlength)/[height](./cj-universal-attribute-size.md#func-heightoptionlength)/[size](./cj-universal-attribute-size.md#func-sizelength-length)）时仍遵守默认布局行为，在主轴上自适应子组件尺寸，此时flexShrink不生效。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func flexShrink(?Int64)

```cangjie
func flexShrink(value: ?Int64): T
```

**功能：** 设置父容器压缩尺寸分配给此属性所在组件的比例。当父容器为Column、Row时，需设置主轴方向的尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int64|是|-|父容器压缩尺寸分配给此属性所在组件的比例。<br> 父容器为Column、Row时，初始值为0。 <br>父容器为Flex时，初始值为1。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
