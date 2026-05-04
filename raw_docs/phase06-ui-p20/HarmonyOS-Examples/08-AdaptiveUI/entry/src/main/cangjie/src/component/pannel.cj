/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.component

import ohos.state_macro_manage.*

// 播放控制组件
@Component
public class Pannel {
    @Link var value: Float64
    let controlIcons: Array<CJResource> = [
        @r(app.media.backward_end_fill),
        @r(app.media.pause_round_triangle_fill),
        @r(app.media.forward_end_fill)
    ]

    func build() {
        Column {
            Row(5) {
                Slider(min: 0.0, max: MUSIC_TIME, step: 1.0, value: this.value)
                    .width(90.percent)
                    .onChange { value: Float64, _: SliderChangeMode =>
                        this.value = value
                    }
                Text(Int64(this.value).toString()).fontSize(12.fp)
            }.width(90.percent)
            Row(15) {
                ForEach(controlIcons, { item: CJResource, _: Int64 =>
                    Button {
                        Image(item).size(width: 32, height: 32)
                    }
                    .backgroundColor(Color.TRANSPARENT).borderRadius(15)
                    .shape(ShapeType.Normal).padding(5)
                })
            }
        }
        .height(10.percent)
        .width(100.percent)
        .justifyContent(FlexAlign.Center)
    }
}