# ohos.net.http（数据请求）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

http模块提供HTTP数据请求能力。应用可以通过HTTP发起一个数据请求，支持常见的GET、POST、OPTIONS、HEAD、PUT、DELETE、TRACE、CONNECT方法。

## 导入模块

```cangjie
import kit.NetworkKit.*
```

## 权限列表

ohos.permission.INTERNET

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func createHttp()

```cangjie
public func createHttp(): HttpRequest
```

**功能：** 创建一个HTTP请求，里面包括发起请求、中断请求、订阅/取消订阅HTTP Response Header事件。当发起多个HTTP请求时，需为每个HTTP请求创建对应HttpRequest对象。每一个HttpRequest对象对应一个HTTP请求。

> **说明：**
>
> 当该请求使用完毕时，需调用destroy方法主动销毁HttpRequest对象，否则会出现资源泄露问题。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[HttpRequest](#class-httprequest)|返回一个HttpRequest对象，里面包括request、requestInStream、destroy、on和off方法。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let httpRequest = createHttp()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createHttpResponseCache(UInt32)

```cangjie
public func createHttpResponseCache(cacheSize!: UInt32 = MAX_CACHE_SIZE): HttpResponseCache
```

**功能：** 创建一个HttpResponseCache对象，可用于存储HTTP请求的响应数据。对象中可调用[flush](#func-flush)与[delete](#delete)方法，cacheSize指定缓存大小。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cacheSize|UInt32|否|MAX_CACHE_SIZE|**命名参数。** 缓存大小。最大为10\*1024\*1024（10MB），默认最大。|

**返回值：**

|类型|说明|
|:----|:----|
|[HttpResponseCache](#class-httpresponsecache)|返回一个存储HTTP访问请求响应的对象。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let httpResponseCache = createHttpResponseCache()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class ClientCert

```cangjie
public class ClientCert {
    public var certPath: String
    public var keyPath: String
    public var certType: CertType
    public var keyPassword: String
    public init(certPath: String, keyPath: String, certType!: CertType = CertType.Pem, keyPassword!: String = "")
}
```

**功能：** 客户端证书类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var certPath

```cangjie
public var certPath: String
```

**功能：** 证书路径。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var certType

```cangjie
public var certType: CertType
```

**功能：** 证书类型。

**类型：** [CertType](#enum-certtype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var keyPassword

```cangjie
public var keyPassword: String
```

**功能：** 证书密钥的密码。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var keyPath

```cangjie
public var keyPath: String
```

**功能：** 证书密钥的路径。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### init(String, String, CertType, String)

```cangjie
public init(certPath: String, keyPath: String, certType!: CertType = CertType.Pem, keyPassword!: String = "")
```

**功能：** 构造ClientCert实例。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|certPath|String|是|-|证书路径。|
|keyPath|String|是|-|证书密钥的路径。|
|certType|[CertType](#enum-certtype)|否|CertType.Pem|**命名参数。** 证书类型，默认是CertType.Pem。|
|keyPassword|String|否|""|**命名参数。** 证书密钥的密码。默认值为空字符串。|

## class DataReceiveProgressInfo

```cangjie
public class DataReceiveProgressInfo {
    public var receiveSize: Int64
    public var totalSize: Int64
}
```

**功能：** 数据接收信息。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var receiveSize

```cangjie
public var receiveSize: Int64
```

**功能：** 已接收的数据量（单位：字节）。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var totalSize

```cangjie
public var totalSize: Int64
```

**功能：** 总共要接收的数据量（单位：字节）。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## class DataSendProgressInfo

```cangjie
public class DataSendProgressInfo {
    public var sendSize: Int64
    public var totalSize: Int64
}
```

**功能：** 数据发送信息。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var sendSize

```cangjie
public var sendSize: Int64
```

**功能：** 每次发送的数据量(单位：字节)。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var totalSize

```cangjie
public var totalSize: Int64
```

**功能：** 总共要发送的数据量(单位：字节)。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## class HttpRequest

```cangjie
public class HttpRequest {}
```

**功能：** HTTP请求任务。在调用HttpRequest的方法前，需要先通过[createHttp()](#func-createhttp)创建一个任务。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### func destroy()

```cangjie
public func destroy(): Unit
```

**功能：** 中断请求任务。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let httpRequest = createHttp()
    httpRequest.destroy()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(HttpRequestEvent, ?CallbackObject)

```cangjie
public func off(event: HttpRequestEvent, callback!: ?CallbackObject = None): Unit
```

**功能：** 取消订阅HTTP请求事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|要取消订阅的HTTP请求事件类型。|
|callback|?[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|否|None|**命名参数。** 回调函数。可以指定传入on中的callback取消对应的订阅，也可以不指定callback清空所有订阅。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*
import std.collection.HashMap

// 定义HeadersReceiveCb类
class HeadersReceiveCb <: Callback1Argument<HashMap<String, String>> {
    let callback_: (HashMap<String, String>)->Unit
    public init(callback: (HashMap<String, String>)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: HashMap<String, String>): Unit {
        callback_(val)
    }
}

try {
    let client = createHttp()

    let headersReceiveCallBack = HeadersReceiveCb({ map => Hilog.info(0, "test", "header info: ${map}") })
    client.on(HttpRequestEvent.HeadersReceive, headersReceiveCallBack)

    client.off(HttpRequestEvent.HeadersReceive)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(HttpRequestEvent, Callback1Argument\<HashMap\<String,String>>)

```cangjie
public func on(event: HttpRequestEvent, callback: Callback1Argument<HashMap<String, String>>): Unit
```

**功能：** 订阅HTTP Response Header 事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|HTTP请求事件类型，仅支持HeadersReceive事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<HashMap\<String,String>>|是|-|回调函数，返回HTTP响应头对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*
import std.collection.HashMap

// 定义HeadersReceiveCb类
class HeadersReceiveCb1 <: Callback1Argument<HashMap<String, String>> {
    let callback_: (HashMap<String, String>)->Unit
    public init(callback: (HashMap<String, String>)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: HashMap<String, String>): Unit {
        callback_(val)
    }
}

try {
    let client = createHttp()

    let headersReceiveCallBack = HeadersReceiveCb1({ map => Hilog.info(0, "test", "header info: ${map}") })
    client.on(HttpRequestEvent.HeadersReceive, headersReceiveCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(HttpRequestEvent, Callback1Argument\<Array\<Byte>>)

```cangjie
public func on(event: HttpRequestEvent, callback: Callback1Argument<Array<Byte>>): Unit
```

**功能：** 订阅HTTP流式响应数据接收事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|HTTP请求事件类型，仅支持DataReceive事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Array\<Byte>>|是|-|回调函数，用于接收HTTP流式响应数据。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义DataReceiveCb类
class DataReceiveCb <: Callback1Argument<Array<Byte>> {
    let callback_: (Array<Byte>)->Unit
    public init(callback: (Array<Byte>)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: Array<Byte>): Unit {
        callback_(val)
    }
}

try {
    let client = createHttp()

    let dataReceiveCallBack = DataReceiveCb({ bytes => Hilog.info(0, "test", "data info : ${bytes}") })
    client.on(HttpRequestEvent.DataReceive, dataReceiveCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(HttpRequestEvent, Callback0Argument)

```cangjie
public func on(event: HttpRequestEvent, callback: Callback0Argument): Unit
```

**功能：** 订阅HTTP流式响应数据接收完毕事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|HTTP请求事件类型，仅支持DataEnd事件。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义DataEndCb类
class DataEndCb <: Callback0Argument {
    let callback_: ()->Unit
    public init(callback: ()->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException): Unit {
        callback_()
    }
}

try {
    let client = createHttp()

    let dataEndCallBack = DataEndCb({ => Hilog.info(0, "test", "data end") })
    client.on(HttpRequestEvent.DataEnd, dataEndCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(HttpRequestEvent, Callback1Argument\<DataReceiveProgressInfo>)

```cangjie
public func on(event: HttpRequestEvent, callback: Callback1Argument<DataReceiveProgressInfo>): Unit
```

**功能：** 订阅HTTP流式响应数据接收进度事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|HTTP请求事件类型，仅支持DataReceiveProgress事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[DataReceiveProgressInfo](#class-datareceiveprogressinfo)>|是|-|回调函数，用于接收数据接收进度信息，参数为DataReceiveProgressInfo对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义DataReceiveProgressCb类
class DataReceiveProgressCb <: Callback1Argument<DataReceiveProgressInfo> {
    let callback_: (DataReceiveProgressInfo)->Unit
    public init(callback: (DataReceiveProgressInfo)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: DataReceiveProgressInfo): Unit {
        callback_(val)
    }
}

try {
    let client = createHttp()

    let dataReceiveProgressCallBack = DataReceiveProgressCb({ info => Hilog.info(0, "test", "receive progress ${info.receiveSize} ${info.totalSize} ") })
    client.on(HttpRequestEvent.DataReceiveProgress, dataReceiveProgressCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(HttpRequestEvent, Callback1Argument\<DataSendProgressInfo>)

```cangjie
public func on(event: HttpRequestEvent, callback: Callback1Argument<DataSendProgressInfo>): Unit
```

**功能：** 订阅HTTP网络请求数据发送进度事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|HTTP请求事件类型，仅支持DataSendProgress事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[DataSendProgressInfo](#class-datasendprogressinfo)>|是|-|回调函数，用于接收数据发送进度信息，参数为DataSendProgressInfo对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import std.collection.HashMap
import ohos.callback_invoke.*

// 定义HeadersReceiveCb类
class HeadersReceiveCb2 <: Callback1Argument<HashMap<String, String>> {
    let callback_: (HashMap<String, String>)->Unit
    public init(callback: (HashMap<String, String>)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: HashMap<String, String>): Unit {
        callback_(val)
    }
}

try {
    let client = createHttp()

    let onceHeadersReceiveCallBack = HeadersReceiveCb2({ map => Hilog.info(0, "test", "header info once: ${map}") })
    client.once(HttpRequestEvent.HeadersReceive, onceHeadersReceiveCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func once(HttpRequestEvent, Callback1Argument\<HashMap\<String,String>>)

```cangjie
public func once(event: HttpRequestEvent, callback: Callback1Argument<HashMap<String, String>>): Unit
```

**功能：** 订阅HTTP Response Header 事件，只能触发一次。触发之后，订阅器就会被移除。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[HttpRequestEvent](#enum-httprequestevent)|是|-|HTTP请求事件类型，仅支持HeadersReceive事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<HashMap\<String,String>>|是|-|回调函数。返回HTTP响应头对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

### func request(String, HttpRequestOptions, AsyncCallback\<HttpResponse>)

```cangjie
public func request(url: String, options: HttpRequestOptions, callback: AsyncCallback<HttpResponse>): Unit
```

**功能：** 根据URL地址，发起HTTP网络请求，

> **说明：**
>
>(1) 此接口仅支持接收5MB以内的数据，如果需要接收超过5MB的数据，则需主动在[HttpRequestOptions](#class-httprequestoptions)的maxLimit中进行设置，或者使用[requestInStream](#func-requestinstreamstring-asynccallbackuint32)接口发起流式请求。
>
>(2) 如需传入cookies，请开发者自行在参数options中添加。
>
>(3) 若URL包含中文或其他语言，需先调用encodeURL(URL)编码，再发起请求。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|发起网络请求的URL地址。|
|options|[HttpRequestOptions](#class-httprequestoptions)|是|-|参考[HttpRequestOptions](#class-httprequestoptions)。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<[HttpResponse](#class-httpresponse)>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2300001 | Unsupported protocol. |
  | 2300003 | Invalid URL format or missing URL. |
  | 2300005 | Failed to resolve the proxy name. |
  | 2300006 | Failed to resolve the host name. |
  | 2300007 | Failed to connect to the server. |
  | 2300008 | Invalid server response. |
  | 2300009 | Access to the remote resource denied. |
  | 2300016 | Error in the HTTP2 framing layer. |
  | 2300018 | Transferred a partial file. |
  | 2300023 | Failed to write the received data to the disk or application. |
  | 2300025 | Upload failed. |
  | 2300026 | Failed to open or read local data from the file or application. |
  | 2300027 | Out of memory. |
  | 2300028 | Operation timeout. |
  | 2300047 | The number of redirections reaches the maximum allowed. |
  | 2300052 | The server returned nothing (no header or data). |
  | 2300055 | Failed to send data to the peer. |
  | 2300056 | Failed to receive data from the peer. |
  | 2300058 | Local SSL certificate error. |
  | 2300059 | The specified SSL cipher cannot be used. |
  | 2300060 | Invalid SSL peer certificate or SSH remote key. |
  | 2300061 | Invalid HTTP encoding format. |
  | 2300063 | Maximum file size exceeded. |
  | 2300070 | Remote disk full. |
  | 2300073 | Remote file already exists. |
  | 2300077 | The SSL CA certificate does not exist or is inaccessible. |
  | 2300078 | Remote file not found. |
  | 2300094 | Authentication error. |
  | 2300997 | Cleartext traffic not permitted. |
  | 2300998 | It is not allowed to access this domain. |
  | 2300999 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let httpRequest = createHttp()
    httpRequest.request("http://www.example.com", {err, resp =>
        if (let Some(e) <- err) {
            Hilog.error(0, "AppLogCj","exception: ${e.message}")
        }
        if (let Some(r) <- resp) {
            Hilog.info(0, "http_test", "resp: ${r.responseCode}")
        } else {
            Hilog.error(0, "AppLogCj", "response is none")
        }
    })
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func request(String, AsyncCallback\<HttpResponse>)

```cangjie
public func request(url: String, callback: AsyncCallback<HttpResponse>): Unit
```

**功能：** 根据URL地址，发起HTTP网络请求，

> **说明：**
>
>(1) 此接口仅支持接收5MB以内的数据，如果需要接收超过5MB的数据。
>
>(2) 如需传入cookies，请开发者自行在参数options中添加。
>
>(3) 若URL包含中文或其他语言，需先调用encodeURL(URL)编码，再发起请求。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|发起网络请求的URL地址。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<[HttpResponse](#class-httpresponse)>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，[HTTP错误码](./cj-errorcode-net-http.md)和[通用错误码](../cj-errorcode-universal.md)。
- HTTP接口返回错误码映射关系：2300000 + curl错误码。更多常用错误码，可参考：[curl错误码](https://curl.se/libcurl/c/libcurl-errors.html)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2300001 | Unsupported protocol. |
  | 2300003 | URL using bad/illegal format or missing URL. |
  | 2300005 | Couldn't resolve proxy name. |
  | 2300006 | Couldn't resolve host name. |
  | 2300007 | Couldn't connect to server. |
  | 2300008 | Weird server reply. |
  | 2300009 | Access denied to remote resource. |
  | 2300016 | Error in the HTTP2 framing layer. |
  | 2300018 | Transferred a partial file. |
  | 2300023 | Failed writing received data to disk/application. |
  | 2300025 | Upload failed. |
  | 2300026 | Failed to open/read local data from file/application. |
  | 2300027 | Out of memory. |
  | 2300028 | Timeout was reached. |
  | 2300047 | Number of redirects hit maximum amount. |
  | 2300052 | Server returned nothing (no headers, no data). |
  | 2300055 | Failed sending data to the peer. |
  | 2300056 | Failure when receiving data from the peer. |
  | 2300058 | Problem with the local SSL certificate. |
  | 2300059 | Couldn't use specified SSL cipher. |
  | 2300060 | SSL peer certificate or SSH remote key was not OK. |
  | 2300061 | Unrecognized or bad HTTP Content or Transfer-Encoding. |
  | 2300063 | Maximum file size exceeded. |
  | 2300070 | Disk full or allocation exceeded. |
  | 2300073 | Remote file already exists. |
  | 2300077 | Problem with the SSL CA cert (path? access rights?). |
  | 2300078 | Remote file not found. |
  | 2300094 | An authentication function returned an error. |
  | 2300997 | Cleartext traffic not permitted. |
  | 2300998 | It is not allowed to access this domain. |
  | 2300999 | Unknown Other Error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let httpRequest = createHttp()
    httpRequest.request("http://www.example.com", {err, resp =>
        if (let Some(e) <- err) {
            Hilog.error(0, "AppLogCj","exception: ${e.message}")
        }
        if (let Some(r) <- resp) {
            Hilog.info(0, "http_test", "resp: ${r.responseCode}")
        } else {
            Hilog.error(0, "AppLogCj", "response is none")
        }
    })
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func requestInStream(String, HttpRequestOptions, AsyncCallback\<UInt32>)

```cangjie
public func requestInStream(url: String, options: HttpRequestOptions, callback: AsyncCallback<UInt32>): Unit
```

**功能：** 根据URL地址和相关配置项，发起HTTP网络请求并返回流式响应，

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|发起网络请求的URL地址。|
|options|[HttpRequestOptions](#class-httprequestoptions)|是|-|参考[HttpRequestOptions](#class-httprequestoptions)。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<UInt32>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[HTTP错误码](./cj-errorcode-net-http.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2300001 | Unsupported protocol. |
  | 2300003 | Invalid URL format or missing URL. |
  | 2300005 | Failed to resolve the proxy name. |
  | 2300006 | Failed to resolve the host name. |
  | 2300007 | Failed to connect to the server. |
  | 2300008 | Invalid server response. |
  | 2300009 | Access to the remote resource denied. |
  | 2300016 | Error in the HTTP2 framing layer. |
  | 2300018 | Transferred a partial file. |
  | 2300023 | Failed to write the received data to the disk or application. |
  | 2300025 | Upload failed. |
  | 2300026 | Failed to open or read local data from the file or application. |
  | 2300027 | Out of memory. |
  | 2300028 | Operation timeout. |
  | 2300047 | The number of redirections reaches the maximum allowed. |
  | 2300052 | The server returned nothing (no header or data). |
  | 2300055 | Failed to send data to the peer. |
  | 2300056 | Failed to receive data from the peer. |
  | 2300058 | Local SSL certificate error. |
  | 2300059 | The specified SSL cipher cannot be used. |
  | 2300060 | Invalid SSL peer certificate or SSH remote key. |
  | 2300061 | Invalid HTTP encoding format. |
  | 2300063 | Maximum file size exceeded. |
  | 2300070 | Remote disk full. |
  | 2300073 | Remote file already exists. |
  | 2300077 | The SSL CA certificate does not exist or is inaccessible. |
  | 2300078 | Remote file not found. |
  | 2300094 | Authentication error. |
  | 2300997 | Cleartext traffic not permitted. |
  | 2300998 | It is not allowed to access this domain. |
  | 2300999 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let httpRequest = createHttp()
    httpRequest.requestInStream("http://www.example.com", {err, code =>
        if (let Some(e) <- err) {
            Hilog.error(0, "AppLogCj","exception: ${e.message}")
        }
        if (let Some(respCode) <- code) {
            Hilog.info(0, "AppLogCj", "resp: ${respCode}")
        } else {
            Hilog.error(0, "AppLogCj", "response is none")
        }
    })
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func requestInStream(String, AsyncCallback\<UInt32>)

```cangjie
public func requestInStream(url: String, callback: AsyncCallback<UInt32>): Unit
```

**功能：** 根据URL地址，发起HTTP网络请求并返回流式响应。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|发起网络请求的URL地址。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<UInt32>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，[HTTP错误码](./cj-errorcode-net-http.md)和[通用错误码](../cj-errorcode-universal.md)。
- HTTP接口返回错误码映射关系：2300000 + curl错误码。更多常用错误码，可参考：[curl错误码](https://curl.se/libcurl/c/libcurl-errors.html)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2300001 | Unsupported protocol. |
  | 2300003 | URL using bad/illegal format or missing URL. |
  | 2300005 | Couldn't resolve proxy name. |
  | 2300006 | Couldn't resolve host name. |
  | 2300007 | Couldn't connect to server. |
  | 2300008 | Weird server reply. |
  | 2300009 | Access denied to remote resource. |
  | 2300016 | Error in the HTTP2 framing layer. |
  | 2300018 | Transferred a partial file. |
  | 2300023 | Failed writing received data to disk/application. |
  | 2300025 | Upload failed. |
  | 2300026 | Failed to open/read local data from file/application. |
  | 2300027 | Out of memory. |
  | 2300028 | Timeout was reached. |
  | 2300047 | Number of redirects hit maximum amount. |
  | 2300052 | Server returned nothing (no headers, no data). |
  | 2300055 | Failed sending data to the peer. |
  | 2300056 | Failure when receiving data from the peer. |
  | 2300058 | Problem with the local SSL certificate. |
  | 2300059 | Couldn't use specified SSL cipher. |
  | 2300060 | SSL peer certificate or SSH remote key was not OK. |
  | 2300061 | Unrecognized or bad HTTP Content or Transfer-Encoding. |
  | 2300063 | Maximum file size exceeded. |
  | 2300070 | Disk full or allocation exceeded. |
  | 2300073 | Remote file already exists. |
  | 2300077 | Problem with the SSL CA cert (path? access rights?). |
  | 2300078 | Remote file not found. |
  | 2300094 | An authentication function returned an error. |
  | 2300997 | Cleartext traffic not permitted. |
  | 2300998 | It is not allowed to access this domain. |
  | 2300999 | Unknown Other Error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let httpRequest = createHttp()
    httpRequest.requestInStream("http://www.example.com", {err, code =>
        if (let Some(e) <- err) {
            Hilog.error(0, "AppLogCj","exception: ${e.message}")
        }
        if (let Some(respCode) <- code) {
            Hilog.info(0, "AppLogCj", "resp: ${respCode}")
        } else {
            Hilog.error(0, "AppLogCj", "response is none")
        }
    })
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class HttpRequestOptions

```cangjie
public class HttpRequestOptions {
    public var method: RequestMethod
    public var extraData: HttpData
    public var expectDataType: ?HttpDataType
    public var usingCache: Bool
    public var priority: UInt32
    public var header: HashMap<String, String>
    public var readTimeout: UInt32
    public var connectTimeout: UInt32
    public var usingProtocol: ?HttpProtocol
    public var usingProxy: UsingProxy
    public var caPath: String
    public var resumeFrom: Int64
    public var resumeTo: Int64
    public var clientCert: ClientCert
    public var dnsOverHttps: String
    public var dnsServers: Array<String>
    public var maxLimit: UInt32
    public var multiFormDataList: Array<MultiFormData>
    public init(method!: RequestMethod = RequestMethod.Get, extraData!: HttpData = HttpData.StringData(""),
        expectDataType!: ?HttpDataType = None, usingCache!: Bool = true, priority!: UInt32 = 1,
        header!: HashMap<String, String> = HashMap<String, String>(), readTimeout!: UInt32 = 60000,
        connectTimeout!: UInt32 = 60000, usingProtocol!: ?HttpProtocol = None,
        usingProxy!: UsingProxy = UsingProxy.UseDefault, caPath!: String = "", resumeFrom!: Int64 = 0,
        resumeTo!: Int64 = 0, clientCert!: ClientCert = ClientCert("", ""), dnsOverHttps!: String = "",
        dnsServers!: Array<String> = Array<String>(), maxLimit!: UInt32 = 5 * 1024 * 1024,
        multiFormDataList!: Array<MultiFormData> = Array<MultiFormData>())
}
```

**功能：** 发起HTTP请求时，可选配置信息。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var caPath

```cangjie
public var caPath: String
```

**功能：** 如果设置了此参数，系统将使用用户指定路径的CA证书（开发者需保证该路径下CA证书的可访问性），否则将使用系统预设CA证书。<br />系统预设CA证书位置：/etc/ssl/certs/cacert.pem。证书路径为沙箱映射路径（开发者可通过UIAbilityContext提供的能力获取应用沙箱路径）。目前仅支持后缀名为.pem的文本格式证书。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var clientCert

```cangjie
public var clientCert: ClientCert
```

**功能：** 支持传输客户端证书。

**类型：** [ClientCert](#class-clientcert)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var connectTimeout

```cangjie
public var connectTimeout: UInt32
```

**功能：** 连接超时时间。单位为毫秒（ms）。传入值需为UInt32范围内的整数。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var dnsOverHttps

```cangjie
public var dnsOverHttps: String
```

**功能：** 设置使用HTTPS协议的服务器进行DNS解析。<br />- 参数必须根据以下格式进行URL编码："https:// host:port/path"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var dnsServers

```cangjie
public var dnsServers: Array<String>
```

**功能：** 设置指定的DNS服务器进行DNS解析。<br />- 最多可以设置3个DNS解析服务器。如果有3个以上，只取前3个。<br />- 服务器必须是IPV4或者IPV6地址。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var expectDataType

```cangjie
public var expectDataType:?HttpDataType
```

**功能：** 指定返回数据的类型。如果设置了此参数，系统将优先返回指定的类型。

**类型：** ?[HttpDataType](#enum-httpdatatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var extraData

```cangjie
public var extraData: HttpData
```

**功能：** 发送请求的额外数据。

> **说明：**
>
> 没有额外数据时，避免添加该参数；若必须添加，避免直接传入空字符串或者空数组。

1. 当HTTP请求为POST、PUT、DELETE等方法时，此字段为HTTP请求的content，以UTF-8编码形式作为请求体。

    示例如下：

    (1) 当'content-Type'为'application/x-www-form-urlencoded'时，请求提交的信息主体数据必须在key和value进行URL转码后（encodeURIComponent/encodeURI），按照键值对"key1=value1&key2=value2&key3=value3"的方式进行编码，该字段对应的类型通常为String。

    (2) 当'content-Type'为'text/xml'时，该字段对应的类型通常为String。

    (3) 当'content-Type'为'application/json'时，该字段对应的类型通常为Object。

    (4) 当'content-Type'为'application/octet-stream'时，该字段对应的类型通常为ArrayBuffer。

    (5) 当'content-Type'为'multipart/form-data'且需上传的字段为文件时，该字段对应的类型通常为ArrayBuffer。

    以上信息仅供参考，并可能根据具体情况有所不同。

2. 当HTTP请求为GET、OPTIONS、TRACE、CONNECT等方法时，此字段为HTTP请求参数的补充。开发者需传入Encode编码后的string类型参数，Object类型的参数无需预编码，参数内容会拼接到URL中进行发送。ArrayBuffer类型的参数不会做拼接处理。

**类型：** [HttpData](#enum-httpdata)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var header

```cangjie
public var header: HashMap<String, String>
```

**功能：** HTTP请求头字段。当请求方式为"POST" "PUT" "DELETE" 或者""时，默认{'content-Type': 'application/json'}， 否则默认{'content-Type': 'application/x-www-form-urlencoded'}。<br />如果head中包含number类型的字段，最大支持int64的整数。

**类型：** HashMap\<String,String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var maxLimit

```cangjie
public var maxLimit: UInt32
```

**功能：** 响应消息的最大字节限制。<br />最大值为100\*1024\*1024，以字节为单位。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var method

```cangjie
public var method: RequestMethod
```

**功能：** 请求方式，默认为Get。

**类型：** [RequestMethod](#enum-requestmethod)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var multiFormDataList

```cangjie
public var multiFormDataList: Array<MultiFormData>
```

**功能：** 当'content-Type'为'multipart/form-data'时，则上传该字段定义的数据字段表单列表。

**类型：** Array\<[MultiFormData](#class-multiformdata)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var priority

```cangjie
public var priority: UInt32
```

**功能：** HTTP/HTTPS请求并发优先级，值越大优先级越高，范围[1,1000]。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var readTimeout

```cangjie
public var readTimeout: UInt32
```

**功能：** 读取超时时间。单位为毫秒（ms）。传入值需为uint32_t范围内的整数。<br />设置为0表示不会出现超时情况。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var resumeFrom

```cangjie
public var resumeFrom: Int64
```

**功能：** 用于设置下载起始位置，该参数只能用于GET方法，不能用于其他。HTTP标准（RFC 7233第3.1节）允许服务器忽略范围请求。<br />- 使用HTTP PUT时，不能使用该选项，因为该选项可能与其他选项冲突。<br />- 取值范围是：[1，4294967296（4GB）]，超出范围则不生效。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var resumeTo

```cangjie
public var resumeTo: Int64
```

**功能：** 用于设置下载结束位置，该参数只能用于GET方法，不能用于其他。HTTP标准（RFC 7233第3.1节）允许服务器忽略范围请求。<br />- 使用HTTP PUT时，不能使用该选项，因为该选项可能与其他选项冲突。<br />- 取值范围是：[1，4294967296（4GB）]，超出范围则不生效。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var usingCache

```cangjie
public var usingCache: Bool
```

**功能：** 是否使用缓存，true表示请求时优先读取缓存，false表示不使用缓存；请求时优先读取缓存。缓存跟随当前进程生效，新缓存会替换旧缓存。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var usingProtocol

```cangjie
public var usingProtocol: ?HttpProtocol
```

**功能：** 使用协议。

**类型：** ?[HttpProtocol](#enum-httpprotocol)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var usingProxy

```cangjie
public var usingProxy: UsingProxy
```

**功能：** HTTP代理配置，该项不配置时表示不使用代理。<br />- 当usingProxy为布尔类型true时，使用默认网络代理，为false时，不使用代理。<br />- 当usingProxy为HttpProxy类型时，使用指定网络代理。当前HttpProxy不支持指定username和password字段。

**类型：** [UsingProxy](#enum-usingproxy)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### init(RequestMethod, HttpData, ?HttpDataType, Bool, UInt32, HashMap\<String,String>, UInt32, UInt32, ?HttpProtocol, UsingProxy, String, Int64, Int64, ClientCert, String, Array\<String>, UInt32, Array\<MultiFormData>)

```cangjie
public init(method!: RequestMethod = RequestMethod.Get, extraData!: HttpData = HttpData.StringData(""),
    expectDataType!: ?HttpDataType = None, usingCache!: Bool = true, priority!: UInt32 = 1,
    header!: HashMap<String, String> = HashMap<String, String>(), readTimeout!: UInt32 = 60000,
    connectTimeout!: UInt32 = 60000, usingProtocol!: ?HttpProtocol = None,
    usingProxy!: UsingProxy = UsingProxy.UseDefault, caPath!: String = "", resumeFrom!: Int64 = 0,
    resumeTo!: Int64 = 0, clientCert!: ClientCert = ClientCert("", ""), dnsOverHttps!: String = "",
    dnsServers!: Array<String> = Array<String>(), maxLimit!: UInt32 = 5 * 1024 * 1024,
    multiFormDataList!: Array<MultiFormData> = Array<MultiFormData>())
```

**功能：** 构造HttpRequestOptions实例。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|method|[RequestMethod](#enum-requestmethod)|否|RequestMethod.Get|**命名参数。** 请求方式，默认为RequestMethod.Get。|
|extraData|[HttpData](#enum-httpdata)|否|HttpData.StringData("")|**命名参数。** 发送请求的额外数据，默认无此字段。|
|expectDataType|?[HttpDataType](#enum-httpdatatype)|否|None|**命名参数。** 指定返回数据的类型，默认无此字段。如果设置了此参数，系统将优先返回指定的类型。|
|usingCache|Bool|否|true|**命名参数。** 是否使用缓存，true表示请求时优先读取缓存，false表示不使用缓存；默认为true，请求时优先读取缓存。缓存跟随当前进程生效，新缓存会替换旧缓存。|
|priority|UInt32|否|1|**命名参数。** HTTP/HTTPS请求并发优先级，值越大优先级越高，范围[1,1000]，默认为1。|
|header|HashMap\<String,String>|否|HashMap<String,String>()|**命名参数。** HTTP请求头字段。当请求方式为"POST" "PUT" "DELETE" 或者""时，默认{'content-Type': 'application/json'}， 否则默认{'content-Type': 'application/x-www-form-urlencoded'}。<br />如果head中包含number类型的字段，最大支持int64的整数。|
|readTimeout|UInt32|否|60000|**命名参数。** 读取超时时间。单位为毫秒（ms），默认为60000ms。传入值需为uint32_t范围内的整数。<br />设置为0表示不会出现超时情况。|
|connectTimeout|UInt32|否|60000|**命名参数。** 连接超时时间。单位为毫秒（ms），默认为60000ms。传入值需为uint32_t范围内的整数。|
|usingProtocol|?[HttpProtocol](#enum-httpprotocol)|否|None|**命名参数。** 使用协议，默认值由系统自动指定为None。|
|usingProxy|[UsingProxy](#enum-usingproxy)|否|UsingProxy.UseDefault|**命名参数。** HTTP代理配置，该项不配置时表示不使用代理。<br />- 当usingProxy为布尔类型true时，使用默认网络代理，为false时，不使用代理。<br />- 当usingProxy为HttpProxy类型时，使用指定网络代理。当前HttpProxy不支持指定username和password字段。|
|caPath|String|否|""|**命名参数。** 如果设置了此参数，系统将使用用户指定路径的CA证书（开发者需保证该路径下CA证书的可访问性），否则将使用系统预设CA证书。<br />系统预设CA证书位置：/etc/ssl/certs/cacert.pem。证书路径为沙箱映射路径（开发者可通过UIAbilityContext提供的能力获取应用沙箱路径）。目前仅支持后缀名为.pem的文本格式证书。|
|resumeFrom|Int64|否|0|**命名参数。** 用于设置下载起始位置，该参数只能用于GET方法，不能用于其他。HTTP标准（RFC 7233第3.1节）允许服务器忽略范围请求。<br />- 使用HTTP PUT时，不能使用该选项，因为该选项可能与其他选项冲突。<br />- 取值范围是：[1，4294967296（4GB）]，超出范围则不生效。|
|resumeTo|Int64|否|0|**命名参数。** 用于设置下载结束位置，该参数只能用于GET方法，不能用于其他。HTTP标准（RFC 7233第3.1节）允许服务器忽略范围请求。<br />- 使用HTTP PUT时，不能使用该选项，因为该选项可能与其他选项冲突。<br />- 取值范围是：[1，4294967296（4GB）]，超出范围则不生效。|
|clientCert|[ClientCert](#class-clientcert)|否|ClientCert("", "")|**命名参数。** 支持传输客户端证书。|
|dnsOverHttps|String|否|""|**命名参数。** 设置使用HTTPS协议的服务器进行DNS解析。<br />- 参数必须根据以下格式进行URL编码："https:// host:port/path"。|
|dnsServers|Array\<String>|否|Array\<String>()|**命名参数。** 设置指定的DNS服务器进行DNS解析。<br />- 最多可以设置3个DNS解析服务器。如果有3个以上，只取前3个。<br />- 服务器必须是IPV4或者IPV6地址。|
|maxLimit|UInt32|否|5 * 1024 * 1024|**命名参数。** 响应消息的最大字节限制。<br />默认值为5\*1024\*1024，以字节为单位。最大值为100\*1024\*1024，以字节为单位。|
|multiFormDataList|Array\<[MultiFormData](#class-multiformdata)>|否|Array\<MultiFormData>()|**命名参数。** 当'content-Type'为'multipart/form-data'时，则上传该字段定义的数据字段表单列表。|

## class HttpResponse

```cangjie
public class HttpResponse {
    public var result: HttpData
    public var resultType: HttpDataType
    public var responseCode: UInt32
    public var header: HashMap<String, String>
    public var cookies: String
    public var performanceTiming: PerformanceTiming
}
```

**功能：** request方法回调函数的返回值类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var cookies

```cangjie
public var cookies: String
```

**功能：** 服务器返回的原始cookies。开发者可自行处理。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var header

```cangjie
public var header: HashMap<String, String>
```

**功能：** 发起HTTP请求返回来的响应头。当前返回的是JSON格式字符串，如需具体字段内容，需开发者自行解析。常见字段及解析方式如下：

- content-type：header['content-type']。

- status-line：header['status-line']。

- date：header.date/header['date']。

- server：header.server/header['server']。

**类型：** HashMap\<String,String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var performanceTiming

```cangjie
public var performanceTiming: PerformanceTiming
```

**功能：** HTTP请求的各个阶段的耗时。

**类型：** [PerformanceTiming](#class-performancetiming)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var responseCode

```cangjie
public var responseCode: UInt32
```

**功能：** 回调函数执行成功时，此字段为[ResponseCode](#var-responsecode)。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var result

```cangjie
public var result: HttpData
```

**功能：** HTTP请求根据响应头中content-type类型返回对应的响应格式内容，若HttpRequestOptions无expectDataType字段，按如下规则返回：<br />- application/json：返回JSON格式的字符串。<br />- application/octet-stream：ArrayBuffer。<br />- image：ArrayBuffer。<br />- 其他：string。<br /> 若HttpRequestOption有expectDataType字段，开发者需传入与服务器返回类型相同的数据类型。

**类型：** [HttpData](#enum-httpdata)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var resultType

```cangjie
public var resultType: HttpDataType
```

**功能：** 返回值类型。

**类型：** [HttpDataType](#enum-httpdatatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## class HttpResponseCache

```cangjie
public class HttpResponseCache {}
```

**功能：** 存储HTTP访问请求响应的对象。在调用HttpResponseCache的方法前，需要先通过[createHttpResponseCache()](#func-createhttpresponsecacheuint32)创建一个任务。

**响应头中的相应关键字使用**

- **`Cache-Control`**：用于指定缓存策略，如`no-cache`, `no-store`, `max-age`, `public`, `private`等。

- **`Expires`**：指定资源的过期时间，格式为GMT时间。

- **`ETag`**：用于资源版本标识，客户端可以使用`If-None-Match`请求头来验证资源是否已更改。

- **`Last-Modified`**：指定资源最后修改时间，客户端可以使用`If-Modified-Since`请求头来验证资源是否已更改。

- **`Vary`**：指定哪些请求头的值会影响缓存的响应，用于区分不同的缓存版本。

使用这些关键字时，服务器端需要正确配置响应头，客户端则需要根据这些响应头来决定是否使用缓存的资源，以及如何验证资源是否是最新的。正确的缓存策略可以显著提高应用的性能和用户体验。

**如何设置Cache-Control头**

`Cache-Control`为通用报头，但通常是在服务器端进行的，允许定义一个响应资源应该何时、如何被缓存以及缓存多长时间。以下是一些常用的`Cache-Control`指令及其含义：

- **`no-cache`**：表示在使用缓存前，必须先去源服务器校验资源的有效性。如果资源未变更，则响应状态码为304(Not Modified)，不发送资源内容，使用缓存中的资源。如果资源已经过期，则响应状态码为200(OK)，并发送资源内容。

- **`no-store`**：表示不允许缓存资源，每次请求都必须从服务器获取资源。

- **`max-age`**：指定缓存的最大时间(以秒为单位)。例如，`Cache-Control: max-age=3600`表示缓存的有效期为1小时。

- **`public`**：表明响应可以被任何对象(包括：发送请求的客户端，代理服务器等)缓存。

- **`private`**：表明响应只能被单个用户缓存，不能作为共享缓存(即代理服务器不能缓存)。

- **`must-revalidate`**：表示必须在使用缓存前验证旧资源的状态，并且在缓存过期后，需要重新验证资源。

- **`no-transform`**：表示不允许代理服务器修改响应内容。

- **`proxy-revalidate`**：与`must-revalidate`类似，但仅适用于共享缓存。

- **`s-maxage`**：类似于`max-age`，但仅适用于共享缓存。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### func delete()

```cangjie
public func delete(): Unit
```

**功能：** 禁用缓存并删除其中的数据。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import ohos.business_exception.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog

let httpResponseCache = createHttpResponseCache()
try {
    httpResponseCache.delete()
} catch (e: BusinessException) {
    Hilog.info(0, "", "${e}")
}
```

### func flush()

```cangjie
public func flush(): Unit
```

**功能：** 将缓存中的数据写入文件系统，以便在下一个HTTP请求中访问所有缓存数据。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import ohos.business_exception.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog

let httpResponseCache = createHttpResponseCache()
try {
    httpResponseCache.flush()
} catch (e: BusinessException) {
    Hilog.info(0, "", "${e}")
}
```

## class MultiFormData

```cangjie
public class MultiFormData {
    public var name: String
    public var contentType: String
    public var remoteFileName: String
    public var data: HttpData
    public var filePath: String
    public init(name: String, contentType: String,  remoteFileName!: String = "",
        data!: HttpData = HttpData.StringData(""), filePath!: String = "")
}
```

**功能：** 多部分表单数据的类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var contentType

```cangjie
public var contentType: String
```

**功能：** 数据类型，如'text/plain'，'image/png', 'image/jpeg', 'audio/mpeg', 'video/mp4'等。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var data

```cangjie
public var data: HttpData
```

**功能：** 表单数据内容。

**类型：** [HttpData](#enum-httpdata)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var filePath

```cangjie
public var filePath: String
```

**功能：** 此参数将文件路径指向的文件内容设置为表单数据，如果未指定data内容，则必须设置filePath。

> **说明：**
>
> 需传入文件管理模块支持的格式，可以通过文件管理的[access](../CoreFileKit/cj-apis-file_fs.md#static-func-accessstring-accessmodetype-accessflagtype)接口，验证文件是否存在且可访问。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 数据名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var remoteFileName

```cangjie
public var remoteFileName: String
```

**功能：** 上传到服务器保存为文件的名称。

> **说明：**
>
> - 指定该字段后，请求头中会添加filename字段，表示上传到服务器文件的名称。
>
> - （1）当上传数据为文件时，若通过data字段指定文件内容，通常需要设置remoteFileName字段，用以指定上传到服务器文件的名称（实际结果与服务器具体行为有关）；若通过filePath字段指定文件路径，请求头中会自动添加filename字段，其默认值为filePath中的文件名称，如需特殊指定，也可通过本字段对filename重新设置。
>
> - （2）当上传数据为二进制格式时，则必须设置remoteFileName字段。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### init(String, String, String, HttpData, String)

```cangjie
public init(name: String, contentType: String,  remoteFileName!: String = "",
    data!: HttpData = HttpData.StringData(""), filePath!: String = "")
```

**功能：** 构造MultiFormData实例。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|数据名称。|
|contentType|String|是|-|数据类型，如'text/plain'，'image/png', 'image/jpeg', 'audio/mpeg', 'video/mp4'等。|
|remoteFileName|String|否|""|**命名参数。** 上传到服务器保存为文件的名称。|
|data|[HttpData](#enum-httpdata)|否|HttpData.StringData("")|**命名参数。** 表单数据内容。|
|filePath|String|否|""|**命名参数。** 此参数将文件路径指向的文件内容设置为表单数据，如果未指定data内容，则必须设置filePath。|

## class PerformanceTiming

```cangjie
public class PerformanceTiming {
    public var dnsTiming: Float64
    public var tcpTiming: Float64
    public var tlsTiming: Float64
    public var firstSendTiming: Float64
    public var firstReceiveTiming: Float64
    public var totalFinishTiming: Float64
    public var redirectTiming: Float64
    public var responseHeaderTiming: Float64
    public var responseBodyTiming: Float64
    public var totalTiming: Float64
}
```

**功能：** 性能打点(单位：毫秒)。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var dnsTiming

```cangjie
public var dnsTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到DNS解析完成耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var firstReceiveTiming

```cangjie
public var firstReceiveTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到接收第一个字节的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var firstSendTiming

```cangjie
public var firstSendTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到开始发送第一个字节的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var redirectTiming

```cangjie
public var redirectTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到完成所有重定向步骤的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var responseBodyTiming

```cangjie
public var responseBodyTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到body解析完成的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var responseHeaderTiming

```cangjie
public var responseHeaderTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到header解析完成的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var tcpTiming

```cangjie
public var tcpTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到TCP连接完成耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var tlsTiming

```cangjie
public var tlsTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到TLS连接完成耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var totalFinishTiming

```cangjie
public var totalFinishTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求到完成请求的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### var totalTiming

```cangjie
public var totalTiming: Float64
```

**功能：** 从[request](#func-requeststring-httprequestoptions-asynccallbackhttpresponse)请求回调到应用程序的耗时。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## enum CertType

```cangjie
public enum CertType {
    | Pem
    | Der
    | P12
    | ...
}
```

**功能：** 枚举，证书类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Der

```cangjie
Der
```

**功能：** 证书类型Der。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### P12

```cangjie
P12
```

**功能：** 证书类型P12。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Pem

```cangjie
Pem
```

**功能：** 证书类型Pem。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## enum HttpData

```cangjie
public enum HttpData {
    | StringData(String)
    | ArrayData(Array<Byte>)
    | ...
}
```

**功能：** HTTP的数据。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### ArrayData(Array\<Byte>)

```cangjie
ArrayData(Array<Byte>)
```

**功能：** 二进制数组。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### StringData(String)

```cangjie
StringData(String)
```

**功能：** 字符串。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## enum HttpDataType

```cangjie
public enum HttpDataType {
    | StringValue
    | ArrayBuffer
    | ...
}
```

**功能：** HTTP的数据类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### ArrayBuffer

```cangjie
ArrayBuffer
```

**功能：** 二进制数组类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### StringValue

```cangjie
StringValue
```

**功能：** 字符串类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## enum HttpProtocol

```cangjie
public enum HttpProtocol {
    | Http1_1
    | Http2
    | Http3
    | ...
}
```

**功能：** HTTP协议版本。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Http1_1

```cangjie
Http1_1
```

**功能：** 协议HTTP1.1。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Http2

```cangjie
Http2
```

**功能：** 协议HTTP2。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Http3

```cangjie
Http3
```

**功能：** 协议HTTP3，若系统或服务器不支持，则使用低版本的HTTP协议请求。<br />**注意：** 仅对HTTPS的URL生效，HTTP则会请求失败。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## enum HttpRequestEvent

```cangjie
public enum HttpRequestEvent <: Equatable<HttpRequestEvent> & Hashable {
    | HeadersReceive
    | DataReceive
    | DataEnd
    | DataReceiveProgress
    | DataSendProgress
    | ...
}
```

**功能：** HTTP请求事件类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**父类型：**

- Equatable\<HttpRequestEvent>
- Hashable

### DataEnd

```cangjie
DataEnd
```

**功能：** HTTP流式响应数据接收完毕事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### DataReceive

```cangjie
DataReceive
```

**功能：** HTTP流式响应数据接收事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### DataReceiveProgress

```cangjie
DataReceiveProgress
```

**功能：** HTTP流式响应数据接收进度更新事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### DataSendProgress

```cangjie
DataSendProgress
```

**功能：** HTTP网络请求数据发送进度更新事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### HeadersReceive

```cangjie
HeadersReceive
```

**功能：** HTTP Response Header事件。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### func !=(HttpRequestEvent)

```cangjie
public operator func !=(other: HttpRequestEvent): Bool
```

**功能：** 比较两个HttpRequestEvent是否不相等。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[HttpRequestEvent](#enum-httprequestevent)|是|-|要比较的另一个HttpRequestEvent实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个HttpRequestEvent不相等则返回true，否则返回false。|

### func ==(HttpRequestEvent)

```cangjie
public operator func ==(other: HttpRequestEvent): Bool
```

**功能：** 比较两个HttpRequestEvent是否相等。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[HttpRequestEvent](#enum-httprequestevent)|是|-|要比较的另一个HttpRequestEvent实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个HttpRequestEvent相等则返回true，否则返回false。|

### func hashCode()

```cangjie
public func hashCode(): Int64
```

**功能：** 获取HttpRequestEvent的哈希值。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int64|返回HttpRequestEvent的哈希值。|

## enum RequestMethod

```cangjie
public enum RequestMethod {
    | Options
    | Get
    | Head
    | Post
    | Put
    | Delete
    | Trace
    | Connect
    | ...
}
```

**功能：** HTTP请求方法。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Connect

```cangjie
Connect
```

**功能：** Connect方法建立到由目标资源标识的服务器的隧道。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Delete

```cangjie
Delete
```

**功能：** Delete方法用于删除指定的资源。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Get

```cangjie
Get
```

**功能：** Get方法请求指定资源的表示。使用Get的请求应该只检索数据，不应该包含请求内容。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Head

```cangjie
Head
```

**功能：** Head方法请求与Get请求相同的响应，但没有响应主体。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Options

```cangjie
Options
```

**功能：** Options方法描述了目标资源的通信选项。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Post

```cangjie
Post
```

**功能：** Post方法将实体提交给指定的资源，通常会导致服务器上的状态更改。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Put

```cangjie
Put
```

**功能：** Put方法将目标资源的所有当前表示替换为请求内容。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### Trace

```cangjie
Trace
```

**功能：** Trace方法沿到达目标资源的路径执行消息环回测试。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

## enum UsingProxy

```cangjie
public enum UsingProxy {
    | NotUse
    | UseDefault
    | UseSpecified(HttpProxy)
    | ...
}
```

**功能：** 使用代理的类型。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### NotUse

```cangjie
NotUse
```

**功能：** 不使用代理。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### UseDefault

```cangjie
UseDefault
```

**功能：** 使用默认代理。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22

### UseSpecified(HttpProxy)

```cangjie
UseSpecified(HttpProxy)
```

**功能：** 使用指定类型代理。

**系统能力：** SystemCapability.Communication.NetStack

**起始版本：** 22
