# ohos.common_event_subscribe_info

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 导入模块

```cangjie
import kit.BasicServicesKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class CommonEventSubscribeInfo

```cangjie
public class CommonEventSubscribeInfo {
    public var events: Array<String>
    public var priority: Int32
    public var userId: Int32
    public var publisherPermission: String
    public var publisherDeviceId: String
    public var publisherBundleName: String
    public init(
        events: Array<String>,
        publisherPermission!: String = "",
        publisherDeviceId!: String = "",
        userId!: Int32 = UNDEFINED_USER,
        priority!: Int32 = 0,
        publisherBundleName!: String = ""
    )
}
```

**功能：** 用于表示订阅者的信息。

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var events

```cangjie
public var events: Array<String>
```

**功能：** 表示要订阅的公共事件。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var priority

```cangjie
public var priority: Int32
```

**功能：** 表示订阅者的优先级。值的范围是-100到1000，超过上下限的优先级将被设置为上下限值。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var publisherBundleName

```cangjie
public var publisherBundleName: String
```

**功能：** 表示要订阅的发布者的bundleName。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var publisherDeviceId

```cangjie
public var publisherDeviceId: String
```

**功能：** 表示设备ID。通过[@ohos.deviceInfo](./cj-apis-device_info.md)获取udid，作为订阅者的设备ID。预留能力，暂不支持。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var publisherPermission

```cangjie
public var publisherPermission: String
```

**功能：** 表示发布者的权限，订阅方将只能接收到具有该权限的发送方发布的事件。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var userId

```cangjie
public var userId: Int32
```

**功能：** 表示用户ID。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### init(Array\<String>, String, String, Int32, Int32, String)

```cangjie
public init(
    events: Array<String>,
    publisherPermission!: String = "",
    publisherDeviceId!: String = "",
    userId!: Int32 = UNDEFINED_USER,
    priority!: Int32 = 0,
    publisherBundleName!: String = ""
)
```

**功能：** 构造CommonEventSubscribeInfo对象。

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|events|Array\<String>|是|-|表示要订阅的公共事件。|
|publisherPermission|String|否|""| **命名参数。** 表示发布者的权限，订阅方将只能接收到具有该权限的发送方发布的事件。|
|publisherDeviceId|String|否|""| **命名参数。** 表示设备ID。通过[@ohos.deviceInfo](./cj-apis-device_info.md)获取udid，作为订阅者的设备ID。预留能力，暂不支持。|
|userId|Int32|否|UNDEFINED_USER| **命名参数。** 表示用户ID。此参数是可选的，默认值当前用户的ID。如果指定了此参数，则该值必须是系统中现有的用户ID。|
|priority|Int32|否|0| **命名参数。** 表示订阅者的优先级。值的范围是-100到1000，超过上下限的优先级将被设置为上下限值。|
|publisherBundleName|String|否|""| **命名参数。** 表示要订阅的发布者的bundleName。|
