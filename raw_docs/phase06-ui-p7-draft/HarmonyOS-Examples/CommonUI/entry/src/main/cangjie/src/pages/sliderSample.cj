package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry
@Component
class SliderView {
  @State var outSetValue: Float64 = 40.0
  @State var inSetValue: Float64 = 40.0
  @State var outVerticalSetValue: Float64 = 40.0
  @State var inVerticalSetValue: Float64 = 40.0

  func build() {
    Column(5) {
      Text("slider out set").fontSize(15).width(90.percent)
      Row {
        Slider(
          value: this.outSetValue,
          min: 0.0,
          max: 100.0,
          step: 1.0,
          style: SliderStyle.OutSet
        )
        .blockColor(Color.BLUE)
        .trackColor(Color.GRAY)
        .selectedColor(Color.BLUE)
        .showSteps(true)
        .showTips(true)
        .onChange({value: Float64, mode: SliderChangeMode =>
          this.outSetValue = value
          nativeLog("value: ${value} mode: ")
        })
        Text("${this.outSetValue}").fontSize(16)
      }
      .padding(top: 50 )
      .width(80.percent)

      Text("slider in set").fontSize(15).width(90.percent)
      Row() {
        Slider(
          value: this.inSetValue,
          min: 0.0,
          max: 100.0,
          step: 1.0,
          style: SliderStyle.InSet
        )
        .blockColor(0xCCCCCC)
        .trackColor(Color.BLACK)
        .selectedColor(0xCCCCCC)
        .showSteps(false)
        .showTips(false)
        .onChange({value: Float64, mode: SliderChangeMode =>
          this.inSetValue = value
          nativeLog("value: ${value} mode: ")
        })
        Text("${this.inSetValue}").fontSize(16)
      }
      .width(80.percent)

      Row() {
        Column() {
          Text("slider out direction set").fontSize(15).width(50.percent)
          Slider(
            value: this.outVerticalSetValue,
            min: 0.0,
            max: 100.0,
            step: 1.0,
            style: SliderStyle.OutSet,
            direction: Axis.Vertical
          )
          .blockColor(Color.BLUE)
          .trackColor(Color.GRAY)
          .selectedColor(Color.BLUE)
          .showSteps(true)
          .showTips(true)
          .onChange({value: Float64, mode: SliderChangeMode =>
            this.outVerticalSetValue = value
            nativeLog("value: ${value} mode: ")
          }).height(60.percent)
          Text("${this.outVerticalSetValue}").fontSize(16)
        }.width(50.percent).height(500)

        Column() {
          Text("slider in direction set").fontSize(15).width(50.percent)
          Slider(
            value: this.inVerticalSetValue,
            min: 0.0,
            max: 100.0,
            step: 1.0,
            style: SliderStyle.InSet,
            direction: Axis.Vertical
          )
          .blockColor(0xCCCCCC)
          .trackColor(Color.BLACK)
          .selectedColor(0xCCCCCC)
          .showSteps(false)
          .showTips(false)
          .onChange({value: Float64, mode: SliderChangeMode =>
            this.inVerticalSetValue = value
            nativeLog("value: ${value} mode: ")
          }).height(60.percent)
          Text("${this.inVerticalSetValue}").fontSize(16)
        }.width(50.percent).height(500)
      }

    }.width(100.percent).margin(top: 5)
  }
}