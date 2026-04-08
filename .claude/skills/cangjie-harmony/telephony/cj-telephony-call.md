# 拨打电话

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

开发者可以通过以下方式实现拨打电话的功能：

- 对于三方应用，开发者可以使用makeCall接口，拉起系统电话应用，用户可以自行呼出通话。

## 基本概念

- 通话状态码
  将当前的通话状态上报给app，可以根据当前的通话状态去做一些逻辑处理。例如在当前没有正在进行呼叫的时候，可以正常拨打新的一通电话。

| 名称                | 说明                               |
| :------------------ | :--------------------------------- |
| CallStateUnknown | 无效状态，当获取呼叫状态失败时返回。   |
| CallStateIdle    | 表示没有正在进行的呼叫。              |
| CallStateRinging | 表示来电正在振铃或等待。              |
| CallStateOffhook | 表示至少有一个呼叫处于拨号、通话中或呼叫保持状态，并且没有新的来电振铃或等待。 |

## 约束与限制

1. 仅支持在标准系统上运行。
2. 设备需插入可用的SIM卡。

## 接口说明

| 接口名 | 描述 |
| :------------------------------------------- | :--------------------------------- |
| hasVoiceCapability() | 判断是否具有语音功能。 |
| makeCall(UIAbilityContext, String) | 转到拨号屏幕，显示被叫号码。  |

## 开发步骤

以使用makeCall拨打电话为例：

1. 导入call和observer模块。
2. 调用hasVoiceCapability，确认当前设备是否支持拨号。
3. 调用makeCall接口，跳转到拨号界面并显示待拨号的号码。

<!-- compile -->

```cangjie
// import需要的模块
import kit.TelephonyKit.*
import kit.AbilityKit.*

var ctx = Option<UIAbilityContext>.None

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello World"

    func build() {
        Row {
            Column {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt =>
                        let isSupport = Call.hasVoiceCapability()
                        if (isSupport) {
                            // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
                            Call.makeCall(ctx.getOrThrow(), "130xxxx")                  
                        }
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

<!-- compile -->

```cangjie
// main_ability.cj

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        Hilog.info(1, "info", "MainAbility OnCreated.${want.abilityName}")
        match (launchParam.launchReason) {
            case LaunchReason.StartAbility => Hilog.info(1, "info", "START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        Hilog.info(1, "info", "MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")
        // declared in index.cj
        ctx = this.context
    }
}
```
<!--Del-->
## 示例代码

[拨打电话](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/Telephony/MakeCall)
<!--DelEnd-->
