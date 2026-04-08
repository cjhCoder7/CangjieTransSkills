# Web

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供具有网页显示能力的Web组件，[@ohos.web.webview](../ArkWeb/cj-apis-webview.md)提供web控制能力。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(ResourceStr, WebviewController)

```cangjie
public init(
    src!: ResourceStr,
    controller!: WebviewController
)
```

**功能：** 创建一个Web组件。

> **说明：**
>
> - 不支持转场动画。
> - 同一页面的多个Web组件，必须绑定不同的WebviewController。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|src|[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** src不能通过状态变量（例如：@State）动态更改地址。|
|controller|[WebviewController](../ArkWeb/cj-apis-webview.md#class-webviewcontroller)|是|-| **命名参数。** 设置Web控制器。|

## 通用属性/通用事件

通用属性：仅支持[aspectRatio](./cj-universal-attribute-size.md#func-aspectratiofloat64)、[backdropBlur](./cj-universal-attribute-imageeffect.md#func-backdropblurfloat64)、[backgroundColor](./cj-universal-attribute-background.md#func-backgroundcolorresourcecolor)、[bindContentCover](./cj-universal-attribute-menu.md)、[bindContextMenu](./cj-universal-attribute-menu.md#func-bindcontextmenucustombuilder-responsetype-contextmenuoptions)、[bindMenu](./cj-universal-attribute-menu.md#func-bindmenuarraymenuelement) 、[bindSheet](./cj-universal-attribute-sheettransition.md#func-bindsheetbool-custombuilder-sheetoptions)、[borderColor](./cj-universal-attribute-border.md#func-bordercolorresourcecolor)、[borderStyle](./cj-common-types.md#enum-borderstyle)、[borderWidth](./cj-universal-attribute-border.md#func-borderwidthedgewidths)、[clip](./cj-common-types.md#clip)、[constraintSize](./cj-universal-attribute-layoutconstraints.md#func-constraintsizelength-length-length-length)、[defaultFocus](./cj-universal-attribute-focus.md#func-defaultfocusbool)、[focusable](./cj-universal-attribute-focus.md#func-focusablebool)、[tabIndex](./cj-universal-attribute-focus.md#func-tabindexint32)、[groupDefaultFocus](./cj-universal-attribute-focus.md#func-groupdefaultfocusbool)、[displayPriority](./cj-universal-attribute-size.md#func-displaypriorityint32)、[enabled](./cj-universal-attribute-enable.md#func-enabledbool)、[flexBasis](./cj-universal-attribute-flexlayout.md#func-flexbasislength)、[flexShrink](./cj-universal-attribute-flexlayout.md#func-flexshrinkfloat64)、[layoutWeight](./cj-universal-attribute-size.md#func-layoutweightint32)、[id](./cj-universal-attribute-componentid.md)、[height](./cj-universal-attribute-size.md#func-heightoptionlength)、[touchable](./cj-apis-window.md#var-touchable)、[margin](./cj-universal-attribute-size.md#func-marginlength)、[markAnchor](./cj-universal-attribute-location.md#func-markanchorlength-length)、[offset](./cj-apis-componentutils.md#class-offset)、[width](./cj-universal-attribute-size.md#func-widthoptionlength)、[zIndex](./cj-universal-attribute-zorder.md#func-zindexint32)、[visibility](./cj-common-types.md#enum-visibility)、[scale](./cj-animation-pagetransition.md#func-scalefloat32-float32-float32-length-length)、[translate](./cj-universal-attribute-transform.md#func-translatelength-length-length)、[responseRegion](./cj-universal-attribute-touchtarget.md#func-responseregionarrayrectangle)、[size](./cj-universal-attribute-size.md#func-sizelength-length)、[opacity](./cj-animation-pagetransition.md#func-opacityfloat64)、[sharedTransition](./cj-animation-sharedtransition.md#func-sharedtransitionstring-sharedtransitionoptions)、[transition](./cj-animation-transition.md#func-transitiontransitioneffect)、[position](./cj-universal-attribute-location.md#func-positionlength-length)、[direction](./cj-universal-attribute-layoutconstraints.md#func-directiondirection)。

通用事件：仅支持[onAppear](./cj-universal-event-appear.md#func-onappear---unit)、[onDisAppear](./cj-universal-event-appear.md#func-ondisappear---unit)、[onBlur](./cj-universal-event-focus.md#func-onblur---unit)、[onFocus](./cj-universal-event-focus.md#func-onfocus---unit)、[onHover](./cj-universal-event-mouse.md)、[onMouse](./cj-universal-event-mouse.md#func-onmousemouseevent---unit)、[onKeyEvent](./cj-universal-event-key.md#func-onkeyeventkeyevent---unit)、[onTouch](./cj-universal-event-touch.md#func-ontouchtouchevent---unit)、[onVisibleAreaChange](./cj-universal-event-visibleareachange.md#func-onvisibleareachangearrayfloat64-bool-float64---unit)。

## 组件属性

### func darkMode(?WebDarkMode)

```cangjie
public func darkMode(mode: ?WebDarkMode): This
```

**功能：** 设置Web深色模式，默认关闭。当深色模式开启时，Web将启用媒体查询prefers-color-scheme中网页所定义的深色样式，若网页未定义深色样式，则保持原状。如需开启强制深色模式，建议配合[forceDarkAccess](#func-forcedarkaccessbool)使用。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mode|?[WebDarkMode](./cj-common-types.md#enum-webdarkmode)|是|-|Web的深色模式为关闭、开启或跟随系统。<br>初始值：WebDarkMode.Off。|

### func domStorageAccess(?Bool)

```cangjie
public func domStorageAccess(domStorageAccess: ?Bool): This
```

**功能：** 设置是否开启文档对象模型存储接口（DOM Storage API）权限。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domStorageAccess|?Bool|是|-|是否开启文档对象模型存储接口（DOM Storage API）权限。true表示开启，false表示未开启。<br> 初始值：false。|

### func fileAccess(?Bool)

```cangjie
public func fileAccess(fileAccess: ?Bool): This
```

**功能：** 设置是否开启应用中文件系统的访问，默认启用。rawfile路径的文件不受该属性影响而限制访问。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fileAccess|?Bool|是|-|是否开启应用中文件系统的访问，默认启用。<br> 初始值：false|

### func forceDarkAccess(?Bool)

```cangjie
public func forceDarkAccess(access: ?Bool): This
```

**功能：** 设置网页是否开启强制深色模式。默认关闭。该属性仅在darkMode开启深色模式时生效。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|access|?Bool|是|-|设置网页是否开启强制深色模式。true：开启，false：关闭。<br>初始值：false。|

### func geolocationAccess(?Bool)

```cangjie
public func geolocationAccess(geolocationAccess: ?Bool): This
```

**功能：** 设置是否开启获取地理位置权限，默认关闭。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|geolocationAccess|?Bool|是|-|设置是否开启获取地理位置权限。<br>初始值：false。|

### func imageAccess(?Bool)

```cangjie
public func imageAccess(imageAccess: ?Bool): This
```

**功能：** 设置是否允许自动加载图片资源，默认允许。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|imageAccess|?Bool|是|-|是否允许自动加载图片资源。<br>初始值：false。|

### func javaScriptProxy(?Array\<(String) -> String>, ?String, ?Array\<String>, ?WebviewController)

```cangjie
public func javaScriptProxy(funcList!: ?Array<(String) -> String>, name!: ?String, methodList!: ?Array<String>,
    controller!: ?WebviewController): This
```

**功能：** 注入JavaScript对象到window对象中，并在window对象中调用该对象的方法。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|funcList|?Array\<(String)->String>|是|-| **命名参数。** 参与注册的应用侧JavaScript对象的同步方法。<br>初始值：[]。|
|name|?String|是|-| **命名参数。** 注册对象的名称，与window中调用的对象名一致。<br>初始值：""。|
|methodList|?Array\<String>|是|-| **命名参数。** 参与注册的应用侧JavaScript对象的异步方法。<br>初始值：[]。|
|controller|?[WebviewController](../ArkWeb/cj-apis-webview.md#class-webviewcontroller)|是|-| **命名参数。** 设置Web控制器。<br>初始值：WebviewController()。|

### func mixedMode(?MixedMode)

```cangjie
public func mixedMode(mixedMode: ?MixedMode): This
```

**功能：** 设置是否允许加载超文本传输协议（HTTP）和超文本传输安全协议（HTTPS）混合内容，默认不允许加载HTTP和HTTPS混合内容。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mixedMode|?[MixedMode](./cj-common-types.md#enum-mixedmode)|是|-|混合内容。<br>初始值：MixedMode.None。表示不允许安全来源（secure origin）加载不安全来源（insecure origin）的内容。|

### func nestedScroll(?NestedScrollMode, ?NestedScrollMode)

```cangjie
public func nestedScroll(
    scrollForward!: ?NestedScrollMode,
    scrollBackward!: ?NestedScrollMode
): This
```

**功能：** 设置向前向后两个方向上的嵌套滚动模式，实现与父组件的滚动联动。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|scrollForward|?[NestedScrollMode](./cj-common-types.md#enum-nestedscrollmode)|是|-| **命名参数。** 向前滚动模式。<br>初始值：NestedScrollMode.SelfFirst。|
|scrollBackward|?[NestedScrollMode](./cj-common-types.md#enum-nestedscrollmode)|是|-| **命名参数。** 向后滚动模式。<br>初始值：NestedScrollMode.SelfFirst。|

### func onlineImageAccess(?Bool)

```cangjie
public func onlineImageAccess(onlineImageAccess: ?Bool): This
```

**功能：** 设置是否允许从网络加载图片资源（通过HTTP和HTTPS访问的资源），默认不允许访问。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|onlineImageAccess|?Bool|是|-|是否允许从网络加载图片资源。true表示设置允许从网络加载图片资源，false表示设置不允许从网络加载图片资源。<br>初始值：false。|

### func verticalScrollBarAccess(?Bool)

```cangjie
public func verticalScrollBarAccess(verticalScrollBar: ?Bool): This
```

**功能：** 设置是否显示纵向滚动条，包括系统默认滚动条和用户自定义滚动条。默认不显示。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|verticalScrollBar|?Bool|是|-|是否显示纵向滚动条。true表示设置显示纵向滚动条，false表示设置不显示纵向滚动条。<br>初始值：false。|

### func zoomAccess(?Bool)

```cangjie
public func zoomAccess(zoomAccess: ?Bool): This
```

**功能：** 设置是否支持手势进行缩放，默认不允许执行缩放。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|zoomAccess|?Bool|是|-|是否支持手势进行缩放。true表示设置支持手势进行缩放，false表示设置不支持手势进行缩放。<br>初始值：false。|

## 组件事件

### func onLoadIntercept(?Callback\<OnLoadInterceptEvent, Bool>)

```cangjie
public func onLoadIntercept(callback: ?Callback<OnLoadInterceptEvent, Bool>): This
```

**功能：** 当Web组件加载url之前触发该回调，用于判断是否阻止此次访问。默认允许加载。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?Callback\<[OnLoadInterceptEvent](#class-onloadinterceptevent), Bool>|是|-|回调函数，截获资源加载时触发的回调。返回true表示阻止此次加载，否则允许此次加载。<br>初始值：{ _ => true}。|

### func onPageBegin(?Callback\<OnPageBeginEvent, Unit>)

```cangjie
public func onPageBegin(callback: ?Callback<OnPageBeginEvent, Unit>): This
```

**功能：** 网页开始加载时触发该回调，且只在主frame触发，iframe或者frameset的内容加载时不会触发此回调。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?Callback\<[OnPageBeginEvent](#class-onpagebeginevent), Unit>|是|-|回调函数，网页加载开始时触发回调。<br>初始值：{ _ => }。|

### func onPageEnd(?Callback\<OnPageEndEvent, Unit>)

```cangjie
public func onPageEnd(callback: ?Callback<OnPageEndEvent, Unit>): This
```

**功能：** 网页加载完成时触发该回调，且只在主frame触发。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?Callback\<[OnPageEndEvent](#class-onpageendevent), Unit>|是|-|是否允许从网络加载图片资源。true表示设置允许从网络加载图片资源，false表示设置不允许从网络加载图片资源。<br>初始值：{ _ => }。|

## 基础类型定义

### class Header

```cangjie
public class Header {
    public var headerKey: ?String
    public var headerValue: ?String
}
```

**功能：** 描述Web组件返回的请求/响应头对象。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### var headerKey

```cangjie
public var headerKey: ?String
```

**功能：** 请求/响应头的key。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### var headerValue

```cangjie
public var headerValue: ?String
```

**功能：** 请求/响应头的Value。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### class OnLoadInterceptEvent

```cangjie
public class OnLoadInterceptEvent {
    public var data: WebResourceRequest
    public init(data: WebResourceRequest)
}
```

**功能：** 当资源加载被拦截时，加载拦截事件。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### var data

```cangjie
public var data: WebResourceRequest
```

**功能：** 网页请求的封装信息。

**类型：** [WebResourceRequest](#class-webresourcerequest)

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### init(WebResourceRequest)

```cangjie
public init(data: WebResourceRequest)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|data|[WebResourceRequest](#class-webresourcerequest)|是|-|请求的信息。|

### class OnPageBeginEvent

```cangjie
public class OnPageBeginEvent {
    public var url: String
    public init(url: String)
}
```

**功能：** 定义网页加载开始时触发的函数。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### var url

```cangjie
public var url: String
```

**功能：** 当前加载页面的URL。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### init(String)

```cangjie
public init(url: String)
```

**功能：** 构造一个OnPageBeginEvent类型的对象。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|当前加载页面的URL。|

### class OnPageEndEvent

```cangjie
public class OnPageEndEvent {
    public var url: String
    public init(url: String)
}
```

**功能：** 定义网页加载结束时触发的函数。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### var url

```cangjie
public var url: String
```

**功能：** 当前加载页面的URL。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### init(String)

```cangjie
public init(url: String)
```

**功能：** OnPageEndEvent的构造函数。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|当前加载页面的URL。|

### class PermissionRequest

```cangjie
public class PermissionRequest {}
```

**功能：** Web组件返回授权或拒绝权限功能的对象。示例代码参考[onPermissionRequest](#class-onpermissionrequestevent)事件。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### func deny()

```cangjie
public func deny(): Unit
```

**功能：** 拒绝网页所请求的权限。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### func getAccessibleResource()

```cangjie
public func getAccessibleResource(): Array<String>
```

**功能：** 获取网页所请求的权限资源列表。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|网页所请求的权限资源列表。|

#### func getOrigin()

```cangjie
public func getOrigin(): String
```

**功能：** 获取网页来源。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|当前请求权限网页的来源。|

#### func grant(Array\<String>)

```cangjie
public func grant(resources: Array<String>): Unit
```

**功能：** 对网页访问的屏幕捕获操作进行授权。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resources|Array\<String>|是|-|屏幕捕获配置。|

### class WebResourceRequest

```cangjie
public class WebResourceRequest {}
```

**功能：** Web组件资源响应对象。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### func getRequestHeader()

```cangjie
public func getRequestHeader(): Array<Header>
```

**功能：** 获取资源请求头信息。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[Header](#class-header)>|返回资源请求头信息。|

#### func getRequestMethod()

```cangjie
public func getRequestMethod(): String
```

**功能：** 获取请求方法。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|返回请求方法。|

#### func getRequestUrl()

```cangjie
public func getRequestUrl(): String
```

**功能：** 获取资源请求的URL信息。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|返回资源请求的URL信息。|

#### func isMainFrame()

```cangjie
public func isMainFrame(): Bool
```

**功能：** 判断资源请求是否为主frame。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回资源请求是否为主frame。true表示返回资源请求为主frame，false表示返回资源请求不为主frame。|

#### func isRedirect()

```cangjie
public func isRedirect(): Bool
```

**功能：** 判断资源请求是否被服务端重定向。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回资源请求是否被服务端重定向。true表示返回资源请求被服务端重定向，false表示返回资源请求未被服务端重定向。|

#### func isRequestGesture()

```cangjie
public func isRequestGesture(): Bool
```

**功能：** 获取资源请求是否与手势（如点击）相关联。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回资源请求是否与手势（如点击）相关联。true表示返回资源请求与手势（如点击）相关联，false表示返回资源请求与手势（如点击）不相关联。|

### class OnPermissionRequestEvent

```cangjie
public class OnPermissionRequestEvent {
    public var request: PermissionRequest
    public init(request: PermissionRequest)
}
```

**功能：** 描述通知收到获取权限请求的参数结构。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### var request

```cangjie
public var request: PermissionRequest
```

**功能：** Web组件返回授权或拒绝权限功能的对象。示例代码参考[onPermissionRequest](#class-onpermissionrequestevent)事件。

**类型：** [PermissionRequest](#class-permissionrequest)

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

#### init(PermissionRequest)

```cangjie

public init(request: PermissionRequest)
```

**功能：** 构造一个OnPermissionRequestEvent类型的对象。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|request|[PermissionRequest](#class-permissionrequest)|是|-|Web组件返回授权或拒绝权限功能的对象。|

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.web.webview.*
import ohos.hilog.Hilog

@Entry
@Component
class EntryView {
    let webController = WebviewController()
    @State var url: String = "www.example.com"
    func build() {
        Column(space: 10) {
            Button("reload")
            .onClick({
                evt =>
                Hilog.info(0, "AppLogCj", "reload")
                webController.reload()
            }).width(400.px).height(150.px)
            Button("loadUrl")
            .onClick({
                evt =>
                Hilog.info(0, "AppLogCj", "loadUrl")
                webController.loadUrl(this.url)

            }).width(400.px).height(150.px)
            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "AppLogCj", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "AppLogCj", "page end url: ${evt.url}")
            })
        }
    }
}
```