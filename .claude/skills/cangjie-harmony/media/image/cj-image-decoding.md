# 使用ImageSource完成图片解码

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

图片解码指将所支持格式的存档图片解码成统一的[PixelMap](./cj-image-overview.md)，以便在应用或系统中进行图片显示或[图片处理](./cj-image-transformation.md)。当前支持的存档图片格式包括JPEG、PNG、GIF、WebP、BMP、SVG、ICO、DNG 和 HEIF（不同硬件设备支持情况可能有所不同）。

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../../reference/cj-development-intro.md#仓颉示例代码说明)。

## 开发步骤

图片解码相关API的详细介绍请参见：[图片解码API说明](../../reference/ImageKit/cj-apis-image.md#class-imagesource)。

1. 全局导入Image模块。

    <!-- compile -->

    ```cangjie
    import kit.ImageKit.*
    ```

2. 获取图片。
    - 方法一：通过沙箱路径获取图片的文件描述符。具体请参考[file.fs API参考文档](../../reference/CoreFileKit/cj-apis-file_fs.md)。
      该方法需要先导入kit.CoreFileKit模块和kit.AbilityKit模块。

        <!-- compile -->

        ```cangjie
        import kit.CoreFileKit.*
        import kit.AbilityKit.*
        ```

        然后调用FileFs.open()获取文件描述符。

        <!-- compile -->

        ```cangjie
        let cacheDir = "/data/storage/el2/base/haps/entry/cache"
        let filePath = cacheDir + '/test.jpg'
        let file = FileIo.open(filePath, mode: OpenMode.READ_WRITE)
        let fd = file.fd 
        ```

    - 方法二：通过资源管理器获取资源文件的Array\<UInt8>。具体请参考[ResourceManager API参考文档](../../reference/LocalizationKit/cj-apis-resource_manager.md#func-getrawfilecontentstring)。

        <!-- compile -->

        ```cangjie
        // 导入resourceManager资源管理器。
        import kit.LocalizationKit.*
        import kit.PerformanceAnalysisKit.Hilog
        import ohos.business_exception.BusinessException

        var abilityContext = Global.abilityContext
        // 获取resourceManager资源管理器。
        let resourceManager = abilityContext.resourceManager
        ```

        不同模型获取资源管理器的方式不同，获取资源管理器后，再调用getRawFileContent()获取资源文件的Array\<UInt8>。

        <!-- compile -->

        ```cangjie
        try {
          let buffer = resourceManager.getRawFileContent("test.jpg")
        } catch (e: BusinessException) {
          Hilog.error(0, "Failed to get RawFileContent", e.message)
        }
        ```

    - 方法四：通过资源管理器获取资源文件的RawFileDescriptor。具体请参考[ResourceManager API参考文档](../../reference/LocalizationKit/cj-apis-resource_manager.md#func-getrawfdstring)。

        <!-- compile -->

        ```cangjie
        // 导入resourceManager资源管理器。
        import kit.LocalizationKit.*
        import kit.PerformanceAnalysisKit.Hilog
        import ohos.business_exception.BusinessException

        var abilityContext = Global.abilityContext
        // 获取resourceManager资源管理器。
        let resourceManager = abilityContext.resourceManager
        ```

        不同模型获取资源管理器的方式不同，获取资源管理器后，再调用getRawFd()获取资源文件的RawFileDescriptor。

        <!-- compile -->

        ```cangjie
        try {
          let rawFileDescriptor = resourceManager.getRawFd("test.jpg")
        } catch (e: BusinessException) {
          Hilog.error(0, "Failed to get RawFileContent", e.message)
        }
        ```

3. 创建ImageSource实例。

    - 方法一：通过沙箱路径创建ImageSource。沙箱路径可以通过步骤2的方法一获取。

        <!-- compile -->

        ```cangjie
        // filePath为已获得的沙箱路径。
        let imageSource = createImageSource(filePath)
        ```

    - 方法二：通过文件描述符fd创建ImageSource。文件描述符可以通过步骤2的方法二获取。

        <!-- compile -->

        ```cangjie
        // fd为已获得的文件描述符。
        let imageSource = createImageSource(fd)
        ```

    - 方法三：通过缓冲区数组创建ImageSource。缓冲区数组可以通过步骤2的方法三获取。

        <!-- compile -->

        ```cangjie
        let imageSource = createImageSource(buffer)
        ```

    - 方法四：通过资源文件的RawFileDescriptor创建ImageSource。RawFileDescriptor可以通过步骤2的方法四获取。

        <!-- compile -->

        ```cangjie
        let imageSource = createImageSource(rawFileDescriptor)
        ```

4. 设置解码参数DecodingOptions，解码获取pixelMap图片对象。
   
    - 设置期望的format进行解码：

        <!-- compile -->

        ```cangjie
        import kit.ImageKit.*
        import kit.AbilityKit.*
        import ohos.arkui.state_macro_manage.r

        var abilityContext = Global.abilityContext
        // 获取resourceManager资源管理器。
        let resourceManager = abilityContext.resourceManager

        let img = resourceManager.getMediaContent(@r(app.media.layered_image).id)
        let imageSource = createImageSource(img)
        let decodingOptions = DecodingOptions(editable: true, desiredPixelFormat: PixelMapFormat.Rgba8888)

        // 创建pixelMap。
        let pixelMap = imageSource.createPixelMap(options: decodingOptions)
        ```

    - HDR图片解码

        <!-- compile -->

        ```cangjie
        import kit.ImageKit.*
        import kit.AbilityKit.*
        import ohos.arkui.state_macro_manage.r

        var abilityContext = Global.abilityContext
        // 获取resourceManager资源管理器。
        let resourceManager = abilityContext.resourceManager

        let img = resourceManager.getMediaContent(@r(app.media.layered_image).id)
        let imageSource = createImageSource(img)
        //设置为AUTO会根据图片资源格式解码，如果图片资源为HDR资源则会解码为HDR的pixelmap。
        let decodingOptions = DecodingOptions(desiredDynamicRange: DecodingDynamicRange.Auto)

        // 创建pixelMap。
        let pixelMap = imageSource.createPixelMap(options: decodingOptions)
        // 判断pixelmap是否为hdr内容。
        let info = pixelMap.getImageInfo()
        ```

    解码完成，获取到pixelMap对象后，可以进行后续[图片处理](./cj-image-transformation.md)。

5. 释放pixelMap和imageSource。

    需确认pixelMap和imageSource方法已经执行完成，不再使用该变量后可按需手动调用下面方法释放。

    <!-- compile -->

    ```cangjie
    pixelMap.release()
    imageSource.release()
    ```

## 开发示例-对资源文件中的图片进行解码

1. 获取resourceManager资源管理器。

    <!-- compile -->

    ```cangjie
    // 导入resourceManager资源管理器。
    import kit.LocalizationKit.*
    import kit.AbilityKit.*

    var abilityContext = Global.abilityContext
    // 获取resourceManager资源管理器。
    let resourceManager = abilityContext.resourceManager
    ```

2. 创建ImageSource。
    - 方式一：通过rawfile文件夹下的test.jpg的Array\<UInt8>创建。

        <!-- compile -->

        ```cangjie
        let buffer = resourceManager.getRawFileContent("test.jpg")
        let imageSource = createImageSource(buffer)
        ```

    - 方式二：通过rawfile文件夹下的test.jpg的RawFileDescriptor创建。

        <!-- compile -->

        ```cangjie
        let rawFileDescriptor = resourceManager.getRawFd("test.jpg")
        let imageSource = createImageSource(rawFileDescriptor)
        ```

3. 创建pixelMap。

    <!-- compile -->

    ```cangjie
    let pixelMap = imageSource.createPixelMap()
    ```

4. 释放pixelMap和imageSource。

    需确认pixelMap和imageSource方法已经执行完成，在不再使用这些变量时，可按需手动调用以下方法进行释放。

    <!-- compile -->

    ```cangjie
    pixelMap.release()
    imageSource.release()
    ```
