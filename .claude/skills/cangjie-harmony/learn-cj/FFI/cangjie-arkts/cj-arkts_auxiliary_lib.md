# 仓颉-ArkTS 互操作辅助库

为了帮助开发者更加方便的编写仓颉- ArkTS 互操作代码，仓颉还提供了互操作辅助库。辅助库提供了更加丰富的 API 供开发者调用。例如，在仓颉应用里使用 ArkTS 存量库场景中，当开发者想要调用的 ArkTS 模块中的接口需要传入一个 context 入参时，可以使用辅助库提供的 getJSContext 函数来获取。

例如，如下给出 ArkTS [相机选择器](https://docs.openharmony.cn/pages/v6.0/zh-cn/application-dev/reference/apis-camera-kit/js-apis-cameraPicker.md) 模块中 pick 方法的声明，其第一个参数类型为 common.Context。

```typescript
declare namespace cameraPicker {
  // ...
  function pick(context: Context, mediaTypes: Array<PickerMediaType>, pickerProfile: PickerProfile): Promise<PickerResult>;
}
```

针对这类互操作场景，互操作辅助库提供了一个 getJSContext 接口，可以将 UIAbilityContext 类型的 context 转换为互操作可调用的 JSValue。

```cangjie
public func getJSContext(runtime: JSRuntime, abilityContext: UIAbilityContext): JSValue
```

用如下示例说明:

1. 在创建 [Cangjie] Empty Ability 工程后，在 entry->src->main->cangjie->main_ability.cj 文件中添加 UIAbilityContext 的全局实例并在 onCreate 函数内赋值：

    ```cangjie
    import ohos.ability.UIAbilityContext

    // UIAbilityContext 的全局实例
    var globalAbilityContext: ?UIAbilityContext = None

    class MainAbility <: UIAbility {
        // ...
        public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
            // 在 UIAbility 创建时保存 context 实例
            globalAbilityContext = context
        }
        // ...
    }
    ```

2. 在仓颉代码中使用辅助库接口：

    ```cangjie
    import ohos.ark_interop.*
    import ohos.ark_interop_helper.*
    import ohos.ability.UIAbilityContext

    var runtime = Option<JSRuntime>.None

    // 从全局变量中获取 JSRuntime 或创建 JSRuntime
    func getRuntime() {
        return match (runtime) {
            case Some(v) => v
            case None =>
                let v = JSRuntime()
                runtime = v
                v
        }
    }

    // 从全局变量中获取 UIAbilityContext
    func getContext(): UIAbilityContext {
        match (globalAbilityContext) {
            case Some(context) =>
                context
            case _ =>
                AppLog.error("####getContext err ")
                throw Exception("get globalAbilityContext failed")
        }
    }

    // 依据辅助库接口 getJSContext 创建 JSValue
    func getJSContextCase(): JSValue {
        let runtime = getRuntime()
        let abilityContext = getContext()
        getJSContext(runtime, abilityContext)
    }
    ```
