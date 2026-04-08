# ohos.web.webview（Webview）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

webview模块提供web控制能力，组件提供网页显示的能力。

## 导入模块

```cangjie
import kit.ArkWeb.*
```

## 权限列表

ohos.permission.APPROXIMATELY_LOCATION

ohos.permission.LOCATION

ohos.permission.LOCATION_IN_BACKGROUND

ohos.permission.INTERNET

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[接口使用说明](../cj-development-intro.md#接口使用说明)。

## class BackForwardList

```cangjie
public class BackForwardList {}
```

**功能：** 当前Webview的历史信息列表。

> **说明：**
>
> 示例效果请以真机运行为准，当前DevEco Studio预览器不支持。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### prop currentIndex

```cangjie
public prop currentIndex: Int32
```

**功能：** 当前页面在历史列表中的索引。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### prop size

```cangjie
public prop size: Int32
```

**功能：** 历史列表中索引的数量，最多保存50条，超过时起始记录会被覆盖。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### func getItemAtIndex(Int32)

```cangjie
public func getItemAtIndex(index: Int32): HistoryItem
```

**功能：** 获取历史列表中指定索引的历史记录项信息。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|index|Int32|是|-|指定历史列表中的索引。|

**返回值：**

|类型|说明|
|:----|:----|
|[HistoryItem](#class-historyitem)|历史记录项。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_0 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getItemAtIndex")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getItemAtIndex")
                let backForwardList = webController.getBackForwardEntries()
                let historyItem = backForwardList.getItemAtIndex(backForwardList.currentIndex)
                Hilog.info(0, "cangjieTest", "Current historyUrl is ${historyItem.historyUrl}.")
                Hilog.info(0, "cangjieTest", "Current historyRawUrl is ${historyItem.historyRawUrl}.")
                Hilog.info(0, "cangjieTest", "Current title is ${historyItem.title}.")
                let pixelMap = historyItem.icon
                let byteInfo = pixelMap?.getPixelBytesNumber() ?? 0
                Hilog.info(0, "cangjieTest", "icon byteInfo is ${byteInfo}")
            }).width(400.px).height(150.px)
            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

## class HistoryItem

```cangjie
public class HistoryItem {
    public var icon: ?PixelMap
    public var historyUrl: String
    public var historyRawUrl: String
    public var title: String
}
```

**功能：** 页面历史记录项。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var historyRawUrl

```cangjie
public var historyRawUrl: String
```

**功能：** 历史记录项的原始URL地址。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var historyUrl

```cangjie
public var historyUrl: String
```

**功能：** 历史记录项的URL地址。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var title

```cangjie
public var title: String
```

**功能：** 历史记录项的标题。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var icon

```cangjie
public var icon: ?PixelMap
```

**功能：** 历史页面图标的PixelMap对象。

**类型：** ?[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

## class HitTestValue

```cangjie
public class HitTestValue {
    public var hitTestType: WebHitTestType
    public var extra: String
}
```

**功能：** 提供点击区域的元素信息。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var extra

```cangjie
public var extra: String
```

**功能：** 点击区域的附加参数信息。若被点击区域为图片或链接，则附加参数信息为其url地址。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var hitTestType

```cangjie
public var hitTestType: WebHitTestType
```

**功能：** 当前被点击区域的元素类型。

**类型：** [WebHitTestType](#enum-webhittesttype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

## class WebCookieManager

```cangjie
public class WebCookieManager {}
```

**功能：** 通过WebCookie可以控制Web组件中的cookie的各种行为，其中每个应用中的所有web组件共享一个WebCookieManager实例。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### static func clearAllCookies(Bool)

```cangjie
public static func clearAllCookies(incognito!: Bool = false): Unit
```

**功能：** 清除所有cookie。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|incognito|Bool|否|false|**命名参数。** true表示清除隐私模式下Webview的所有内存cookies，false表示清除正常非隐私模式下的持久化cookies。<br>默认值：false。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // cookie从web session中获取，如从http请求的request中获取。此示例中假设获取到的cookie为"ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置的cookie
    let cookie = "ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置指定url的cookie
    WebCookieManager.configCookie("https://www.example.com", cookie, incognito: false)
    // ... 
    // 此处执行业务逻辑，如加载带有cookie的网页。
    // 执行完后清除cookie
    WebCookieManager.clearAllCookies()
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", "ErrorCode: ${e.code}, ErrorMessage: ${e.message}")
}
```

### static func clearSessionCookie()

```cangjie
public static func clearSessionCookie(): Unit
```

**功能：** 清除所有会话cookie。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // cookie从web session中获取，如从http请求的request中获取。此示例中假设获取到的cookie为"ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置的cookie
    let cookie = "ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置指定url的cookie
    WebCookieManager.configCookie("https://www.example.com", cookie, incognito: false)
    // ... 
    // 此处执行业务逻辑，如加载带有cookie的网页。
    // 执行完后清除cookie
    WebCookieManager.clearSessionCookie()
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", "ErrorCode: ${e.code}, ErrorMessage: ${e.message}")
}
```

### static func configCookie(String, String, Bool)

```cangjie
public static func configCookie(url: String, value: String, incognito!: Bool = false): Unit
```

**功能：** 为指定URL设置cookie的值。

> **说明：**
>
> - configCookie中的url，可以指定域名的方式来使得页面内请求也附带上cookie。
>
> - 同步cookie的时机建议在Web组件加载之前完成。
>
> - 若通过configCookie进行两次或多次设置cookie，则每次设置的cookie之间会通过"; "进行分隔。
>
> - cookie每30s周期性保存到磁盘中。
>
> - 若存在相同host、path和名称的cookie，将被新cookie替换。若设置的cookie已过期，则不会存储该cookie。如需设置多个cookie，应多次调用此方法。
>
> - value参数必须遵循Set-Cookie HTTP响应头的格式。形式为"key=value"的键值对，后面可跟随以分号分隔的cookie属性列表（例如"key=value;Max-Age=100"）。
>
> - 如果指定的值包含"Secure"属性，则url必须使用"https://"协议。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|要设置的cookie所属的url，建议使用完整的url。|
|value|String|是|-|要设置的cookie的值。|
|incognito|Bool|否|false|**命名参数。** true表示设置隐私模式下对应url的cookies，false表示设置正常非隐私模式下对应url的cookies。<br>默认值：false。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100002 | URL error. No valid cookie found for the specified URL. |
  | 17100005 | The provided cookie value is invalid. It must follow the format specified. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // cookie从web session中获取，如从http请求的request中获取。此示例中假设获取到的cookie为"ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置的cookie
    let cookie = "ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置指定url的cookie
    WebCookieManager.configCookie("https://www.example.com", cookie, incognito: false)
    // ... 
    // 此处执行业务逻辑，如加载带有cookie的网页。
    // 执行完后清除cookie
    WebCookieManager.clearSessionCookie()
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", "ErrorCode: ${e.code}, ErrorMessage: ${e.message}")
}
```

### static func hasCookie(Bool)

```cangjie
public static func hasCookie(incognito!: Bool = false): Bool
```

**功能：** 获取是否存在cookie。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|incognito|Bool|否|false|**命名参数。** true表示隐私模式下查询是否存在cookies，false表示正常非隐私模式下查询是否存在cookies。<br>默认值：false。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true表示存在cookie，false表示不存在cookie。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog

let result = WebCookieManager.hasCookie()
Hilog.info(0, "AppLogCj", "WebCookiemanager result: ${result}")
```

### static func fetchCookie(String, Bool)

```cangjie
public static func fetchCookie(url: String, incognito!: Bool = false): String
```

**功能：** 获取指定url对应cookie的值。

> **说明：**
>
> - 系统会自动清理过期的cookie，对于同名key的数据，新数据将会覆盖前一个数据。
>
> - 为了获取可正常使用的cookie值，fetchCookie需传入完整链接。
>
> - fetchCookie用于获取所有的cookie值，每条cookie值之间会通过"; "进行分隔，但无法单独获取某一条特定的cookie值。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|要获取的cookie所属的url，建议使用完整的url。|
|incognito|Bool|否|false|**命名参数。** true表示获取隐私模式下webview的内存cookies，false表示正常非隐私模式下的cookies。<br>默认值：false。|

**返回值：**

|类型|说明|
|:----|:----|
|String|指定url对应的cookie的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100002 | URL error. No valid cookie found for the specified URL. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    // 需要设置的cookie，其中cookie的格式为name=value，本例中name为ZFY，value为4Mvfh8V4iYFnDc8CGowMa3KE4m0dV
    let cookie = "ZFY=4Mvfh8V4iYFnDc8CGowMa3KE4m0dV"
    // 设置指定url的cookie
    WebCookieManager.configCookie("https://www.example.com", cookie, incognito: false)
    // 设置完后获取指定url的cookie
    let value = WebCookieManager.fetchCookie("https://www.example.com")
    Hilog.info(0, "AppLogCj",  "WebCookieManager,fetchCookie cookie = ${value}", "")
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", "ErrorCode: ${e.code}, ErrorMessage: ${e.message}", "")
}
```

### static func isCookieAllowed()

```cangjie
public static func isCookieAllowed(): Bool
```

**功能：** 获取WebCookieManager实例是否拥有发送和接收cookie的权限。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|是否拥有发送和接收cookie的权限。<br>true表示拥有发送和接收cookie的权限，false表示无发送和接收cookie的权限。<br>默认值：true。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog

let result = WebCookieManager.isCookieAllowed()
Hilog.info(0, "AppLogCj",  "WebCookieManager, result: ${result}")
```

### static func isThirdPartyCookieAllowed()

```cangjie
public static func isThirdPartyCookieAllowed(): Bool
```

**功能：** 获取WebCookieManager实例是否拥有发送和接收第三方cookie的权限。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|是否拥有发送和接收第三方cookie的权限。<br>true表示拥有发送和接收第三方cookie的权限，false表示无发送和接收第三方cookie的权限。<br>默认值：false。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog

let result = WebCookieManager.isThirdPartyCookieAllowed()
Hilog.info(0, "AppLogCj",  "WebCookieManager, result: ${result}")
```

### static func setAcceptCookiesEnabled(Bool)

```cangjie
public static func setAcceptCookiesEnabled(accept: Bool): Unit
```

**功能：** 设置WebCookieManager实例是否拥有发送和接收cookie的权限。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|accept|Bool|是|-|设置是否拥有发送和接收cookie的权限，true表示拥有发送和接收cookie的权限。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog

WebCookieManager.setAcceptCookiesEnabled(false)
```

### static func setAcceptThirdPartyCookieEnabled(Bool)

```cangjie
public static func setAcceptThirdPartyCookieEnabled(accept: Bool): Unit
```

**功能：** 设置WebCookieManager实例是否拥有发送和接收第三方cookie的权限。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|accept|Bool|是|-|是否允许设置、获取第三方cookie。<br>true表示允许设置、获取第三方cookie，false表示不允许设置、获取第三方cookie。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog

WebCookieManager.setAcceptThirdPartyCookieEnabled(true)
```

## class WebHeader

```cangjie
public class WebHeader {
    public var headerKey: String
    public var headerValue: String
    public init(headerKey: String, headerValue: String)
}
```

**功能：** Web组件返回的请求/响应头对象。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var headerKey

```cangjie
public var headerKey: String
```

**功能：** 请求/响应头的key。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### var headerValue

```cangjie
public var headerValue: String
```

**功能：** 请求/响应头的value。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### init(String, String)

```cangjie
public init(headerKey: String, headerValue: String)
```

**功能：** WebHeader的构造函数。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|headerKey|String|是|-|请求/响应头的key。|
|headerValue|String|是|-|请求/响应头的value。|

## class WebviewController

```cangjie
public class WebviewController {
    public init(webTag!: ?String = None)
}
```

**功能：** 通过WebviewController可以控制Web组件各种行为（包括页面导航、生命周期状态、JavaScript交互等行为）。一个WebviewController对象只能控制一个Web组件，且必须在Web组件和WebviewController绑定后，才能调用WebviewController上的方法（静态方法除外）。

> **说明：**
>
> 示例效果请以真机运行为准，当前DevEco Studio预览器不支持。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### init(?String)

```cangjie
public init(webTag!: ?String = None)
```

**功能：** 用于创建 WebviewController 对象的构造函数。

> **说明：**
>
> Web组件销毁后会解绑WebViewController，之后调用WebviewController的非静态方法会抛出17100001异常，应注意调用时机和捕获异常，防止进程异常退出。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|webTag|?String|否|None|**命名参数。** 指定了Web组件的名称。|

### static func setWebDebuggingAccess(Bool)

```cangjie
public static func setWebDebuggingAccess(webDebuggingAccess: Bool): Unit
```

**功能：** 设置是否启用网页调试功能。

安全提示：启用网页调试功能可以让用户检查修改Web页面内部状态，存在安全隐患，不建议在应用正式发布版本中启用。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|webDebuggingAccess|Bool|是|-|设置是否启用网页调试功能。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_1 {
    let webController = WebviewController()
    let headers = [WebHeader("headerKey", "headerValue")]
    func build() {
        Column(space: 10) {
            Button("setWebDebuggingAccess")
            .onClick ({
                evt =>
                Hilog.info(0, "AppLogCj", "setWebDebuggingAccess")
                WebviewController.setWebDebuggingAccess(true)
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

### func canGoBack()

```cangjie
public func canGoBack(): Bool
```

**功能：** 当前页面是否可后退，即当前页面是否有返回历史记录。

可以结合使用[getBackForwardEntries](#func-getbackforwardentries)来获取当前WebView的历史信息列表，以及使用[accessStep](#func-accessstepint32)来判断是否可以按照给定的步数前进或后退。

> **说明：**
>
> - 在Web组件首次加载过程中调用[setCustomUserAgent](#func-setcustomuseragentstring)，可能会导致在当前存在多个历史节点的情况下，获取的canGoBack实际为false，即没有后退节点。建议先调用setCustomUserAgent方法设置UserAgent，再通过loadUrl加载具体页面。
>
> - 该现象是由于在Web组件首次加载时，调用[setCustomUserAgent](#func-setcustomuseragentstring)会导致组件重新加载并保持初始历史节点的状态。随后新增的节点将替换初始历史节点，不会生成新的历史节点，导致canGoBack为false。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|当前页面可以后退返回true,否则返回false。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_2 {
    let webController = WebviewController()
    func build() {
        Column(space:10) {
            Button("canGoBack")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "canGoBack")
                let bool = webController.canGoBack()
                Hilog.info(0, "cangjieTest", "canGoBack returns ${bool}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func accessStep(Int32)

```cangjie
public func accessStep(step: Int32): Bool
```

**功能：** 当前页面是否可前进或者后退给定的step步。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|step|Int32|是|-|要跳转的步数，正数代表前进，负数代表后退。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|页面是否前进或后退。<br>返回true表示可以前进或者后退，返回false表示不可以前进或后退。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkUI.Text
import kit.ArkUI.ObservedProperty
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_3 {
    var message: String = "Hello World"
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("accessStep")
             Text(this.message).onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "accessStep")
                let access = webController.accessStep(2)
                Hilog.info(0, "cangjieTest", "accessStep returns: ${access}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func goBackOrForward(Int32)

```cangjie
public func goBackOrForward(step: Int32): Unit
```

**功能：** 按照历史栈，前进或者后退指定步长的页面，当历史栈中不存在对应步长的页面时，不会进行页面跳转。

前进或者后退页面时，直接使用已加载过的网页，无需重新加载网页。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|step|Int32|是|-|需要前进或后退的步长。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_4 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("goBackOrForward")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "goBackOrForward")
                webController.goBackOrForward(-2)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func goBack()

```cangjie
public func goBack(): Unit
```

**功能：** 按照历史栈，后退一个页面。一般结合[canGoBack](#func-cangoback)一起使用。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_5 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("goBack")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "goBack")
                webController.goBack()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func clearHistory()

```cangjie
public func clearHistory(): Unit
```

**功能：** 删除所有前进后退记录，不建议在onPageBegin中调用clearHistory，会造成异常退出。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_6 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("clearHistory")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "clearHistory")
                webController.clearHistory()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func enableSafeBrowsing(Bool)

```cangjie
public func enableSafeBrowsing(enable: Bool): Unit
```

**功能：** 启用检查网站安全风险的功能，非法和欺诈网站是强制启用的，不能通过此功能禁用。
本功能默认不生效，OpenHarmony只提供恶意网址拦截页WebUI，网址风险检测以及显示WebUI的功能由Vendor实现。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|enable|Bool|是|-|是否启用检查网站安全风险的功能。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_7 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("enableSafeBrowsing")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "enableSafeBrowsing")
                webController.enableSafeBrowsing(true)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func goForward()

```cangjie
public func goForward(): Unit
```

**功能：** 按照历史栈，前进一个页面。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_8 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("goForward")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "goForward")
                webController.goForward()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getBackForwardEntries()

```cangjie
public func getBackForwardEntries(): BackForwardList
```

**功能：** 获取当前Webview的历史信息列表。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[BackForwardList](#class-backforwardlist)|当前Webview的历史信息列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_9 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getBackForwardEntries")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getBackForwardEntries")
                let backForwardList = webController.getBackForwardEntries()
                Hilog.info(0, "cangjieTest", "backForwardList currentIndex is ${backForwardList.currentIndex}")
                Hilog.info(0, "cangjieTest", "backForwardList size is ${backForwardList.size}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getCustomUserAgent()

```cangjie
public func getCustomUserAgent(): String
```

**功能：** 获取自定义用户代理。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|用户自定义代理信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_10 {
    let webController = WebviewController()
    let headers = [WebHeader("headerKey", "headerValue")]
    func build() {
        Column(space: 10) {
            Button("getCustomUserAgent")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getCustomUserAgent")
                let agent = webController.getCustomUserAgent()
                Hilog.info(0, "cangjieTest", "getCustomUserAgent returns ${agent}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getOriginalUrl()

```cangjie
public func getOriginalUrl(): String
```

**功能：** 获取当前页面的原始URL地址。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|当前页面的原始URL地址。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_13 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getOriginalUrl")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getOriginalUrl")
                let url = webController.getOriginalUrl()
                Hilog.info(0, "cangjieTest", "getOriginalUrl is ${url}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getPageHeight()

```cangjie
public func getPageHeight(): Int32
```

**功能：** 获取当前网页的页面高度。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int32|当前网页的页面高度。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_14 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getOriginalUrl")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getOriginalUrl")
                let height = webController.getPageHeight()
            }).width(400.px).height(150.px)
        }
    }
}
```

### func getSecurityLevel()

```cangjie
public func getSecurityLevel(): SecurityLevel
```

**功能：** 获取当前网页的安全级别。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[SecurityLevel](#enum-securitylevel)|当前网页的安全级别，具体值为NoneLevel、Secure、Warning、Dangerous。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_15 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getSecurityLevel")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getSecurityLevel")
                let securityLevel = webController.getSecurityLevel()
                match(securityLevel) {
                    case SecurityLevel.NoneLevel => Hilog.info(0, "cangjieTest", "getSecurityLevel returns NoneLevel")
                    case SecurityLevel.Secure => Hilog.info(0, "cangjieTest", "getSecurityLevel returns Secure")
                    case SecurityLevel.Warning => Hilog.info(0, "cangjieTest", "getSecurityLevel returns Warning ")
                    case SecurityLevel.Dangerous => Hilog.info(0, "cangjieTest", "getSecurityLevel returns Dangerous")
                    case _ => throw IllegalArgumentException("The type is not supported.")
                 }
            }).width(400.px).height(150.px)
            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getTitle()

```cangjie
public func getTitle(): String
```

**功能：** 获取当前网页的标题。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|当前网页的标题。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_16 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getTitle")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getTitle")
                let title = webController.getTitle()
                Hilog.info(0, "cangjieTest", "getTitle returns ${title}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getUrl()

```cangjie
public func getUrl(): String
```

**功能：** 获取当前页面的url地址。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|当前页面的url地址。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_17 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("getUrl")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getUrl")
                let url = webController.getUrl()
                Hilog.info(0, "cangjieTest", "getUrl is ${url}")
            }).width(400.px).height(150.px)
            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func getUserAgent()

```cangjie
public func getUserAgent(): String
```

**功能：** 获取当前默认用户代理。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|默认用户代理。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_18 {
    let webController = WebviewController()
    let headers = [WebHeader("headerKey", "headerValue")]
    func build() {
        Column(space: 10) {
            Button("getUserAgent")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "getUserAgent")
                webController.getUserAgent()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func isIncognitoMode()

```cangjie
public func isIncognitoMode(): Bool
```

**功能：** 查询当前是否是隐私模式的Webview。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回是否是隐私模式的Webview。<br>true表示是隐私模式，false表示不是隐私模式。<br>默认为false。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_19 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("isIncognitoMode")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "isIncognitoMode")
                let bool = webController.isIncognitoMode()
                Hilog.info(0, "cangjieTest", "isIncognitoMode returns ${bool}")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}

```

### func isSafeBrowsingEnabled()

```cangjie
public func isSafeBrowsingEnabled(): Bool
```

**功能：** 获取当前网页是否启用了检查网站安全风险。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|当前网页是否启用了检查网站安全风险的功能。<br>true表示启用了检查网站安全风险的功能，false表示未启用检查网站安全风险的功能。<br>默认值：false。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_20 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("isSafeBrowsingEnabled")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "isSafeBrowsingEnabled")
                let bool = webController.isSafeBrowsingEnabled()
                Hilog.info(0, "cangjieTest", "isSafeBrowsingEnabled returns ${bool}")
            }).width(400.px).height(150.px)
            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func pageDown(Bool)

```cangjie
public func pageDown(bottom: Bool): Unit
```

**功能：** 将Webview的内容向下滚动半个视框大小或者跳转到页面最底部，通过bottom入参控制。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|bottom|Bool|是|-|是否跳转到页面最底部。<br>false时表示将页面内容向下滚动半个视框大小，true表示跳转到页面最底部。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_21 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("pageDown")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "pageDown")
                webController.pageDown(true)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func pageUp(Bool)

```cangjie
public func pageUp(top: Bool): Unit
```

**功能：** 将Webview的内容向上滚动半个视框大小或者跳转到页面最顶部，通过top入参控制。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|Bool|是|-|是否跳转到页面最顶部。<br>false表示将页面内容向上滚动半个视框大小，true表示跳转到页面最顶部。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_22 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("pageUp")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "pageUp")
                webController.pageUp(true)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func reload()

```cangjie
public func reload(): Unit
```

**功能：** 调用此接口通知Web组件刷新网页。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_23 {
    let webController = WebviewController()
    let headers = [WebHeader("headerKey", "headerValue")]
    func build() {
        Column(space: 10) {
            Button("reload")
            .onClick ({
                evt =>
                Hilog.info(0, "cangjieTest", "reload")
                webController.reload()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "cangjieTest", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "cangjieTest", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func registerJavaScriptProxy(Array\<(String) -> String>, String, Array\<String>)

```cangjie
public func registerJavaScriptProxy(funcs: Array<(String) -> String>, name: String, methodList: Array<String>): Unit
```

**功能：** 注入仓颉方法到Window对象中，并在window对象中调用该方法。注册后，须调用[reload](#func-reload)接口生效。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|funcs|Array\<(String)->String>|是|-|参与注册的应用侧仓颉方法数组。注册的仓颉方法的入参和返回值都是String类型。|
|name|String|是|-|注册仓颉方法数组的名称，与window中调用的对象名一致。注册后window对象可以通过此名字访问应用侧仓颉方法。|
|methodList|Array\<String>|是|-|参与注册的应用侧仓颉方法名，此数组的长度需要与funcs数组一致。注册完成后，后续如果想注册新的、或更改funcs，需要传入新的methodList。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |
  | 17100015 | New failed, out of memory. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkUI.Row
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*

let webController = WebviewController()
let callback: AsyncCallback<String> = {
    errorCode: Option<BusinessException>, data: Option<String> => match (errorCode) {
        case Some(e) => Hilog.error(0, "test", "callback error: errcode is ${e.code}")
        case _ => match (data) {
            case Some(value) =>
                Hilog.info(0, "test", "callback: get data successfully and data is ${value.toArray()}")
                Hilog.info(0, "test", "callback: get data successfully and data is ${value}")
            case _ => Hilog.error(0, "test", "callback: data is null")
        }
    }
}
@Entry
@Component
class webview_24 {
    func build() {
        Row {
            Column {
                Button("reload").onClick ({
                    evt =>
                    Hilog.info(0, "test", "reload")
                    webController.reload()
                }).width(400.px).height(150.px)
                Button("proxy").onClick ({
                    evt =>
                    Hilog.info(0, "test", "registerJavaScriptProxy")
                    let funcA1 = {
                        a: String =>
                        Hilog.info(0, "test", "funcA1 ${a}")
                        return "funcA1 " + a
                    }
                    let funcA2 = {
                        a: String =>
                        Hilog.info(0, "test", "funcA2 ${a}")
                        return "funcA2 " + a
                    }
                    let funcA3 = {
                        a: String =>
                        Hilog.info(0, "test", "funcA3 ${a}")
                        return "funcA3 " + a
                    }
                    let funcB1 = {
                        a: String =>
                        Hilog.info(0, "test", "funcB1 ${a}")
                        return "funcB1 " + a
                    }
                    let funcB2 = {
                        a: String =>
                        Hilog.info(0, "test", "funcB2 ${a}")
                        return "funcB2 " + a
                    }
                    let funcB3 = {
                        a: String =>
                        Hilog.info(0, "test", "funcB3 ${a}")
                        return "funcB3 " + a
                    }
                    let funcsA = [funcA1, funcA2, funcA3]
                    let funcsB = [funcB1, funcB2, funcB3]
                    let methodListA = ["testFunA1", "testFunA2", "testFunA3"]
                    let methodListB = ["testFunB1", "testFunB2", "testFunB3"]
                    try {
                        webController.registerJavaScriptProxy(funcsA, "testObjA", methodListA)
                        webController.registerJavaScriptProxy(funcsB, "testObjB", methodListB)
                    } catch (e: Exception) {
                        Hilog.info(0, "test", e.message)
                    }
                }).width(400.px).height(150.px)
                Button("runProxy").onClick ({
                    evt =>
                    Hilog.info(0, "test", "runProxy")
                    webController.runJavaScript("testObjA.testFunA2('someData')", callback)
                    webController.runJavaScript("testObjB.testFunB2('someData')", callback)
                }).width(400.px).height(150.px)

                Web(src: "www.example.com", controller: webController).onPageBegin(
                    {
                    evt => Hilog.info(0, "test", "page begin url: ${evt.url}")
                }).onPageEnd({
                    evt => Hilog.info(0, "test", "page end url: ${evt.url}")
                })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

加载的html文件。需要在`entry\src\main\resources\rawfile`目录下新增`index.html`文件。

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
<meta charset="utf-8">
<body>
<button type="button" onclick="htmlTest()">Click Me!</button>
<p id="demo"></p>
<p id="webDemo"></p>
</body>
<script type="text/javascript">
    function htmlTest() {
      // This function call expects to return "ArkUI Web Component"
      let AStr=testObjA.testFunA2("A2 data");
      let BStr=testObjB.testFunB1("B1 data");
      testObjA.testFunA3("A3 data");
      document.getElementById("demo").innerHTML=AStr;
      document.getElementById("webDemo").innerHTML=BStr;
      console.log('objName.test result:'+ str)
    }
</script>
</html>
```

### func loadUrl\<T>(T, Array\<WebHeader>) where T \<: ResourceStr

```cangjie
public func loadUrl<T>(url: T, headers!: Array<WebHeader> = Array<WebHeader>()): Unit where T <: ResourceStr
```

**功能：** 加载指定的URL。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|T|是|-|需要加载的URL。|
|headers|Array\<[WebHeader](#class-webheader)>|否|Array\<WebHeader>()|**命名参数。** URL的附加HTTP请求头。<br>默认值：Array\<WebHeader>()。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |
  | 17100002 | URL error. The webpage corresponding to the URL is invalid, or the URL length exceeds 2048. |
  | 17100003 | Invalid resource path or file type. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog
import ohos.arkui.state_macro_manage.rawfile

@Entry
@Component
class webview_25 {
    let webController = WebviewController()
    let headers = [WebHeader("headerKey", "headerValue")]
    func build() {
        Column(space: 10) {
            Button("loadUrl")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "loadUrl")
                webController.loadUrl(@rawfile("index.html"), headers: headers)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func setCustomUserAgent(String)

```cangjie
public func setCustomUserAgent(userAgent: String): Unit
```

**功能：** 设置自定义用户代理，会覆盖系统的用户代理。

不建议将User-Agent设置在onLoadIntercept回调事件中，会概率性出现设置失败。

当Web组件src设置为空字符串时，建议先调用setCustomUserAgent方法设置User-Agent，再通过loadUrl加载具体页面。

> **说明：**
>
> 当Web组件src设置了url，再调用setCustomUserAgent方法时，可能会出现加载的页面与实际设置User-Agent不符的异常现象。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|userAgent|String|是|-|用户自定义代理信息。建议先使用[getUserAgent](#func-getuseragent)获取当前默认用户代理，在此基础上追加自定义用户代理信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_26 {
    let webController = WebviewController()
    let headers = [WebHeader("headerKey", "headerValue")]
    func build() {
        Column(space: 10) {
            Button("setCustomUserAgent")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "setCustomUserAgent")
                webController.setCustomUserAgent("ua")
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func stop()

```cangjie
public func stop(): Unit
```

**功能：** 停止页面加载。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_27 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("stop")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "stop")
                webController.stop()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func storeWebArchive(String, Bool, AsyncCallback\<String>)

```cangjie
public func storeWebArchive(baseName: String, autoName: Bool, callback: AsyncCallback<String>): Unit
```

**功能：** 以回调方式保存当前页面。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|baseName|String|是|-|生成的离线网页存储位置，该值不能为空。|
|autoName|Bool|是|-|决定是否自动生成文件名。如果为false，则按baseName的文件名存储；如果为true，则根据当前Url自动生成文件名，并按baseName的文件目录存储。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<String>|是|-|返回文件存储路径，保存网页失败会返回空字符串。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |
  | 17100003 | Invalid resource path or file type. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*

let callback1: AsyncCallback<String> = {
    errorCode: Option<BusinessException>, data: Option<String> => match (errorCode) {
        case Some(e) => Hilog.error(0, "test", "callback error: errcode is ${e.code}")
        case _ =>
            match (data) {
                case Some(value) =>
                    Hilog.info(0, "test", "callback: get data successfully and data is ${value}")
                case _ => Hilog.error(0, "test", "callback: data is null")
            }
    }
}
@Entry
@Component
class webview_28 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("storeWebArchive")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "storeWebArchive")
                webController.storeWebArchive("/data/storage/el2/base/", true, callback1)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func zoom(Float32)

```cangjie
public func zoom(factor: Float32): Unit
```

**功能：** 调整当前网页的缩放比例，zoomAccess需为true。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|factor|Float32|是|-|基于当前网页所需调整的相对缩放比例，入参要求大于0，当入参为1时为默认加载网页的缩放比例，入参小于1为缩小，入参大于1为放大。<br>取值范围：(0，100]。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |
  | 17100004 | Function not enable. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_29 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("zoom")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "zoom")
                webController.zoom(2.5)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func zoomIn()

```cangjie
public func zoomIn(): Unit
```

**功能：** 调用此接口将当前网页进行放大，比例为25%。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |
  | 17100004 | Function not enable. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_30 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("zoomIn")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "zoomIn")
                webController.zoomIn()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func zoomOut()

```cangjie
public func zoomOut(): Unit
```

**功能：** 调用此接口将当前网页进行缩小，比例为20%。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |
  | 17100004 | Function not enable. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_31 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("zoomOut")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "zoomOut")
                webController.zoomOut()
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

### func runJavaScript(String, AsyncCallback\<String>)

```cangjie
public func runJavaScript(script: String, callback: AsyncCallback<String>): Unit
```

**功能：** 在当前显示页面的上下文中执行JavaScript脚本，脚本执行的结果将通过回调方式返回。此方法必须在用户界面（UI）线程上使用，并且回调也将在用户界面（UI）线程上调用。

> **说明：**
>
> - 跨导航操作（如loadUrl）时，JavaScript状态将不再保留。例如，调用loadUrl前定义的全局变量和函数在加载的页面中将不存在。
> - 建议应用程序使用registerJavaScriptProxy来确保JavaScript状态能够在页面导航间保持。
> - 目前不支持传递对象，支持传递结构体。
> - 前端页面传到Native的string数据类型会被视为json格式的数据，需要调用JSON.parse反序列化。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|script|String|是|-|JavaScript脚本。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<String>|是|-|回调执行JavaScript脚本结果。JavaScript脚本若执行失败或无返回值时，返回字符串null。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*
import ohos.arkui.state_macro_manage.rawfile
import ohos.resource.__GenerateResource__

let callback2: AsyncCallback<String> = {
    errorCode: Option<BusinessException>, data: Option<String> => match (errorCode) {
        case Some(e) => Hilog.error(0, "test", "callback error: errcode is ${e.code}")
        case _ =>
            match (data) {
                case Some(value) =>
                    Hilog.info(0, "test", "callback: get data successfully and data is ${value}")
                case _ => Hilog.error(0, "test", "callback: data is null")
            }
    }
}
@Entry
@Component
class webview_32 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("runJavaScript")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "runJavaScript")
                webController.runJavaScript("test()", callback2)
            }).width(400.px).height(150.px)

            Web(src: @rawfile("index.html"), controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

加载的html文件。需要在`entry\src\main\resources\rawfile`目录下新增`index.html`文件。

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
  <meta charset="utf-8">
  <body>
      Hello world!
  </body>
  <script type="text/javascript">
  function test() {
      console.log('Ark WebComponent')
      return "This value is from index.html"
  }
  </script>
</html>
```

### func scrollBy(Float32, Float32, ?Int32)

```cangjie
public func scrollBy(deltaX: Float32, deltaY: Float32, duration!: ?Int32 = None): Unit
```

**功能：** 在指定时间内将页面滚动指定的偏移量。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deltaX|Float32|是|-|水平偏移量，其中水平向右为正方向。<br>单位：vp。|
|deltaY|Float32|是|-|垂直偏移量，其中垂直向下为正方向。<br>单位：vp。|
|duration|?Int32|否|None|**命名参数。** 滚动动画时间。<br>单位：ms。<br>不传入为无动画，当传入数值为负数或传入0时，按照不传入处理。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_33 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("scrollBy")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "scrollBy")
                webController.scrollBy(50.0, 50.0)
            }).width(400.px).height(150.px)

            Web(src: ("index.html"), controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

加载的html文件。需要在`entry\src\main\resources\rawfile`目录下新增`index.html`文件。

```html
<!--index.html-->
<!DOCTYPE html>
<html>
<head>
    <title>Demo</title>
    <style>
        body {
            width:3000px;
            height:3000px;
            padding-right:170px;
            padding-left:170px;
            border:5px solid blueviolet
        }
    </style>
</head>
<body>
Scroll Test
</body>
</html>
```

### func scrollTo(Float32, Float32, ?Int32)

```cangjie
public func scrollTo(x: Float32, y: Float32, duration!: ?Int32 = None): Unit
```

**功能：** 在指定时间内，将页面滚动到指定的绝对位置。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|Float32|是|-|绝对位置的水平坐标，当传入数值为负数时，按照传入0处理。<br>单位：vp。|
|y|Float32|是|-|绝对位置的垂直坐标，当传入数值为负数时，按照传入0处理。<br>单位：vp。|
|duration|?Int32|否|None|**命名参数。** 滚动动画时间。<br>单位：ms。<br>不传入为无动画，当传入数值为负数或传入0时，按照不传入处理。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_34 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("scrollTo")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "scrollTo")
                webController.scrollTo(50.0, 50.0)
            }).width(400.px).height(150.px)

            Web(src: ("index.html"), controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

加载的html文件。需要在`entry\src\main\resources\rawfile`目录下新增`index.html`文件。

```html
<!--index.html-->
<!DOCTYPE html>
<html>
<head>
    <title>Demo</title>
    <style>
        body {
            width:3000px;
            height:3000px;
            padding-right:170px;
            padding-left:170px;
            border:5px solid blueviolet
        }
    </style>
</head>
<body>
Scroll Test
</body>
</html>
```

### func removeCache(Bool)

```cangjie
public func removeCache(clearRom: Bool): Unit
```

**功能：** 清除应用中的资源缓存文件，此方法将会清除同一应用中所有Webview的缓存文件。

> **说明：**
>
> 可以通过在data/storage/el2/base/cache/web/Cache目录下查看Webview的缓存。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|clearRom|Bool|是|-|设置为true时同时清除ROM和RAM中的缓存，设置为false时只清除RAM中的缓存。|

**异常：**

- BusinessException：对应错误码如下表，详见[Webview错误码](./cj-errorcode-webview.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17100001 | Init error. The WebviewController must be associated with a Web component. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.LengthProp
import kit.ArkUI.Button
import kit.ArkUI.Column
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.loadNativeView
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.Entry
import ohos.arkui.state_macro_manage.Component
import kit.ArkWeb.*
import kit.ArkUI.Web
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class webview_35 {
    let webController = WebviewController()
    func build() {
        Column(space: 10) {
            Button("removeCache")
            .onClick ({
                evt =>
                Hilog.info(0, "test", "removeCache")
                webController.removeCache(true)
            }).width(400.px).height(150.px)

            Web(src: "www.example.com", controller: webController)
            .onPageBegin({evt =>
                Hilog.info(0, "test", "page begin url: ${evt.url}")
            })
            .onPageEnd({evt =>
                Hilog.info(0, "test", "page end url: ${evt.url}")
            })
        }
    }
}
```

## enum SecurityLevel

```cangjie
public enum SecurityLevel <: Equatable<SecurityLevel> & ToString {
    | NoneLevel
    | Secure
    | Warning
    | Dangerous
    | ...
}
```

**功能：** 当前网页的安全级别。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**父类型：**

- Equatable\<SecurityLevel>
- ToString

### NoneLevel

```cangjie
NoneLevel
```

**功能：** 页面既不绝对安全，也不是不安全，即是中立。例如，部分scheme非http/https的URL。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Secure

```cangjie
Secure
```

**功能：** 页面安全，页面使用的是HTTPS协议，且使用了信任的证书。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Warning

```cangjie
Warning
```

**功能：** 页面不安全。例如，使用HTTP协议或使用HTTPS协议但使用旧版TLS版本。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Dangerous

```cangjie
Dangerous
```

**功能：** 页面不安全。尝试HTTPS并失败、页面未通过身份验证、页面上包含不安全活动内容的HTTPS、恶意软件、网络钓鱼或任何其他可能危险的严重安全问题。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### func !=(SecurityLevel)

```cangjie
public operator func !=(other: SecurityLevel): Bool
```

**功能：** 判断两个枚举值是否不等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SecurityLevel](#enum-securitylevel)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不等，返回true，否则返回false。|

### func ==(SecurityLevel)

```cangjie
public operator func ==(other: SecurityLevel): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SecurityLevel](#enum-securitylevel)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串表示。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串表示。|

## enum WebHitTestType

```cangjie
public enum WebHitTestType <: Equatable<WebHitTestType> & ToString {
    | EditText
    | Email
    | Unknown
    | ...
}
```

**功能：** 用于指示游标节点。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**父类型：**

- Equatable\<WebHitTestType>
- ToString

### EditText

```cangjie
EditText
```

**功能：** 可编辑的区域。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Email

```cangjie
Email
```

**功能：** 电子邮件地址。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Unknown

```cangjie
Unknown
```

**功能：** 未知内容。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### func !=(WebHitTestType)

```cangjie
public operator func !=(other: WebHitTestType): Bool
```

**功能：** 判断两个枚举值是否不等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WebHitTestType](#enum-webhittesttype)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不等，返回true，否则返回false。|

### func ==(WebHitTestType)

```cangjie
public operator func ==(other: WebHitTestType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WebHitTestType](#enum-webhittesttype)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串表示。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串表示。|
