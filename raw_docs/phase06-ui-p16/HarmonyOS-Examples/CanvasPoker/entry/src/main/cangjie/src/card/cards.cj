/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.card

internal import ohos.hilog.Hilog
internal import ohos.component.CanvasRenderingContext2D
internal import ohos.component.FontStyle
internal import ohos.component.FontWeight
internal import ohos.component.TextAlignStyle
internal import ohos.base.Length
import std.math.*
import std.random.Random

public func drawCard(context: CanvasRenderingContext2D, width: Float64, height: Float64, dregree: Float64,
    offset: Float64, suit: Int64, rank: Int64) {
    context.save()
    // 牌扇形中心点坐标
    context.translate(width / 2.0, height / 2.0)
    context.rotate(dregree / 180.0 * Float64.PI)
    //牌中心坐标
    context.translate(0.0, -offset)

    //根据屏幕尺寸和牌面尺寸 计算牌圆角坐标
    let cornerX: Float64 = CARD_WIDTH / 2.0 - CARD_CORNER_RADIUS
    let cornerY: Float64 = CARD_HEIGHT / 2.0 - CARD_CORNER_RADIUS

    //1、绘制扑克上半部分
    context.beginPath()
    context.moveTo(cornerX, -Float64(CARD_HEIGHT / 2.0))
    //左上圆角
    context.arc(-cornerX, -cornerY, Float64(CARD_CORNER_RADIUS), 3.0 / 2.0 * Float64.PI, Float64.PI, anticlockwise: true
    )
    //左边线
    context.lineTo(-Float64(CARD_WIDTH / 2.0), cornerY)
    //左下圆角
    context.arc(-cornerX, cornerY, Float64(CARD_CORNER_RADIUS), Float64.PI, Float64.PI / 2.0, anticlockwise: true)
    //下边线
    context.lineTo(cornerX, Float64(CARD_HEIGHT / 2.0))
    //右下圆角
    context.arc(cornerX, cornerY, Float64(CARD_CORNER_RADIUS), Float64.PI / 2.0, 0.0, anticlockwise: true)
    //右边线
    context.lineTo(Float64(CARD_WIDTH / 2.0), cornerY)
    //右上圆角
    context.arc(cornerX, -cornerY, Float64(CARD_CORNER_RADIUS), 0.00, 3.0 / 2.0 * Float64.PI, anticlockwise: true)
    context.closePath()

    //填充扑克底色
    context.fillStyle(BACKGROUND)
    context.fill()

    //绘制扑克边框线
    // context.lineWidth(1)
    context.strokeStyle(BORDER)
    context.stroke()

    //左上角标
    if (suit.suitColor()) {
        context.fillStyle(REDSUIT)
    } else {
        context.fillStyle(BLACKSUIT)
    }
    context.font(style: FontStyle.Normal, weight: FontWeight.W300, size: Length(10), family: "system-ui")
    context.fillText(rank.rankName(), -cornerX, -cornerY + 6.0)
    context.fillText(suit.suitName(), -cornerX - 2.0, -cornerY + 19.0)

    //2、绘制中央花色 
    context.font(style: FontStyle.Normal, weight: FontWeight.W200, size: Length(25), family: "sans-serif")
    context.textAlign(TextAlignStyle.Center)
    context.fillText(suit.suitName(), 0.0, 10.0)

    //3、绘制扑克右下角角标
    // context.rotate(Float64.PI)
    context.transform(-1.0, 0.0, 0.0, -1.0, 0.0, 0.0) //旋转180°
    context.font(style: FontStyle.Normal, weight: FontWeight.W300, size: Length(10), family: "system-ui")
    context.fillText(rank.rankName(), -cornerX + 3.0, -cornerY + 6.0) //旋转后 x向坐标有偏移 需要修正 原因未知
    context.fillText(suit.suitName(), -cornerX + 3.0, -cornerY + 19.0) //旋转后 x向坐标有偏移 需要修正 原因未知
    context.restore()
}

public func deck(): Array<Array<Int64>> {
    var deck = Array<Array<Int64>>(52, {i => [5, 5]})
    //生成不含大小王的牌
    for (s in 0..4) {
        for (r in 0..13) {
            deck[s * 13 + r][0] = s
            deck[s * 13 + r][1] = r + 1
        }
    }
    shuffle(deck)
    return deck
}

/**
 * 洗牌
 * 采用Knuth_Durstenfeld算法
 * Knuth_Durstenfeld每次从未处理的数据中随机取出一个数据，然后把该数字放在数组的尾部，即数组尾部存放的是已经处理过的数字。
 */
public func shuffle(deck: Array<Array<Int64>>) {
    let length = deck.size - 1
    for (j in length..0 : -1) {
        let rand = Random(0X073)
        let randCard = rand.nextInt64(j + 1)
        let s = deck[j][0]
        let r = deck[j][1]
        deck[j][0] = deck[randCard][0]
        deck[j][1] = deck[randCard][1]
        deck[randCard][0] = s
        deck[randCard][1] = r
    }
}
