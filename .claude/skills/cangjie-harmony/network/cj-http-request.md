# HTTP数据请求

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

应用通过HTTP发起一个数据请求，支持常见的GET、POST、OPTIONS、HEAD、PUT、DELETE、TRACE、CONNECT方法。

## 接口说明

HTTP数据请求功能主要由http模块提供。

使用该功能需要申请ohos.permission.INTERNET权限。

权限申请请参见[声明权限](../security/AccessToken/cj-declare-permissions.md)。

涉及的接口如下表，具体的接口说明请参见[API文档](../reference/NetworkKit/cj-apis-net-http.md)。

| 接口名 | 描述 |
| ------------------------| ---------------- |
| createHttp(): HttpRequest | 创建一个 HTTP 请求。                            |
| request(url: String, options: HttpRequestOptions, callback: AsyncCallback\<HttpResponse>): Unit | 根据URL地址，发起HTTP网络请求。 |
| requestInStream(url: String, options: HttpRequestOptions, callback: AsyncCallback\<UInt32>): Unit | 根据URL地址，发起HTTP网络请求并返回流式响应。   |
| destroy(): Unit | 中断请求任务。 |
| on(event: HttpRequestEvent, callback: Callback1Argument\<HashMap\<String, String>>): Unit | 订阅HTTP Response Header 事件。                 |
| once(event: HttpRequestEvent, callback: Callback1Argument\<HashMap\<String, String>>): Unit | 订阅HTTP Response Header 事件，但是只触发一次。 |
| on(event: HttpRequestEvent, callback: Callback1Argument\<Array\<Byte>>): Unit | 订阅HTTP流式响应数据接收事件。 |
| on(event: HttpRequestEvent, callback: Callback0Argument): Unit | 订阅HTTP流式响应数据接收完毕事件。              |
| on(event: HttpRequestEvent, callback: Callback1Argument\<DataReceiveProgressInfo>): Unit | 订阅HTTP流式响应数据接收进度事件。              |
| on(event: HttpRequestEvent, callback: Callback1Argument\<DataSendProgressInfo>): Unit | 订阅HTTP网络请求数据发送进度事件。 |
| off(event: HttpRequestEvent, callback!: ?CallbackObject = None): Unit | 取消订阅HTTP请求事件。 |

## request接口开发步骤

1. 从kit.NetworkKit中导入http。
2. 调用createHttp()方法，创建一个HttpRequest对象。
3. 调用该对象的on()方法，订阅http响应头事件，此接口会比request请求先返回。可以根据业务需要订阅此消息。
4. 调用该对象的request()方法，传入http请求的url地址和可选参数，发起网络请求。
5. 按照实际业务需要，解析返回结果。
6. 调用该对象的off()方法，取消订阅http响应头事件。
7. 当该请求使用完毕时，调用destroy()方法主动销毁。

<!-- compile -->

```cangjie
// 引入包名
import kit.PerformanceAnalysisKit.Hilog
import kit.NetworkKit.*
import std.collection.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

// 每一个httpRequest对应一个HTTP请求任务，不可复用
let httpRequest = createHttp()

// 请求的配置
let option = HttpRequestOptions(
    method: RequestMethod.Post, // 可选，默认为http.RequestMethod.GET
    // 当使用POST请求时此字段用于传递内容
    extraData: HttpData.StringData("data to send"),
    expectDataType: HttpDataType.StringValue, // 可选，指定返回数据的类型
    usingCache: true, // 可选，默认为true
    priority: 1, // 可选，默认为1
    // 开发者根据自身业务需要添加header字段
    header: HashMap<String, String>([("content-type", "application/json")]),
    readTimeout: 60000, // 可选，默认为60000ms
    connectTimeout: 60000, // 可选，默认为60000ms
    usingProtocol: HttpProtocol.Http1_1, // 可选，协议类型默认值由系统自动指定
    usingProxy: UsingProxy.UseDefault, //可选，默认不使用网络代理，自API 10开始支持该属性
    caPath: "/path/to/cacert.pem", // 可选，默认使用系统预设CA证书，自API 10开始支持该属性
    clientCert: ClientCert(
        "/path/to/client.pem", // 默认不使用客户端证书
        "/path/to/client.key", // 若证书包含Key信息，传入空字符串
        certType: CertType.Pem, // 可选，默认使用PEM
        keyPassword: "passwordToKey" // 可选，输入key文件的密码
    ),
    multiFormDataList: [ // 可选，仅当Header中，'content-Type'为'multipart/form-data'时生效
        MultiFormData (
            "Part1", // 数据名
            "text/plain", // 数据类型
            data: StringData("Example data"), // 可选，数据内容
            remoteFileName: "example.txt" // 可选
        ),
        MultiFormData (
            "Part2", // 数据名
            "text/plain", // 数据类型
            filePath: "/data/app/el2/100/base/com.example.myapplication/haps/entry/files/fileName.txt", // 可选，传入文件路径
            remoteFileName: "fileName.txt" // 可选
        )
    ]
)

httpRequest.request(
    // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
    "EXAMPLE_URL",
    option,
    {
        err, resp =>
        if (let Some(v) <- err) {
            loggerError("v")
        }
        if (let Some(v) <- resp) {
            // data.result为HTTP响应内容，可根据业务需要进行解析
            loggerInfo("code: ${v.responseCode}")
            // data.header为HTTP响应头，可根据业务需要进行解析
            loggerInfo("header: ${v.header}")
            loggerInfo("cookies: ${v.cookies}")
            // 当该请求使用完毕时，调用destroy方法主动销毁
            httpRequest.destroy()
        }
    })
```

## requestInStream接口开发步骤

1. 从kit.NetworkKit中导入http。
2. 调用createHttp()方法，创建一个HttpRequest对象。
3. 调用该对象的on()方法，可以根据业务需要订阅HTTP响应头事件、HTTP流式响应数据接收事件、HTTP流式响应数据接收进度事件和HTTP流式响应数据接收完毕事件。
4. 调用该对象的requestInStream()方法，传入http请求的url地址和可选参数，发起网络请求。
5. 按照实际业务需要，可以解析返回的响应码。
6. 调用该对象的off()方法，取消订阅响应事件。
7. 当该请求使用完毕时，调用destroy()方法主动销毁。

<!-- compile -->

```cangjie
// 引入包名
import kit.PerformanceAnalysisKit.Hilog
import kit.NetworkKit.*
import std.collection.*
import ohos.callback_invoke.*
import ohos.business_exception.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

class HeadersReceiveCb <: Callback1Argument<HashMap<String, String>> {
    let callback_: (HashMap<String, String>)->Unit
    public init(callback: (HashMap<String, String>)->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException, val: HashMap<String, String>): Unit {
        callback_(val)
    }
}

class DataReceiveCb <: Callback1Argument<Array<Byte>> {
    let callback_: (Array<Byte>)->Unit
    public init(callback: (Array<Byte>)->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException, val: Array<Byte>): Unit {
        callback_(val)
    }
}

class DataEndCb <: Callback0Argument {
    let callback_: ()->Unit
    public init(callback: ()->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException): Unit {
        callback_()
    }
}

class DataReceiveProgressCb <: Callback1Argument<DataReceiveProgressInfo> {
    let callback_: (DataReceiveProgressInfo)->Unit
    public init(callback: (DataReceiveProgressInfo)->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException, val: DataReceiveProgressInfo): Unit {
        callback_(val)
    }
}

func test() {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = createHttp()
    // 用于订阅HTTP响应头事件
    let headersReceiveCallBack = HeadersReceiveCb({ header => loggerInfo("header: ${header}") })
    httpRequest.on(HttpRequestEvent.HeadersReceive, headersReceiveCallBack)
    // 用于订阅HTTP流式响应数据接收事件
    let res = ArrayList<Byte>()
    let dataReceiveCallBack = DataReceiveCb({ bytes =>
        res.add(all: bytes)
        loggerInfo("receive length: ${bytes.size}")
    })
    httpRequest.on(HttpRequestEvent.DataReceive, dataReceiveCallBack)

    // 用于订阅HTTP流式响应数据接收完毕事件
    let dataEndCallBack = DataEndCb({ =>
        loggerInfo("No more data in response, data receive end")
        // 取消订阅HTTP响应头事件
        httpRequest.off(HttpRequestEvent.HeadersReceive)
        // 取消订阅HTTP流式响应数据接收事件
        httpRequest.off(HttpRequestEvent.DataReceive)
        // 取消订阅HTTP流式响应数据接收进度事件
        httpRequest.off(HttpRequestEvent.DataReceiveProgress)
        // 取消订阅HTTP流式响应数据接收完毕事件
        httpRequest.off(HttpRequestEvent.DataEnd)
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy()
    })
    httpRequest.on(HttpRequestEvent.DataEnd,dataEndCallBack)
    // 用于订阅HTTP流式响应数据接收进度事件
    let dataReceiveProgressCallBack = DataReceiveProgressCb({ progress =>
        loggerInfo("dataReceiveProgress receiveSize: ${progress.receiveSize} totalSize: ${progress.totalSize}")
    })
    httpRequest.on(HttpRequestEvent.DataReceiveProgress, dataReceiveProgressCallBack)

    let option = HttpRequestOptions(
        method: RequestMethod.Post, // 可选，默认为http.RequestMethod.GET
        // 当使用POST请求时此字段用于传递内容
        extraData: HttpData.StringData("data to send"),
        expectDataType: HttpDataType.StringValue, // 可选，指定返回数据的类型
        usingCache: true, // 可选，默认为true
        priority: 1, // 可选，默认为1
        // 开发者根据自身业务需要添加header字段
        header: HashMap<String, String>([("content-type", "application/json")]),
        readTimeout: 60000, // 可选，默认为60000ms
        connectTimeout: 60000, // 可选，默认为60000ms
        usingProtocol: HttpProtocol.Http1_1, // 可选，协议类型默认值由系统自动指定
        usingProxy: UsingProxy.UseDefault, //可选，默认不使用网络代理，自API 10开始支持该属性
        caPath: "/path/to/cacert.pem", // 可选，默认使用系统预设CA证书，自API 10开始支持该属性
        clientCert: ClientCert(
            "/path/to/client.pem", // 默认不使用客户端证书
            "/path/to/client.key", // 若证书包含Key信息，传入空字符串
            certType: CertType.Pem, // 可选，默认使用PEM
            keyPassword: "passwordToKey" // 可选，输入key文件的密码
        ),
        multiFormDataList: [ // 可选，仅当Header中，'content-Type'为'multipart/form-data'时生效
            MultiFormData (
                "Part1", // 数据名
                "text/plain", // 数据类型
                data: StringData("Example data"), // 可选，数据内容
                remoteFileName: "example.txt" // 可选
            ),
            MultiFormData (
                "Part2", // 数据名
                "text/plain", // 数据类型
                filePath: "/data/app/el2/100/base/com.example.myapplication/haps/entry/files/fileName.txt", // 可选，传入文件路径
                remoteFileName: "fileName.txt" // 可选
            )
        ]
    )

    // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定

    httpRequest.requestInStream(
        "EXAMPLE_URL",
        option,
        {err, code =>
        if (let Some(e) <- err) {
            loggerError("exception: ${e.message}")
        }
        if (let Some(respCode) <- code) {
            loggerInfo("ResponseCode: ${respCode}")
        } else {
            loggerError("response is none")
        }
    })
}
```

## 证书锁定

可以通过预置应用级证书，或者预置证书公钥哈希值的方式来进行证书锁定，即只有开发者特别指定的证书才能正常建立https连接。

两种方式都是在配置文件中配置的，配置文件在APP中的路径是：`src/main/resources/base/profile/network_config.json`。在该配置中，可以为预置的证书与网络服务器建立对应关系。

如果不知道服务器域名的证书，可以通过以下方式访问该域名获取证书，注意把`www.example.com`改成想要获取域名证书的域名，`www.example.com.pem`改成想保存的证书文件名：

```shell
openssl s_client -servername www.example.com -connect www.example.com:443 \
    < /dev/null | sed -n "/-----BEGIN/,/-----END/p" > www.example.com.pem
```

如果使用Windows操作系统，需要注意：

* 将`/dev/null`替换成`NUL`。
* 和Linux的OpenSSL表现可能不同，OpenSSL可能会等待用户输入才会退出，按Enter键即可。
* 如果没有sed命令，将输出中从`-----BEGIN CERTIFICATE-----`到`-----END CERTIFICATE-----`之间的部分复制下来保存即可（复制部分包括这两行）。

### 预置应用级证书

直接把证书原文件预置在APP中。目前支持crt和pem格式的证书文件。

> **注意：**
>
> 当前ohos.net.http和Image组件的证书锁定，会匹配证书链上所有证书的哈希值，如果服务器更新了任意一本证书，都会导致校验失败。如果服务器出现了更新证书的情况，APP版本应当随之更新并推荐消费者尽快升级APP版本，否则可能导致联网失败。

### 预置证书公钥哈希值

通过在配置中指定域名证书公钥的哈希值来只允许使用公钥哈希值匹配的域名证书访问此域名。

域名证书的公钥哈希值可以用如下的命令计算，这里假设域名证书是通过上面的OpenSSL命令获得的，并保存在`www.example.com.pem`文件。#开头的行是注释，可以不用输入：

```shell
# 从证书中提取出公钥
openssl x509 -in www.example.com.pem -pubkey -noout > www.example.com.pubkey.pem
# 将pem格式的公钥转换成der格式
openssl asn1parse -noout -inform pem -in www.example.com.pubkey.pem -out www.example.com.pubkey.der
# 计算公钥的SHA256并转换成base64编码
openssl dgst -sha256 -binary www.example.com.pubkey.der | openssl base64
```

### JSON配置文件示例

预置应用级证书的配置示例如下：

```json
{
  "network-security-config": {
    "base-config": {
      "trust-anchors": [
        {
          "certificates": "/etc/security/certificates"
        }
      ]
    },
    "domain-config": [
      {
        "domains": [
          {
            "include-subdomains": true,
            "name": "example.com"
          }
        ],
        "trust-anchors": [
          {
            "certificates": "/data/storage/el1/bundle/entry/resources/resfile"
          }
        ]
      }
    ]
  }
}
```

预置证书公钥哈希值的配置示例如下：

```json
{
  "network-security-config": {
    "domain-config": [
      {
        "domains": [
          {
            "include-subdomains": true,
            "name": "server.com"
          }
        ],
        "pin-set": {
          "expiration": "2024-11-08",
          "pin": [
            {
              "digest-algorithm": "sha256",
              "digest": "FEDCBA987654321"
            }
          ]
        }
      }
    ]
  }
}
```

**各个字段含义:**

| 字段                    | 类型    | 说明                                                                                                                         |
| ----------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| network-security-config | object  | 网络安全配置。可包含0或者1个base-config，必须包含1个domain-config。                                                          |
| base-config             | object  | 指示应用程序范围的安全配置。必须包含1个trust-anchors。                                                                       |
| domain-config           | array   | 指示每个域的安全配置。可以包含任意个item。item必须包含1个domains，可以包含0或者1个trust-anchors，可以包含0个或者1个pin-set。 |
| trust-anchors           | array   | 受信任的CA。可以包含任意个item。item必须包含1个certificates。                                                                |
| certificates            | string  | CA证书路径。                                                                                                                 |
| domains                 | array   | 域。可以包含任意个item。item必须包含1个name(string:指示域名)，可以包含0或者1个include-subdomains。                           |
| include-subdomains      | boolean | 指示规则是否适用于子域。                                                                                                     |
| pin-set                 | object  | 证书公钥哈希设置。必须包含1个pin，可以包含0或者1个expiration。                                                               |
| expiration              | string  | 指示证书公钥哈希的过期时间。                                                                                                 |
| pin                     | array   | 证书公钥哈希。可以包含任意个item。item必须包含1个digest-algorithm，item必须包含1个digest。                                   |
| digest-algorithm        | string  | 指示用于生成哈希的摘要算法。目前只支持`sha256`。                                                                             |
| digest                  | string  | 指示公钥哈希。                                                                                                               |
