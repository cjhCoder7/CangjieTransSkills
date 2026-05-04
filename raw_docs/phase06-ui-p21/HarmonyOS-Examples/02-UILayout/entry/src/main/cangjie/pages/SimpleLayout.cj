/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import ohos_app_cangjie_entry.components.global.{PageHeader, SectionTitle, DescriptionText}
import ohos_app_cangjie_entry.utils.{countInnerWidth, interColor}
import ohos_app_cangjie_entry.components.SimpleLayout.{RowExampAverageBand, RowExampSingleBand, ColumnExampSingleBand, RowSplitExampBand, BillExampBand, IntroRecBand, ColumnSplitExampBand}


@Entry
@Component
class SimpleLayoutView {
    /**
    * 简单布局主要涉及四个容器组件 Row, RowSplit, Column 和 ColumnSplit
    * 对于这四个组件, 你可以把它们都当作HTML里的<div>, 它们的呈现结果就是一个矩形方块
    *
    * Row 表示沿水平方向布局的容器, 内部的子组件会沿**水平**分布
    * RowSplit 和 Row 是类似的, 区别在于:
    *   1. 它必须要有子组件
    *   2. 它会在子组件之间添加显式的分隔符(一条线)
    * Column 表示沿垂直方向布局的容器, 内部的子组件会沿**垂直**分布
    * ColumnSplit 和 Column 是类似的, 区别在于:
    *   1. 它必须要有子组件
    *   2. 它同样会在子组件之间添加显式的分隔符(一条线)
    */

    let contentWidth: Int64 = countInnerWidth(720, 20)  // designWidth默认值为720,是整个屏幕的宽度,单位lpx
    let scroller: Scroller = Scroller()  // 外层垂直滚动

    func build() {
        // 最外层用一个Column进行包裹,内部的内容自上而下垂直分布
        Column() {
            PageHeader(title: "块 / 矩形 / 水平布局 / 垂直布局")

            Scroll(scroller) {
                Column() {
                    SectionTitle(title: "简介")
                    DescriptionText(content: "Row RowSplit Column ColumnSplit 本体都是一个矩形方块, 相当于HTML中的div。")
                    IntroRecBand(width: contentWidth)

                    SectionTitle(title: "Row")
                    DescriptionText(content: "Row 内的子元素呈水平分布。")
                    RowExampSingleBand()
                    DescriptionText(content: "平均分布(数字为宽度, 单位lpx)。")
                    RowExampAverageBand(width: contentWidth)

                    SectionTitle(title: "Column")
                    DescriptionText(content: "Column内的子元素呈垂直分布。")
                    ColumnExampSingleBand(width: contentWidth)

                    SectionTitle(title: "RowSplit")
                    DescriptionText(content: "RowSplit 相比 Row, 支持子组件 宽度 动态变化。")
                    RowSplitExampBand(width: contentWidth)
                    DescriptionText(content: "按住两个方块的边界处可以 左右 拖动, 以调整方块子组件的宽度, 数字是其宽度,单位px。")

                    SectionTitle(title: "ColumnSplit")
                    DescriptionText(content: "RowSplit 相比 Row, 支持子组件 高度 动态变化。")
                    ColumnSplitExampBand(width: contentWidth)
                    DescriptionText(content: "按住两个方块的边界处可以 上下 拖动, 以调整方块子组件的高度, 数字是其高度,单位px。")

                    SectionTitle(title: "Examples")
                    Column(30.lpx) {
                        BillExampBand()
                    }
                }.padding(left: viewPadX.lpx, right: viewPadX.lpx, top: viewPadTop.lpx)
            }.padding(bottom: 100.lpx).scrollable(ScrollDirection.Vertical)
        }
    }
}


