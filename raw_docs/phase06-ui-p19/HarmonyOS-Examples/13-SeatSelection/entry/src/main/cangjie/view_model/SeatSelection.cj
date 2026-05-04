/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.view_model

import std.math.*
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.prompt_action.PromptAction
import ohos_app_cangjie_entry.constants.*
import std.collection.ArrayList

@Observed
public class SeatSelection {
    @Publish
    public var seatsState: ObservedArrayList<ObservedArray<SEAT_TYPE>> = ObservedArrayList<ObservedArray<SEAT_TYPE>>()

    @Publish
    public var selectedSeats: ObservedArrayList<SeatInfo> = ObservedArrayList<SeatInfo>()

    private var onStateChangeCallback: Option<(SeatInfo, SEAT_TYPE) -> Unit> = Option.None
    private let RECT_SPACE = StyleConstants.MATRIX_SPACE
    private let RECT_SIZE = StyleConstants.MATRIX_RECT_SIZE

    public func setRedrawCallback(callback: (SeatInfo, SEAT_TYPE) -> Unit) {
        this.onStateChangeCallback = Option.Some(callback)
    }

    public func initSeatState() {
        if (!this.seatsState.isEmpty()) {
            return
        }
        for (row in DataConstants.SEATS) {
            seatsState.append(ObservedArray<SEAT_TYPE>(row.clone()))
        }
    }

    public func deleteSelected(seatInfo: SeatInfo) {
        selectedSeats.removeIf {seat => seat == seatInfo}
        let oldSeatType = DataConstants.SEATS[seatInfo.row][seatInfo.col]
        seatsState[seatInfo.row][seatInfo.col] = oldSeatType

        this.onStateChangeCallback?(seatInfo, oldSeatType)
    }

    public func soldSelected() {
        for (seat in selectedSeats.get()) {
            seatsState[seat.row][seat.col] = SOLD
            this.onStateChangeCallback?(seat, SOLD)
        }
        selectedSeats.clear()
    }

    public func handleCanvasClick(evt: ClickEvent) {
        let gridCol = Int64(floor((evt.x - Float64(StyleConstants.CANVAS_PADDING)) / Float64(RECT_SIZE + RECT_SPACE)))
        let gridRow = Int64(floor((evt.y - Float64(StyleConstants.CANVAS_PADDING)) / Float64(RECT_SIZE + RECT_SPACE)))

        if (gridRow >= 0 && gridRow < this.seatsState.size &&
            gridCol >= 0 && gridCol < this.seatsState[gridRow].size) {

            let seatX = gridCol * (RECT_SIZE + RECT_SPACE) + StyleConstants.CANVAS_PADDING
            let seatY = gridRow * (RECT_SIZE + RECT_SPACE) + StyleConstants.CANVAS_PADDING

            let localX = evt.x - Float64(seatX)
            let localY = evt.y - Float64(seatY)

            if(localX >= 0.0 && localX <= Float64(RECT_SIZE) && localY >= 0.0 && localY <= Float64(RECT_SIZE)) {
                this.handleSeatClick(SeatInfo(gridRow, gridCol))
            }
        }
    }

    public func recommendSeats(count: Int64) {
        let numRows = this.seatsState.size
        if (numRows == 0) { return }

        let searchRows: ArrayList<Int64> = ArrayList<Int64>()
        let midRow = numRows / 2
        searchRows.append(midRow)
        for (d in 1..(numRows / 2 + 1)) {
            if (midRow - d >= 0) { searchRows.append(midRow - d) }
            if (midRow + d < numRows) { searchRows.append(midRow + d) }
        }

        for (row in searchRows) {
            match (this.findBestBlockInRow(row, count)) {
                case Some(block) =>
                    for (seat in block) {
                        this.seatsState[seat.row][seat.col] = SELECTED
                        this.selectedSeats.append(seat)
                        this.onStateChangeCallback?(seat, SELECTED)
                    }
                    return
                case None => ()
            }
        }

        PromptAction.showToast(message: "没有找到合适的${count}人座位")
    }

    private func findBestBlockInRow(row: Int64, count: Int64): Option<ArrayList<SeatInfo>> {
        let numCols = this.seatsState[row].size
        let rowCenterCol = Float64(numCols - 1) / 2.0

        var bestBlock: Option<ArrayList<SeatInfo>> = Option.None
        var minCenterDistance = 10000.0

        for (startCol in 0..(numCols - count + 1)) {
            let currentBlock = ArrayList<SeatInfo>()
            var isBlockAvailable = true

            for (k in 0..count) {
                let col = startCol + k
                if (this.seatsState[row][col] == SOLD) {
                    isBlockAvailable = false
                    break
                }
                currentBlock.append(SeatInfo(row, col))
            }
            if (isBlockAvailable) {
                let blockCenterCol = Float64(startCol) + (Float64(count - 1) / 2.0)
                let distance = abs(blockCenterCol - rowCenterCol)

                if (distance < minCenterDistance) {
                    minCenterDistance = distance
                    bestBlock = Option.Some(currentBlock)
                }
            }
        }
        return bestBlock
    }

    private func handleSeatClick(seatInfo: SeatInfo) {
        let row = seatInfo.row
        let col = seatInfo.col
        var newSeatType: SEAT_TYPE

        match (seatsState[row][col]) {
            case SOLD =>
                PromptAction.showToast(message: "该座位已经售出，请选择其他座位")
                return
            case SELECTED =>
                newSeatType = DataConstants.SEATS[row][col]
                seatsState[row][col] = newSeatType
                selectedSeats.removeIf {seat => seat == seatInfo}
            case _ =>
                newSeatType = SELECTED
                seatsState[row][col] = newSeatType
                selectedSeats.append(SeatInfo(row, col))
        }

        this.onStateChangeCallback?(seatInfo, newSeatType)
    }
}
