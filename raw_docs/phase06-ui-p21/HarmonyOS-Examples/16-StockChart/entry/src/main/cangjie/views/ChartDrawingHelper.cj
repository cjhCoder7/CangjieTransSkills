/**
 * Created on 2025/8/8
 */
package ohos_app_cangjie_entry.views

import ohos.component.*
import ohos_app_cangjie_entry.models.ChartDimensions
import ohos_app_cangjie_entry.constants.StyleConstants

public class ChartDrawingHelper {
    private let ctx: CanvasRenderingContext2D
    private let dims: ChartDimensions

    public init(ctx: CanvasRenderingContext2D, dims: ChartDimensions) {
        this.ctx = ctx
        this.dims = dims
    }

    public func drawYAxisLabels(labels: Array<(text: String, y: Float64)>, align: TextAlignStyle, xOffset: Float64) {
        ctx.font(size: StyleConstants.AXIS_LABEL_FONT_SIZE, family: "sans-serif")
        ctx.fillStyle(StyleConstants.GRAY_COLOR)
        ctx.textAlign(align)

        for (label in labels) {
            ctx.fillText(label[0], xOffset, label[1])
        }
    }

    public func drawXAxisLabels(labels: Array<(text: String, x: Float64, align: TextAlignStyle)>, y: Float64) {
        ctx.font(size: StyleConstants.AXIS_LABEL_FONT_SIZE, family: "sans-serif")
        ctx.fillStyle(StyleConstants.GRAY_COLOR)

        for (label in labels) {
            ctx.textAlign(label[2])
            ctx.fillText(label[0], label[1], y)
        }
    }

    public func prepareBackground(rows: Int64, cols: Int64) {
        let width = dims.paddingLeft + dims.chartWidth + dims.paddingRight
        let height = dims.paddingTop + dims.chartHeight + dims.paddingBottom
        ctx.clearRect(0, 0, Int64(width) + 1, Int64(height) + 1)
        ctx.drawGrid(dims, rows, cols)
    }
}