/**
 * Created on 2025/8/2
 */
package ohos_app_cangjie_entry.components.SimpleLayout

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos_app_cangjie_entry.utils.{interColor}
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.utils.countSubWidth


let FONT_COLOR_ARR: Array<UInt32> = [0xffffff, 0x758a8a]
let BACKGROUND_COLOR_ARR: Array<UInt32> = [0xeff1f5, 0x758a8a]


@Component
public class RowExampSingleBand {
    let blockSize: Int64 = 80

    @Builder
    public func item(src: CJResource) {
        Image(src).width(blockSize.lpx).height(blockSize.lpx)
    }

    func build() {
        Row(20.lpx) {
            item(@r(app.media.avatar_0))
            item(@r(app.media.avatar_1))
            item(@r(app.media.avatar_2))
            item(@r(app.media.avatar_3))
            item(@r(app.media.avatar_4))
            item(@r(app.media.avatar_5))

            Row() {
                Text("99+").fontSize(28.lpx).fontColor(0xffffff).textAlign(TextAlign.Center).width(100.percent)
                    .height(100.percent).backgroundColor(0x015a58).borderRadius(5.lpx)
            }.width(blockSize.lpx).height(blockSize.lpx)
        }.width(100.percent).margin(bottom: 20.lpx)
    }
}

@Component
private class RowExampAverageItem {
    @Prop var num: Int64  // 方块的数量
    @Prop var width: Int64  // 整块面板的总宽度
    @State var blockWidth: Int64 = 0

    protected func aboutToAppear() {
        // 在build运行前执行
        blockWidth = countSubWidth(width, 0, num)
    }

    func build() {
        Row() {
            ForEach(Array<Int64>(num, { _ => 0 }), itemGeneratorFunc: { _: Int64, index: Int64 =>
                Row() {
                    Text("${blockWidth}").fontColor(interColor(index + 1, FONT_COLOR_ARR))
                        .width(100.percent).height(100.percent).textAlign(TextAlign.Center)
                }.width(blockWidth.lpx).height(60.lpx)
                    .backgroundColor(interColor(index, BACKGROUND_COLOR_ARR))
            })
        }
    }
}

@Component
public class RowExampAverageBand {
    @Prop var width: Int64  // 整块面板的总宽度

    func build() {
        Column(10.lpx) {
            RowExampAverageItem(num: 1, width: width)
            RowExampAverageItem(num: 2, width: width)
            RowExampAverageItem(num: 3, width: width)
            RowExampAverageItem(num: 4, width: width)
            RowExampAverageItem(num: 5, width: width)
            RowExampAverageItem(num: 6, width: width)
        }.margin(bottom: 20.lpx)
    }
}
