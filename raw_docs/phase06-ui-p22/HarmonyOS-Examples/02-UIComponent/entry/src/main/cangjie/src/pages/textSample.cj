package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import ohos_app_cangjie_entry.components.*
import ohos_app_cangjie_entry.components.playground.font.*
import ohos_app_cangjie_entry.components.playground.utils.*
import ohos_app_cangjie_entry.utils.*

@Entry
@Component
class TextView {
  // 字体大小
  @State var fontSize: Int64 = 16

  // 字体颜色
  @State var fontColor: UInt32 = 0x000000

  // 字重
  @State var fontWeight: FontWeight = FontWeight.Normal

  // 行高
  @State var lineHeight: Int64 = 24

  // 字体对齐方式
  @State var textAlign: TextAlign = TextAlign.Center

  // 字体装饰方式
  @State var decorationType: TextDecorationType = TextDecorationType.None

  // 字体装饰颜色
  @State var decorationColor: UInt32 = 0xffffff

  // 字体的大小写
  @State var textCase: TextCase = TextCase.Normal

  // 字体的样式
  @State var fontStyle: FontStyle = FontStyle.Normal

  func build() {
    Scroll() {
      Column(SECTION_EXTERNAL_SPACE) {
        PageTitle(content: "Text")

        PageDescription(content: "Text 组件主要用来呈现一串文本。Text 组件提供了一系列接口来控制，包括对齐、换行、加粗等")

        Column(SECTION_INTERNAL_SPACE) {
          SectionTitle(content: "Playground")

          Column() {
            Text("Hello Cangjie").fontSize(fontSize).fontColor(fontColor)
            .fontWeight(fontWeight).textAlign(textAlign)
            .lineHeight(lineHeight)
            .width(100.percent)
            .decoration(decorationType: decorationType, color: decorationColor)
            .textCase(textCase)
            .fontStyle(fontStyle)
          }.codeCard().playgroundCard()

           Scroll() {
            Column(BAR_OUTER_GRID_SIZE) {
              SliderBar(
                value: fontSize,
                sliderParams: SliderParams(14.0, 60.0, 1.0),
                title: "FontSize"
              )

              ColorBand(
                color: fontColor,
                title: 'FontColor'
              )

              FontWeightBar(fontWeight: fontWeight)

              SliderBar(
                value: lineHeight,
                sliderParams: SliderParams(24.0, 72.0, 1.0),
                title: "LineHeight"
              )

              TextAlignBar(textAlign: textAlign)

              TextDecorationBar(
                decorationType: decorationType,
                decorationColor: decorationColor
              )

              TextCaseBar(textCase: textCase)

              FontStyleBar(fontStyle: fontStyle)
            }
           }.playgound()
          .height(600)
        }.section()
      }.pageContainer()
    }
  }
}
