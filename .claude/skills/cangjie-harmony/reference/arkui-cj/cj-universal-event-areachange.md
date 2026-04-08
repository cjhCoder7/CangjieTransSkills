# 组件区域变化事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

组件区域变化事件指组件显示的尺寸、位置等发生变化时触发的事件。

> **说明：**
>
> onAreaChange回调执行仅与本组件有关，对祖先或子孙组件上的onAreaChange的回调没有严格的执行顺序和限制保障。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onAreaChange(?(Area, Area) -> Unit)

```cangjie
func onAreaChange(event: ?(Area, Area) -> Unit): T
```

**功能：** 组件区域变化时触发该回调。仅会响应由布局变化所导致的组件大小、位置发生变化时的回调。

由绘制变化所导致的渲染属性变化不会响应回调，如translate、offset。若组件自身位置由绘制变化决定也不会响应回调，如bindSheet。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?([Area](./cj-common-types.md#class-area), [Area](./cj-common-types.md#class-area)) -> Unit|是|-|组件区域变化时触发该回调。<br/>参数一：变化前的组件区域信息。<br/>参数二：变化后的组件区域信息。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|