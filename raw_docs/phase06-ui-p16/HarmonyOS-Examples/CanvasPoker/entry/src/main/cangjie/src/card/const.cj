/**
 * Created on 2024/8/23
 */
package ohos_app_cangjie_entry.card

internal import ohos.hilog.Hilog
internal import ohos.window.*
internal import ohos.display.*
internal import ohos.base.AppLog

public type Suit = Int64

public type Rank = Int64

public type Color = Bool

//花色
public const SPADES: Suit = 0 //黑桃
public const CLUBS: Suit = 1 //梅花
public const HEARTS: Suit = 2 //红桃
public const DIAMONDS: Suit = 3 //方块

//大小

public const ACE: Int64 = 1
public const TWO: Int64 = 2
public const THREE: Int64 = 3
public const FOUR: Int64 = 4
public const FIVE: Int64 = 5
public const SIX: Int64 = 6
public const SEVEN: Int64 = 7
public const EIGHT: Int64 = 8
public const NINE: Int64 = 9
public const TEN: Int64 = 10
public const JACK: Int64 = 11
public const QUEEN: Int64 = 12
public const KING: Int64 = 13

//颜色
public const RED: Color = true
public const BLACK: Color = false

//牌面配色
public const REDSUIT: UInt32 = 0xA01400
public const BLACKSUIT: UInt32 = 0x000000
public const BORDER: UInt32 = 0x808080
public const BACKGROUND: UInt32 = 0xF0F0F0

//牌面尺寸
public const CARD_WIDTH: Float64 = 58.0
public const CARD_HEIGHT: Float64 = 88.0
public const CARD_CORNER_RADIUS: Float64 = 6.0

//屏幕尺寸
public var windowWidth: Float64 = 0.0
public var windowHeight: Float64 = 0.0

extend Int64 {
    public func rankName(): String {
        match (this) {
            case 1 => return "A"
            case 2 => return "2"
            case 3 => return "3"
            case 4 => return "4"
            case 5 => return "5"
            case 6 => return "6"
            case 7 => return "7"
            case 8 => return "8"
            case 9 => return "9"
            case 10 => return "10"
            case 11 => return "J"
            case 12 => return "Q"
            case 13 => return "K"
            case _ => return "?"
        }
    }
}

extend Int64 {
    public func suitName(): String {
        match (this) {
            case 0 => return "♠"
            case 1 => return "♣"
            case 2 => return "♥"
            case 3 => return "♦"
            case _ => return "?"
        }
    }

    public func suitColor(): Bool {
        match (this) {
            case 0 => return BLACK
            case 1 => return BLACK
            case 2 => return RED
            case 3 => return RED
            case _ => return BLACK
        }
    }
}

