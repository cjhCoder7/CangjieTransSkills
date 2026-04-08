# ohos.file.fileuri（文件URI）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

fileuri模块提供通过PATH获取文件统一资源标志符（Uniform Resource Identifier，URI）的能力，后续可通过使用[ohos.file_fs（文件管理）](cj-apis-file_fs.md)进行相关操作，如open、read、write等，以实现文件分享。

## 导入模块

```cangjie
import kit.CoreFileKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func getUriFromPath(String)

```cangjie
public func getUriFromPath(path: String): String
```

**功能：** 通过传入的路径path生成应用自己的URI；将path转URI时，路径中的中文及非数字字母的特殊字符将会被编译成对应的ASCII码，拼接在URI中。

**系统能力：** SystemCapability.FileManagement.AppFileService

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|文件的沙箱路径。|

**返回值：**

|类型|说明|
|:----|:----|
|String|返回文件URI。|

**异常：**

- BusinessException：对应错误码如下表，详见[文件管理错误码](./cj-errorcode-filemanagement.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 13900020 | Invalid argument. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CoreFileKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let uri = getUriFromPath("test.txt")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class FileUri

```cangjie
public class FileUri {
    public init(uriOrPath: String)
}
```

**功能：** 提供通过PATH获取文件统一资源标志符（Uniform Resource Identifier，URI）的能力，后续可通过使用[ohos.file.fs](./cj-apis-file_fs.md)进行相关操作，如open、read、write等，以实现文件分享。

**系统能力：** SystemCapability.FileManagement.AppFileService

**起始版本：** 22

### prop name

```cangjie
public prop name: String
```

**功能：** 通过传入的uri获取到对应的文件名称。（如果文件名中存在ASCII码将会被解码处理后拼接在原处）

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.FileManagement.AppFileService

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[文件管理错误码](./cj-errorcode-filemanagement.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 13900005 | I/O error. |
  | 13900042 | Unknown error. |

### prop path

```cangjie
public override prop path: String
```

**功能：** 将uri转换成对应的沙箱路径path。 1、uri转path过程中会将uri中存在的ASCII码进行解码后拼接在原处，非系统接口生成的uri中可能存在ASCII码解析范围之外的字符，导致字符串无法正常拼接；2、转换处理为系统约定的字符串替换规则（规则随系统演进可能会发生变化），转换过程中不进行路径校验操作，无法保证转换结果的一定可以访问。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.FileManagement.AppFileService

**起始版本：** 22

### init(String)

```cangjie
public init(uriOrPath: String)
```

**功能：** FileUri的构造函数。

**系统能力：** SystemCapability.FileManagement.AppFileService

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|uriOrPath|String|是|-|URI或路径。URI类型：<br/>-&nbsp; 应用沙箱URI：file://\<bundleName>/\<sandboxPath> <br/>-&nbsp; 公共目录文件类URI：file://docs/storage/Users/currentUser/\<publicPath> <br/>-&nbsp; 公共目录媒体类URI：file://media/\<mediaType>/IMG_DATATIME_ID/\<displayName>|

**异常：**

- BusinessException：对应错误码如下表，详见[文件管理错误码](./cj-errorcode-filemanagement.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 13900005 | I/O error. |
  | 13900011 | Out of memory. |
  | 13900020 | Invalid argument. |
  | 13900042 | Unknown error. |
  | 14300002 | Invalid uri. |

### func toString()

```cangjie
public override func toString(): String
```

**功能：** 返回字符串类型URI。

**系统能力：** SystemCapability.FileManagement.AppFileService

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|返回字符串类型URI。|

