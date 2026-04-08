# 取消动态订阅公共事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

动态订阅者完成业务需求后，应主动取消订阅。通过调用[unsubscribe()](../../reference/BasicServicesKit/cj-apis-common_event_manager.md#static-func-unsubscribecommoneventsubscriber)方法，取消订阅事件。

## 接口说明

| 接口名 | 接口描述 |
| -------- | -------- |
| unsubscribe(subscriber:&nbsp;[CommonEventSubscriber](../../reference/BasicServicesKit/cj-apis-common_event_subscriber.md#class-commoneventsubscriber)): Unit | 取消订阅公共事件。 |

## 开发步骤

1. 导入模块。

   <!-- compile -->

   ```cangjie
   import kit.BasicServicesKit.*
   ```

2. 根据[动态订阅公共事件](./cj-common-event-subscription.md)章节的步骤来订阅某个事件。

3. 调用CommonEvent中的[unsubscribe()](../../reference/BasicServicesKit/cj-apis-common_event_manager.md#static-func-unsubscribecommoneventsubscriber)方法取消订阅某事件。

   <!-- compile -->

   ```cangjie
   // subscriber为订阅事件时创建的订阅者对象
   CommonEventManager.unsubscribe(subscriber)
   ```
