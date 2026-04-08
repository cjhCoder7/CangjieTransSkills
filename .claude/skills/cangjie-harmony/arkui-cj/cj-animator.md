# 帧动画（ohos.animator）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

帧动画具备逐帧回调的特性，便于开发者在每一帧中处理需调整的属性。通过向应用提供onFrame逐帧回调，帧动画使开发者能够在应用的每一帧设置属性值，从而实现组件属性值变化的自然过渡，营造出动画效果。

与属性动画相比，帧动画能让开发者实时感知动画进程，即时调整UI值，具备事件即时响应和可暂停的优势，但在性能上略逊于属性动画。当属性动画能满足需求时，建议优先采用属性动画接口实现。属性动画接口请参见[实现属性动画](cj-attribute-animation-apis.md)。

|名称|实现方式|事件响应方式|可暂停|性能|
|:---|:---|:---|:---|:---|
|帧动画（ohos.animator）|开发者可每帧修改UI侧属性值，UI侧属性实时更新|实时响应|是|较差|
|属性动画|UI侧只计算动画最终状态，动画过程为渲染值在改变，UI侧一直为动画最终状态，不感知实时渲染值|按最终状态响应|否|较好|

如图所示，帧动画在动画过程中即可实时响应，而属性动画按最终状态响应。

![animator](figures/animator1.gif)

![animator](figures/animator2.gif)

## 使用帧动画实现动画效果

使用如下步骤可以创建一个简单的animator，并且在每个帧回调中打印当前插值。

1. 引入相关依赖。

    ```cangjie
    import kit.ArkUI.*
    ```

2. 创建执行动画的对象。

    <!-- code_check_manual -->

    ```cangjie
    // 创建动画的初始参数
    this.backAnimator = getUIContext.createAnimator(AnimatorOptions(
      duration: 1500,
      easing: "friction",
      delay: 0,
      fill: AnimatorFill.Forwards,
      direction: AnimatorDirection.Normal,
      iterations: 2,
      // 动画onFrame 插值首帧值
      begin: 200.0,
      // 动画onFrame 插值尾帧值
      end: 400.0
    ))
    // 设置接收到帧时回调，动画播放过程中每帧会调用onFrame回调
    this.backAnimator?.onFrame =  {  progress: Float64 =>
      Hilog.info(0,"",current value is :" + progress.toString())
    }
    ```

3. 播放动画。

    ```cangjie
    // 播放动画
    this.backAnimator?.play()
    ```

4. 动画执行完成后手动释放AnimatorResult对象。

    ```cangjie
    // 释放动画对象
    this.backAnimator = None
    ```

## 使用帧动画实现小球抛物运动

1. 引入相关依赖。

    ```cangjie
    import kit.ArkUI.*
    ```

2. 定义要做动画的组件。

    <!-- code_check_manual -->

    ```cangjie
    Button()
    .borderRadius(45.vp)
    .width(60)
    .height(60)
    .translate( x: this.translateX, y: this.translateY )
    ```

3. 在onPageShow中创建AnimatorResult对象。

    <!-- code_check_manual -->

    ```cangjie
    // 创建animatorResult对象
    protected override func onPageShow() {
      this.backAnimator = getUIContext.createAnimator(AnimatorOptions(
        duration: 4000,
        easing: "ease",
        delay: 0,
        fill: AnimatorFill.Forwards,
        direction: AnimatorDirection.Normal,
        iterations: 1,
        begin: 0.0,
        end: 200.0
      ))
      this.backAnimator?.onFrame =  {  progress: Float64 =>
        this.translateX = Int64(progress)
        if (progress > this.topWidth && this.translateY < this.bottomHeight) {
          this.translateY = Int64(pow(Float64(progress - this.topWidth), 2) * this.g)
        }
      }
      // 动画取消时执行方法
      this.backAnimator?.onCancel = { =>
        this.animatorStatus = '取消'
      }
      // 动画完成时执行方法
      this.backAnimator?.onFinish = { =>
        this.animatorStatus = '完成'
      }
      // 动画重复播放时执行方法
      this.backAnimator?.onRepeat = { =>
          Hilog.info(0,"","动画重复播放")
      }
    }
    ```

4. 定义动画播放，重置，暂停的按钮。

    <!-- code_check_manual -->

    ```cangjie
    Button('播放').onClick({ =>
      this.backAnimator?.play()
      this.animatorStatus = '播放中'
    }).width(80).height(35)
    Button("重置").onClick({ =>
      this.translateX = 0
      this.translateY = 0
    }).width(80).height(35)
    Button("暂停").onClick({ =>
      this.backAnimator?.pause()
      this.animatorStatus = '暂停'
    }).width(80).height(35)
    ```

5. 在页面隐藏或销毁的生命周期中释放动画对象，避免内存泄漏。

    <!-- code_check_manual -->

    ```cangjie
    protected override func onPageHide() {
      this.backAnimator = None
    }
    ```

完整示例如下。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import ohos.arkui.ui_context.*
import kit.ArkUI.*
import std.math.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView {
    var backAnimator: ?AnimatorResult = None
    @State
    var animatorStatus: String = '创建'
    var topWidth: Float64 = 150.0
    var bottomHeight: Int64 = 100
    var g: Float64 = 0.18
    @State
    var translateX: Int64 = 0
    @State
    var translateY: Int64 = 0
    protected override func onPageShow() {
        this.backAnimator = this.getUIContext().createAnimator(AnimatorOptions(
          duration: 4000,
          easing: "ease",
          delay: 0,
          fill: AnimatorFill.Forwards,
          direction: AnimatorDirection.Normal,
          iterations: 1,
          begin: 0.0,
          end: 200.0
        ))
        this.backAnimator?.onFrame =  {  progress: Float64 =>
          this.translateX = Int64(progress)
          if (progress > this.topWidth && this.translateY < this.bottomHeight) {
            this.translateY = Int64(pow(Float64(progress - this.topWidth), 2) * this.g)
          }
        }
        this.backAnimator?.onCancel = { =>
          this.animatorStatus = '取消'
        }
        this.backAnimator?.onFinish = { =>
          this.animatorStatus = '完成'
        }
        this.backAnimator?.onRepeat = { =>
            Hilog.info(0,"","动画重复播放")
        }
    }
    protected override func onPageHide() {
        this.backAnimator = None
    }
    func build() {
        Column() {
          Column(space:30) {
            Button('播放').onClick({ evt=>
              this.backAnimator?.play()
              this.animatorStatus = '播放中'
            }).width(80).height(35).margin(top: 20)
            Button("重置").onClick({ evt=>
              this.translateX = 0
              this.translateY = 0
            }).width(80).height(35)
            Button("暂停").onClick({ evt=>
              this.backAnimator?.pause()
              this.animatorStatus = '暂停'
            }).width(80).height(35)
          }.width(100.percent).height(25.percent)

          Stack() {
            Button()
              .borderRadius(45.vp)
              .width(60)
              .height(60)
              .translate( x: this.translateX, y: this.translateY ).margin(left: 20)
          }
          .width(100.percent)
          .height(45.percent)
          .align(Alignment.Start)

          Text("当前动画状态为:" + this.animatorStatus)
        }.width(100.percent).height(100.percent)
    }
}
```

![animator](figures/animator3.gif)
