# ohos.metadata

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

metadata模块描述元数据信息。

> **说明：**
>
> 描述的module、UIAbility、ExtensionAbility配置信息，标签值为数组类型，该标签下的配置只对当前module、UIAbility或ExtensionAbility生效。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](./cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Metadata

```cangjie
public class Metadata {
    public var name: String
    public var value: String
    public var resource: String
}
```

**功能：** 元数据信息。通过调用[getBundleInfoForSelf](./cj-apis-bundle_manager.md#static-func-getbundleinfoforselfint32)接口获取，bundleFlags参数传入GET_BUNDLE_INFO_WITH_HAP_MODULE、GET_BUNDLE_INFO_WITH_ABILITY和GET_BUNDLE_INFO_WITH_METADATA的值。

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 元数据名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var resource

```cangjie
public var resource: String
```

**功能：** 元数据资源描述符，参考示例$profile:config_file，表示profile目录下配置了config_file.json文件。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22

### var value

```cangjie
public var value: String
```

**功能：** 元数据值。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.BundleManager.BundleFramework.Core

**起始版本：** 22
