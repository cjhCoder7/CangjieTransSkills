# ohos.skill

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

skill模块介绍了skill标签对象。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](./cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Skill

```cangjie
public class Skill {
    public let actions: Array<String>
    public let entities: Array<String>
    public let uris: Array<SkillUri>
    public let domainVerify: Bool
}
```

**功能：** skill标签对象，可以通过[getBundleInfoForSelf](./cj-apis-bundle_manager.md#static-func-getbundleinfoforselfint32)获取skill信息，其中入参bundleFlags至少包含 GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY 和 GET_BUNDLE_INFO_WITH_SKILL。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let actions

```cangjie
public let actions: Array<String>
```

**功能：** Skill接收的Action集合。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let domainVerify

```cangjie
public let domainVerify: Bool
```

**功能：** Skill接收的DomainVerify值，仅在AbilityInfo中存在，表示是否开启域名校验，取值为true表示开启域名校验，取值为false表示未开启域名校验。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let entities

```cangjie
public let entities: Array<String>
```

**功能：** Skill接收的Entity集合。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let uris

```cangjie
public let uris: Array<SkillUri>
```

**功能：** Want匹配的Uri集合。

**类型：** Array\<[SkillUri](#class-skilluri)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class SkillUri

```cangjie
public class SkillUri {
    public let scheme: String
    public let host: String
    public let port: Int32
    public let path: String
    public let pathStartWith: String
    public let pathRegex: String
    public let uriType: String
    public let utd: String
    public let maxFilesSupported: Int32
    public let linkFeature: String
}
```

**功能：** 描述标识URI信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let host

```cangjie
public let host: String
```

**功能：** 标识 URI 主机地址部分，仅当 scheme 存在时才生效。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let linkFeature

```cangjie
public let linkFeature: String
```

**功能：** 标识 URI 提供的功能类型，用于实现应用间跳转，仅在AbilityInfo中存在。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let maxFilesSupported

```cangjie
public let maxFilesSupported: Int32
```

**功能：** 对于指定类型的文件，标识一次能接收或打开的最大数量。取值范围：不小于0的整数。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let path

```cangjie
public let path: String
```

**功能：** 标识 URI 路径部分，仅当 scheme 和 host 同时存在时才生效。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let pathRegex

```cangjie
public let pathRegex: String
```

**功能：** 标识 URI 路径部分，用于正则匹配，仅当 scheme 和 host 同时存在时才生效。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let pathStartWith

```cangjie
public let pathStartWith: String
```

**功能：** 标识 URI 路径部分，用于前缀匹配，仅当 scheme 和 host 同时存在时才生效。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let port

```cangjie
public let port: Int32
```

**功能：** 标识 URI 端口，仅当 scheme 和 host 同时存在时才生效。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let scheme

```cangjie
public let scheme: String
```

**功能：** 标识 URI 协议名，常见的有http、https、file、ftp等。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let uriType

```cangjie
public let uriType: String
```

**功能：** 标识与Want相匹配的数据类型，使用MIME（Multipurpose&nbsp;Internet&nbsp;Mail&nbsp;Extensions）类型规范和UniformDataType类型规范。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let utd

```cangjie
public let utd: String
```

**功能：** 标识与 Want 相匹配的 URI 的标准化数据类型，适用于分享等场景。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22
