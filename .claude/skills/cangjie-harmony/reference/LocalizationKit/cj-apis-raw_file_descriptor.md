# ohos.raw_file_descriptor

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

raw_file_descriptor模块表示rawfile的描述符信息。

## 导入模块

```cangjie
import kit.LocalizationKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class RawFileDescriptor

```cangjie
public class RawFileDescriptor {
    public var fd: Int32
    public var offset: Int64
    public var length: Int64
}
```

**功能：** 表示rawfile文件所在HAP的文件描述符（fd）。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var fd

```cangjie
public var fd: Int32
```

**功能：** 文件描述符。

**类型：** Int32

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var length

```cangjie
public var length: Int64
```

**功能：** 文件长度。

**类型：** Int64

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var offset

```cangjie
public var offset: Int64
```

**功能：** 起始偏移量。

**类型：** Int64

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22
