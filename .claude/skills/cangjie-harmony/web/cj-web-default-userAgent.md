# User-Agent开发指导

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

<!--RP1-->
User-Agent（简称UA）是一个特殊的字符串，包含设备类型、操作系统及其版本等关键信息。在Web开发中，这个字符串使服务器能够识别请求的来源设备及其特性，从而据此提供定制化的内容和服务。如果页面无法正确识别UA，可能会导致多种异常情况。例如，为移动设备优化的页面布局可能会在桌面设备上显示错乱，反之亦然。此外，某些浏览器功能或CSS样式可能仅在特定浏览器版本中受支持，如果页面无法根据UA字符串作出正确判断，就可能出现渲染问题或逻辑错误。

## 默认User-Agent结构

- 默认User-Agent定义

  ```text
  Mozilla/5.0 ({DeviceType}; {OSName} {OSVersion}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/{ChromeCompatibleVersion}.0.0.0 Safari/537.36  ArkWeb/{ArkWeb VersionCode} {DeviceCompat} {扩展区}
  ```

- 举例说明

  ```text
  Mozilla/5.0 (Phone; OpenHarmony 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile
  ```

- 字段说明

  | 字段                  | 含义                                                         |
  | :--------------------- | :------------------------------------------------------------ |
  | DeviceType            | 当前的设备类型。<br>取值范围：<br>- Phone：手机<br>- Tablet：平板设备 |
  | OSName                | 基础操作系统名称。<br>默认取值：OpenHarmony                  |
  | OSVersion             | 基础操作系统版本，两位数字，M.S。<br>通过系统参数const.ohos.fullname解析版本号，取版本号中M.S的前两位。<br>默认取值：例如5.0  |
  | ChromeCompatibleVersion | 兼容Chrome主版本的版本号，从114版本开始演进。<br>默认取值：114            |
  | ArkWeb                | OpenHarmony版本Web内核名称。<br>默认取值：ArkWeb             |
  | ArkWeb VersionCode    | ArkWeb版本号，格式a.b.c.d。<br>默认取值：例如4.1.6.1         |
  | DeviceCompat          | 前向兼容字段。<br>默认取值：Mobile                          |
  | 扩展区                | 三方应用可以扩展的字段。<br>三方应用使用ArkWeb组件时，可以做UA扩展，例如加入APP相关信息标识。 |

> **说明：**
>
> - 当前默认User-Agent的ArkWeb字段前有两个空格。
> - 当前通过User-Agent中是否含有"Mobile"字段来判断是否开启前端HTML页面中meta标签的viewport属性。当User-Agent中不含有"Mobile"字段时，meta标签中viewport属性默认关闭。
> - 建议通过OpenHarmony关键字识别是否为OpenHarmony设备，同时通过DeviceType识别设备类型，以适配不同设备的页面显示（ArkWeb关键字表示设备使用的Web内核，OpenHarmony关键字表示设备使用的操作系统，因此推荐通过OpenHarmony关键字识别是否为OpenHarmony设备）。

## 自定义User-Agent结构

在下面的示例中，接口提供的默认User-Agent信息为开发者提供基础，使其能够在此基础上进行定制或扩展。

<!-- compile -->

```cangjie
// index.cj
import kit.PerformanceAnalysisKit.Hilog
import kit.ArkWeb.WebviewController
import kit.ArkUI.Web
import ohos.business_exception.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

@Entry
@Component
class EntryView {
    let webController = WebviewController()

    func build() {
        Column {
            Button("getUserAgent").onClick ({ evt =>
                try {
                    let userAgent = webController.getUserAgent()
                    loggerInfo("userAgent: ${userAgent}")
                } catch (e: BusinessException) {
                    loggerError("getUserAgent ErrorCode: ${e.code},  Message: ${e.message}")
                }
            })
            Web(src: 'www.example.com', controller: webController)
        }
    }
}
```

## 相关User-Agent接口优先级

| 接口名称 | 优先级 | 说明 |
| :-------- | :-------- | :-------- |
| setCustomUserAgent | 最高 | 对调用的Web组件生效。|
| ArkWeb默认UA | 最低 | 对应用中所有Web组件生效，只读，通过getDefaultUserAgent获取。|

## 常见问题

### 如何通过User-Agent来识别OpenHarmony操作系统中不同设备

OpenHarmony设备的识别主要通过User-Agent中的系统、系统版本和设备类型三个维度来判断。建议同时检查系统、系统版本和设备类型，以确保更准确的设备识别。

1. 系统识别

   通过User-Agent中的{OSName}字段识别OpenHarmony系统。

   ```html
   const isOpenHarmony = () => /OpenHarmony/i.test(navigator.userAgent);
   ```

2. 系统版本识别

   通过User-Agent中的{OSName}和{OSVersion}字段识别OpenHarmony系统及系统版本。格式为：OpenHarmony + 版本号。

   ```html
   const matches = navigator.userAgent.match(/OpenHarmony (\d+\.?\d*)/);  
   matches?.length && Number(matches[1]) >= 5;  
   ```

3. 设备类型识别

    通过deviceType字段来识别不同设备类型。

   ```html
   // 检测是否为手机设备
   const isPhone = () => /Phone/i.test(navigator.userAgent);

   // 检测是否为平板设备  
   const isTablet = () => /Tablet/i.test(navigator.userAgent);

   ```

### 如何模拟OpenHarmony操作系统的User-Agent进行前端调试

在Windows/Mac/Linux等操作系统中，可以通过Chrome/Edge/Firefox等浏览器DevTools提供的User-Agent复写能力，模拟OpenHarmony User-Agent。
<!--RP1End-->
