# 传感器开发指导

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

当设备需要获取传感器数据时，可以使用sensor模块，例如：通过订阅方向传感器数据感知用户设备当前的朝向，通过订阅计步传感器数据统计用户的步数等。

详细的API介绍请参见[Sensor API](../../reference/SensorServiceKit/cj-apis-sensor.md)。

## 接口说明

| 名称 | 描述 |
| -------- | -------- |
| on\<T>(sensorType: SensorId, callback: Callback1Argument\<T>, option!: ?Options = None): Unit where T \<: Response | 持续监听传感器数据变化。 |
| once\<T>(sensorType: SensorId, callback: Callback1Argument\<T>): Unit where T \<: Response | 获取一次传感器数据变化。 |
| off(sensorType: SensorId, callback!: ?CallbackObject = None): Unit | 注销传感器数据的监听。 |
| getSensorList():Array\<Sensor> | 获取设备上的所有传感器信息。 |

## 开发步骤

开发步骤以加速度传感器ACCELEROMETER为例。

1. 导入模块。

    <!-- compile -->

    ```cangjie
    import kit.SensorServiceKit.*
    import ohos.business_exception.BusinessException
    import ohos.callback_invoke.Callback1Argument
    import kit.PerformanceAnalysisKit.Hilog
    ```

2. 查询设备支持的所有传感器的参数。

    <!-- compile -->

    ```cangjie
    try {
        let sensors = getSensorList()
        for (index in 0..sensors.size) {
            Hilog.info(1, "info",
                "{sensorName: ${sensors[index].sensorName}, vendorName: ${sensors[index].vendorName}, firmwareVersion: ${sensors[index].firmwareVersion}, \n hardwareVersion: ${sensors[index].hardwareVersion}, sensorId: ${sensors[index].sensorId}, \n minSamplePeriod: ${sensors[index].minSamplePeriod}, maxSamplePeriod: ${sensors[index].maxSamplePeriod}}")
        }
    } catch (e: BusinessException) {
        Hilog.info(1, "info", "Failed to get sensor list. Code: ${e.code}, message: ${e.message}")
    }
    ```

    ![sensor-list](figures/sensor-list.png)

    该传感器支持的最小采样周期为2000000纳秒，最大采样周期是200000000纳秒。不同传感器支持的采样周期范围也不同，interval应该设置在传感器支持范围内，大于最大值时以最大值上报数据，小于最小值时以最小值上报数据。设置数值越小数据上报越频繁，其功耗越大。

3. 检查是否已经配置相应权限，不同传感器所需权限信息请参见[传感器开发概述](./cj-sensor-overview.md#约束与限制)，具体配置方式请参见[声明权限](../../security/AccessToken/cj-declare-permissions.md)，申请权限请参见[向用户申请授权](../../security/AccessToken/cj-request-user-authorization.md)。

4. 注册监听。可以通过on()和once()两种接口监听传感器的调用结果。

   通过on()接口，实现对传感器的持续监听，传感器上报周期interval设置为100000000纳秒。

    <!-- compile -->

    ```cangjie
    // 自定义回调
    class SensorCallback <: Callback1Argument<AccelerometerResponse>
    {
        init() {}
        public func invoke(err: ?BusinessException, arg: AccelerometerResponse): Unit {
            Hilog.info(1, "info", "Succeeded in getting SensorCallback arg: x: ${arg.x}, y: ${arg.y}, z: ${arg.z}")
        }
    }

    func onExample() {
        let callback = SensorCallback()
        try {
            //周期传感器与瞬时传感器开发步骤相同。
            //区别是周期传感器按设定的固定时间间隔option采集并输出数据,瞬时传感器受特定触发事件影响采集并输出数据,不受option约束。
            on(SensorId.Accelerometer, callback, option: Options(interval: SensorNumber(100000000)))
        } catch (e: BusinessException) {
            Hilog.error(1, "info", "Sensor on error code: ${e.code}, message: ${e.message}")
        }
    }
    ```

    ![sensor-on](figures/sensor-on.png)

    通过once()接口，实现对传感器的一次监听。

    <!-- compile -->

    ```cangjie
    // 自定义回调
    class SensorCallback <: Callback1Argument<AccelerometerResponse>
    {
        init() {}
        public func invoke(err: ?BusinessException, arg: AccelerometerResponse): Unit {
            Hilog.info(1, "info", "Succeeded in getting SensorCallback arg: x: ${arg.x}, y: ${arg.y}, z: ${arg.z}")
        }
    }

    func onceExample() {
        try {
            let callback = SensorCallback()
            once(SensorId.Accelerometer, callback)
        } catch (e: BusinessException) {
            Hilog.error(1, "info", "Sensor once error code: ${e.code}, message: ${e.message}")
        }
    }
    ```

    ![sensor-once](figures/sensor-once.png)

5. 取消持续监听。

    <!-- compile -->

    ```cangjie
    func offExample() {
        try {
            // 取消注册SensorId.ORIENTATION的所有回调
            off(SensorId.Accelerometer)
        } catch (e: BusinessException) {
            Hilog.error(1, "info", "Sensor off error code: ${e.code}, message: ${e.message}")
        }
    }
    ```

## 备注

传感器的开发均同上述加速度传感器ACCELEROMETER。需要注意的是，传感器按采集数据方式分为周期传感器和瞬时传感器。周期传感器按预先设定的固定时间间隔采集并输出数据，如环境温度传感器AMBIENT_TEMPERATURE，订阅后，传感器按设计的时间间隔上报数据。周期传感器有GRAVITY、AMBIENT_TEMPERATURE、HUMIDITY、BAROMETER等。瞬时传感器受特定触发事件影响才采集并输出数据，如计步传感器PEDOMETER，步数有变化会上报。瞬时传感器有HALL、PROXIMITY、WEAR_DETECTION、PEDOMETER、PEDOMETER_DETECTION。
<!--Del-->
## 示例代码

[获取传感器信息](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/DeviceManagement/Sensor)
<!--DelEnd-->
