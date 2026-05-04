package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

const YLH = 0x24271Eu32

@Entry
@Component
class SwiperView {
    var ctr1: SwiperController = SwiperController()
    var ctr2: SwiperController = SwiperController()

    func build() {
        Column {
            Swiper(ctr1) {
                Text("铜器青").size(width: 100.percent, height: 500.px).backgroundColor(0x283F3E).fontColor(Color.WHITE)
                Text("藏花红").size(width: 100.percent, height: 500.px).backgroundColor(0xE9A182).fontColor(Color.WHITE)
                Text("淡土棕").size(width: 100.percent, height: 500.px).backgroundColor(0x824E40).fontColor(Color.WHITE)
            }.autoPlay(true).vertical(true).width(100.percent).margin(bottom: 20, top: 100)
            .onChange({
                index => nativeLog("Swiper onChanged." + index.toString())
            })

            Row {
                Button("上一页").margin(right: 100).backgroundColor(YLH).fontColor(Color.WHITE)
                .onClick({
                    evt => ctr1.showPrevious()
                })
                Button("下一页").backgroundColor(YLH).fontColor(Color.WHITE)
                .onClick({
                    evt => ctr1.showNext()
                })
            }

            Swiper(ctr2) {
                Text("长石灰").size(width: 100.percent, height: 500.px).backgroundColor(0x313534).fontColor(Color.WHITE)
                Text("金鸢黄").size(width: 100.percent, height: 500.px).backgroundColor(0xF0A72E).fontColor(Color.WHITE)
                Text("淡玫灰").size(width: 100.percent, height: 500.px).backgroundColor(0xAE7F77).fontColor(Color.WHITE)
            }.autoPlay(true).duration(500).width(100.percent).margin(bottom: 20, top: 200)
            .onChange({
                index => nativeLog("Swiper onChanged." + index.toString())
            })

            Row {
                Button("上一页").margin(right: 100).backgroundColor(YLH).fontColor(Color.WHITE)
                .onClick({
                    evt => ctr2.showPrevious()
                })
                Button("下一页").backgroundColor(YLH).fontColor(Color.WHITE)
                .onClick({
                    evt => ctr2.showNext()
                })
            }
        }.width(100.percent)
    }
}