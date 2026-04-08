# 事件上报

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HiAppEvent提供用于处理并上报事件的接口。

## 接口说明

API接口的具体使用说明（参数使用限制、具体取值范围等）请参见[应用事件打点API文档](../reference/PerformanceAnalysisKit/cj-apis-hiappevent.md)。

**数据处理者接口功能介绍：**

| 接口名 | 描述 |
| --------------- | ---------------- |
| addProcessor(processor: Processor): Int64 | 添加数据处理者，通过预置处理者进行事件上报。     |
| removeProcessor(id: Int64): Unit          | 移除数据处理者，取消预置处理者。                 |

**用户ID接口功能介绍：**

| 接口名 | 描述  |
| ---------- | --------------- |
| setUserId(name: String, value: String): Unit | 设置用户ID，数据处理者上报事件时可携带用户ID。 |
| getUserId(name: String): String              | 获取已设置的用户ID。 |

**用户属性接口功能介绍：**

| 接口名 | 描述  |
| ------------ | ----------------- |
| setUserProperty(name: String, value: String): Unit | 设置用户属性，数据处理者上报事件时可携带用户属性。   |
| getUserProperty(name: String): String              | 获取已设置的用户属性。 |

## 开发步骤

以实现对用户点击按钮行为的事件打点并由处理者进行事件上报为例，说明开发步骤。

1. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，添加一个按钮并在其onClick函数中添加数据处理者。analytics_demo为预置在设备里面的数据处理者lib库。完整示例代码如下：

    <!-- compile -->

    ```cangjie
    import kit.PerformanceAnalysisKit.*
    import kit.ArkUI.Button
    import std.collection.HashMap

    func loggerInfo(str: String) {
        Hilog.info(0, "CangjieTest", str)
    }

    func loggerError(str: String) {
        Hilog.error(0, "CangjieTest", str)
    }

    @Entry
    @Component
    class EntryView {
        @State
        var message: String = "Hello World"

        var processorId = -1

        func build() {
            Row {
                Column {
                    Button(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt => this.message = "Hello Cangjie"
                        // 在按钮点击函数中进行数据处理者添加
                        let eventConfig = AppEventReportConfig(
                            // 事件领域定义
                            domain: "button",
                            // 事件名称定义
                            name: "click",
                            // 是否实时上报事件
                            isRealTime: true
                        )
                        let processor = Processor(
                            'analytics_demo',
                            debugMode: true,
                            routeInfo: 'CN',
                            appId: '111',
                            onStartReport: true,
                            onBackgroundReport: true,
                            periodReport: 10,
                            batchReport: 5,
                            userIds: ['testUserIdName'],
                            userProperties: ['testUserPropertyName'],
                            eventConfigs: [eventConfig]
                        )
                        this.processorId = HiAppEvent.addProcessor(processor)
                    })
                }.height(100.percent)
            }.width(100.percent)
        }
    }
    ```

2. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，添加一个按钮并在其onClick函数中添加并查看用户ID，完整示例代码如下：

    <!-- compile -->

    ```cangjie
    Button("userIdTest").onClick ({
        evt =>
        // 在按钮点击函数中设置用户ID
        HiAppEvent.setUserId('testUserIdName', '123456')

        // 在按钮点击函数中获取刚设置的用户ID
        let userId = HiAppEvent.getUserId('testUserIdName')
        Hilog.info(0x0000, 'testTag', 'userId: ${userId}')
    })
    ```

3. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，添加一个按钮并在其onClick函数中添加并查看用户属性，完整示例代码如下：

    <!-- compile -->

    ```cangjie
    Button("userPropertyTest").onClick ({
        evt =>
        // 在按钮点击函数中设置用户属性值
        HiAppEvent.setUserProperty('testUserPropertyName', '123456')

        // 在按钮点击函数中获取刚设置的用户属性值
        let userProperty = HiAppEvent.getUserProperty('testUserPropertyName')
        Hilog.info(0x0000, 'testTag', 'userProperty: ${userProperty}')
    })
    ```

4. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，添加一个按钮并在其onClick函数中进行事件打点，以记录按钮点击事件，完整示例代码如下：

    <!-- compile -->

    ```cangjie
    Button("writeTest").onClick ({
        evt =>
        let eventParams = HashMap<String, EventValueType>([
            ("click_time", IntValue(100))
        ])
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

5. 编辑工程中的“entry > src > main > cangjie > index.cj” 文件，添加一个按钮并在其onClick函数中进行数据处理者移除(第二步已完成数据处理者添加)，完整示例代码如下：

    <!-- compile -->

    ```cangjie
    Button("removeProcessorTest").onClick ({
        evt =>
        // 在按钮点击函数中进行数据处理者移除
        HiAppEvent.removeProcessor(this.processorId)
    })
    ```

6. 点击IDE界面中的运行按钮，运行应用工程，然后在应用界面中依次点击按钮“addProcessorTest”、“userIdTest”、“userPropertyTest”、“writeTest”、“removeProcessorTest”，则成功通过数据处理者进行一次事件上报。

   最终，事件处理者成功接收到事件数据，并在Log窗口看到按钮点击事件打点成功的日志：

   ```text
   HiAppEvent success to write event
   ```
