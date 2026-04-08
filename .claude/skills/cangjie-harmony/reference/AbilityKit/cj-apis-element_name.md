# ohos.element_name

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

element_name模块描述应用组件结构体，包含bundleName、moduleName和abilityName等。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## class ElementName

```cangjie
public class ElementName {
    public var deviceId: String
    public var bundleName: String
    public var abilityName: String
    public var moduleName: String
    public init(bundleName: String, abilityName: String, deviceId!: String = "", moduleName!: String = "")
}
```

**功能：** ElementName信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var abilityName

```cangjie
public var abilityName: String
```

**功能：** Ability名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var bundleName

```cangjie
public var bundleName: String
```

**功能：** 应用Bundle名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** 设备ID。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var moduleName

```cangjie
public var moduleName: String
```

**功能：** Ability所属的HAP的模块名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### init(String, String, String, String)

```cangjie
public init(bundleName: String, abilityName: String, deviceId!: String = "", moduleName!: String = "")
```

**功能：** 通过指定设备ID、应用Bundle名称、Ability名称和模块名称构造ElementName对象。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|bundleName|String|是|-|应用Bundle名称。|
|abilityName|String|是|-|Ability名称。|
|deviceId|String|否|""|**命名参数。** 设备ID。|
|moduleName|String|否|""|**命名参数。** Ability所属的HAP的模块名称。|

**示例：**

<!-- compile -->
```cangjie
import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let elementName = ElementName("com.ohos.example", "com.ohos.example.MainAbility");
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```
