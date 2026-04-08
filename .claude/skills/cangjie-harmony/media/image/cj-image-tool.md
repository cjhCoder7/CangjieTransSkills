# 编辑图片EXIF信息

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

图片工具当前主要提供图片EXIF信息的读取与编辑能力。

EXIF（Exchangeable image file format）是专门为数码相机的照片设定的文件格式，可以记录数码照片的属性信息和拍摄数据。当前仅支持JPEG格式图片。

在图库等应用中，需要查看或修改数码照片的EXIF信息。由于摄像机的手动镜头的参数无法自动写入到EXIF信息中或者因为相机断电等原因经常会导致拍摄时间出错，这时候就需要手动修改错误的EXIF数据，即可使用本功能。

OpenHarmony目前仅支持对部分EXIF信息的查看和修改，具体支持的范围请参见：[Exif信息](../../reference/ImageKit/cj-apis-image.md#enum-propertykey)。

## 开发步骤

EXIF信息的读取与编辑相关API的详细介绍请参见[API参考](../../reference/ImageKit/cj-apis-image.md#func-getimagepropertypropertykey-imagepropertyoptions)。

1. 获取图片，创建图片源ImageSource。

   <!-- compile -->

   ```cangjie
   // 导入相关模块包。
   import kit.ImageKit.*

   // 获取沙箱路径创建ImageSource。
   let fd : Int32 = 0 // 获取需要被处理的图片的fd。
   let imageSourceApi = createImageSource(fd)
   ```

2. 读取、编辑EXIF信息。

    <!-- compile -->

    ```cangjie
    // 读取EXIF信息，BitsPerSample为每个像素比特数。
    let options : ImagePropertyOptions = ImagePropertyOptions(index: 0, defaultValue: '9999')
    let data = imageSourceApi.getImageProperty(PropertyKey.BitsPerSample, options: options)

    // 编辑EXIF信息。
    imageSourceApi.modifyImageProperty(PropertyKey.ImageWidth, "120")
    ```
