# CanvasPattern

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

一个Object对象，使用createPattern方法创建，通过指定图像和重复方式创建图片填充的模板。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class CanvasPattern

```cangjie
public class CanvasPattern {}
```

**功能：**  一个Object对象，使用createPattern方法创建，通过指定图像和重复方式创建图片填充的模板。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func setTransform(?Matrix2D)

```cangjie
public func setTransform(transform: ?Matrix2D): Unit
```

**功能：** 使用Matrix2D对象作为参数，对当前CanvasPattern进行矩阵变换。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|transform|?[Matrix2D](./cj-canvas-drawing-matrix2d.md#class-matrix2d)|是|-|2D 变换矩阵。|