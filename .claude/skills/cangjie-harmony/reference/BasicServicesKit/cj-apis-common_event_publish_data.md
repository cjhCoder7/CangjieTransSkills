# ohos.common_event_publish_data

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

common_event_publish_data模块描述公共事件内容和属性。

## 导入模块

```cangjie
import kit.BasicServicesKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class CommonEventPublishData

```cangjie
public class CommonEventPublishData {
    public var bundleName: String
    public var data: String
    public var code: Int32
    public var subscriberPermissions: Array<String>
    public var isOrdered: Bool
    public var isSticky: Bool
    public var parameters: HashMap<String, CommonEventValueType>
    public init(
        bundleName!: String = "",
        data!: String = "",
        code!: Int32 = 0,
        subscriberPermissions!: Array<String> = Array<String>(),
        isOrdered!: Bool = false,
        isSticky!: Bool = false,
        parameters!: HashMap<String, CommonEventValueType> = HashMap<String, CommonEventValueType>()
    )
}
```

**功能：** 包含公共事件内容和属性。

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var bundleName

```cangjie
public var bundleName: String
```

**功能：** 表示订阅者包名称，只有包名为bundleName的订阅者才能收到该公共事件。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var code

```cangjie
public var code: Int32
```

**功能：** 表示发布方传递的公共事件数据（Int32类型）。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var data

```cangjie
public var data: String
```

**功能：** 表示发布方传递的公共事件数据（string类型）。数据大小不超过64KB。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var isOrdered

```cangjie
public var isOrdered: Bool
```

**功能：** 表示是否是有序事件。

- true：有序公共事件，根据订阅者设置的优先级等级，优先将公共事件发送给优先级较高的订阅者，等待其成功接收该公共事件之后再将事件发送给优先级较低的订阅者。如果有多个订阅者具有相同的优先级，则他们将随机接收到公共事件。

- false：无序公共事件，不考虑订阅者是否接收到该事件，也不保证订阅者接收到该事件的顺序与其订阅顺序一致。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var isSticky

```cangjie
public var isSticky: Bool
```

**功能：** 表示是否是粘性事件。

- true：粘性公共事件，能够让订阅者收到在订阅前已经发送的公共事件。

- false：普通公共事件，只能让订阅者收到在订阅后才发送的公共事件。

仅系统应用或系统服务允许发送粘性事件。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var parameters

```cangjie
public var parameters: HashMap<String, CommonEventValueType>
```

**功能：** 表示发布方传递的公共事件的附加信息。

**类型：** HashMap\<String, CommonEventValueType>

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var subscriberPermissions

```cangjie
public var subscriberPermissions: Array<String>
```

**功能：** 表示订阅者的权限。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### init(String, String, Int32, Array\<String>, Bool, Bool, HashMap\<String,CommonEventValueType>)

```cangjie
public init(
    bundleName!: String = "",
    data!: String = "",
    code!: Int32 = 0,
    subscriberPermissions!: Array<String> = Array<String>(),
    isOrdered!: Bool = false,
    isSticky!: Bool = false,
    parameters!: HashMap<String, CommonEventValueType> = HashMap<String, CommonEventValueType>()
)
```

**功能：** 构造CommonEventPublishData对象。

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|bundleName|String|否|""| **命名参数。** 表示订阅者包名称，只有包名为bundleName的订阅者才能收到该公共事件。|
|data|String|否|""| **命名参数。** 表示发布方传递的公共事件数据（String类型）。数据大小不超过64KB。|
|code|Int32|否|0| **命名参数。** 表示发布方传递的公共事件数据（Int32类型）。默认值为0。|
|subscriberPermissions|Array\<String>|否|Array\<String>()| **命名参数。** 表示订阅者的权限。|
|isOrdered|Bool|否|false| **命名参数。** 表示是否是有序事件。默认为false。|
|isSticky|Bool|否|false| **命名参数。** 表示是否是粘性事件。默认为false。|
|parameters|HashMap\<String, CommonEventValueType>|否|HashMap<String, CommonEventValueType>()| **命名参数。** 表示发布方传递的公共事件的附加信息。|
