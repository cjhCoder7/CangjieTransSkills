# 拉起文件处理类应用（startAbility）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 使用场景

例如，浏览器下应用下载PDF文件，可以调用此接口选择文件处理应用打开此PDF文件。开发者需要在请求中设置待打开文件的URI路径（[uri](#接口关键参数说明)）、文件格式（[type](#接口关键参数说明)）等字段，以便系统能够识别，直接拉起文件打开应用或弹出一个选择框，让用户选择合适的应用来打开文件，效果示意如下图所示。

图1 效果示意图

![file-open](figures/file-open.jpeg)

## 接口关键参数说明

开发者通过调用[startAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)接口即可实现由已安装的垂域应用来打开文件。

**表1** startAbility请求中[Want](../reference/AbilityKit/cj-apis-app-ability-want.md#class-want)相关参数说明

| 参数名称 | 类型   | 是否必填 | 说明       |
|----------|--------|----------|----------|
| uri      | String | 是       | 表示待打开文件的URI路径，一般配合type使用。<br/>uri格式为：file:\/\/bundleName\/path<br/>- file：文件URI的标志。<br/>- bundleName：该文件资源的属主。<br/>- path：文件资源在应用沙箱中的路径。 |
| type     | String | 否       | 表示打开文件的类型，推荐使用[UTD类型](../database/cj-uniform-data-type-list.md#基础类型)，比如：'general.plain-text'、'general.image'。目前也可以兼容使用[MIME type类型](https://www.iana.org/assignments/media-types/media-types.xhtml?utm_source=ld246.com)，如：'text/xml' 、 'image/*'等。<br/>**说明：** <br/>1. type为可选字段，如果不传type，系统会尝试根据uri后缀名判断文件类型进行匹配；如果传入type，必须确保与uri的文件类型一致，否则会导致无法匹配到合适的应用。文件后缀与文件类型的映射关系参见[Uniform Type Descriptor(UTD)预置列表](../database/cj-uniform-data-type-list.md)。<br/>2. 不支持传\*/\*。|
| parameters | String      | 否         | 表示由系统定义，由开发者按需赋值的自定义参数，文件打开场景请参见表2。|
| flags | UInt32 | 否 | 表示处理方式，文件打开场景请参见表3。|

**表2** [parameters](../reference/AbilityKit/cj-apis-app-ability-want_constant.md#class-params)相关参数说明

| 参数名称                              | 类型    | 说明                                                                                                                                                                |
|---------------------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ability.params.stream                 | String  | 指示携带的文件URI要授权给目标方，用于待打开的文件存在其他文件依赖的场景。例如打开本地html文件依赖本地其余资源文件的场景等。对应的value必须是string类型的文件URI数组。文件URI的获取参考表1中uri参数。 |
| ohos.ability.params.showDefaultPicker | Bool | 表示是否强制展示文件打开方式的选择弹框，缺省为false。<br/>- false：表示由系统策略或默认应用设置决定直接拉起文件打开应用还是展示弹框。<br/>- true：表示始终展示弹框。                                                                            |
| showCaller                            | Bool | 表示调用方本身是否作为目标方应用之一参与匹配，缺省为false。<br/>- false：不参与匹配。<br/>- true：参与匹配。                                                                            |

**表3** [flags](../reference/AbilityKit/cj-apis-app-ability-want_constant.md#class-flags)相关参数说明

| 参数名称                       | 值         | 说明                       |
|--------------------------------|------------|----------------------------|
| Flags.FLAG_AUTH_READ_URI_PERMISSION  | 0x00000001 | 指对URI执行读取操作的授权。 |
| Flags.FLAG_AUTH_WRITE_URI_PERMISSION | 0x00000002 | 指对URI执行写入操作的授权。 |

## 接入步骤

### 调用方接入步骤

1. 导入相关模块。

    <!-- compile -->

    ```cangjie
    import kit.AbilityKit.{UIAbility, Want, LaunchParam, Flags, WantValueType}
    import kit.ArkUI.WindowStage
    import kit.CoreFileKit.FileUri
    import ohos.business_exception.BusinessException
    import std.collection.HashMap
    import kit.PerformanceAnalysisKit.Hilog
    ```

2. 获取应用文件路径。

    <!-- compile -->

    ```cangjie
    // 假设应用bundleName值为com.example.demo
    class MainAbility <: UIAbility {
        public override func onWindowStageCreate(windowStage: WindowStage): Unit {
            // 获取文件沙箱路径
            let filePath = this
            .context
            .filesDir + '/test1.txt'
            // 将沙箱路径转换为uri
            let uri = FileUri(filePath).toString()
            // 获取的uri为"file://com.example.demo/data/storage/el2/base/files/test.txt"
        }
        // ...
    }
    ```

3. 构造请求数据。

    <!-- compile -->

    ```cangjie
    // 假设应用bundleName值为com.example.demo
    class MainAbility <: UIAbility {
        public override func onWindowStageCreate(windowStage: WindowStage): Unit {
            // 获取文件沙箱路径
            let filePath = this
            .context
            .filesDir + '/test1.txt'
            // 将沙箱路径转换为uri
            let uri = FileUri(filePath).toString()
            // 构造请求数据
            let want = Want(
                deviceId: "",
                bundleName: "",
                abilityName: "",
                moduleName: "",
                // 配置被分享文件的读写权限，例如对文件打开应用进行读写授权
                flags: Flags.FLAG_AUTH_WRITE_URI_PERMISSION | Flags.FLAG_AUTH_READ_URI_PERMISSION,
                uri: uri,
                action: "ohos.want.action.viewData", // 表示查看数据的操作，文件打开场景固定为此值
                entities: [],
                dataType: 'general.plain-text', // 表示待打开文件的类型
                parameters: HashMap<String, WantValueType>(),
                fds: HashMap<String, Int32>()
            )
        }
        // ...
    }
    ```

4. 调用接口启动。

    <!-- compile -->

    ```cangjie
    class MainAbility <: UIAbility {
        public override func onWindowStageCreate(windowStage: WindowStage): Unit {
            // 打印日志
            Hilog.info(1, "info", "MainAbility onWindowStageCreate.")
            // 获取文件沙箱路径
            let filePath = this
                .context
                .filesDir + '/test1.txt'
            // 将沙箱路径转换为uri
            let uri = FileUri(filePath).toString()
            // 获取的uri为"file://com.example.demo/data/storage/el2/base/files/test1.txt"
            // 构造请求数据
            let want = Want(
                deviceId: "",
                bundleName: "",
                abilityName: "",
                moduleName: "",
                // 配置被分享文件的读写权限，例如对文件打开应用进行读写授权
                flags: Flags.FLAG_AUTH_WRITE_URI_PERMISSION | Flags.FLAG_AUTH_READ_URI_PERMISSION,
                uri: uri,
                action: "ohos.want.action.viewData", // 表示查看数据的操作，文件打开场景固定为此值
                entities: [],
                dataType: 'general.plain-text', // 表示待打开文件的类型
                parameters: HashMap<String, WantValueType>(),
                fds: HashMap<String, Int32>()
            )
            try {
                this
                    .context
                    .startAbility(want)
            } catch (e: BusinessException) {
                Hilog.error(1, "info", "Failed to invoke startAbility, code: ${e.code}, message: ${e.message}")
            }
        }
    }
    ```

### 目标方接入步骤

1. 声明文件打开能力。

    支持打开文件的应用需要在[module.json5](../cj-start/basic-knowledge/cj-module-configuration-file.md)配置文件中声明文件打开能力。其中uris字段表示接收URI的类型，其中scheme固定为file。type字段表示支持打开的文件类型（参见[MIME type类型](https://www.iana.org/assignments/media-types/media-types.xhtml?utm_source=ld246.com)），如下举例中类型为txt文件。

    ```json
    {
    "module": {
        // ...
        "abilities": [
        {
            // ...
            "skills": [
            {
                "actions": [
                "ohos.want.action.viewData" // 必填，声明数据处理能力
                ],
                "uris": [
                {
                    // 允许打开uri中以file://协议开头标识的本地文件
                    "scheme": "file", // 必填，声明协议类型为文件
                    "type": "general.plain-text", // 必填，表示支持打开的文件类型
                    "linkFeature": "FileOpen" // 必填且大小写敏感，表示此URI的功能为文件打开
                }
                // ...
                ]
                // ...
            }
            ]
        }
        ]
    }
    }
    ```

2. 应用处理待打开文件。

    <!-- compile -->

    ```cangjie
    import kit.AbilityKit.{UIAbility, Want, LaunchParam}
    import kit.ArkUI.{WindowStage}
    import kit.CoreFileKit.{FileIo, OpenMode}
    import ohos.business_exception.BusinessException
    import kit.PerformanceAnalysisKit.Hilog

    class MainAbility <: UIAbility {
        public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
            // 从want信息中获取uri字段
            let uri = want.uri
            if (uri == "") {
                Hilog.error(1, "info", 'uri is invalid')
                return
            }
            try {
                // 根据待打开文件的URI进行相应操作。例如同步读写的方式打开URI获取file对象
                let file = FileIo.open(uri, mode: OpenMode.READ_WRITE)
                Hilog.info(1, "info", "Succeed to open file.")
            } catch (e: BusinessException) {
                Hilog.error(1, "info", "Failed to open file openSync, code: ${e.code}, message: ${e.message}")
            }
        }
    }
    ```
