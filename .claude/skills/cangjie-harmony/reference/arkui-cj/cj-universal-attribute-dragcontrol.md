# 拖拽控制

设置组件是否可以响应拖拽事件。

> **说明：**
>
> ArkUI框架对以下组件实现了默认的拖拽能力，支持对数据的拖出或拖入响应。开发者也可以通过实现通用拖拽事件来自定义拖拽响应。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func dragPreview(String)

```cangjie
func dragPreview(value: String): T
```

**功能：** 设置组件拖拽过程中的预览图。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|String|是|-|组件拖拽过程中的预览图，此接口负责设置预览图，产生效果依赖其他接口。<br/>当组件支持拖拽并同时设置[bindContextMenu](./cj-universal-attribute-menu.md#func-bindcontextmenucustombuilder-responsetype-contextmenuoptions)的预览图时，则长按浮起的预览图以[bindContextMenu](./cj-universal-attribute-menu.md#func-bindcontextmenucustombuilder-responsetype-contextmenuoptions)设置的预览图为准。<br>当传入类型为String的id时，则将id对应组件的截图作为预览图。如果id对应的组件无法查找到，或者id对应的组件[Visibility](./cj-common-types.md#enum-visibility)属性设置成None/Hidden，则对组件自身进行截图作为拖拽预览图。目前截图不含有亮度、阴影、模糊和旋转等视觉效果。<br>初始值：空。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
