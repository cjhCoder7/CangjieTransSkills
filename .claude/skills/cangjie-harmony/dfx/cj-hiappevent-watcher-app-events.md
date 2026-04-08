# 订阅应用事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HiAppEvent提供了事件订阅接口，用于本地获取应用事件。

## 接口说明

API接口的具体使用说明（参数使用限制、具体取值范围等）请参见[应用事件打点API文档](../reference/PerformanceAnalysisKit/cj-apis-hiappevent.md)。

**打点接口功能介绍：**

| 接口名                          | 描述               |
| ------------------------------- | ------------------ |
| write(info: AppEventInfo): Unit | 应用事件打点方法。 |

**订阅接口功能介绍：**

| 接口名                                                       | 描述                                         |
| ------------------------------------------------------------ | -------------------------------------------- |
| addWatcher(watcher: Watcher): Option\<AppEventPackageHolder> | 添加应用事件观察者，以添加对应用事件的订阅。 |
| removeWatcher(watcher: Watcher): Unit                        | 移除应用事件观察者，以移除对应用事件的订阅。 |

## 开发步骤

以实现对用户点击按钮行为的事件打点及订阅为例，说明开发步骤。

1. 新建一个Cangjie应用工程，编辑工程中的“entry > src > main > cangjie > main_ability.cj”文件，导入依赖模块：

    <!-- compile -->

    ```cangjie
    import kit.PerformanceAnalysisKit.*
    ```

2. 编辑工程中的“entry > src > main > cangjie > main_ability.cj” 文件，在onCreate函数中添加对用户点击按钮事件的订阅，示例代码如下：

    <!-- compile -->

    ```cangjie
    var condition = TriggerCondition(row: 1, size: 120, timeOut: 0)
    var appEventFilter = [AppEventFilter("cangjie_watcher")]
    var watcher = Watcher(
        "watcher1",
        triggerCondition: condition,
        appEventFilters: appEventFilter,
        onTrigger: Some(
            {
                row, size, holder =>
                Hilog.info(0, "test_hiAppEvent_addWatcher_01",
                    "HiAppEvent onTrigger: curRow=${row},curSize=${size}")
                while (let Some(v) <- holder.takeNext()) {
                    let eventPkg = v
                    Hilog.info(0, "test_hiAppEvent_addWatcher_01", "HiAppEvent packageId=${eventPkg.packageId}")
                    Hilog.info(0, "test_hiAppEvent_addWatcher_01", "HiAppEvent row=${eventPkg.row}")
                    Hilog.info(0, "test_hiAppEvent_addWatcher_01", "HiAppEvent size=${eventPkg.size}")
                    for (i in 0..eventPkg.data.size) {
                        Hilog.info(0, "test_hiAppEvent_addWatcher_01", "HiAppEvent info=${eventPkg.data[i]}")
                    }
                }
            }
        )
    )
    ```

3. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，导入依赖模块：

    <!-- compile -->

    ```cangjie
    import kit.PerformanceAnalysisKit.*
    import kit.ArkUI.Button
    import std.collection.HashMap
    ```

4. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，添加一个按钮并在其onClick函数中进行事件打点，以记录按钮点击事件，示例代码如下：

    <!-- compile -->

    ```cangjie
    Button("writeTest").onClick({ evt =>
        // 在按钮点击函数中进行事件打点，以记录按钮点击事件
        let eventParams = HashMap<String, EventValueType>([("click_time", IntValue(100))])
        let eventInfo: AppEventInfo = AppEventInfo(
            // 事件领域定义
            "button",
            // 事件名称定义
            "click",
            // 事件类型定义
            EventType.Behavior,
            // 事件参数定义
            eventParams)

        HiAppEvent.write(eventInfo)
    })
    ```

5. 点击DevEco Studio界面中的运行按钮，运行应用工程，然后在应用界面中点击按钮“writeTest”，触发一次按钮点击事件打点。

6. 可以在Log窗口看到按钮点击事件打点成功的日志，以及触发订阅回调后对打点事件数据的处理日志：

   ```text
   HiAppEvent success to write event
   HiAppEvent eventPkg.packageId=0
   HiAppEvent eventPkg.row=1
   HiAppEvent eventPkg.size=124
   HiAppEvent eventPkg.info={"domain_":"button","name_":"click","type_":4,"time_":1670268234523,"tz_":"+0800","pid_":3295,"tid_":3309,"click_time":100}
   ```
