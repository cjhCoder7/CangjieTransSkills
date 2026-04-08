# 使用PixelMap完成图像变换

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

图片处理是指对PixelMap进行相关的操作，如获取图片信息、裁剪、缩放、偏移、旋转、翻转、设置透明度、读写像素数据等。图片处理主要包括图像变换和[位图操作](./cj-image-pixelmap-operation.md)，本文介绍图像变换。

## 开发步骤

图像变换相关API的详细介绍请参见[API参考](../../reference/ImageKit/cj-apis-image.md#class-pixelmap)。

1. 完成[图片解码](./cj-image-decoding.md)，获取PixelMap对象。

2. 获取图片信息。

    <!-- compile -->

    ```cangjie
    // 获取图片大小。
    let info = pixelMap.getImageInfo()
    ```

3. 进行图像变换操作。

   原图：

     ![Original drawing](./figures/original-drawing.jpeg)

   - 裁剪

     <!-- compile -->

     ```cangjie
     // x：裁剪起始点横坐标0。
     // y：裁剪起始点纵坐标0。
     // height：裁剪高度400，方向为从上往下（裁剪后的图片高度为400）。
     // width：裁剪宽度400，方向为从左到右（裁剪后的图片宽度为400）。
     pixelMap.crop(Region(Size(400, 400), 0, 0))
     ```

     ![cropping](./figures/cropping.jpeg)

   - 缩放

     <!-- compile -->

     ```cangjie
     // 宽为原来的0.5。
     // 高为原来的0.5。
     pixelMap.scale(0.5, 0.5)
     ```

     ![zoom](./figures/zoom.jpeg)

   - 偏移

     <!-- compile -->

     ```cangjie
     // 向下偏移100。
     // 向右偏移100。
     pixelMap.translate(100.0, 100.0);
     ```

     ![offsets](./figures/offsets.jpeg)

   - 旋转

     <!-- compile -->

     ```cangjie
     // 顺时针旋转90°。
     pixelMap.rotate(90.0);
     ```

     ![rotate](./figures/rotate.jpeg)

   - 翻转

     <!-- compile -->

     ```cangjie
     // 垂直翻转。
     pixelMap.flip(false, true);
     ```

     ![Vertical Flip](./figures/vertical-flip.jpeg)

     <!-- compile -->

     ```cangjie
     // 水平翻转。
     pixelMap.flip(true, false);
     ```

     ![Horizontal Flip](./figures/horizontal-flip.jpeg)

   - 透明度

     <!-- compile -->

     ```cangjie
     // 透明度0.5。
     pixelMap.opacity(0.5);
     ```

     ![Transparency](./figures/transparency.png)
<!--Del-->
## 示例代码

[使用PixelMap完成图像变换](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/Media/ImageTransformation)
<!--DelEnd-->
