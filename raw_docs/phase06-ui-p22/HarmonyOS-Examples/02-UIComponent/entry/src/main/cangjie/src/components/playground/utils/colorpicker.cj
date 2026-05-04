/**
 * Created on 2024/8/1
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.base.*
import ohos.state_manage.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.utils.*
import std.sync.Timer
import std.time.Duration

@Component
public class SwatchBlock {
  // 颜色
  @Prop var color: UInt32

  func build() {
    Row().size(width: 40, height: 40)
      .backgroundColor(color)
      .borderRadius(10.fp)
  }
}

@Component
public class ColorBand {
  // 颜色
  @Link var color: UInt32

  // 标题
  @Prop var title: String

  // 高度
  @State var height: Int64 = 0

  // 是否显示
  @State var visible: Bool = false

  func onVisible() {
    this.visible = !this.visible
    if (this.visible) {
      this.height = 220
    } else {
      this.height = 0
    }
  }

  func build() {
    Column(BAR_INNER_GRID_SIZE) {
      Row() {
        labelText(title)

        SwatchBlock(color: color)
      }.alignItems(VerticalAlign.Center)
      .onClick({ e: ClickEvent => this.onVisible() })

      Column() {
        ColorPicker(selectedColor: color, visible: visible)
      }.animationStart(animation)
      .height(height)
      .animationEnd()
    }.width(100.percent)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
public class ColorPicker {
  // 当前的颜色
  @Link var selectedColor: UInt32

  // 高度
  @Prop @Watch[onVisibleChange] var visible: Bool

  @State var visibility: Visibility = Visibility.None

  @State var opacity: Float64 = 0.0

  var timer: Option<Timer> = None

  func onVisibleChange() {
    if (this.visible) {
      this.timer = Timer.once(Duration.second * 0.8, { =>
            this.visibility = Visibility.Visible
            this.opacity = 1.0
          })
    } else {
      if (this.timer.isSome()) {
        this.timer.getOrThrow().cancel()
      }
      this.opacity = 0.0
      this.visibility = Visibility.None
    }
  }

  // 色块
  @Builder
  func createSwatchBlock(color: UInt32, backgroundColor!: UInt32 = COLOR_LIGHT) {
    Row().animationStart(colorPickerAnimation)
    .size(width: 50, height: 50)
    .backgroundColor(color)
    .borderRadius(10.fp)
    .borderWidth(2)
    .borderColor(backgroundColor)
    .opacity(opacity)
    .animationEnd()
    .onClick({
      e => selectedColor = color
    })
  }

  func build() {
    Column(10) {
      Row() {
        createSwatchBlock(COLOR_BLUE)
        createSwatchBlock(COLOR_INDIGO)
        createSwatchBlock(COLOR_PURPLE)
        createSwatchBlock(COLOR_PINK)
        createSwatchBlock(COLOR_RED)
      }.width(100.percent)
      .justifyContent(FlexAlign.SpaceEvenly)

      Row() {
        createSwatchBlock(COLOR_ORANGE)
        createSwatchBlock(COLOR_YELLOW)
        createSwatchBlock(COLOR_GREEN)
        createSwatchBlock(COLOR_TEAL)
        createSwatchBlock(COLOR_CYAN)
      }.width(100.percent)
      .justifyContent(FlexAlign.SpaceEvenly)

      Row() {
        createSwatchBlock(COLOR_BLACK)
        createSwatchBlock(COLOR_GRAY)
        createSwatchBlock(COLOR_GRAY_DARK)
        createSwatchBlock(COLOR_WHITE,backgroundColor: COLOR_GRAY_300)
        createSwatchBlock(COLOR_LIGHT,backgroundColor: COLOR_GRAY_300)
      }.width(100.percent)
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width(100.percent)
    .padding(20)
    .borderRadius(10).borderWidth(2).borderColor(0xdee2e6)
    .visibility(visibility)
  }
}