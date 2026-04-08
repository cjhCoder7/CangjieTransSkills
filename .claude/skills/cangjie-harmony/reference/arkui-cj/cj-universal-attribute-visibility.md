# 显隐控制

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

控制组件是否可见。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func visibility(?Visibility)

```cangjie
func visibility(value: ?Visibility): T
```

**功能：** 设置组件的可见性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Visibility](./cj-common-types.md#enum-visibility)|是|-|控制当前组件显示或隐藏。根据具体场景需要，可使用条件渲染代替。初始值: Visibility.Visible|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|