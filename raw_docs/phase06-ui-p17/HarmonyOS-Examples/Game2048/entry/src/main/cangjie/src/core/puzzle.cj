/**
 * Created on 2024/9/19
    2048 逻辑管理
 */
package ohos_app_cangjie_entry.core

import std.collection.*
import std.random.*
import std.format.*
import std.math.*

public class Puzzle {

    //棋盘数量大小
    public static const size: Int64 = 16

    //棋盘地图
    public var board = Array<Int64>(size, {i => 0})

    public var score: Int64 = 0

    private static let random = Random()

    //重置棋盘，随机选择pick个初始格子
    public func reset(pick!: Int64 = 2): Unit {
        board = Array<Int64>(size, {i => 0})
        score = 0
        for (_ in 0..pick) {
            pickOne()
        }
    }

    //随机选择空白格，数据为随机的2或4
    public func pickOne(): Unit {
        let r = random.nextInt64(size)
        for (i in 0..size) {
            let idx = (r + i) % board.size
            if (board[idx] == 0) {
                if (r > size / 2) {
                    board[idx] = 4
                } else {
                    board[idx] = 2
                }
                return
            }
        }
    }

    //检测是否失败
    public func check(): Bool {
        //检查是否有空格
        for (tile in board) {
            if (tile == 0) {
                return false
            }
        }
        //检查水平和垂直方向相邻的数字是否相同
        let rowSize = Int64(sqrt(Float64(board.size)))
        for (i in 0..rowSize) {
            for (j in 0..rowSize) {
                if (i + 1 < rowSize && board[i + j * rowSize] == board[i + j * rowSize + 1]) {
                    return false
                }
                if (j + 1 < rowSize && board[i + j * rowSize] == board[i + (j + 1) * rowSize]) {
                    return false
                }
            }
        }
        return true
    }

    //打印数组
    func print_array(board: Array<Int64>): Unit {
        let rowSize = Int64(sqrt(Float64(board.size)))
        for (i in 0..board.size) {
            print(board[i].format("2"))
            print(" ")
            if ((i + 1) % rowSize == 0) {
                println()
            }
        }
    }

    //翻转数组
    func reverse(row: Array<Int64>): Array<Int64> {
        for (i in 0..(row.size / 2)) {
            let temp = row[i]
            row[i] = row[row.size - i - 1]
            row[row.size - i - 1] = temp
        }
        return row
    }

    //合并数组
    func merge(row: Array<Int64>): Array<Int64> {
        var newRow = Array<Int64>(row.size, {i => 0})

        var newIndex = 0
        for (i in 0..row.size) {
            if (row[i] == 0) {
                continue
            }
            if (newIndex > 0 && newRow[newIndex - 1] == row[i]) {
                newRow[newIndex - 1] *= 2

                //记录得分
                score += newRow[newIndex - 1]
            } else {
                newRow[newIndex] = row[i]
                newIndex++
            }
        }

        return newRow
    }

    //滑动方法
    public func move(direction: String): Array<Int64> {
        let boradSize: Int64 = board.size
        var newBorad = Array<Int64>(boradSize, {i => 0})
        let rowSize = Int64(sqrt(Float64(boradSize)))
        for (i in 0..rowSize) {
            var row = Array<Int64>(rowSize, {i => 0})
            //取一行或者一列数据
            for (j in 0..rowSize) {
                if ("left" == direction || "right" == direction) {
                    //第一行，0，1，2，3
                    row[j] = board[i * rowSize + j]
                } else {
                    //第一列，0，4，8，12
                    row[j] = board[j * rowSize + i]
                }
            }
            //右划或者下划要翻转数据
            if ("right" == direction || "down" == direction) {
                row = reverse(row)
            }

            //合并数据
            row = merge(row)

            //还原翻转的数据
            if ("right" == direction || "down" == direction) {
                row = reverse(row)
            }

            for (j in 0..rowSize) {
                if ("left" == direction || "right" == direction) {
                    newBorad[i * rowSize + j] = row[j]
                } else {
                    newBorad[j * rowSize + i] = row[j]
                }
            }
        }
        board = newBorad
        return newBorad
    }
}
