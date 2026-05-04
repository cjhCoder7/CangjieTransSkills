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
public class ColumnSplitExampItem {
    @Prop var initialHeight: Int64  // 各个子组件的初始高度,单位lpx
    @Prop var bgColor: UInt32  // 背景颜色
    @Prop var fontColor: UInt32  // 字体颜色
    @State var height: Float64 = 0.0  // 实际的高度(单位px)

    protected func aboutToAppear() {
        height = lpx2px(initialHeight.lpx).getOrDefault({ => 0.0.px }).value
    }
    
    func build() {
        Column() {
            Text("${formatFloat64(height)}").fontColor(fontColor).padding(top: 30.lpx)
        }.width(100.percent).height(initialHeight.lpx)
        .backgroundColor(bgColor).constraintSize(minHeight: 100.lpx)
        .onAreaChange({ old, new => height = new.height })
    }
}

@Component
public class ColumnSplitExampBand {
    @Prop var width: Int64  // RowColumn示例面板的总宽度

    func build() {
        ColumnSplit() {
            ColumnSplitExampItem(initialHeight: 300, bgColor: 0x33384f, fontColor: 0xffffff)
            ColumnSplitExampItem(initialHeight: 300, bgColor: 0xeaebf1, fontColor: 0x333333)
            ColumnSplitExampItem(initialHeight: 300, bgColor: 0xceb87b, fontColor: 0x3b4134)
        }.width(width.lpx).resizeable(true)
    }
}