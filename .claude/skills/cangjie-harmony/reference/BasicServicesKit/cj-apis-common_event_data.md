# ohos.common_event_data

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

common_event_data模块描述公共事件的数据。

## 导入模块

```cangjie
import kit.BasicServicesKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class CommonEventData

```cangjie
public class CommonEventData {
    public var event: String
    public var bundleName: String
    public var code: Int32
    public var data: String
    public var parameters: HashMap<String, CommonEventValueType>
}
```

**功能：** 公共事件的数据。

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var bundleName

```cangjie
public var bundleName: String
```

**功能：** 表示包名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var code

```cangjie
public var code: Int32
```

**功能：** 表示订阅者接收到的公共事件数据（Int32类型）。该字段取值与发布者使用[commonEventManager.publish](./cj-apis-common_event_manager.md#static-func-publishstring-commoneventpublishdata)发布公共事件时，通过[CommonEventPublishData](./cj-apis-common_event_publish_data.md#class-commoneventpublishdata)中的`code`字段传递的数据一致。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var data

```cangjie
public var data: String
```

**功能：** 表示订阅者接收到的公共事件数据（String类型）。该字段取值与发布者使用[commonEventManager.publish](./cj-apis-common_event_manager.md#static-func-publishstring-commoneventpublishdata)发布公共事件时，通过[CommonEventPublishData](./cj-apis-common_event_publish_data.md#class-commoneventpublishdata)中的`data`字段传递的数据一致。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var event

```cangjie
public var event: String
```

**功能：** 表示当前接收的公共事件名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22

### var parameters

```cangjie
public var parameters: HashMap<String, CommonEventValueType>
```

**功能：** 表示订阅者接收到的公共事件的附加信息。该字段取值与发布者使用[commonEventManager.publish](./cj-apis-common_event_manager.md#static-func-publishstring-commoneventpublishdata)发布公共事件时，通过[CommonEventPublishData](./cj-apis-common_event_publish_data.md#class-commoneventpublishdata)中的`parameters`字段传递的数据一致。

**类型：** HashMap\<String, CommonEventValueType>

**读写能力：** 可读写

**系统能力：** SystemCapability.Notification.CommonEvent

**起始版本：** 22
