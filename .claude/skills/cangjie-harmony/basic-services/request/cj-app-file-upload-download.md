# 应用文件上传下载

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

应用可以将应用文件上传到网络服务器，也可以从网络服务器下载网络资源文件到本地应用文件目录。

## 上传应用文件

开发者可以使用上传下载模块（[ohos.request](../../reference/BasicServicesKit/cj-apis-request-agent.md)）的上传接口将本地文件上传。文件上传过程使用系统服务代理完成，支持用户设置自定义代理地址。

> **说明：**
>
> 当前上传应用文件功能，仅支持上传应用缓存文件路径（cacheDir）下的文件。
>
> 使用上传下载模块，请参见[声明权限](../../security/AccessToken/cj-declare-permissions.md)：ohos.permission.INTERNET。

以下示例代码演示将应用缓存文件路径下的文件上传至网络服务器的方式：

<!-- compile -->

```cangjie
// pages/xxx.cj
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.BasicServicesKit.*
import kit.CoreFileKit.*
import kit.PerformanceAnalysisKit.Hilog

func Upload(): Unit {
    // 获取应用文件路径
    let UiStageContext = Global.abilityContext
    let DefaultSandBoxCache = "/data/storage/el2/base/haps/entry/cache"
    // 新建一个本地应用文件
    let filePath = "${DefaultSandBoxCache}/test.txt"
    let file = FileIo.open(filePath, mode: (OpenMode.CREATE | OpenMode.READ_WRITE))
    FileIo.write(file.fd, "hello world")
    FileIo.fdatasync(file.fd)
    let randomAccessFile = FileIo.createRandomAccessFile(file)
    randomAccessFile.close()
    let responseCallback = ProgressCallback()

    let fileSpec = FileSpec(
        "./test.txt",
        filename: "test.txt",
        mimeType: "application/octet-stream"
    )
    let attachments = ConfigData.FormItems([
        FormItem(
            "taskOnTest",
            FormItemValue.FileItem(fileSpec)
        )
    ])

    let uploadConfig = Config(
        Action.Upload,
        "http://xxx",
        title: "taskOnTest",
        mode: Mode.Foreground,
        description: "Sample code for event listening",
        overwrite: false,
        method: "POST",
        data: attachments,
        saveas: "./",
        network: Network.Cellular,
        metered: false,
        roaming: true,
        retry: true,
        redirect: true,
        index: 0,
        begins: 0,
        ends: -1,
        gauge: false,
        precise: false,
        token: "it is a secret"
    )
    let task = create(UiStageContext, uploadConfig)
    task.on(EventCallbackType.Progress, responseCallback)
    task.start()
}

public class ProgressCallback <: Callback1Argument<Progress> {
    public ProgressCallback() {}

    public open func invoke(err: ?BusinessException, arg: Progress): Unit {
        Hilog.info(0, "CangjieTest", "ProgressCallback Invoke")
    }
}
```

## 下载网络资源文件至应用文件目录

开发者可以使用上传下载模块（[ohos.request](../../reference/BasicServicesKit/cj-apis-request-agent.md)）的下载接口将网络资源文件下载到应用文件目录。对已下载的网络资源文件，开发者可以使用基础文件IO接口（[ohos.file_fs](../../reference/CoreFileKit/cj-apis-file_fs.md)）对其进行访问，使用方式与[应用文件访问](../../file-management/cj-app-file-access.md)一致。文件下载过程使用系统服务代理完成，支持用户设置自定义代理地址。

> **说明：**
>
> 当前网络资源文件仅支持下载至应用文件目录。
>
> 使用上传下载模块，请参见[声明权限](../../security/AccessToken/cj-declare-permissions.md)：ohos.permission.INTERNET。

以下示例代码演示将网络资源文件下载到应用文件目录的方式：

<!-- compile -->

```cangjie
// pages/xxx.cj
// 将网络资源文件下载到应用文件目录
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.BasicServicesKit.*
import kit.CoreFileKit.*
import std.collection.*
import std.sync.*
import kit.PerformanceAnalysisKit.Hilog

//下载的函数
func Download(): Unit {
    // 获取应用文件路径
    let UiStageContext = Global.abilityContext
    let DefaultSandBoxCache = "/data/storage/el2/base/haps/entry/cache"
    let fileName = "test.txt"
    let filePath = "${DefaultSandBoxCache}/${fileName}"

    // 下载url地址
    let fileURL = "https://xxx.txt"
    let responseCallback = HttpResponseCallback()

    let config = Config(
        Action.Download,
        fileURL,
        saveas: fileName,
        headers: HashMap<String, String>([("headers", "http")]),
        metered: false,
        roaming: true,
        description: "download test",
        network: Network.AnyType,
        title: "download test title"
    )
    let task = create(UiStageContext, config)
    task.on(EventCallbackType.Response, responseCallback)

    task.start()
    requestWaitFor(Duration.second * 10) {
        =>
        let stat = FileIo.stat(filePath)
        let size = stat.size
        size > 0
    }
    //检查文件是否存在
    if (FileIo.access(filePath)) {
        //删除文件
        FileIo.unlink(filePath)
    }
    //结束任务
    remove(task.tid)
}

class HttpResponseCallback <: Callback1Argument<HttpResponse> {
    public HttpResponseCallback() {}
    public open func invoke(err: ?BusinessException, arg: HttpResponse): Unit {
        Hilog.info(0, "CangjieTest", "HttpResponse Invoke")
    }
}

public func requestWaitFor(timeout: Duration, condition: () -> Bool) {
    let monitor = Monitor()
    let conditionIsMet = AtomicBool(false)
    let checkerTimer = Timer.repeatDuring(timeout, Duration.Zero, Duration.millisecond * 500,
        {
            => if (condition()) {
                conditionIsMet.store(true)
                synchronized(monitor) {
                    monitor.notify()
                }
            }
        })
    let cancellerTimer = Timer.once(timeout) {
        => synchronized(monitor) {
            monitor.notify()
        }
    }
    synchronized(monitor) {
        monitor.wait()
    }

    checkerTimer.cancel()
    cancellerTimer.cancel()
}
```
<!--Del-->
## 示例代码

[下载文件](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/Connectivity/FileDownload)
<!--DelEnd-->
