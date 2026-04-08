# 应用深浅色适配

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 概述

当前系统存在深浅色两种显示模式，为了给用户更好的使用体验，应用应适配深浅色模式。

## 应用跟随系统的深浅色模式

1. 颜色适配

    - 自定义资源实现

     resources目录下增加深色模式限定词目录（命名为dark）并新建color.json文件，可显示深色模式颜色资源的配置。详细请参见[资源分类与访问](../cj-start/start/cj-ide-resource-categories-and-access.md)。

     resources目录结构示意

     ![colorJsonDir](./figures/colorJsonDir.png)

     例如，开发者可在这两个color.json中定义同名配色定义并赋予不同的色值。

     base/element/color.json文件：

     ```json
     {
       "color": [
         {
           "name": "app_title_color",
           "value": "#000000"
         }
       ]
     }
     ```

     dark/element/color.json文件：

     ```json
     {
       "color": [
         {
           "name": "app_title_color",
           "value": "#FFFFFF"
         }
       ]
     }
     ```

    - 通过系统资源实现

     开发者可直接使用的[系统预置资源](../cj-start/start/cj-ide-resource-categories-and-access.md#系统资源)，即分层参数，同一资源ID在设备类型、深浅色等不同配置下有不同的取值。通过使用系统资源，不同的开发者可以开发出具有相同视觉风格的应用，不需要自定义两份颜色资源，在深浅色模式下也会自动切换成不同的颜色值。例如，开发者可调用系统资源中的文本主要配色来定义应用内文本颜色。

     ```cangjie
     Text('使用系统定义配色')
       .fontColor(@r(sys.color.ohos_id_color_text_primary))
     ```

2. 图片资源适配

    采用资源限定词目录的方式。参照颜色适配的方法，需要将深色模式下对应的同名图片放到 dark/media 目录下，再通过$r的方式加载图片资源的key值，系统做深浅色模式切换时，会自动加载对应资源文件中的value值。

    对于 SVG 格式的一些简单图标，可以使用[fillColor](./cj-graphics-display.md#显示矢量图)属性配合系统资源改变图片的绘制颜色。不通过两套图片资源的方式，也可以实现深浅色模式适配。

    ```cangjie
    Image(@r(app.media.pic_svg))
      .width(50)
      .fillColor(@r(sys.color.ohos_id_color_text_primary))
    ```

3. Web组件适配

    Web组件支持对前端页面进行深色模式配置，可参见[Web组件深色模式](../web/cj-web-set-dark-mode.md)进行相关配置。
