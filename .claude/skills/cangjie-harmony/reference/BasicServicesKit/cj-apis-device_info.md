# ohos.device_info（设备信息）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

device_info模块提供终端设备信息查询，开发者不可配置。

## 导入模块

```cangjie
import kit.BasicServicesKit.*
```

## 权限列表

ohos.permission.sec.ACCESS_UDID

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class DeviceInfo

```cangjie
public class DeviceInfo {}
```

**功能：** 提供终端设备信息查询方法。

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop ODID

```cangjie
public static prop ODID: String
```

**功能：** 开发者匿名设备标识符。例如“1234a567-XXXX-XXXX-XXXX-XXXXXXXXXXXX”。

ODID值会在以下场景重新生成：

- 手机恢复出厂设置。

- 同一设备上同一个开发者(developerId相同)的应用全部卸载后重新安装时。

ODID生成规则：

- 根据签名信息里developerId解析出的groupId生成，developerId规则为groupId.developerId，若无groupId则取整个developerId作为groupId。

- 同一设备上运行的同一个开发者(developerId相同)的应用，ODID相同。

- 同一个设备上不同开发者(developerId不同)的应用，ODID不同。

- 不同设备上同一个开发者(developerId相同)的应用，ODID不同。

- 不同设备上不同开发者(developerId不同)的应用，ODID不同。

> **说明：**
>
> 数据长度为37字节。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop abiList

```cangjie
public static prop abiList: String
```

**功能：** 应用二进制接口（Abi）。例如“arm64-v8a”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop bootloaderVersion

```cangjie
public static prop bootloaderVersion: String
```

**功能：** Bootloader版本号。例如“bootloader”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop brand

```cangjie
public static prop brand: String
```

**功能：** 设备品牌名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop buildHost

```cangjie
public static prop buildHost: String
```

**功能：** 构建主机。例如“default”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop buildRootHash

```cangjie
public static prop buildRootHash: String
```

**功能：** 构建版本Hash。例如“default”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop buildTime

```cangjie
public static prop buildTime: String
```

**功能：** 构建时间。例如“default”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop buildType

```cangjie
public static prop buildType: String
```

**功能：** 构建类型。例如“default”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop buildUser

```cangjie
public static prop buildUser: String
```

**功能：** 构建用户。例如“default”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop buildVersion

```cangjie
public static prop buildVersion: Int32
```

**功能：** Build版本号，标识编译构建的版本号，值为osFullName中的第四位数值，建议直接使用deviceInfo.buildVersion获取，可提升效率，不建议开发者自主解析osFullName获取。例如“1”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop deviceType

```cangjie
public static prop deviceType: String
```

**功能：** 设备类型。详细请参考[deviceTypes标签](../../cj-start/basic-knowledge/cj-module-configuration-file.md#devicetypes标签)。例如“<!--RP1-->tablet<!--RP1End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop displayVersion

```cangjie
public static prop displayVersion: String
```

**功能：** 产品版本。例如“<!--RP8-->SGT-AL00 6.0.0.125<!--RP8End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop distributionOSApiName

```cangjie
public static prop distributionOSApiName: String
```

**功能：** 发行版系统api版本名称<!--Del-->，由发行方定义<!--DelEnd-->。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop distributionOSApiVersion

```cangjie
public static prop distributionOSApiVersion: Int32
```

**功能：** 发行版系统api版本<!--Del-->，由发行方定义<!--DelEnd-->。例如“60001”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop distributionOSName

```cangjie
public static prop distributionOSName: String
```

**功能：** 发行版系统名称<!--Del-->，由发行方定义<!--DelEnd-->。例如“OpenHarmony”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop distributionOSReleaseType

```cangjie
public static prop distributionOSReleaseType: String
```

**功能：** 发行版系统类型<!--Del-->，由发行方定义<!--DelEnd-->。例如“Release”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop distributionOSVersion

```cangjie
public static prop distributionOSVersion: String
```

**功能：** 发行版系统版本号<!--Del-->，由发行方定义<!--DelEnd-->。<!--RP11--><!--RP11End-->例如“6.0.0”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop featureVersion

```cangjie
public static prop featureVersion: Int32
```

**功能：** Feature版本号，标识规划的新特性版本，值为osFullName中的第三位数值，建议直接使用deviceInfo.featureVersion获取，可提升效率，不建议开发者自主解析osFullName获取。例如“0”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop firstApiVersion

```cangjie
public static prop firstApiVersion: Int32
```

**功能：** 首个版本系统软件API版本。例如“3”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop hardwareModel

```cangjie
public static prop hardwareModel: String
```

**功能：** 硬件版本号。例如“<!--RP6-->TASA00CVN1<!--RP6End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop incrementalVersion

```cangjie
public static prop incrementalVersion: String
```

**功能：** 差异版本号。例如“default”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop majorVersion

```cangjie
public static prop majorVersion: Int32
```

**功能：** Major版本号，随主版本更新增加，值为osFullName中的第一位数值，建议直接使用deviceInfo.majorVersion获取，可提升效率，不建议开发者解析osFullName获取。例如“5”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop manufacture

```cangjie
public static prop manufacture: String
```

**功能：** 设备厂家名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop marketName

```cangjie
public static prop marketName: String
```

**功能：** 外部产品系列。例如“<!--RP2-->Mate XX<!--RP2End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop osFullName

```cangjie
public static prop osFullName: String
```

**功能：** 系统版本，版本格式OpenHarmony-x.x.x.x,x为数值。例如“OpenHarmony-6.0.2.126”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop osReleaseType

```cangjie
public static prop osReleaseType: String
```

**功能：** 系统的发布类型，取值为：

Canary：面向特定开发者发布的早期预览版本，不承诺API稳定性。

Beta：面向开发者公开发布的Beta版本，不承诺API稳定性。

Release：面向开发者公开发布的正式版本，承诺API稳定性。

例如“<!--RP9-->Canary/Beta/Release<!--RP9End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop productModel

```cangjie
public static prop productModel: String
```

**功能：** 认证型号。例如“<!--RP4-->TAS-AL00<!--RP4End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop productSeries

```cangjie
public static prop productSeries: String
```

**功能：** 产品系列。例如“<!--RP3-->TAS<!--RP3End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop sdkApiVersion

```cangjie
public static prop sdkApiVersion: Int32
```

**功能：** 系统软件API版本。例如“22”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop securityPatchTag

```cangjie
public static prop securityPatchTag: String
```

**功能：** 安全补丁级别。例如“<!--RP7-->2026/01/31<!--RP7End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop seniorVersion

```cangjie
public static prop seniorVersion: Int32
```

**功能：** Senior版本号，随局部架构、重大特性增加，值为osFullName中的第二位数值，建议直接使用deviceInfo.seniorVersion获取，可提升效率，不建议开发者自主解析osFullName获取。
例如“0”。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop serial

```cangjie
public static prop serial: String
```

**功能：** 设备序列号SN(Serial Number)。序列号随设备差异。

> **说明：**
>
> 可作为设备唯一识别码。

**类型：** String

**读写能力：** 只读

**需要权限：** ohos.permission.sec.ACCESS_UDID

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop softwareModel

```cangjie
public static prop softwareModel: String
```

**功能：** 内部软件子型号。例如“<!--RP5-->TAS-AL00<!--RP5End-->”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop udid

```cangjie
public static prop udid: String
```

**功能：** 设备Udid。例如“9D6AABD147XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXE5536412”。

> **说明：**
>
> 数据长度为65字节。可作为设备唯一识别码。

**类型：** String

**读写能力：** 只读

**需要权限：** ohos.permission.sec.ACCESS_UDID

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

### static prop versionId

```cangjie
public static prop versionId: String
```

**功能：** 版本ID。由deviceType、manufacture、brand、productSeries、osFullName、productModel、softwareModel、sdkApiVersion、incrementalVersion、buildType拼接组成。例如“wearable/TAS/OpenHarmony-6.0.2.126/TAS-AL00/TAS-AL00/22/default/release:nolog”。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Startup.SystemInfo

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.BasicServicesKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let osFullName = DeviceInfo.osFullName
    Hilog.info(0, "deviceinfo", "the value of the osFullName is: :${osFullName}")
    let productModel = DeviceInfo.productModel
    Hilog.info(0, "deviceinfo", "the value of the productModelis : :${productModel}")
    let brand = DeviceInfo.brand
    Hilog.info(0, "deviceinfo", "the value of the brand is : :${brand}")
    let deviceType = DeviceInfo.deviceType
    Hilog.info(0, "deviceinfo", "the value of the deviceType is: :${deviceType}")
    let udid = DeviceInfo.udid
    Hilog.info(0, "deviceinfo", "the value of the udid is : :${udid}")
    let buildRootHash = DeviceInfo.buildRootHash
    Hilog.info(0, "deviceinfo", "the value of the buildRootHashis : :${buildRootHash}")
    let buildTime = DeviceInfo.buildTime
    Hilog.info(0, "deviceinfo", "the value of the buildTime is: :${buildTime}")
    let buildHost = DeviceInfo.buildHost
    Hilog.info(0, "deviceinfo", "the value of the buildHost is: :${buildHost}")
    let buildUser = DeviceInfo.buildUser
    Hilog.info(0, "deviceinfo", "the value of the buildUser is: :${buildUser}")
    let buildType = DeviceInfo.buildType
    Hilog.info(0, "deviceinfo", "the value of the buildType is: :${buildType}")
    let versionId = DeviceInfo.versionId
    Hilog.info(0, "deviceinfo", "the value of the versionId is: :${versionId}")
    let firstApiVersion = DeviceInfo.firstApiVersion
    Hilog.info(0, "deviceinfo", "the value of thefirstApiVersion is : :${firstApiVersion}")
    let sdkApiVersion = DeviceInfo.sdkApiVersion
    Hilog.info(0, "deviceinfo", "the value of the sdkApiVersionis : :${sdkApiVersion}")
    let buildVersion = DeviceInfo.buildVersion
    Hilog.info(0, "deviceinfo", "the value of the buildVersionis : :${buildVersion}")
    let majorVersion = DeviceInfo.majorVersion
    Hilog.info(0, "deviceinfo", "the value of the majorVersionis : :${majorVersion}")
    let displayVersion = DeviceInfo.displayVersion
    Hilog.info(0, "deviceinfo", "the value of thedisplayVersion is : :${displayVersion}")
    let serial = DeviceInfo.serial
    Hilog.info(0, "deviceinfo", "the value of the serial is : :${serial}")
    let osReleaseType = DeviceInfo.osReleaseType
    Hilog.info(0, "deviceinfo", "the value of the osReleaseTypeis : :${osReleaseType}")
    let incrementalVersion = DeviceInfo.incrementalVersion
    Hilog.info(0, "deviceinfo", "the value of theincrementalVersion is : :${incrementalVersion}")
    let securityPatchTag = DeviceInfo.securityPatchTag
    Hilog.info(0, "deviceinfo", "the value of thesecurityPatchTag is : :${securityPatchTag}")
    let abiList = DeviceInfo.abiList
    Hilog.info(0, "deviceinfo", "the value of the abiList is ::${abiList}")
    let bootloaderVersion = DeviceInfo.bootloaderVersion
    Hilog.info(0, "deviceinfo", "the value of thebootloaderVersion is : :${bootloaderVersion}")
    let hardwareModel = DeviceInfo.hardwareModel
    Hilog.info(0, "deviceinfo", "the value of the hardwareModelis : :${hardwareModel}")
    let softwareModel = DeviceInfo.softwareModel
    Hilog.info(0, "deviceinfo", "the value of the softwareModelis : :${softwareModel}")
    let productSeries = DeviceInfo.productSeries
    Hilog.info(0, "deviceinfo", "the value of the productSeriesis : :${productSeries}")
    let marketName = DeviceInfo.marketName
    Hilog.info(0, "deviceinfo", "the value of the marketName is: :${marketName}")
    let manufacture = DeviceInfo.manufacture
    Hilog.info(0, "deviceinfo", "the value of the manufactureis : :${manufacture}")
    let distributionOSName = DeviceInfo.distributionOSName
    Hilog.info(0, "deviceinfo", "the value of thedistributionOSName is : :${distributionOSName}")
    let distributionOSVersion = DeviceInfo.distributionOSVersion
    Hilog.info(0, "deviceinfo", "the value of the distributionOSVersion is : :${distributionOSVersion}")
    let distributionOSApiVersion = DeviceInfo.distributionOSApiVersion
    Hilog.info(0, "deviceinfo", "the value of the distributionOSApiVersion is : :${distributionOSApiVersion}")
    let distributionOSReleaseType = DeviceInfo.distributionOSReleaseType
    Hilog.info(0, "deviceinfo", "the value of the distributionOSReleaseType is : :${distributionOSReleaseType}")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```
