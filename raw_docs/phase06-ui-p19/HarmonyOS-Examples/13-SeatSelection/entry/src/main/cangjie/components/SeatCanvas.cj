/**
 * Created on 2025/7/22
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.view_model.SeatSelection

@Component
public class SeatCanvas {
    @LocalStorageLink['viewModel']
    var viewModel: SeatSelection = SeatSelection()

    private let context = CanvasRenderingContext2D(RenderingContextSettings(antialias: true))

    private let RECT_SIZE = StyleConstants.MATRIX_RECT_SIZE
    private let RECT_SPACE = StyleConstants.MATRIX_SPACE
    
    protected override func aboutToAppear() {
        viewModel.initSeatState()
        viewModel.setRedrawCallback { seatInfo, seatType =>
            this.drawSeat(seatInfo.row, seatInfo.col, seatType)
        }
    }

    func build() {
        Canvas(this.context)
            .margin(left: 20)
            .backgroundColor(StyleConstants.BACKGROUND_COLOR)
            .onClick { evt => this.viewModel.handleCanvasClick(evt) }
            .height(DataConstants.SEATS.size * (RECT_SIZE + RECT_SPACE) - RECT_SPACE + (StyleConstants.CANVAS_PADDING * 2))
            .width(DataConstants.SEATS[0].size * (RECT_SIZE + RECT_SPACE) - RECT_SPACE + (StyleConstants.CANVAS_PADDING * 2))
            .onReady {
                this.drawAllSeats()
            }
    }

    private func drawAllSeats() {
        this.context.clearRect(0, 0, 1000, 1000)

        for (x in 0..this.viewModel.seatsState.size) {
            for (y in 0..this.viewModel.seatsState[x].size) {
                this.drawSeat(x, y, this.viewModel.seatsState[x][y])
            }
        }
    }

    private func drawSeat(row: Int64, col: Int64, seatType: SEAT_TYPE) {
        let xPos = col * (RECT_SIZE + RECT_SPACE) + StyleConstants.CANVAS_PADDING
        let yPos = row * (RECT_SIZE + RECT_SPACE) + StyleConstants.CANVAS_PADDING

        this.context.lineWidth(1.3)
        this.context.fillStyle(StyleConstants.FILL_COLOR[seatType])
        this.context.strokeStyle(StyleConstants.STROKE_COLOR[seatType])

        this.context.beginPath()
        this.context.moveTo(xPos + 4, yPos)
        this.context.lineTo(xPos + RECT_SIZE - 4, yPos)
        this.context.quadraticCurveTo(xPos + RECT_SIZE, yPos, xPos + RECT_SIZE, yPos + 4)
        this.context.lineTo(xPos + RECT_SIZE, yPos + RECT_SIZE - 4)
        this.context.quadraticCurveTo(xPos + RECT_SIZE, yPos + RECT_SIZE, xPos + RECT_SIZE - 4, yPos + RECT_SIZE)
        this.context.lineTo(xPos + 4, yPos + RECT_SIZE)
        this.context.quadraticCurveTo(xPos, yPos + RECT_SIZE, xPos, yPos + RECT_SIZE - 4)
        this.context.lineTo(xPos, yPos + 4)
        this.context.quadraticCurveTo(xPos, yPos, xPos + 4, yPos)
        this.context.closePath()
        
        this.context.fill()
        this.context.stroke()
        
        if (seatType == SELECTED) {
            let img = ImageBitmap("resource://RAWFILE/selected.png")
            this.context.drawImage(img, xPos + 6, yPos + 6, 12, 12)
        }
    }
}
