# 使用Display实现屏幕属性查询及状态监听

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

[Display](../reference/arkui-cj/cj-apis-display.md)屏幕属性提供管理设备屏幕的一些基础能力，例如获取默认显示设备的相关信息、获取全部显示设备的信息，此外还能对显示设备的插拔行为进行监听。应用可以根据对应的屏幕信息、屏幕状态变化、屏幕折叠状态等适配不同的UI界面显示。

屏幕属性的常见使用场景有以下几种：

- 查询屏幕信息：包括屏幕的分辨率、物理像素密度、逻辑像素密度、刷新率、屏幕尺寸、屏幕旋转方向、屏幕旋转角度等，具体可见[Display属性](../reference/arkui-cj/cj-apis-display.md)。
- 监听屏幕状态变化，包括屏幕旋转变化，屏幕分辨率变化、屏幕刷新率变化等。
- 查询当前设备是否为可折叠设备，同时支持折叠状态（展开/折叠）变化的监听。

## 接口说明

屏幕属性的常用接口如下表所示，更多功能及接口说明和使用请见[@ohos.display (屏幕属性)](../reference/arkui-cj/cj-apis-display.md)。

| 接口                                                         | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| getAllDisplays(): Array\<Display>                   | 获取当前所有的Display对象。             |
| getDefaultDisplaySync(): Display                             | 获取当前默认的Display对象。                                  |
| func isFoldable(): Bool                                        | 检查设备是否可折叠，true表示设备可折叠，false表示设备不可折叠。                          |
| on(listenerType: ListenerType, callback: Callback1Argument\<FoldStatus>): Unit | 开启折叠设备折叠状态变化的监听。                             |
| off(listenerType: ListenerType, callback: Callback1Argument\<FoldStatus>): Unit | 关闭折叠设备折叠状态变化的监听。                             |

## 获取Display对象

Display对象，即屏幕实例，提供屏幕相关属性及监听变化的接口。目前有以下几种不同获取Display的方式，开发者可根据具体场景需要选择使用。

- 获取当前默认的Display对象：使用getDefaultDisplaySync()接口获取。
- 获取当前所有Display对象：使用getAllDisplays()获取。

此处，以使用getDefaultDisplaySync()获取当前默认Display对象为例，示例如下：

<!-- compile -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog

func getDefaultDisplaySyncExample() {
    try {
        let displayClass: Display = getDefaultDisplaySync()
        Hilog.info(0, "AppLogCj", displayClass.name)
    } catch (exception: Exception) {
        Hilog.error(0, "AppLogCj", exception.toString())
    }
}
// 确保获取到Display对象，即displayClass，再进行后续相关屏幕属性信息查询和事件/状态变化监听
```

## 获取屏幕相关属性

1. 确保获取到Display对象之后（具体可见[获取Display对象](#获取display对象)），可以通过相关属性查询屏幕的一些基础信息。

    <!-- compile -->

    ```cangjie
    import ohos.display.*
    import ohos.hilog.Hilog

    func getDefaultDisplaySyncExample() {
        try {
            let displayClass: Display = getDefaultDisplaySync()
            // 获取屏幕Id
            Hilog.info(0, "1", "AppLogCj", "The screen Id is ${displayClass.id}.")
            // 获取屏幕刷新率
            Hilog.info(0, "1", "AppLogCj", "The screen Id is ${displayClass.refreshRate}.")
            // 获取屏幕宽度
            Hilog.info(0, "1", "AppLogCj", "The screen Id is ${displayClass.width}.")
            // 获取屏幕高度
            Hilog.info(0, "1", "AppLogCj", "The screen Id is ${displayClass.height}.")
            // ...
        } catch (exception: Exception) {
            Hilog.error(0, "AppLogCj", exception.toString())
        }
    }
    ```

2. 还可以通过getCutoutInfo()获取挖孔屏、刘海屏、瀑布屏等不可用的屏幕区域信息，以在UI布局时更好地规避该区域。

    <!-- compile -->

    ```cangjie
    import kit.ArkUI.*
    import kit.PerformanceAnalysisKit.Hilog

    func getCutoutInfoExample() {
        try {
            let displayClass = getDefaultDisplaySync()
            let cutout = displayClass.getCutoutInfo()
            Hilog.info(0, "AppLogCj", "${cutout.boundingRects.size}")
        } catch (exception: Exception) {
            Hilog.error(0, "AppLogCj", exception.toString())
        }
    }
    ```

## 监听折叠设备状态变化

1. 可以通过display.isFoldable()接口查询当前设备是不是折叠设备。

    <!-- compile -->

    ```cangjie
    import ohos.display.*
    import ohos.hilog.Hilog

    func isFoldableExample() {
        try {
            let displayClass = getDefaultDisplaySync()
            var ret: Bool = false
            try {
                ret = isFoldable()
            } catch (exception: Exception) {
                Hilog.error(0, "AppLogCj", exception.toString())
            }
            if (ret) {
                Hilog.info(0, "1", "AppLogCj", "The device is foldable.")
            } else {
                Hilog.info(0, "1", "AppLogCj", "The device is not foldable.")
            }
        } catch (exception: Exception) {
            Hilog.error(0, "AppLogCj", exception.toString())
        }
    }
    ```

2. 若当前设备为折叠设备，可以通过display.on('foldStatusChange')开启折叠设备折叠状态变化的监听；可通过display.off('foldStatusChange')关闭对应的监听。

    <!-- compile -->

    ```cangjie
    import ohos.display.*
    import ohos.hilog.Hilog

    class TestCallback <: Callback1Argument<FoldStatus> {
        public init() {}
        public open func invoke(value: FoldStatus): Unit {
            Hilog.info(0, "1", "AppLogCj", 
                "Display fold status changed, current fold status: " + match (value) {
                    case FoldStatusUnknown => "FoldStatusUnknown"
                    case FoldStatusExpanded => "FoldStatusExpanded"
                    case FoldStatusFolded => "FoldStatusFolded"
                    case FoldStatusHalfFolded => "FoldStatusHalfFolded"
                    case _ => "Failed to get fold status."
                })
        }
    }
    let testCallback = TestCallback()
    // 注册监听的callback参数要采用对象传递.
    on(ListenerTypeFoldStatusChange, testCallback)

    // 如果通过on注册多个callback，同时关闭所有callback监听
    off(ListenerTypeFoldStatusChange);

    // 关闭单个callback监听
    off(ListenerTypeFoldStatusChange, testCallback);
    ```
