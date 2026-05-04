/**
 * Created on 2025-08-20
 */
package ohos_app_cangjie_entry.view

import ohos.image.Component
import ohos.component.*
import ohos_app_cangjie_entry.common.*
import ohos.base.*
import ohos.state_manage.*
import cj_res_entry.app
import ohos.resource_manager.*
import ohos.state_macro_manage.*
import std.sync.*
import std.time.{Duration, DurationExtension}
import std.format.*

@Component
public class PanelComponent {
    private var mode = 0
    private  var title: CJResource
    @State var outSetValue: Float32 = 0.0
    @State var min: Float64 = 0.0
    @State var max: Float64 = 0.0
    @State var step: Float64 = 0.0
    private var callback:(value:Float64, mode: SliderChangeMode)-> Unit;


    public func build(){
        Column(){
            Text(this.title)
            .width(Constants.PANEL_WIDTH)
            .padding( left: Constants.TITLE_PADDING )
            .fontSize(Constants.FONT_SIZE)
            .fontWeight(FontWeight.Medium)
            .fontColor(@r(app.color.font_color))
            .margin( left: Constants.TITLE_MARGIN_HORIZONTAL,
                    right: Constants.TITLE_MARGIN_HORIZONTAL )
            Column() {
                Text(this.outSetValue.format(".1").toString())
                  .fontSize(Constants.FONT_SIZE)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(@r(app.color.font_color))
                  .margin( bottom: Constants.SPEED_MARGIN_BOTTOM )
                Row() {
                if (this.mode == SliderMode.SPEED) {
                    Image(@rawfile('speedLow.png'))
                      .objectFit(ImageFit.Contain)
                      .height(Constants.PANEL_IMAGE_HEIGHT)
                      .width(Constants.PANEL_IMAGE_WIDTH)
                  } else {
                    Text(Constants.PANEL_HOLDER)
                      .fontSize(Constants.PANEL_FONT_SIZE)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(@r(app.color.font_color))
                      .margin( bottom: Constants.SPEED_MARGIN_BOTTOM )
                  }

                  Slider(min:this.min, max: this.max, step:this.step, style: SliderStyle.InSet)
                    .layoutWeight(Constants.LAYOUT_WEIGHT)
                    .selectedColor(Constants.SLIDER_SKIN)
                    .onChange({value: Float64, mode: SliderChangeMode =>
                        this.outSetValue=Float32(value)
                        this.callback(value, mode)
                    })
                    .margin( left: Constants.SLIDER_MARGIN_HORIZONTAL,
                      right: Constants.SLIDER_MARGIN_HORIZONTAL )

                  if (this.mode == SliderMode.SPEED) {
                    Image(@rawfile('speed.png'))
                      .objectFit(ImageFit.Contain)
                      .height(Constants.PANEL_IMAGE_BIG_HEIGHT)
                      .width(Constants.PANEL_IMAGE_BIG_WIDTH)
                      .height(Constants.PANEL_IMAGE_BIG_HEIGHT)
                      .width(Constants.PANEL_IMAGE_BIG_WIDTH)
                  } else {
                    Text(Constants.PANEL_HOLDER)
                      .fontSize(Constants.PANEL_END_FONT_SIZE)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(@r(app.color.font_color))
                      .margin( bottom: Constants.SPEED_MARGIN_BOTTOM )
                    }
                }
            }.justifyContent(FlexAlign.Center)
              .backgroundColor(Color.WHITE)
              .borderRadius(Constants.PANEL_RADIUS)
              .height(Constants.PANEL_HEIGHT)
              .width(Constants.PANEL_WIDTH)
              .padding( left: Constants.PANEL_PADDING,
                right: Constants.PANEL_PADDING )
              .margin( top: Constants.PANEL_MARGIN,
                bottom: Constants.PANEL_MARGIN )
        }
        .padding( left: Constants.PANEL_PADDING,
          right: Constants.PANEL_PADDING)
        .width(Constants.PERCENTAGE_100)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
    }
}