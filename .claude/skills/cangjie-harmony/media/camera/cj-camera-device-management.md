# 相机管理

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在开发一个相机应用前，需要先通过调用相机接口来创建一个独立的相机设备。

## 开发步骤

详细的API说明请参见[Camera API参考](../../reference/CameraKit/cj-apis-multimedia-camera.md)。

1. 导入camera接口，接口中提供了相机相关的属性和方法，导入方法如下。

    <!-- compile -->

    ```cangjie
    import kit.CameraKit.*
    import kit.AbilityKit.*
    import kit.PerformanceAnalysisKit.Hilog
    import ohos.callback_invoke.Callback1Argument
    import ohos.business_exception.BusinessException
    ```

2. 通过[getCameraManager](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-getcameramanageruiabilitycontext)方法，获取cameraManager对象。

    Context获取方式请参见：[获取UIAbility的上下文信息](../../application-models/cj-uiability-usage.md#获取uiability的上下文信息)。

    <!-- compile -->

    ```cangjie
    func createCameraManager(context: UIAbilityContext): CameraManager {
        let cameraManager: CameraManager = getCameraManager(context)
        return cameraManager
    }
    ```

    > **说明：**
    >
    > 如果获取对象失败，说明相机可能被占用或无法使用。如果被占用，须等到相机被释放后才能重新获取。

3. 通过[CameraManager](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-cameramanager)类中的[getSupportedCameras](../../reference/CameraKit/cj-apis-multimedia-camera.md#func-getsupportedcameras)方法，获取当前设备支持的相机列表，列表中存储了设备支持的所有相机ID。若列表不为空，则说明列表中的每个ID都支持独立创建相机对象；否则，说明当前设备无可用相机，不可继续后续操作。

    <!-- compile -->

    ```cangjie
    func getCameraDevices(cameraManager: CameraManager): Array<CameraDevice> {
        let cameraArray: Array<CameraDevice> = cameraManager.getSupportedCameras()
        if (cameraArray.size > 0) {
            for (index in 0..cameraArray.size) {
                Hilog.info(0,"","cameraId : ${cameraArray[index].cameraId}")  // 获取相机ID。
                Hilog.info(0,"","cameraPosition : ${cameraArray[index].cameraPosition}")  // 获取相机位置。
                Hilog.info(0,"","cameraType : ${cameraArray[index].cameraType}")  // 获取相机类型。
                Hilog.info(0,"","connectionType : ${cameraArray[index].connectionType}")  // 获取相机连接类型。
            }
            return cameraArray
        } else {
            Hilog.error(0,"","cameraManager.getSupportedCameras error")
            return []
        }
    }
    ```

## 状态监听

在相机应用开发过程中，可以随时监听相机状态，包括新相机的出现、相机的移除、相机的可用状态。在回调函数中，通过相机ID、相机状态这两个参数进行监听，如当有新相机出现时，可以将新相机加入到应用的备用相机中。

通过注册cameraStatus事件，通过回调返回监听结果，callback返回CameraStatusInfo参数，参数的具体内容请参见相机管理器回调接口实例[CameraStatusInfo](../../reference/CameraKit/cj-apis-multimedia-camera.md#class-camerastatusinfo)。

<!-- compile -->

```cangjie
class CameraStatusCallBack <: Callback1Argument<CameraStatusInfo> {
    public open func invoke(error: ?BusinessException,cameraStatusInfo: CameraStatusInfo): Unit {
        // 如果当通过USB连接相机设备时，回调函数会返回新的相机出现状态。
        if (cameraStatusInfo.status == CameraStatus.CameraStatusAppear) {
            Hilog.info(0,"","New Camera device appear.")
        }
        // 如果当断开相机设备USB连接时，回调函数会返回相机被移除状态。
        if (cameraStatusInfo.status == CameraStatus.CameraStatusDisappear) {
            Hilog.info(0,"","Camera device has been removed.")
        }
        // 相机被关闭时，回调函数会返回相机可用状态。
        if (cameraStatusInfo.status == CameraStatus.CameraStatusAvailable) {
            Hilog.info(0,"","Current Camera is available.")
        }
        // 相机被打开/占用时，回调函数会返回相机不可用状态。
        if (cameraStatusInfo.status == CameraStatus.CameraStatusUnavailable) {
            Hilog.info(0,"","Current Camera has been occupied.")
        }
        Hilog.info(0,"","camera: ${cameraStatusInfo.camera.cameraId}")
        Hilog.info(0,"","status: ${cameraStatusInfo.status}")
    }
}

func onCameraStatusChange(cameraManager: CameraManager): Unit {
    cameraManager.on(CameraEvents.CameraStatus, CameraStatusCallBack())
}
```
