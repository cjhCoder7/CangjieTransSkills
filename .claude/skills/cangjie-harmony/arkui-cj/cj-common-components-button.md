# 按钮（Button）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Button是按钮组件，通常用于响应用户的点击操作，其类型包括胶囊按钮、圆形按钮、普通按钮。Button作为容器使用时可以通过添加子组件实现包含文字、图片等元素的按钮。具体用法请参见[Button](../reference/arkui-cj/cj-button-picker-button.md)。

## 创建按钮

Button通过调用接口来创建，接口调用有以下两种形式：

- 通过label和[ButtonOptions](../reference/arkui-cj/cj-button-picker-button.md#class-buttonoptions)创建不包含子组件的按钮。以ButtonOptions中的shape和stateEffect为例。

  ```cangjie
  init(label: String, options: ButtonOptions)
  ```

  其中，label用来设置按钮文字，type用于设置Button类型，stateEffect属性设置Button是否开启点击效果。

  <!-- code_check_manual -->

  ```cangjie
  Button('Ok', ButtonOptions(shape: ButtonType.Normal, stateEffect: true))
      .borderRadius(8)
      .backgroundColor(0x317aff)
      .width(90)
      .height(40)
  ```

  ![Button](figures/Button.png)

- 通过[ButtonOptions](../reference/arkui-cj/cj-button-picker-button.md#class-buttonoptions)创建包含子组件的按钮。以ButtonOptions中的shape和stateEffect为例。

  ```cangjie
  init(options: ButtonOptions, content: () -> Unit)
  ```

  只支持包含一个子组件，子组件可以是基础组件或者容器组件。

  <!-- code_check_manual -->

  ```cangjie
  Button(ButtonOptions(shape: ButtonType.Normal, stateEffect: true)){
      Row() {
          Image(@r(app.media.loading)).width(20).height(40).margin(left: 12)
          Text('loading').fontSize(12).fontColor(0xffffff).margin(left: 5, right: 12)
      }.alignItems(VerticalAlign.Center)
  }
  .borderRadius(8)
  .backgroundColor(0x317aff)
  .width(90)
  .height(40)
  ```

  ![Button2](figures/Button2.png)

## 设置按钮类型

Button有四种可选类型，分别为胶囊类型（Capsule）、圆形按钮（Circle）、普通按钮（Normal）和圆角矩形按钮（ROUNDED_RECTANGLE），通过shape进行设置。

- 胶囊按钮（默认类型）。

  此类型按钮的圆角自动设置为高度的一半，不支持通过borderRadius属性重新设置圆角。

  <!-- code_check_manual -->

  ```cangjie
  Button('Disable', ButtonOptions(shape: ButtonType.Capsule, stateEffect: false))
      .backgroundColor(0x317aff)
      .width(90)
      .height(40)
  ```

  ![Button3](figures/Button3.png)

- 圆形按钮。

  此类型按钮为圆形，不支持通过borderRadius属性重新设置圆角。

  <!-- code_check_manual -->

  ```cangjie
  Button('Circle', ButtonOptions(shape: ButtonType.Circle, stateEffect: false))
      .backgroundColor(0x317aff)
      .width(90)
      .height(90)
  ```

  ![Button4](figures/Button4.png)

- 普通按钮。

  此类型的按钮默认圆角为0，支持通过[borderRadius](../reference/arkui-cj/cj-common-types.md#class-borderradiuses)属性重新设置圆角。

  <!-- code_check_manual -->

  ```cangjie
  Button('Ok', ButtonOptions(shape: ButtonType.Normal, stateEffect: true))
      .borderRadius(8)
      .backgroundColor(0x317aff)
      .width(90)
      .height(40)
  ```

  ![Button5](figures/Button5.png)

## 自定义样式

- 设置边框弧度。

  使用通用属性来自定义按钮样式。例如通过[borderRadius](../reference/arkui-cj/cj-common-types.md#class-borderradiuses)属性设置按钮的边框弧度。

  <!-- code_check_manual -->

  ```cangjie
  Button('circle border', ButtonOptions(shape: ButtonType.Normal))
      .borderRadius(20)
      .height(40)
  ```

  ![Button6](figures/Button6.png)

- 设置文本样式。

  通过添加文本样式设置按钮文本的展示样式。

  <!-- code_check_manual -->

  ```cangjie
  Button('font style', ButtonOptions(shape: ButtonType.Normal))
      .fontSize(20)
      .fontColor(0xffffc0cb)
  ```

  ![Button7](figures/Button7.png)

- 设置背景颜色。

  添加[backgroundColor](../reference/arkui-cj/cj-universal-attribute-background.md#func-backgroundcolorresourcecolor)属性设置按钮的背景颜色。

  <!-- code_check_manual -->

  ```cangjie
  Button('background color').backgroundColor(0xF55A42)
  ```

  ![Button8](figures/Button8.png)

- 创建功能型按钮。

  为删除操作创建一个按钮。

  <!-- code_check_manual -->

  ```cangjie
  Button(ButtonOptions(shape: ButtonType.Circle, stateEffect: true)) {
      Image(@r(app.media.ic_public_delete_filled))
        .width(30)
        .height(30)
  }
  .width(55)
  .height(55)
  .margin(left:20)
  .backgroundColor(0xF55A42)
  ```

  ![Button9](figures/Button9.png)

## 添加事件

Button组件通常用于触发某些操作，可以绑定[onClick](../reference/arkui-cj/cj-universal-event-click.md#func-onclickclickevent---unit)事件来响应点击操作后的自定义行为。

<!-- code_check_manual -->

```cangjie
  Button('Ok', ButtonOptions(shape: ButtonType.Normal, stateEffect: true))
      .onClick({ evt =>
      Hilog.info(0, '', 'Button onClick')
  })
```

## 场景示例

- 用于提交表单。

  在用户登录/注册页面，使用按钮进行登录或注册操作。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              TextInput(placeholder: 'input your username')
                .margin(top: 20)
              TextInput(placeholder: 'input your password')
                .margin(top: 20)
              Button('Register')
                .width(300)
                .margin(top: 20)
                .onClick({ evt =>
                    // 需要执行的操作
                    })
          }
          .padding(20)
      }
  }
  ```

  ![Button10](figures/Button10.png)

- 悬浮按钮。

  在可以滑动的界面，滑动时按钮始终保持悬浮状态。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*
  import kit.LocalizationKit.AppResource
  import ohos.resource.__GenerateResource__

  @Entry
  @Component
  class EntryView {
      private var arr: Array<Int64> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
      func build() {
          Stack() {
              List(space: 20, initialIndex: 0) {
                  ForEach(
                      this.arr,
                      itemGeneratorFunc: {
                          item: Int64, _: Int64 => ListItem() {
                              Text("${item}")
                                  .width(100.percent)
                                  .height(100)
                                  .fontSize(16)
                                  .textAlign(TextAlign.Center)
                                  .borderRadius(10)
                                  .backgroundColor(0xFFFFFF)
                          }
                      }
                  )
              }.width(90.percent)

              Button() {
                  Image(@r(app.media.startIcon))
                      .width(50)
                      .height(50)
              }
              .shape(ButtonType.Circle)
              .width(60)
              .height(60)
              .position(x: 80.percent, y: 600)
              .shadow(radius: 10.0)
              .onClick ({
                  evt =>
                  // 需要执行的操作
              })
          }
          .width(100.percent)
          .height(100.percent)
          .backgroundColor(0xDCDCDC)
          .padding(top: 5)
      }
  }
  ```

  ![floating_button](figures/floating_button.gif)
