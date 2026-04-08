# 动态订阅公共事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

动态订阅是指当应用在运行状态时，对某个公共事件进行订阅。在运行期间，如果有订阅的事件发布，那么订阅了这个事件的应用将会收到该事件及其传递的参数。

例如，某应用希望在其运行期间收到电量过低的事件，并根据该事件降低其运行功耗，那么该应用便可动态订阅电量过低事件，收到该事件后关闭一些非必要的任务来降低功耗。

订阅部分系统公共事件需要先[申请权限](../../security/AccessToken/cj-determine-application-mode.md)。

> **说明：**
>
> 订阅者对象的生命周期需要接入方管理，不再使用时需主动销毁释放，避免内存泄漏。

## 接口说明

详细接口见[接口文档](../../reference/BasicServicesKit/cj-apis-common_event_manager.md)。

| 接口名 | 接口描述 |
| -------- | -------- |
| createSubscriber(subscribeInfo:&nbsp;[CommonEventSubscribeInfo](../../reference/BasicServicesKit/cj-apis-common_event_subscribe_info.md#class-commoneventsubscribeinfo)): [CommonEventSubscriber](../../reference/BasicServicesKit/cj-apis-common_event_subscriber.md#class-commoneventsubscriber)| 创建订阅者对象。 |
| subscribe(subscriber:&nbsp;[CommonEventSubscriber](../../reference/BasicServicesKit/cj-apis-common_event_subscriber.md#class-commoneventsubscriber),&nbsp;callback: ([CommonEventData](../../reference/BasicServicesKit/cj-apis-common_event_data.md#class-commoneventdata)) -> Unit): Unit | 订阅公共事件。 |

## 开发步骤

1. 导入模块。

   <!-- compile -->

   ```cangjie
   import kit.BasicServicesKit.*
   import kit.PerformanceAnalysisKit.Hilog
   import ohos.business_exception.*
   ```

2. 创建订阅者信息，详细的订阅者信息数据类型及包含的参数请见[CommonEventSubscribeInfo](../../reference/BasicServicesKit/cj-apis-common_event_subscribe_info.md#class-commoneventsubscribeinfo)文档介绍。

   <!-- compile -->

   ```cangjie
   // 用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
   let subscriber: CommonEventSubscriber
   // 订阅者信息，其中的event字段需要替换为实际的事件名称
   let support1 = Support.COMMON_EVENT_SCREEN_ON
   let events = [support1]
   let subscribeInfo = CommonEventSubscribeInfo(events)
   ```

3. 创建订阅者，保存返回的订阅者对象subscriber，用于执行后续的订阅、退订、接收事件回调等操作。

   <!-- compile -->

   ```cangjie
   // 创建订阅者回调
   subscriber = CommonEventManager.createSubscriber(subscribeInfo)
   ```

4. 创建订阅回调函数，订阅回调函数会在接收到事件时触发。订阅回调函数返回的data内包含了公共事件的名称、发布者携带的数据等信息，公共事件数据的详细参数和数据类型请见[CommonEventData](../../reference/BasicServicesKit/cj-apis-common_event_data.md#class-commoneventdata)文档介绍。

   <!-- compile -->

   ```cangjie
   // 订阅公共事件回调
   let callback = {
      a: ?BusinessException, b: ?CommonEventData =>
         Hilog.info(0, "TestCEM", "=======================================")
         Hilog.info(0, "TestCEM", "callback excute success!")
   }
   CommonEventManager.subscribe(subscriber, callback)
   ```
