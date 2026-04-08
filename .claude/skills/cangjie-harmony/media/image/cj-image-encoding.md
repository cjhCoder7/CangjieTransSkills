# 使用ImagePacker完成图片编码

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

图片编码指将PixelMap编码成不同格式的存档图片，当前支持打包为JPEG、WebP、PNG 和 HEIF(不同硬件设备的支持情况有所不同) 格式，用于后续处理，如保存、传输等。

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../../reference/cj-development-intro.md#仓颉示例代码说明)。

## 开发步骤

图片编码相关API的详细介绍请参见：[图片编码接口说明](../../reference/ImageKit/cj-apis-image.md#class-imagepacker)。

### 图片编码进文件流

1. 创建图像编码ImagePacker对象。

    <!-- compile -->

    ```cangjie
    // 导入相关模块包。
    import kit.ImageKit.*

    let imagePackerApi = createImagePacker()
    ```

2. 设置编码输出流和编码参数。

    - format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量。

        > **说明：**
        >
        > 根据MIME标准，标准编码格式为image/jpeg。当使用image编码时，PackingOption.format设置为image/jpeg，image编码后的文件扩展名可设为.jpg或.jpeg，可在支持image/jpeg解码的平台上使用。

        <!-- compile -->

        ```cangjie
        var packOpts = PackingOption('image/jpeg', 98)
        ```

    - 编码为hdr内容(需要资源本身为hdr，支持jpeg格式)。

        <!-- compile -->

        ```cangjie
        packOpts.desiredDynamicRange = PackingDynamicRange.Auto
        ```

3. [创建PixelMap对象或创建ImageSource对象](./cj-image-decoding.md)。

4. 进行图片编码，并保存编码后的图片。

    方法一：通过PixelMap进行编码。

    <!-- compile -->

    ```cangjie
    // data 为打包获取到的文件流，写入文件保存即可得到一张图片。
    let imagePacker = createImagePacker()
    let data = imagePacker.packToData(pixelMap, packOpts)
    ```

    方法二：通过imageSource进行编码。

    <!-- compile -->

    ```cangjie
    // data 为打包获取到的文件流，写入文件保存即可得到一张图片。
    let imagePacker = createImagePacker()
    let data = imagePacker.packToData(imageSource, packOpts)
    ```

### 图片编码进文件

在编码时，开发者可以传入对应的文件路径，编码后的内存数据将直接写入文件。

方法一：通过PixelMap编码进文件。

为实现通过PixelMap编码进文件功能，需要导入如下包：

```cangjie
import kit.ImageKit.*
import kit.CoreFileKit.*
import ohos.arkui.state_macro_manage.r
```

实现通过PixelMap编码进文件功能的核心代码是：

```cangjie
var abilityContext = Global.abilityContext
// 获取resourceManager资源管理器。
let resourceManager = abilityContext.resourceManager   
        
let img = resourceManager.getMediaContent(@r(app.media.layered_image).id)
let imageSource = createImageSource(img)
let cacheDir = "/data/storage/el2/base/haps/entry/cache"
let filePath = cacheDir + '/test.jpg'

let file = FileIo.open(filePath, mode: OpenMode.CREATE | OpenMode.READ_WRITE)
// 直接打包进文件。
let imagePacker = createImagePacker()
imagePacker.packToFile(imageSource, Int32(file.fd), PackingOption("image/jpeg", 100))
FileIo.close(file.fd)
```

方法二：通过ImageSource编码进文件。

为实现通过ImageSource编码进文件功能，需要导入如下包：

```cangjie
import kit.ImageKit.*
import kit.CoreFileKit.*
import ohos.arkui.state_macro_manage.r
```

实现通过ImageSource编码进文件功能的核心代码是：

```cangjie
var abilityContext = Global.abilityContext
// 获取resourceManager资源管理器。
let resourceManager = abilityContext.resourceManager   
        
let img = resourceManager.getMediaContent(@r(app.media.layered_image).id)
let imageSource = createImageSource(img)
let cacheDir = "/data/storage/el2/base/haps/entry/cache"
let filePath = cacheDir + '/test.jpg'

let file = FileIo.open(filePath, mode: OpenMode.CREATE | OpenMode.READ_WRITE)
// 直接打包进文件。
let imagePacker = createImagePacker()
imagePacker.packToFile(imageSource, Int32(file.fd), PackingOption("image/jpeg", 100))
FileIo.close(file.fd)
```
