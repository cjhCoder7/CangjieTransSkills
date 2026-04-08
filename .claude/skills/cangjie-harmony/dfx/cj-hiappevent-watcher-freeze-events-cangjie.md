# 订阅应用冻屏事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 简介

本文介绍如何使用HiAppEvent提供的仓颉接口订阅应用冻屏事件。接口的详细使用说明（参数限制、取值范围等）请参见[应用事件打点API文档](../reference/PerformanceAnalysisKit/cj-apis-hiappevent.md)。

## 接口说明

| 接口名                                              | 描述                                         |
| --------------------------------------------------- | -------------------------------------------- |
| addWatcher(watcher: Watcher): Option\<AppEventPackageHolder> | 添加应用事件观察者，以添加对应用事件的订阅。 |
| removeWatcher(watcher: Watcher): Unit               | 移除应用事件观察者，以移除对应用事件的订阅。 |

## 开发步骤

以实现对用户点击按钮触发应用无响应场景生成的应用冻屏事件订阅为例，说明开发步骤。

1. 新建一个仓颉应用工程，编辑工程中的“entry > src > main > cangjie > main_bility.cj”文件，导入依赖模块：

   <!-- compile -->

   ```cangjie
   import kit.PerformanceAnalysisKit.*
   ```

2. 编辑工程中的“entry > src > main > cangjie > main_bility.cj”文件，在onCreate函数中添加系统事件的订阅，示例代码如下：

   <!-- compile -->

    ```cangjie
    let eventfilter = AppEventFilter("OS", names: ["APP_FREEZE"])
    let watcher = Watcher(
        // 开发者可以自定义观察者名称，系统会使用名称来标识不同的观察者
        "watcher2",
        // 开发者可以订阅感兴趣的系统事件，此处是订阅了应用冻屏事件
          appEventFilters: [eventfilter],
        // 开发者可以自行实现订阅实时回调函数，以便对订阅获取到的事件数据进行自定义处理
        onReceive: {
            domain: String, appEventGroups: Array<AppEventGroup> =>
                Hilog.info(0x0000, 'testTag', "HiAppEvent onReceive: domain=${domain}")
            for (eventGroup in appEventGroups) {
                // 开发者可以根据事件集合中的事件名称区分不同的系统事件
                Hilog.info(0x0000, 'testTag', "HiAppEvent eventName=${eventGroup.name}")
                for (eventInfo in eventGroup.appEventInfos) {
                    // 开发者可以对事件集合中的事件数据进行自定义处理，此处是将事件数据打印在日志中
                    Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.domain=${eventInfo.domain}")
                    Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.name=${eventInfo.name}")
                    for ((k, v) in eventInfo.params) {
                        // 开发者可以获取到应用冻屏事件发生的相关信息
                        if (k == "hilog") {
                            Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.params.${k}=${v}")
                        } else {
                            Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.params.${k}=${v}")
                        }
                    }
                }
            }
        }
        )
    HiAppEvent.addWatcher(watcher)
    ```

3. 可新建一个仓颉应用工程，编辑工程中的“entry > src > main > cangjie > index.cj”文件，在onClick函数构造应用无响应场景，以触发应用冻屏事件，示例代码如下：

    ```cangjie
    // 在按钮点击函数中构造一个freeze场景，触发应用冻屏事件
    while(true) {}
    ```

4. 点击DevEco Studio界面中的运行按钮，运行应用工程，然后在应用界面中点击按钮“appFreeze”，触发一次应用冻屏事件。

5. 应用无响应退出后，重新进入应用可以在Log窗口看到对系统事件数据的处理日志

   ```text
   HiAppEvent onReceive: domain=OS
   HiAppEvent eventName=APP_FREEZE
   HiAppEvent eventInfo.domain=OS
   HiAppEvent eventInfo.name=APP_FREEZE
   HiAppEvent eventInfo.eventType=1
   HiAppEvent eventInfo.params.time=1711440881768
   HiAppEvent eventInfo.params.foreground=true
   HiAppEvent eventInfo.params.bundle_version=1.0.0
   HiAppEvent eventInfo.params.bundle_name=com.example.myapplication
   HiAppEvent eventInfo.params.process_name=com.example.myapplication
   HiAppEvent eventInfo.params.pid=3197
   HiAppEvent eventInfo.params.uid=20010043
   HiAppEvent eventInfo.params.uuid=27fac7098da46efe1cae9904946ec06c5acc91689c365efeefb7a23a0c37df77
   HiAppEvent eventInfo.params.exception={"message":"App main thread is not response!","name":"THREAD_BLOCK_6S"}
   HiAppEvent eventInfo.params.hilog.size=77
   HiAppEvent eventInfo.params.event_handler.size=6
   HiAppEvent eventInfo.params.event_handler_size_3s=5
   HiAppEvent eventInfo.params.event_handler_size_6s=6
   HiAppEvent eventInfo.params.peer_binder.size=0
   HiAppEvent eventInfo.params.threads.size=28
   HiAppEvent eventInfo.params.memory={"pss":0,"rss":0,"sys_avail_mem":1361464,"sys_free_mem":796232,"sys_total_mem":1992340,"vss":0}
   HiAppEvent eventInfo.params.external_log=["/data/storage/el2/log/hiappevent/APP_FREEZE_1711440899240_3197.log"]
   HiAppEvent eventInfo.params.log_over_limit=false
   HiAppEvent eventInfo.params.test_data=100
   ```
