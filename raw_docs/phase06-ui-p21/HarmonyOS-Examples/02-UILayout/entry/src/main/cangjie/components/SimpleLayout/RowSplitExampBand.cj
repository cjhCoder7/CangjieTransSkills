/**
 * Created on 2025/8/4
 */
package ohos_app_cangjie_entry.components.SimpleLayout

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.utils.formatFloat64


@Component
public class RowSplitExampItem {
    @Prop var initialWidth: Int64  // 初始宽度
    @Prop var bgColor: UInt32  // 背景颜色
    @Prop var fontColor: UInt32  // 字体颜色
    @State var width: Float64 = 0.0  // 实际的宽度(单位px)

    protected func aboutToAppear() {
        width = lpx2px(initialWidth.lpx).getOrDefault({ => 0.0.px}).value
    }

    func build() {
        Row() {
            Text("${formatFloat64(width)}").fontColor(fontColor).padding(left: 30.lpx)
        }.height(100.lpx).width(initialWidth.lpx)
        .backgroundColor(bgColor).constraintSize(minWidth: 150.lpx)
        .onAreaChange({ old, new => width = new.width })
    }
}


@Component
public class RowSplitExampBand {
    @Prop var width: Int64  // RowSplit示例面板的总宽度

    let rightItemWidth: Int64 = 200

    func build() {
        RowSplit() {
            RowSplitExampItem(initialWidth: (width - rightItemWidth), bgColor: 0x33384f, fontColor: 0xffffff)
            RowSplitExampItem(initialWidth: rightItemWidth, bgColor: 0xeaebf1, fontColor: 0x333333)
        }.width(width.lpx).resizeable(true)
    }
}