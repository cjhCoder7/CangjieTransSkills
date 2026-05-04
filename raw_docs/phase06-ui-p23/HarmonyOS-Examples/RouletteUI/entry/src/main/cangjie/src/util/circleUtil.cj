/**
 * Created on 2024/9/1
 */
package ohos_app_cangjie_entry.util

import ohos.base.*
import ohos.component.*
import ohos_app_cangjie_entry.model.{CircleModel}
import std.math.*
import ohos.hilog.Hilog
import std.collection.ArrayList

//绘制圆形工具类
public class CircleUtil {
    //颜色数组
    let colorList = ArrayList<UInt32>(
        [0xe42630, 0x974494, 0x605da4, 0x2b8c79, 0x40ac57, 0x8fc04b, 0xf3c733, 0xee8a32, 0xF7CE00, 0x5C8059])

    //文本数组
    let textList = ArrayList<String>(["鸿蒙", "仓颉", "C", "C++", "C#", "Java"])

    var context: CanvasRenderingContext2D
    var width: UInt32 = 350
    var height: UInt32 = 350
    var startAngle: Float64 = 0.0
    var avAngle: Float64 = 360.0 / 6.0

    public CircleUtil(context: CanvasRenderingContext2D) {
        this.context = context
    }

    public func canvaAll(res: Bool) {
        this.context.translate(Float64(this.width) / 2.0, Float64(this.height) / 2.0)
        this.canvaOutCircle(CircleModel(0.0, 0.0, Float64(this.width) / 2.0, 0.0, 360.0), 0xf6f6f6)
        this.canvaInnerCircle(CircleModel(0.0, 0.0, Float64(this.width) * 0.428, 0.0, 360.0), 0xffffff)
        this.canvaInnerArc()
        this.canvaArcText()
        this.context.translate(-Float64(this.width) / 2.0, -Float64(this.height) / 2.0)
    }

    //绘制弧线
    public func fillAct(circle: CircleModel, color: UInt32) {
        //创建一个新的绘制路径。
        this.context.beginPath()
        //指定绘制的填充色。
        this.context.fillStyle(color)
        //绘制弧线路径。
        this.context.arc(circle.getCircleX(), circle.getCircleY(), circle.getCircleRadius(),
            circle.getCircleStartAngle(), circle.getCircleEndAngle())
        //对封闭路径进行填充。
        this.context.fill()
    }

    //绘制外圈大圆
    public func canvaOutCircle(circle: CircleModel, color: UInt32) {
        this.fillAct(circle, color)
    }

    //绘制小圆
    public func canvaSmallCircle(res: Bool) {
        //开始的角度
        var beginAngle = 0.0
        this.context.translate(Float64(this.width) / 2.0, Float64(this.height) / 2.0)
        //绘制小圆
        for (i in 0..18) {
            this.context.save()
            //针对当前坐标轴进行顺时针旋转。
            this.context.rotate(Float64(beginAngle) * Float64.PI / 180.0)
            //绘制
            this.fillAct(CircleModel(Float64(this.width) * 0.46, 0.0, 5.0, 0.0, 360.0), changeSmallCircleColor(i, res))
            this.context.restore()
            beginAngle += 360.0 / 18.0
        }
        this.context.translate(-Float64(this.width) / 2.0, -Float64(this.height) / 2.0)
    }

    //绘制内圈的圆
    public func canvaInnerCircle(circle: CircleModel, color: UInt32) {
        this.fillAct(circle, color)
    }

    //绘制内圈圆的扇形区域
    public func canvaInnerArc() {
        let radius = Float64(this.width) * 0.428
        for (i in 0..this.textList.size) {
            this.fillAct(
                CircleModel(0.0, 0.0, radius, this.startAngle * Float64.PI / 180.0,
                    (this.startAngle + this.avAngle) * Float64.PI / 180.0),
                this.colorList[i]
            )
            this.context.lineTo(0.0, 0.0)
            this.context.fill()
            this.startAngle += this.avAngle
        }
    }

    //绘制内圈圆蒙层扇形区域
    public func canvaInnerMaskArc(resultOfLuckyDraw: String) {
        let radius = Float64(this.width) * 0.428
        this.context.translate(Float64(this.width) / 2.0, Float64(this.height) / 2.0)
        for (i in 0..this.textList.size) {
            this.fillAct(
                CircleModel(0.0, 0.0, radius, this.startAngle * Float64.PI / 180.0,
                    (this.startAngle + this.avAngle) * Float64.PI / 180.0),
                0xf6f6f6
            )
            this.context.globalAlpha(0.1)
            this.context.lineTo(0.0, 0.0)
            this.context.fill()
            this.startAngle += this.avAngle
        }
        this.context.translate(-Float64(this.width) / 2.0, -Float64(this.height) / 2.0)
    }

    //绘制扇形区域的文字
    public func canvaArcText() {
        //设置文本绘制中的文本对齐方式。
        this.context.textAlign(TextAlignStyle.Center)
        //设置文本绘制中的水平对齐方式。
        this.context.textBaseline(TextBaseline.Middle)
        //指定绘制的填充色。
        this.context.fillStyle(Color.WHITE)
        //指定文本绘制的填充色
        this.context.font(size: 20.vp, family: "sans-serif")

        let arcTextStartAngle: Float64 = 39.0
        let arcTextEndAngle: Float64 = 26.0
        for (i in 0..this.textList.size) {
            this.canvaCircularText(textList[i], this.textList.size,
                (this.startAngle + arcTextStartAngle) * Float64.PI / 180.0,
                (this.startAngle + arcTextEndAngle) * Float64.PI / 180.0)
            this.startAngle += this.avAngle
        }
    }

    //绘制弧形文本内的文字
    public func canvaCircularText(textString: String, textCount: Int64, startAngle: Float64, endAngle: Float64) {
        let circleTextRadius: Float64 = Float64(this.width) * 0.4

        let radius: Float64 = circleTextRadius - circleTextRadius / Float64(textCount)
        let angleDecrement: Float64 = (startAngle - endAngle) / Float64(textString.getStringLenght() - 1)

        var angle: Float64 = startAngle
        var index: Int64 = 0
        var character: Rune = 'r'

        while (index < textString.size) {
            character = textString.StringToRune(index)[0]
            this.context.save()
            this.context.beginPath()
            this.context.translate(0.0 + cos(angle) * radius, 0.0 - sin(angle) * radius)
            //针对当前坐标轴进行顺时针旋转。
            this.context.rotate(Float64.PI / 2.0 - angle)
            //绘制文本
            this.context.fillText(character.toString(), 0.0, 0.0)
            angle -= angleDecrement
            index += textString.StringToRune(index)[1]
            //对保存的绘图上下文进行恢复。
            this.context.restore()
        }
    }

    //改变小圆的颜色
    private func changeSmallCircleColor(index: Int64, res: Bool): UInt32 {
        match (index % 2) {
            case 0 => if (!res) {
                0xff0000
            } else {
                0xffffff
            }
            case _ => if (!res) {
                0xffffff
            } else {
                0xff0000
            }
        }
    }

    //获取转盘停止后停在的文字
    public func getText(randomAngle: Float32): String {
        Hilog.info(0x000000, "randomAngle", "randomAngle:${randomAngle}")
        for (i in 0..=textList.size) {
            if (randomAngle <= Float32(i * (360 / textList.size))) {
                Hilog.info(0x000000, "randomAngle", "i:${i}")
                match (i) {
                    case 1 => return this.textList[5]
                    case 2 => return this.textList[4]
                    case 3 => return this.textList[3]
                    case 4 => return this.textList[2]
                    case 5 => return this.textList[1]
                    case 6 => return this.textList[0]
                    case _ => ''
                }
            }
        }
        return ""
    }
}

extend String {

    //取出字符串中的每个字符
    func StringToRune(index: Int64): (Rune, Int64) {
        var UInt8Arr: Array<UInt8> = this.toArray()
        Hilog.info(0x000000, "character", "character:${UInt8Arr}")
        Hilog.info(0x000000, "character", "character:${index}")
        var r = Rune.fromUtf8(UInt8Arr, index)
        return r
    }

    //获取文字的长度
    func getStringLenght(): Int64 {
        var strLength: Int64 = 0
        var chart: Rune = 'r'
        var RuneTuple: (Rune, Int64) = (chart, 0)
        var index: Int64 = 0
        while (index < this.size) {
            RuneTuple = this.StringToRune(index)
            index += RuneTuple[1]
            strLength++
        }
        strLength
    }
}
