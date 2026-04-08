# Z序控制

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

组件的Z序，设置组件的堆叠顺序。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func zIndex(?Int32)

```cangjie
func zIndex(value: ?Int32): T
```

**功能：** 设置组件的Z轴层级。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|同一容器中兄弟组件显示层级关系。zIndex值越大，显示层级越高，即zIndex值大的组件会覆盖在zIndex值小的组件上方。<br>初始值：0。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## 示例代码

### 示例1（Z序控制）

该示例演示了如何使用zIndex控制组件的堆叠顺序。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Stack() {
            Text("红色 zIndex:0")
                .width(100)
                .height(100)
                .backgroundColor(Color.Red)
                .zIndex(0)
            
            Text("绿色 zIndex:2")
                .width(100)
                .height(100)
                .backgroundColor(Color.Green)
                .zIndex(2)
                .offset(x: 20.vp, y: 20.vp)
            
            Text("蓝色 zIndex:1")
                .width(100)
                .height(100)
                .backgroundColor(Color.Blue)
                .zIndex(1)
                .offset(x: 40.vp, y: 40.vp)
        }
        .width(100.percent)
        .height(100.percent)
    }
}
```

![zorder](./figures/zorder.PNG)
