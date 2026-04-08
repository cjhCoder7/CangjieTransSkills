# ohos.app.ability.want_constant（Want常量）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

want_constant模块提供了Want操作相关的系统预设枚举和常量，例如在启动Ability时常用的Flag、Param参数等。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 权限列表

ohos.permission.DISTRIBUTED_DATASYNC

ohos.permission.PREPARE_APP_TERMINATE

ohos.permission.PRIVACY_WINDOW

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](./cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Flags

```cangjie
public class Flags {
    public static const FLAG_AUTH_READ_URI_PERMISSION: UInt32 = 0x00000001
    public static const FLAG_AUTH_WRITE_URI_PERMISSION: UInt32 = 0x00000002
    public static const FLAG_AUTH_PERSISTABLE_URI_PERMISSION: UInt32 = 0x00000040
    public static const FLAG_INSTALL_ON_DEMAND: UInt32 = 0x00000800
    public static const FLAG_START_WITHOUT_TIPS: UInt32 = 0x40000000
}
```

**功能：** [Want.flags](./cj-apis-app-ability-want.md#class-want)字段常用的系统预置关键字。开发者可以通过这些预置关键字设置或获取应用跳转等场景中额外携带的标志位信息。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const FLAG_AUTH_PERSISTABLE_URI_PERMISSION

```cangjie
public static const FLAG_AUTH_PERSISTABLE_URI_PERMISSION: UInt32 = 0x00000040
```

**功能：** 表示该URI可被接收方持久化。该字段仅在Tablet设备上生效。

**类型：** UInt32

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const FLAG_AUTH_READ_URI_PERMISSION

```cangjie
public static const FLAG_AUTH_READ_URI_PERMISSION: UInt32 = 0x00000001
```

**功能：** 表示临时授予接收方读取该URI指向的数据的权限。

**类型：** UInt32

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const FLAG_AUTH_WRITE_URI_PERMISSION

```cangjie
public static const FLAG_AUTH_WRITE_URI_PERMISSION: UInt32 = 0x00000002
```

**功能：** 表示临时授予接收方写入该URI指向的数据的权限。

**类型：** UInt32

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const FLAG_INSTALL_ON_DEMAND

```cangjie
public static const FLAG_INSTALL_ON_DEMAND: UInt32 = 0x00000800
```

**功能：** 表示拉起原子化服务时开启免安装功能。

- 如果开启了免安装功能，当系统检测到被拉起的原子化服务未安装时，会自动安装原子化服务，再进行拉起。

- 如果未开启免安装功能，当原子化服务未安装时，将拉起失败。

**类型：** UInt32

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const FLAG_START_WITHOUT_TIPS

```cangjie
public static const FLAG_START_WITHOUT_TIPS: UInt32 = 0x40000000
```

**功能：** 表示是否关闭匹配失败弹窗功能。

通过隐式方式拉起应用时，如果没有能够匹配的应用，默认会弹出提示弹窗“暂无可用打开方式”。开发者可以通过该字段屏蔽该弹窗。

**类型：** UInt32

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

## class Params

```cangjie
public class Params {
    public static const ABILITY_BACK_TO_OTHER_MISSION_STACK: String = "ability.params.backToOtherMissionStack"
    public static const ABILITY_RECOVERY_RESTART: String = "ohos.ability.params.abilityRecoveryRestart"
    public static const CONTENT_TITLE_KEY: String = "ohos.extra.param.key.contentTitle"
    public static const SHARE_ABSTRACT_KEY: String = "ohos.extra.param.key.shareAbstract"
    public static const SHARE_URL_KEY: String = "ohos.extra.param.key.shareUrl"
    public static const SUPPORT_CONTINUE_PAGE_STACK_KEY: String = "ohos.extra.param.key.supportContinuePageStack"
    public static const SUPPORT_CONTINUE_SOURCE_EXIT_KEY: String = "ohos.extra.param.key.supportContinueSourceExit"
}
```

**功能：** [Want.parameters](./cj-apis-app-ability-want.md#class-want)字段常用的系统预置关键字。开发者可以通过这些预置关键字设置或获取应用跳转等场景中额外携带的参数信息。例如在[UIAbility](./cj-apis-app-ability-ui_ability.md)的启动阶段，如果从onCreate回调的入参want字段中获取到ABILITY_RECOVERY_RESTART的值为true，则表示当前UIAbility发生了故障重启。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const ABILITY_BACK_TO_OTHER_MISSION_STACK

```cangjie
public static const ABILITY_BACK_TO_OTHER_MISSION_STACK: String = "ability.params.backToOtherMissionStack"
```

**功能：** 表示是否支持跨任务链返回。

该参数用于控制跨任务链返回逻辑，其核心作用是改变用户执行返回键时的应用跳转行为。例如，现有UIAbility A和UIAbility B，前台显示的是UIAbility A，随后系统服务拉起UIAbility B（同时在Want的Params字段配置该参数为true）。如果配置了该参数，当UIAbility B退出时，会返回到UIAbility A（即返回到最近一次的访问任务）；如果未配置该参数，则默认直接返回桌面。

需要注意的是，该字段仅支持系统设置，三方应用传入该字段不生效。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const ABILITY_RECOVERY_RESTART

```cangjie
public static const ABILITY_RECOVERY_RESTART: String = "ohos.ability.params.abilityRecoveryRestart"
```

**功能：** 表示当前Ability是否发生了故障恢复重启。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const CONTENT_TITLE_KEY

```cangjie
public static const CONTENT_TITLE_KEY: String = "ohos.extra.param.key.contentTitle"
```

**功能：** 表示原子化服务分享的标题。

在跨端分享的onShare回调中，开发者可通过该字段设置分享的标题。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const SHARE_ABSTRACT_KEY

```cangjie
public static const SHARE_ABSTRACT_KEY: String = "ohos.extra.param.key.shareAbstract"
```

**功能：** 表示原子化服务分享的内容摘要。

在跨端分享的onShare回调中，开发者可通过该字段设置分享的摘要。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const SHARE_URL_KEY

```cangjie
public static const SHARE_URL_KEY: String = "ohos.extra.param.key.shareUrl"
```

**功能：** 表示原子化服务分享的URL链接。

在跨端分享的onShare回调中，开发者可通过该字段设置分享的URL链接。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const SUPPORT_CONTINUE_PAGE_STACK_KEY

```cangjie
public static const SUPPORT_CONTINUE_PAGE_STACK_KEY: String = "ohos.extra.param.key.supportContinuePageStack"
```

**功能：** 表示在跨端迁移过程中是否迁移页面栈信息。默认值为true，表示在跨端迁移过程中自动迁移页面栈信息。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### static const SUPPORT_CONTINUE_SOURCE_EXIT_KEY

```cangjie
public static const SUPPORT_CONTINUE_SOURCE_EXIT_KEY: String = "ohos.extra.param.key.supportContinueSourceExit"
```

**功能：** 表示跨端迁移源端应用是否退出。默认值为true，表示在跨端迁移过程中源端应用自动退出。

**类型：** String

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22
