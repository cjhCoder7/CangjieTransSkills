# 手电筒使用

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

手电筒模式的使用是通过操作终端启用手电筒功能，使设备的手电筒功能持续保持常亮状态。

在使用相机应用并操作手电筒功能时，存在以下几种情况说明：

- 当使用后置摄像头并设置闪光灯模式[FlashMode](../../reference/CameraKit/cj-apis-multimedia-camera.md#enum-flashmode)关闭时，手电筒功能无法启用。
- 当使用前置摄像头时，手电筒可以正常启用并保持常亮状态。
- 从前置摄像头切换至后置摄像头时，如果手电筒原本处于开启状态，它将会被自动关闭。

## 开发步骤

详细的API说明请参见[Camera API参考](../../reference/CameraKit/cj-apis-multimedia-camera.md)。

1. 导入camera接口，接口中提供了相机相关的属性和方法，导入方法如下。

    <!-- compile -->

    ```cangjie
    import kit.CameraKit.*
    import kit.PerformanceAnalysisKit.Hilog
    import ohos.callback_invoke.Callback1Argument
    import ohos.business_exception.BusinessException
    ```

2. 通过[CameraManager](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-cameramanager)类中的[isTorchSupported](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-istorchsupported)方法，检测当前设备是否支持手电筒功能。

    <!-- compile -->

    ```cangjie
    func isTorchSupported(cameraManager: CameraManager): Bool {
        let torchSupport: Bool = cameraManager.isTorchSupported()
        Hilog.info(0,"","Returned with the torch support status: ${torchSupport}")
        return torchSupport
    }
    ```

3. 通过[CameraManager](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-cameramanager)类中的[isTorchModeSupported](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-istorchmodesupportedtorchmode)方法，检测是否支持指定的手电筒模式[TorchMode](../../reference/CameraKit/cj-apis-multimedia-camera.md#enum-torchmode)。

    <!-- compile -->

    ```cangjie
    func isTorchModeSupported(cameraManager: CameraManager, torchMode: TorchMode): Bool {
        return cameraManager.isTorchModeSupported(torchMode)
    }
    ```

4. 通过[CameraManager](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-cameramanager)类中的[setTorchMode](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-settorchmodetorchmode)方法，设置当前设备的手电筒模式。以及通过[CameraManager](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-cameramanager)类中的[getTorchMode](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-gettorchmode)方法，获取当前设备的手电筒模式。

    > **说明：**
    >
    > 在使用[getTorchMode](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-gettorchmode)方法前，需要先注册监听手电筒的状态变化，请参见[状态监听](#状态监听)。

    <!-- compile -->

    ```cangjie
    func setTorchModeSupported(cameraManager: CameraManager, torchMode: TorchMode): Unit {
        cameraManager.setTorchMode(torchMode)
        let isTorchMode = cameraManager.getTorchMode()
        Hilog.info(0,"", "Returned with the torch mode supportd mode: ${isTorchMode}")
    }
    ```

## 状态监听

在相机应用开发过程中，可以随时监听手电筒状态，包括手电筒打开、手电筒关闭、手电筒不可用、手电筒恢复可用。手电筒状态发生变化，可通过回调函数获取手电筒模式的变化。

通过注册TorchStatusChange事件，通过回调返回监听结果，callback返回TorchStatusInfo参数，参数的具体内容请参见相机管理器回调接口实例[TorchStatusInfo](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-torchstatusinfo)。

<!-- compile -->

```cangjie
class TorchStatusChangeCallBack <: Callback1Argument<TorchStatusInfo> {
    public open func invoke(error: ?BusinessException,torchStatusInfo: TorchStatusInfo): Unit {
        Hilog.info(0,"","onTorchStatusChange, isTorchAvailable: ${torchStatusInfo.isTorchAvailable}, isTorchActive: ${torchStatusInfo.isTorchActive}, level: ${torchStatusInfo.torchLevel}")
    }
}

func onTorchStatusChange(cameraManager: CameraManager): Unit {
    cameraManager.on(CameraEvents.TorchStatusChange, TorchStatusChangeCallBack())
}
```
