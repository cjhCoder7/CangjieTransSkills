# 全屏模态转场

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

通过bindContentCover属性为组件绑定全屏模态页面，在组件插入和删除时可通过设置转场参数ModalTransition显示过渡动效。

> **说明：**
>
> - 不支持横竖屏切换。
> - 不支持路由跳转。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func bindContentCover(?Bool, ?CustomBuilder, ?ContentCoverOptions)

```cangjie
func bindContentCover(isShow: ?Bool, builder: ?CustomBuilder, options!: ?ContentCoverOptions): T
```

**功能：** 给组件绑定全屏模态页面，点击后显示模态页面。模态页面内容自定义，显示方式可设置无动画过渡，上下切换过渡以及透明渐变过渡方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isShow|?Bool|是|-|是否显示全屏模态页面。<br/>初始值：false。|
|builder|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|配置全屏模态页面内容。<br>初始值：{ => }。|
|options|?[ContentCoverOptions](./cj-common-types.md#class-contentcoveroptions)|是|-|**命名参数。** 配置全屏模态页面的可选属性。<br/>初始值：ContentCoverOptions()。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
