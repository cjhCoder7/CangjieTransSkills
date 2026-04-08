# ohos.app.ability.context_constant

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

context_constant模块提供Context相关的枚举，包含文件加密分区等级、UIAbility启动后的进程模式等。

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

## enum AreaMode

```cangjie
public enum AreaMode <: Equatable<AreaMode> & ToString {
    | El1
    | El2
    | El3
    | El4
    | El5
    | ...
}
```

**功能：** 文件加密分区等级，保证应用在不同场景下的数据安全。开发者可以根据应用的具体需求选择合适的加密等级，以保护用户的数据安全。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**父类型：**

- [Equatable\<AreaMode>](#enum-areamode)
- ToString

### El1

```cangjie
El1
```

**功能：** 设备级加密区，设备开机后可访问的数据区。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### El2

```cangjie
El2
```

**功能：** 用户级加密区，设备开机，首次输入密码后才能够访问的数据区。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### El3

```cangjie
El3
```

**功能：** 用户级加密区，不同场景的文件权限如下：

已打开文件：锁屏时，可读写；解锁后，可读写。

未打开文件：锁屏时，不可打开、不可读写；解锁后，可打开、可读写。

创建新文件：锁屏时，可创建、可打开、可写不可读；解锁后，可创建、可打开、可读写。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### El4

```cangjie
El4
```

**功能：** 用户级加密区，不同场景的文件权限如下：

已打开文件：锁屏时，不可读写；解锁后，可读写。

未打开文件：锁屏时，不可打开、不可读写；解锁后，可打开、可读写。

创建新文件：锁屏时，不可创建；解锁后，可创建、可打开、可读写。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### El5

```cangjie
El5
```

**功能：** 应用级加密区，不同场景的文件权限如下：

已打开文件：锁屏时，可读写；解锁后，可读写。

创建新文件：锁屏时，可创建、可打开、可读写；解锁后，可创建、可打开、可读写。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### func !=(AreaMode)

```cangjie
public operator func !=(other: AreaMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AreaMode](#enum-areamode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(AreaMode)

```cangjie
public operator func ==(other: AreaMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AreaMode](#enum-areamode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取当前枚举的字符串表示。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|当前枚举的字符串表示。|
