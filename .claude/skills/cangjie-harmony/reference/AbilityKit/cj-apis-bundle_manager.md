# ohos.bundle.bundle_manager（bundleManager管理）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

bundle_manager模块提供应用信息的查询能力，支持查询应用包信息[BundleInfo](#class-bundleinfo)、应用程序信息[ApplicationInfo](#class-applicationinfo)、UIAbility组件信息[AbilityInfo](#class-abilityinfo)、ExtensionAbility组件信息[ExtensionAbilityInfo](#class-extensionabilityinfo)等。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class AbilityInfo

```cangjie
public class AbilityInfo {
    public let bundleName: String
    public let moduleName: String
    public let name: String
    public let label: String
    public let labelId: Int32
    public let description: String
    public let descriptionId: Int32
    public let icon: String
    public let iconId: Int32
    public let process: String
    public let exported: Bool
    public let orientation: DisplayOrientation
    public let launchType: LaunchType
    public let permissions: Array<String>
    public let deviceTypes: Array<String>
    public let applicationInfo: ApplicationInfo
    public let metadata: Array<Metadata>
    public let enabled: Bool
    public let supportedWindowModes: Array<SupportedWindowMode>
    public let windowSize: WindowSize
    public let excludeFromDock: Bool
    public let skills: Array<Skill>
    public let appIndex: Int32
}
```

**功能：** Ability信息。三方应用可以通过[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)获取Ability信息，其中入参bundleFlags至少包含GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_ABILITY。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appIndex

```cangjie
public let appIndex: Int32
```

**功能：** 应用包的分身索引标识，仅在分身应用中生效。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let applicationInfo

```cangjie
public let applicationInfo: ApplicationInfo
```

**功能：** 应用程序的配置信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY和GET_BUNDLE_INFO_WITH_APPLICATION的值。

**类型：** [ApplicationInfo](#class-applicationinfo)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let bundleName

```cangjie
public let bundleName: String
```

**功能：** 应用Bundle名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let description

```cangjie
public let description: String
```

**功能：** Ability的描述，对应module.json5中abilities下配置的description字段，用于描述当前ability提供的页面内容和功能作用。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let descriptionId

```cangjie
public let descriptionId: Int32
```

**功能：** Ability的描述资源id，是编译构建时根据应用配置abilities下的description自动生成的资源id。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let deviceTypes

```cangjie
public let deviceTypes: Array<String>
```

**功能：** Ability支持的设备类型，来源于module.json5配置的deviceTypes。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let enabled

```cangjie
public let enabled: Bool
```

**功能：** Ability的可用性。可用表示可以拉起或查询，不可用时调用getAbilityInfo需携带GET_ABILITY_INFO_WITH_DISABLE的AbilityFlag。取值true表示可用，false表示不可用。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let excludeFromDock

```cangjie
public let excludeFromDock: Bool
```

**功能：** 判断Ability是否可在dock区域隐藏图标，true表示可以，false表示不可以。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let exported

```cangjie
public let exported: Bool
```

**功能：** 判断Ability是否可以被其他应用拉起，true表示可以，false表示不可以。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let icon

```cangjie
public let icon: String
```

**功能：** Ability的图标资源描述符，对应module.json5中abilities下配置的icon字段。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let iconId

```cangjie
public let iconId: Int32
```

**功能：** Ability的图标资源id，是编译构建时根据应用配置abilities下的icon自动生成的资源id。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let label

```cangjie
public let label: String
```

**功能：** Ability对用户显示的名称的资源描述符，对应module.json5中abilities下配置的label字段。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let labelId

```cangjie
public let labelId: Int32
```

**功能：** Ability的标签资源id，编译构建时根据应用配置abilities下的label自动生成。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let launchType

```cangjie
public let launchType: LaunchType
```

**功能：** Ability的启动模式，决定该Ability在启动时是否以多实例启动，详情参考[启动模式枚举](#enum-launchtype) 。

**类型：** [LaunchType](#enum-launchtype)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let metadata

```cangjie
public let metadata: Array<Metadata>
```

**功能：** Ability的元信息。可以配置成系统定义的参数，使用系统提供的能力，例如快捷方式、窗口元数据配置等。也可以自定义配置参数，通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY和GET_BUNDLE_INFO_WITH_METADATA获取。

**类型：** Array\<[Metadata](./cj-apis-metadata.md#class-metadata)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let moduleName

```cangjie
public let moduleName: String
```

**功能：** Ability所属的模块名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let name

```cangjie
public let name: String
```

**功能：** Ability名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let orientation

```cangjie
public let orientation: DisplayOrientation
```

**功能：** Ability的显示模式。来源于module.json5中abilies标签下配置的orientation字段，如果module.json5配置文件中orientation配置枚举，orientation属性有值且非0，取值详情参考[显示模式枚举](#enum-displayorientation)；如果配置文件中配置的是资源索引，orientation属性值为0。

**类型：** [DisplayOrientation](#enum-displayorientation)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let permissions

```cangjie
public let permissions: Array<String>
```

**功能：** 被其他应用拉起/访问时，其他应用需要申请的权限集合，只有当前AbilityInfo的exported为true，即当前Ability可以被其他应用拉起时，才会查看其他应用是否存在拉起/访问的权限。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let process

```cangjie
public let process: String
```

**功能：** Ability的进程名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let skills

```cangjie
public let skills: Array<Skill>
```

**功能：** Ability的Skills信息，标识UIAbility组件或者ExtensionAbility组件能够接收的[Want](../../application-models/cj-want-overview.md)的特征。

**类型：** Array\<[Skill](./cj-apis-skill.md#class-skill)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let supportedWindowModes

```cangjie
public let supportedWindowModes: Array<SupportedWindowMode>
```

**功能：** Ability支持的窗口模式。

**类型：** Array\<[SupportedWindowMode](#enum-supportedwindowmode)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let windowSize

```cangjie
public let windowSize: WindowSize
```

**功能：** Ability窗口尺寸。

**类型：** [WindowSize](#class-windowsize)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class ApplicationInfo

```cangjie
public class ApplicationInfo {
    public let name: String
    public let description: String
    public let descriptionId: Int32
    public let enabled: Bool
    public let label: String
    public let labelId: Int32
    public let icon: String
    public let iconId: Int32
    public let process: String
    public let permissions: Array<String>
    public let codePath: String
    public let metadataArray: Array<ModuleMetadata>
    public let removable: Bool
    public let accessTokenId: UInt32
    public let uid: Int32
    public let iconResource: AppResource
    public let labelResource: AppResource
    public let descriptionResource: AppResource
    public let appDistributionType: String
    public let appProvisionType: String
    public let systemApp: Bool
    public let bundleType: BundleType
    public let debug: Bool
    public let dataUnclearable: Bool
    public let cloudFileSyncEnabled: Bool
    public let nativeLibraryPath: String
    public let multiAppMode: MultiAppMode
    public let appIndex: Int32
    public let installSource: String
    public let releaseType: String
}
```

**功能：** 应用程序的配置信息。三方应用可以通过[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)获取自身的应用程序信息，其中入参bundleFlags至少包含GET_BUNDLE_INFO_WITH_APPLICATION。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let accessTokenId

```cangjie
public let accessTokenId: UInt32
```

**功能：** 应用程序的accessTokenId，应用的身份标识，在[程序访问控制校验接口](./cj-apis-ability_access_ctrl.md#func-checkaccesstokenuint32-permissions)中使用。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appDistributionType

```cangjie
public let appDistributionType: String
```

**功能：** 应用程序签名证书的分发类型。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appIndex

```cangjie
public let appIndex: Int32
```

**功能：** 应用包的分身索引标识，仅在分身应用中生效。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appProvisionType

```cangjie
public let appProvisionType: String
```

**功能：** 应用程序签名证书文件的类型，分为debug和release两种类型。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let bundleType

```cangjie
public let bundleType: BundleType
```

**功能：** 标识包的类型，取值为APP（应用）或者ATOMIC_SERVICE（原子化服务）。

**类型：** [BundleType](#enum-bundletype)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let cloudFileSyncEnabled

```cangjie
public let cloudFileSyncEnabled: Bool
```

**功能：** 标识当前应用是否启用端云文件同步能力。true表示当前应用启用端云文件同步能力，false表示当前应用不启用端云文件同步能力。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let codePath

```cangjie
public let codePath: String
```

**功能：** 应用程序的安装目录。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let dataUnclearable

```cangjie
public let dataUnclearable: Bool
```

**功能：** 标识应用数据是否可被删除。true表示不可删除，false表示可以删除。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let debug

```cangjie
public let debug: Bool
```

**功能：** 标识应用是否处于调试模式，取值为true表示应用处于调试模式，取值为false表示应用处于非调试模式。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let description

```cangjie
public let description: String
```

**功能：** 标识应用的描述信息，对应app.json5中配置的description字段。关于description的详细信息详见本表中的descriptionResource字段说明。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let descriptionId

```cangjie
public let descriptionId: Int32
```

**功能：** 标识应用的描述信息的资源id，编译构建时根据应用配置的description自动生成。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let descriptionResource

```cangjie
public let descriptionResource: AppResource
```

**功能：** 应用程序的描述资源信息，包含bundleName、moduleName和id，可以调用全球化的接口[getMediaContent](../LocalizationKit/cj-apis-resource_manager.md#func-getmediacontentuint32-screendensity)来获取详细的资源数据信息。

**类型：** [AppResource](../LocalizationKit/cj-apis-resource.md#class-appresource)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let enabled

```cangjie
public let enabled: Bool
```

**功能：** 判断应用程序是否可以使用，取值为true表示可以使用，取值为false表示不可使用。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let icon

```cangjie
public let icon: String
```

**功能：** 应用程序的图标，对应app.json5中配置的icon字段。关于icon的详细信息详见本表中的iconResource字段说明。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let iconId

```cangjie
public let iconId: Int32
```

**功能：** 应用程序图标的资源id，是编译构建时根据应用配置的icon自动生成的资源id。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let iconResource

```cangjie
public let iconResource: AppResource
```

**功能：** 应用程序的图标资源信息，包含bundleName、moduleName和id，可以调用全球化的接口[getMediaContent](../LocalizationKit/cj-apis-resource_manager.md#func-getmediacontentuint32-screendensity)来获取详细的资源数据信息。

**类型：** [AppResource](../LocalizationKit/cj-apis-resource.md#class-appresource)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let installSource

```cangjie
public let installSource: String
```

**功能：** 应用程序的安装来源，支持的取值如下：

- pre-installed表示应用为第一次开机时安装的预置应用。

- ota表示应用为系统升级时新增的预置应用。

- recovery表示卸载后再恢复的预置应用。

- bundleName表示应用由此包名对应的应用安装。

- unknown表示应用安装来源未知。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let label

```cangjie
public let label: String
```

**功能：** 标识应用的名称，对应app.json5中配置的label字段。关于label的详细信息详见本表中的labelResource字段说明。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let labelId

```cangjie
public let labelId: Int32
```

**功能：** 标识应用名称的资源id，是编译构建时根据应用配置的label自动生成的资源id。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let labelResource

```cangjie
public let labelResource: AppResource
```

**功能：** 应用程序的名称资源信息，包含bundleName、moduleName和id，可以调用全球化的接口[getMediaContent](../LocalizationKit/cj-apis-resource_manager.md#func-getmediacontentuint32-screendensity)来获取详细的资源数据信息。

**类型：** [AppResource](../LocalizationKit/cj-apis-resource.md#class-appresource)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let metadataArray

```cangjie
public let metadataArray: Array<ModuleMetadata>
```

**功能：** 应用程序的元信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_APPLICATION和GET_BUNDLE_INFO_WITH_METADATA的值。

**类型：** Array\<[ModuleMetadata](#class-modulemetadata)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let multiAppMode

```cangjie
public let multiAppMode: MultiAppMode
```

**功能：** 应用多开模式。

**类型：** [MultiAppMode](#class-multiappmode)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let name

```cangjie
public let name: String
```

**功能：** 应用程序的名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let nativeLibraryPath

```cangjie
public let nativeLibraryPath: String
```

**功能：** 应用程序的本地库文件路径。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let permissions

```cangjie
public let permissions: Array<String>
```

**功能：** 访问应用程序所需的权限。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_APPLICATION和GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION的值。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let process

```cangjie
public let process: String
```

**功能：** 应用程序的进程名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let releaseType

```cangjie
public let releaseType: String
```

**功能：** 标识应用打包时使用的SDK的发布类型。当前SDK的发布类型可能为Canary、Beta、Release，其中Canary和Beta可能通过序号进一步细分，例如Canary1、Canary2、Beta1、Beta2等。开发者可通过对比应用打包依赖的SDK发布类型和OS的发布类型（[deviceInfo.distributionOSReleaseType](../BasicServicesKit/cj-apis-device_info.md)）来判断兼容性。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let removable

```cangjie
public let removable: Bool
```

**功能：** 应用程序是否可以被移除，取值为true表示可以被移除，取值为false表示不可以被移除。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let systemApp

```cangjie
public let systemApp: Bool
```

**功能：** 标识应用是否为系统应用，取值为true表示系统应用，取值为false表示非系统应用。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let uid

```cangjie
public let uid: Int32
```

**功能：** 应用程序的UID。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class BundleFlag

```cangjie
public class BundleFlag {
    public static const GET_BUNDLE_INFO_DEFAULT: Int32 = 0x00000000
    public static const GET_BUNDLE_INFO_WITH_APPLICATION: Int32 = 0x00000001
    public static const GET_BUNDLE_INFO_WITH_HAP_MODULE: Int32 = 0x00000002
    public static const GET_BUNDLE_INFO_WITH_ABILITY: Int32 = 0x00000004
    public static const GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY: Int32 = 0x00000008
    public static const GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION: Int32 = 0x00000010
    public static const GET_BUNDLE_INFO_WITH_METADATA: Int32 = 0x00000020
    public static const GET_BUNDLE_INFO_WITH_DISABLE: Int32 = 0x00000040
    public static const GET_BUNDLE_INFO_WITH_SIGNATURE_INFO: Int32 = 0x00000080
    public static const GET_BUNDLE_INFO_WITH_MENU: Int32 = 0x00000100
    public static const GET_BUNDLE_INFO_WITH_ROUTER_MAP: Int32 = 0x00000200
    public static const GET_BUNDLE_INFO_WITH_SKILL: Int32 = 0x00000800
}
```

**功能：** 包信息标志，指示需要获取的包信息的内容。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_DEFAULT

```cangjie
public static const GET_BUNDLE_INFO_DEFAULT: Int32 = 0x00000000
```

**功能：** 获取默认包信息，不包含signatureInfo、applicationInfo、hapModuleInfo、ability、extensionAbility和permission的信息。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_ABILITY

```cangjie
public static const GET_BUNDLE_INFO_WITH_ABILITY: Int32 = 0x00000004
```

**功能：** 用于获取包含ability的bundleInfo，获取的bundleInfo不包含signatureInfo、applicationInfo、extensionAbility和permission的信息。单独使用不生效，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE一起使用。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_APPLICATION

```cangjie
public static const GET_BUNDLE_INFO_WITH_APPLICATION: Int32 = 0x00000001
```

**功能：** 用于获取包含applicationInfo的bundleInfo，获取的bundleInfo不包含signatureInfo、hapModuleInfo、ability、extensionAbility和permission的信息。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_DISABLE

```cangjie
public static const GET_BUNDLE_INFO_WITH_DISABLE: Int32 = 0x00000040
```

**功能：** 用于获取application被禁用的BundleInfo和被禁用的Ability信息。获取的bundleInfo不包含signatureInfo、applicationInfo、hapModuleInfo、ability、extensionAbility和permission的信息。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY

```cangjie
public static const GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY: Int32 = 0x00000008
```

**功能：** 用于获取包含extensionAbility的bundleInfo，获取的bundleInfo不包含signatureInfo、applicationInfo、ability 和permission的信息。单独使用不生效，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE一起使用。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_HAP_MODULE

```cangjie
public static const GET_BUNDLE_INFO_WITH_HAP_MODULE: Int32 = 0x00000002
```

**功能：** 用于获取包含hapModuleInfo的bundleInfo，获取的bundleInfo不包含signatureInfo、applicationInfo、ability、extensionAbility和permission的信息。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_MENU

```cangjie
public static const GET_BUNDLE_INFO_WITH_MENU: Int32 = 0x00000100
```

**功能：** 用于获取包含fileContextMenuConfig的bundleInfo。单独使用不生效，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE一起使用。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_METADATA

```cangjie
public static const GET_BUNDLE_INFO_WITH_METADATA: Int32 = 0x00000020
```

**功能：** 用于获取applicationInfo、moduleInfo、abilityInfo和extensionAbilityInfo中包含的metadata。

单独使用时无效，必须与以下权限配合使用：GET_BUNDLE_INFO_WITH_APPLICATION、GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY、GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY。其中：

- 获取applicationInfo中包含的metadata，需要与GET_BUNDLE_INFO_WITH_APPLICATION一起使用。

- 获取moduleInfo中包含的metadata，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE一起使用。

- 获取abilityInfo中包含的metadata，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY一起使用。

- 获取extensionAbilityInfo中包含的metadata，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY一起使用。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION

```cangjie
public static const GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION: Int32 = 0x00000010
```

**功能：** 用于获取包含permission的bundleInfo。获取的bundleInfo不包含signatureInfo、applicationInfo、hapModuleInfo、extensionAbility和ability的信息。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_ROUTER_MAP

```cangjie
public static const GET_BUNDLE_INFO_WITH_ROUTER_MAP: Int32 = 0x00000200
```

**功能：** 用于获取包含routerMap的bundleInfo。单独使用不生效，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE一起使用。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_SIGNATURE_INFO

```cangjie
public static const GET_BUNDLE_INFO_WITH_SIGNATURE_INFO: Int32 = 0x00000080
```

**功能：** 用于获取包含signatureInfo的bundleInfo。获取的bundleInfo不包含applicationInfo、hapModuleInfo、extensionAbility、ability和permission的信息。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static const GET_BUNDLE_INFO_WITH_SKILL

```cangjie
public static const GET_BUNDLE_INFO_WITH_SKILL: Int32 = 0x00000800
```

**功能：** 用于获取包含skills的bundleInfo。单独使用不生效，需要与GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY、GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY一起使用。

**类型：** Int32

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class BundleInfo

```cangjie
public class BundleInfo {
    public let name: String
    public let vendor: String
    public let versionCode: UInt32
    public let versionName: String
    public let minCompatibleVersionCode: UInt32
    public let targetVersion: UInt32
    public let appInfo: ApplicationInfo
    public let hapModulesInfo: Array<HapModuleInfo>
    public let reqPermissionDetails: Array<ReqPermissionDetail>
    public let permissionGrantStates: Array<PermissionGrantState>
    public let signatureInfo: SignatureInfo
    public let installTime: Int64
    public let updateTime: Int64
    public let routerMap: Array<RouterItem>
    public let appIndex: Int32
}
```

**功能：** 应用包信息，可以通过[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)获取自身的应用包信息，其中参数[bundleFlags](#class-bundleflag)指定所返回的[BundleInfo](#class-bundleinfo)中所包含的信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appIndex

```cangjie
public let appIndex: Int32
```

**功能：** 应用包的分身索引标识，仅在分身应用中生效。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appInfo

```cangjie
public let appInfo: ApplicationInfo
```

**功能：** 应用程序的配置信息，通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_APPLICATION获取。

**类型：** [ApplicationInfo](#class-applicationinfo)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let hapModulesInfo

```cangjie
public let hapModulesInfo: Array<HapModuleInfo>
```

**功能：** 模块的配置信息，通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE获取。

**类型：** Array\<[HapModuleInfo](#class-hapmoduleinfo)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let installTime

```cangjie
public let installTime: Int64
```

**功能：** 应用包安装时间戳，表示从1970-01-01 08:00:00 UTC+8逝去的毫秒数，单位毫秒。

> **说明：**
>
> 设备出厂首次开机时，如果未获取到当前时间，会以Unix时间戳基准（1970-01-01 08:00:00 UTC+8）作为当前系统的起始时间。例如，开机后未获取到时间，等待32s之后安装成功，则应用包安装时间戳为32000。

**类型：** Int64

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let minCompatibleVersionCode

```cangjie
public let minCompatibleVersionCode: UInt32
```

**功能：** 分布式场景下的应用包兼容的最低版本，对应app.json5中配置的minCompatibleVersionCode字段。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let name

```cangjie
public let name: String
```

**功能：** 应用包的名称，对应app.json5中配置的bundleName字段。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let permissionGrantStates

```cangjie
public let permissionGrantStates: Array<PermissionGrantState>
```

**功能：** 申请权限的授予状态。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION的值。

**类型：** Array\<[PermissionGrantState](#enum-permissiongrantstate)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let reqPermissionDetails

```cangjie
public let reqPermissionDetails: Array<ReqPermissionDetail>
```

**功能：** 应用运行时需向系统申请的权限集合的详细信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION的值。

**类型：** Array\<[ReqPermissionDetail](#class-reqpermissiondetail)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let routerMap

```cangjie
public let routerMap: Array<RouterItem>
```

**功能：** 应用的路由表配置，由hapModulesInfo下的routerMap信息，根据RouterItem中的name字段进行去重后合并得到。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_ROUTER_MAP的值。

**类型：** Array\<[RouterItem](#class-routeritem)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let signatureInfo

```cangjie
public let signatureInfo: SignatureInfo
```

**功能：** 应用包的签名信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_SIGNATURE_INFO的值。

**类型：** [SignatureInfo](#class-signatureinfo)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let targetVersion

```cangjie
public let targetVersion: UInt32
```

**功能：** 应用运行目标版本，对应app.json5中配置的targetAPIVersion字段。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let updateTime

```cangjie
public let updateTime: Int64
```

**功能：** 应用包更新时间戳，表示从1970-01-01 08:00:00 UTC+8逝去的毫秒数，单位毫秒。

**类型：** Int64

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let vendor

```cangjie
public let vendor: String
```

**功能：** 应用包的供应商，对应app.json5中配置的vendor字段。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let versionCode

```cangjie
public let versionCode: UInt32
```

**功能：** 应用包的版本号，对应app.json5中配置的versionCode字段。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let versionName

```cangjie
public let versionName: String
```

**功能：** 应用包的版本文本描述信息，对应app.json5中配置的versionName字段。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class BundleManager

```cangjie
public class BundleManager {}
```

**功能：** 提供Bundle信息查询方法的类。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### static func canOpenLink(String)

```cangjie
public static func canOpenLink(link: String): Bool
```

**功能：** 根据给定的链接判断目标应用是否可访问，链接中的scheme需要在module.json5文件的querySchemes字段下配置。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|link|String|是|-|表示需要查询的链接。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示给定的链接可以打开，返回false表示给定的链接不能打开。|

**异常：**

- BusinessException：对应错误码如下表，详见[包管理子系统通用错误码](./cj-errorcode-bundle.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17700055 | The specified link is invalid. |
  | 17700056 | The scheme of the specified link is not in the querySchemes. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let link = "app1Scheme://test.example.com/home"
    let canOpen = BundleManager.canOpenLink(link)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getBundleInfoForSelf(Int32)

```cangjie
public static func getBundleInfoForSelf(bundleFlags: Int32): BundleInfo
```

**功能：** 根据给定的bundleFlags获取当前应用的BundleInfo。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|bundleFlags|Int32|是|-|指定返回的BundleInfo所包含的信息。|

**返回值：**

|类型|说明|
|:----|:----|
|[BundleInfo](#class-bundleinfo)|BundleInfo对象，返回当前应用的BundleInfo。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let bundleFlags = BundleFlag.GET_BUNDLE_INFO_DEFAULT | BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE | BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY
    let res = BundleManager.getBundleInfoForSelf(bundleFlags)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getProfileByAbility(String, String, String)

```cangjie
public static func getProfileByAbility(moduleName: String, abilityName: String, metadataName!: String = ""): Array<String>
```

**功能：** 根据给定的moduleName、abilityName和metadataName（module.json5中metadata标签下的name）获取自身相应配置文件的json格式字符串，返回对象为string数组。

>如果配置文件信息采用了资源引用格式，则返回值将保持资源引用格式（例如 $string:res_id），开发者可以通过[资源管理模块](../LocalizationKit/cj-apis-resource_manager.md)的相关接口，来获取引用的资源。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|moduleName|String|是|-|表示Module名称。|
|abilityName|String|是|-|表示UIAbility组件的名称。|
|metadataName|String|否|""|**命名参数。** 表示UIAbility组件的元信息名称，即module.json5配置文件中abilities标签下的metadata标签的name，默认值为空。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|数组对象，返回Array\<String>。|

**异常：**

- BusinessException：对应错误码如下表，详见[包管理子系统通用错误码](./cj-errorcode-bundle.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 17700002 | The specified moduleName is not existed. |
  | 17700003 | The specified abilityName is not existed. |
  | 17700024 | Failed to get the profile because there is no profile in the HAP. |
  | 17700029 | The specified ability is disabled. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let moduleName = "entry"
    let abilityName = "EntryAbility"
    let infoList = BundleManager.getProfileByAbility(moduleName, abilityName)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class DataItem

```cangjie
public class DataItem {
    public let key: String
    public let value: String
}
```

**功能：** 描述模块配置的路由表中的自定义数据。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let key

```cangjie
public let key: String
```

**功能：** 标识路由表自定义数据的键。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let value

```cangjie
public let value: String
```

**功能：** 标识路由表自定义数据的值。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class DefaultAppManager

```cangjie
public class DefaultAppManager {}
```

**功能：** 该类提供查询默认应用的能力，支持查询当前应用是否是默认应用。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### static func isDefaultApplication(ApplicationType)

```cangjie
public static func isDefaultApplication(appType: ApplicationType): Bool
```

**功能：** 根据系统已定义的应用类型判断当前应用是否是该类型的默认应用。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|appType|ApplicationType|是|-|要查询的应用类型，取[ApplicationType](#enum-applicationtype)类型中的值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回当前应用是否是默认应用，true表示是默认应用，false表示不是默认应用。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let tag = DefaultAppManager.isDefaultApplication(ApplicationType.Image)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Dependency

```cangjie
public class Dependency {
    public let bundleName: String
    public let moduleName: String
    public let versionCode: UInt32
}
```

**功能：** 描述模块所依赖的动态共享库信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let bundleName

```cangjie
public let bundleName: String
```

**功能：** 标识当前模块依赖的共享包的包名。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let moduleName

```cangjie
public let moduleName: String
```

**功能：** 标识当前模块依赖的共享包模块名。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let versionCode

```cangjie
public let versionCode: UInt32
```

**功能：** 标识当前共享包的版本号。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class ExtensionAbilityInfo

```cangjie
public class ExtensionAbilityInfo {
    public let bundleName: String
    public let moduleName: String
    public let name: String
    public let labelId: Int32
    public let descriptionId: Int32
    public let iconId: Int32
    public let exported: Bool
    public let extensionAbilityType: ExtensionAbilityType
    public let permissions: Array<String>
    public let applicationInfo: ApplicationInfo
    public let metadata: Array<Metadata>
    public let enabled: Bool
    public let readPermission: String
    public let writePermission: String
    public let extensionAbilityTypeName: String
    public let skills: Array<Skill>
    public let appIndex: Int32
}
```

**功能：** ExtensionAbility信息，可以通过[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)获取自身的ExtensionAbility信息，其中参数[bundleFlags](#class-bundleflag)至少包含GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appIndex

```cangjie
public let appIndex: Int32
```

**功能：** 应用包的分身索引标识，仅在分身应用中生效。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let applicationInfo

```cangjie
public let applicationInfo: ApplicationInfo
```

**功能：** 应用程序的配置信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY和GET_BUNDLE_INFO_WITH_APPLICATION获取。

**类型：** [ApplicationInfo](#class-applicationinfo)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let bundleName

```cangjie
public let bundleName: String
```

**功能：** 应用Bundle名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let descriptionId

```cangjie
public let descriptionId: Int32
```

**功能：** ExtensionAbility的描述资源ID。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let enabled

```cangjie
public let enabled: Bool
```

**功能：** ExtensionAbility是否可用，取值为true表示ExtensionAbility可用，取值为false表示ExtensionAbility不可用。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let exported

```cangjie
public let exported: Bool
```

**功能：** 判断ExtensionAbility是否可以被其他应用调用，取值为true表示ExtensionAbility可以被其他应用调用，取值为false表示ExtensionAbility不可以被其他应用调用。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let extensionAbilityType

```cangjie
public let extensionAbilityType: ExtensionAbilityType
```

**功能：** ExtensionAbility类型。

**类型：** [ExtensionAbilityType](#enum-extensionabilitytype)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let extensionAbilityTypeName

```cangjie
public let extensionAbilityTypeName: String
```

**功能：** ExtensionAbility的类型名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let iconId

```cangjie
public let iconId: Int32
```

**功能：** ExtensionAbility的图标资源ID。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let labelId

```cangjie
public let labelId: Int32
```

**功能：** ExtensionAbility的标签资源ID。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let metadata

```cangjie
public let metadata: Array<Metadata>
```

**功能：** ExtensionAbility的元信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY和GET_BUNDLE_INFO_WITH_METADATA获取。

**类型：** Array\<[Metadata](./cj-apis-metadata.md#class-metadata)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let moduleName

```cangjie
public let moduleName: String
```

**功能：** ExtensionAbility所属的HAP的名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let name

```cangjie
public let name: String
```

**功能：** ExtensionAbility名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let permissions

```cangjie
public let permissions: Array<String>
```

**功能：** 被其他应用ExtensionAbility调用时需要申请的权限集合。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let readPermission

```cangjie
public let readPermission: String
```

**功能：** 读取ExtensionAbility数据所需的权限。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let skills

```cangjie
public let skills: Array<Skill>
```

**功能：** ExtensionAbility的Skills信息。

**类型：** Array\<[Skill](./cj-apis-skill.md#class-skill)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let writePermission

```cangjie
public let writePermission: String
```

**功能：** 向ExtensionAbility写数据所需的权限。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class HapModuleInfo

```cangjie
public class HapModuleInfo {
    public let name: String
    public let icon: String
    public let iconId: Int32
    public let label: String
    public let labelId: Int32
    public let description: String
    public let descriptionId: Int32
    public let mainElementName: String
    public let abilitiesInfo: Array<AbilityInfo>
    public let extensionAbilitiesInfo: Array<ExtensionAbilityInfo>
    public let metadata: Array<Metadata>
    public let deviceTypes: Array<String>
    public let installationFree: Bool
    public let hashValue: String
    public let moduleType: ModuleType
    public let preloads: Array<PreloadItem>
    public let dependencies: Array<Dependency>
    public let fileContextMenuConfig: String
    public let routerMap: Array<RouterItem>
    public let codePath: String
    public let nativeLibraryPath: String
}
```

**功能：** HAP信息，可以通过[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)获取自身的HAP信息，其中参数[bundleFlags](#class-bundleflag)至少包含GET_BUNDLE_INFO_WITH_HAP_MODULE。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let abilitiesInfo

```cangjie
public let abilitiesInfo: Array<AbilityInfo>
```

**功能：** 当前模块所有Ability的信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_ABILITY获取。

**类型：** Array\<[AbilityInfo](#class-abilityinfo)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let codePath

```cangjie
public let codePath: String
```

**功能：** 模块的安装路径。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let dependencies

```cangjie
public let dependencies: Array<Dependency>
```

**功能：** 模块运行依赖的动态共享库列表。

**类型：** Array\<[Dependency](#class-dependency)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let description

```cangjie
public let description: String
```

**功能：** 模块描述信息。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let descriptionId

```cangjie
public let descriptionId: Int32
```

**功能：** 描述信息的资源id值。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let deviceTypes

```cangjie
public let deviceTypes: Array<String>
```

**功能：** 可以运行模块的设备类型。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let extensionAbilitiesInfo

```cangjie
public let extensionAbilitiesInfo: Array<ExtensionAbilityInfo>
```

**功能：** 当前模块所有ExtensionAbility的信息。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY获取。

**类型：** Array\<[ExtensionAbilityInfo](#class-extensionabilityinfo)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let fileContextMenuConfig

```cangjie
public let fileContextMenuConfig: String
```

**功能：** 模块的文件菜单配置。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_MENU获取。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let hashValue

```cangjie
public let hashValue: String
```

**功能：** 模块的Hash值。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let icon

```cangjie
public let icon: String
```

**功能：** 当前模块入口Ability的图标，取值为图标资源文件的索引，与模块配置文件中abilities标签或extensionAbilities标签的icon字段值一致。若未配置入口Ability，则为空。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let iconId

```cangjie
public let iconId: Int32
```

**功能：** 当前模块入口Ability的图标资源id值。若未配置入口Ability，则为空。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let installationFree

```cangjie
public let installationFree: Bool
```

**功能：** 模块是否支免安装（无需用户通过应用市场显式安装），取值为true表示支持免安装，取值为false表示不支持免安装。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let label

```cangjie
public let label: String
```

**功能：** 当前模块入口Ability的名称，取值为字符串资源的索引，与模块配置文件中abilities标签或extensionAbilities标签的label字段值一致。若未配置入口Ability，则为空。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let labelId

```cangjie
public let labelId: Int32
```

**功能：** 当前模块入口Ability名称的资源id值。若未配置入口Ability，则为空。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let mainElementName

```cangjie
public let mainElementName: String
```

**功能：** 当前模块的入口UIAbility名称或者ExtensionAbility名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let metadata

```cangjie
public let metadata: Array<Metadata>
```

**功能：** 当前模块的元数据。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_METADATA获取。

**类型：** Array\<[Metadata](./cj-apis-metadata.md#class-metadata)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let moduleType

```cangjie
public let moduleType: ModuleType
```

**功能：** 标识当前模块的类型。

**类型：** [ModuleType](#enum-moduletype)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let name

```cangjie
public let name: String
```

**功能：** 模块名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let nativeLibraryPath

```cangjie
public let nativeLibraryPath: String
```

**功能：** 应用程序内模块本地库文件路径。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let preloads

```cangjie
public let preloads: Array<PreloadItem>
```

**功能：** 原子化服务中模块的预加载列表。

**类型：** Array\<[PreloadItem](#class-preloaditem)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let routerMap

```cangjie
public let routerMap: Array<RouterItem>
```

**功能：** 模块的路由表配置。通过调用[getBundleInfoForSelf](#static-func-getbundleinfoforselfint32)接口，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE和GET_BUNDLE_INFO_WITH_ROUTER_MAP获取。

**类型：** Array\<[RouterItem](#class-routeritem)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class ModuleMetadata

```cangjie
public class ModuleMetadata {
    public let moduleName: String
    public let metadata: Array<Metadata>
}
```

**功能：** 描述模块的元数据信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let metadata

```cangjie
public let metadata: Array<Metadata>
```

**功能：** 该模块下的元数据信息列表。

**类型：** Array\<[Metadata](./cj-apis-metadata.md#class-metadata)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let moduleName

```cangjie
public let moduleName: String
```

**功能：** 模块名。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class MultiAppMode

```cangjie
public class MultiAppMode {
    public let multiAppModeType: MultiAppModeType
    public let maxCount: Int32
}
```

**功能：** 表示应用多开模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let maxCount

```cangjie
public let maxCount: Int32
```

**功能：** 应用多开的最大个数。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let multiAppModeType

```cangjie
public let multiAppModeType: MultiAppModeType
```

**功能：** 应用多开模式的类型。

**类型：** [MultiAppModeType](#enum-multiappmodetype)

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class PreloadItem

```cangjie
public class PreloadItem {
    public let moduleName: String
}
```

**功能：** 描述原子化服务中模块的预加载模块信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let moduleName

```cangjie
public let moduleName: String
```

**功能：** 模块名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class ReqPermissionDetail

```cangjie
public class ReqPermissionDetail {
    public var name: String
    public var moduleName: String
    public var reason: String
    public var reasonId: Int32
    public var usedScene: UsedScene
}
```

**功能：** 应用运行时需向系统申请的权限集合的详细信息。

> **说明：**
>
> 如果应用内多包申请的权限名称一样，但是权限申请理由不一致，系统只会返回一个权限申请理由，优先级从高到低顺序为entry类型HAP、feature类型HAP、应用内HSP。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var moduleName

```cangjie
public var moduleName: String
```

**功能：** 申请该权限的module名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 需要使用的权限名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var reason

```cangjie
public var reason: String
```

**功能：** 描述申请权限的原因。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var reasonId

```cangjie
public var reasonId: Int32
```

**功能：** 描述申请权限的原因ID。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var usedScene

```cangjie
public var usedScene: UsedScene
```

**功能：** 权限使用的场景和时机。

**类型：** [UsedScene](#class-usedscene)

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class RouterItem

```cangjie
public class RouterItem {
    public let name: String
    public let pageSourceFile: String
    public let buildFunction: String
    public let data: Array<DataItem>
    public let customData: String
}
```

**功能：** 描述模块配置的路由表信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let buildFunction

```cangjie
public let buildFunction: String
```

**功能：** 标识被@Builder修饰的函数，该函数描述页面的UI。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let customData

```cangjie
public let customData: String
```

**功能：** 标识路由表配置文件中的任意类型的自定义数据，即customData字段的JSON字符串，开发者需要调用JSON.parse函数解析出具体内容。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let data

```cangjie
public let data: Array<DataItem>
```

**功能：** 标识路由表配置文件中的字符串自定义数据，即data字段的信息，该字段已由系统解析，无需开发者自行解析。

**类型：** Array\<[DataItem](#class-dataitem)>

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let name

```cangjie
public let name: String
```

**功能：** 标识跳转页面的名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let pageSourceFile

```cangjie
public let pageSourceFile: String
```

**功能：** 标识页面在模块内的路径。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class SignatureInfo

```cangjie
public class SignatureInfo {
    public let appId: String
    public let fingerprint: String
    public let appIdentifier: String
}
```

**功能：** 描述应用包的签名信息。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appId

```cangjie
public let appId: String
```

**功能：** 应用的appId，表示应用的唯一标识。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let appIdentifier

```cangjie
public let appIdentifier: String
```

**功能：** 应用的唯一标识。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let fingerprint

```cangjie
public let fingerprint: String
```

**功能：** 应用包的指纹信息，由签名证书通过SHA-256算法计算哈希值生成。使用的签名证书发生变化时，该字段也会发生变化。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class UsedScene

```cangjie
public class UsedScene {
    public var abilities: Array<String>
    public var when: String
}
```

**功能：** 描述权限使用的场景和时机。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var abilities

```cangjie
public var abilities: Array<String>
```

**功能：** 使用到该权限的Ability集合。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var when

```cangjie
public var when: String
```

**功能：** 使用该权限的时机。支持的取值有inuse（使用时）、always（始终）。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## class WindowSize

```cangjie
public class WindowSize {
    public let maxWindowRatio: Float64
    public let minWindowRatio: Float64
    public let maxWindowWidth: UInt32
    public let minWindowWidth: UInt32
    public let maxWindowHeight: UInt32
    public let minWindowHeight: UInt32
}
```

**功能：** 描述窗口尺寸。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let maxWindowHeight

```cangjie
public let maxWindowHeight: UInt32
```

**功能：** 表示自由窗口状态下窗口的最大高度，高度单位为vp。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let maxWindowRatio

```cangjie
public let maxWindowRatio: Float64
```

**功能：** 表示自由窗口状态下窗口的最大宽高比；取值范围0-1，例如：0.12。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let maxWindowWidth

```cangjie
public let maxWindowWidth: UInt32
```

**功能：** 表示自由窗口状态下窗口的最大宽度，宽度单位为vp。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let minWindowHeight

```cangjie
public let minWindowHeight: UInt32
```

**功能：** 表示自由窗口状态下窗口的最小高度，高度单位为vp。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let minWindowRatio

```cangjie
public let minWindowRatio: Float64
```

**功能：** 表示自由窗口状态下窗口的最小宽高比；取值范围0-1，例如：0.5。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### let minWindowWidth

```cangjie
public let minWindowWidth: UInt32
```

**功能：** 表示自由窗口状态下窗口的最小宽度，宽度单位为vp。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum ApplicationType

```cangjie
public enum ApplicationType {
    | Browser
    | Image
    | Audio
    | Video
    | Pdf
    | Word
    | Excel
    | Ppt
    | Email
    | ...
}
```

**功能：** 默认应用的应用类型。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Audio

```cangjie
Audio
```

**功能：** 默认音频播放器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Browser

```cangjie
Browser
```

**功能：** 默认浏览器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Email

```cangjie
Email
```

**功能：** 邮件默认应用。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Excel

```cangjie
Excel
```

**功能：** 默认EXCEL文档查看器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Image

```cangjie
Image
```

**功能：** 默认图片查看器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Pdf

```cangjie
Pdf
```

**功能：** 默认PDF文档查看器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Ppt

```cangjie
Ppt
```

**功能：** 默认PPT文档查看器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Video

```cangjie
Video
```

**功能：** 默认视频播放器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

### Word

```cangjie
Word
```

**功能：** 默认WORD文档查看器。

**系统能力：** SystemCapability.BundleManager.BundleFramework.DefaultApp

**起始版本：** 22

## enum BundleType

```cangjie
public enum BundleType {
    | App
    | ...
}
```

**功能：** 标识应用的类型。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### App

```cangjie
App
```

**功能：** 该Bundle是应用。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum DisplayOrientation

```cangjie
public enum DisplayOrientation {
    | Unspecified
    | Landscape
    | Portrait
    | FollowRecent
    | LandscapeInverted
    | PortraitInverted
    | AutoRotation
    | AutoRotationLandscape
    | AutoRotationPortrait
    | AutoRotationRestricted
    | AutoRotationLandscapeRestricted
    | AutoRotationPortraitRestricted
    | Locked
    | AutoRotationUnspecified
    | FollowDesktop
    | ...
}
```

**功能：** 标识该Ability的显示模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotation

```cangjie
AutoRotation
```

**功能：** 表示传感器在旋转到横向和竖向时，页面会自动旋转。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotationLandscape

```cangjie
AutoRotationLandscape
```

**功能：** 表示传感器在旋转到横向时，页面会自动旋转。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotationLandscapeRestricted

```cangjie
AutoRotationLandscapeRestricted
```

**功能：** 表述受开关控制的自动横向旋转模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotationPortrait

```cangjie
AutoRotationPortrait
```

**功能：** 表示传感器在旋转到竖向时，页面会自动旋转。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotationPortraitRestricted

```cangjie
AutoRotationPortraitRestricted
```

**功能：** 表示受开关控制的自动竖向旋转模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotationRestricted

```cangjie
AutoRotationRestricted
```

**功能：** 表示受开关控制的自动竖向旋转模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AutoRotationUnspecified

```cangjie
AutoRotationUnspecified
```

**功能：** 受开关控制和由系统判定的自动旋转模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### FollowDesktop

```cangjie
FollowDesktop
```

**功能：** 跟随桌面的旋转模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### FollowRecent

```cangjie
FollowRecent
```

**功能：** 表示跟随上一个显示模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Landscape

```cangjie
Landscape
```

**功能：** 表示横屏显示模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### LandscapeInverted

```cangjie
LandscapeInverted
```

**功能：** 表示反向横屏显示模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Locked

```cangjie
Locked
```

**功能：** 表示锁定模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Portrait

```cangjie
Portrait
```

**功能：** 表示竖屏显示模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### PortraitInverted

```cangjie
PortraitInverted
```

**功能：** 表示反向竖屏显示模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Unspecified

```cangjie
Unspecified
```

**功能：** 表示未定义方向模式，由系统判定。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum ExtensionAbilityType

```cangjie
public enum ExtensionAbilityType {
    | WorkScheduler
    | InputMethod
    | Service
    | Accessibility
    | DataShare
    | FileShare
    | StaticSubscriber
    | Wallpaper
    | Backup
    | Window
    | EnterpriseAdmin
    | Thumbnail
    | Preview
    | Print
    | Share
    | Push
    | Driver
    | Action
    | AdsService
    | EmbeddedUI
    | InsightIntentUI
    | Unspecified
    | ...
}
```

**功能：** 扩展组件的类型。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Accessibility

```cangjie
Accessibility
```

**功能：** 无障碍服务扩展能力，支持访问与操作前台界面。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Action

```cangjie
Action
```

**功能：** 自定义服务扩展能力，为开发者提供基于UIExtension的自定义操作业务模板。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AdsService

```cangjie
AdsService
```

**功能：** 广告服务扩展能力，对外提供后台自定义广告业务服务，仅系统应用支持。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Backup

```cangjie
Backup
```

**功能：** 数据备份扩展能力，提供应用数据的备份恢复能力。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### DataShare

```cangjie
DataShare
```

**功能：** 数据共享扩展能力，用于对外提供数据读写服务。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Driver

```cangjie
Driver
```

**功能：** 提供外设驱动扩展能力。应用配置driver类型的ExtensionAbility后，被视为驱动应用，安装、卸载和恢复驱动应用时，不区分用户。创建新用户时，设备上已有的驱动应用也会安装。例如，创建子用户时，默认安装主用户已有的驱动应用。在子用户上卸载驱动应用时，主用户上对应的驱动应用也会被卸载。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### EmbeddedUI

```cangjie
EmbeddedUI
```

**功能：** 嵌入式UI扩展能力，提供跨进程界面嵌入的能力。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### EnterpriseAdmin

```cangjie
EnterpriseAdmin
```

**功能：** 企业设备管理扩展能力，提供企业管理时处理管理事件的能力，比如设备上应用安装事件、锁屏密码输入错误次数过多事件等。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### FileShare

```cangjie
FileShare
```

**功能：** 文件共享扩展能力，用于应用间的文件分享。预留能力，仅系统应用支持。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### InputMethod

```cangjie
InputMethod
```

**功能：** 输入法扩展能力，用于开发输入法应用。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### InsightIntentUI

```cangjie
InsightIntentUI
```

**功能：** 为开发者提供能被小艺意图调用，以窗口形态呈现内容的扩展能力。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Preview

```cangjie
Preview
```

**功能：** 文件预览扩展，支持系统应用直接嵌入显示。预留能力，仅系统应用支持。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Print

```cangjie
Print
```

**功能：** 文件打印扩展，提供应用打印照片、文档等办公场景能力。仅系统应用支持。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Push

```cangjie
Push
```

**功能：** 推送扩展能力，提供推送场景化消息能力。预留能力，仅系统应用支持。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Service

```cangjie
Service
```

**功能：** 后台服务扩展能力，提供后台运行并对外提供相应能力。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Share

```cangjie
Share
```

**功能：** 提供分享业务能力，为开发者提供基于UIExtension的分享业务模板。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### StaticSubscriber

```cangjie
StaticSubscriber
```

**功能：** 静态广播扩展能力，用于处理静态事件，比如开机事件。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Thumbnail

```cangjie
Thumbnail
```

**功能：** 文件缩略图扩展能力，用于为文件提供图标缩略图的能力。预留能力，仅系统应用支持。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Unspecified

```cangjie
Unspecified
```

**功能：** 不指定类型，配合queryExtensionAbilityInfo接口可以查询所有类型的ExtensionAbility。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Wallpaper

```cangjie
Wallpaper
```

**功能：** 壁纸扩展能力，用于实现桌面壁纸。预留能力，仅系统应用支持

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Window

```cangjie
Window
```

**功能：** 界面组合扩展能力，允许系统应用进行跨应用的界面拉起和嵌入。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### WorkScheduler

```cangjie
WorkScheduler
```

**功能：** 延时任务扩展能力，允许应用在系统闲时执行实时性不高的任务。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum LaunchType

```cangjie
public enum LaunchType {
    | Singleton
    | Multiton
    | Specified
    | ...
}
```

**功能：** 标识组件的启动模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Multiton

```cangjie
Multiton
```

**功能：** UIAbility的启动模式，表示普通多实例。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Singleton

```cangjie
Singleton
```

**功能：** UIAbility的启动模式，表示单实例。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Specified

```cangjie
Specified
```

**功能：** UIAbility的启动模式，表示该UIAbility内部根据业务自己指定多实例。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum ModuleType

```cangjie
public enum ModuleType {
    | Entry
    | Feature
    | Shared
    | ...
}
```

**功能：** 标识模块类型。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Entry

```cangjie
Entry
```

**功能：** 应用的主模块，作为应用的入口，提供了应用的基础功能。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Feature

```cangjie
Feature
```

**功能：** 应用的动态特性模块，作为应用能力的扩展，可以根据用户的需求和设备类型进行选择性安装。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Shared

```cangjie
Shared
```

**功能：** 应用的动态共享库模块。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum MultiAppModeType

```cangjie
public enum MultiAppModeType {
    | Unspecified
    | MultiInstance
    | AppClone
    | ...
}
```

**功能：** 标识应用多开的模式类型。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### AppClone

```cangjie
AppClone
```

**功能：** 分身模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### MultiInstance

```cangjie
MultiInstance
```

**功能：** 多实例模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Unspecified

```cangjie
Unspecified
```

**功能：** 未指定类型，表示multiAppMode配置未配置时的默认状态。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum PermissionGrantState

```cangjie
public enum PermissionGrantState {
    | PermissionDenied
    | PermissionGranted
    | ...
}
```

**功能：** 权限授予状态。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### PermissionDenied

```cangjie
PermissionDenied
```

**功能：** 拒绝授予权限。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### PermissionGranted

```cangjie
PermissionGranted
```

**功能：** 授予权限。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

## enum SupportedWindowMode

```cangjie
public enum SupportedWindowMode {
    | FullScreen
    | Split
    | Floating
    | ...
}
```

**功能：** 支持窗口模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### FullScreen

```cangjie
FullScreen
```

**功能：** 表示支持全屏模式的窗口模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Split

```cangjie
Split
```

**功能：**表示支持分屏模式的窗口模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### Floating

```cangjie
Floating
```

**功能：** 表示支持浮动模式的窗口模式。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22