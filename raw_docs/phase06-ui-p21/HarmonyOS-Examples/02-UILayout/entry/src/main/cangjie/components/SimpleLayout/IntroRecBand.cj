/**
 * Created on 2025/8/3
 */
package ohos_app_cangjie_entry.components.SimpleLayout

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.utils.{countSubWidth}


let REC_HEIGHT = 100


@Component
class RecInfo {
    @Prop var content: String
    @Prop var color: UInt32

    func build() {
        Text(content).width(100.percent).fontSize(26.lpx).fontColor(color)
            .lineHeight(REC_HEIGHT.lpx).fontWeight(FontWeight.W300).padding(left: 10.lpx)
    }
}


@Component
public class IntroRecBand {
    @Prop var width: Int64  // 介绍面板的总宽度
    @State var recWidth: Int64 = 0  // 简介部分矩形方块的宽度

    let space: Int64 = 10  // 简介部分矩形方块之间的间隔宽度

    protected func aboutToAppear() {
        recWidth = countSubWidth(width, space, 2)
    }

    func build() {
        Column(space.lpx) {
            Row(space.lpx) {
                Row() {
                    RecInfo(content: "Row", color: 0xffffff)
                }.width(recWidth.lpx).height(REC_HEIGHT.lpx).backgroundColor(0x758a8a)

                Column() {
                    RecInfo(content: "Column", color: 0x000000)
                }.width(recWidth.lpx).height(REC_HEIGHT.lpx).backgroundColor(0xf2f2f2)
            }

            Row(space.lpx) {
                RowSplit() {
                    RecInfo(content: "RowSplit", color: 0x000000)
                }.width(recWidth.lpx).height(REC_HEIGHT.lpx).border(width: 1.lpx, color: Color(0x000000))

                ColumnSplit() {
                    RecInfo(content: "ColumnSplit", color: 0xffffff)
                }.width(recWidth.lpx).height(REC_HEIGHT.lpx).backgroundColor(0x38404b)
            }
        }
    }
}