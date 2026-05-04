/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.components.Badge

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*


@Component
public class PseudoBadgeLine {
    @Prop var num: Int64
    @Prop var badgeColor: UInt32
    @Prop var position: PseudoBadgePosition

    let space: Int64 = 60

    func build() {
        Row(space.lpx) {
            ForEach(AVATAR_LIST, itemGeneratorFunc: { avatar: CJResource, index: Int64 =>
                ChatAvatar(num: num, position: position, iconSrc: avatar, badgeColor: badgeColor, pad: 0)
            }, keyGeneratorFunc: { avatar: CJResource, index: Int64 => "chatAvatar-${index}" })
        }
    }
}


@Component
public class PseudoBadgeLineWithPad {
    @Prop var num: Int64
    @Prop var badgeColor: UInt32
    @Prop var position: PseudoBadgePosition
    @Prop var pad: Int64

    let space: Int64 = 60

    func build() {
        Row(space.lpx) {
            ForEach(AVATAR_LIST, itemGeneratorFunc: { avatar: CJResource, index: Int64 =>
                ChatAvatar(num: num, position: position, iconSrc: avatar, badgeColor: badgeColor, pad: pad)
            }, keyGeneratorFunc: { avatar: CJResource, index: Int64 => "chatAvatar-${index}" })
        }
    }
}

@Component
public class PseudoBadgeBand {
    func build() {
        Column(20.lpx) {
            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLine(num: 0, position: PseudoBadgePosition.TopRight, badgeColor: color)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })

            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLine(num: 0, position: PseudoBadgePosition.BottomRight, badgeColor: color)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })

            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLine(num: 60, position: PseudoBadgePosition.TopRight, badgeColor: color)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })

            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLine(num: 989, position: PseudoBadgePosition.TopRight, badgeColor: color)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })
        }
    }
}

@Component
public class PseudoBadgeWithPadBand {
    func build() {
        Column(20.lpx) {
            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLineWithPad(num: 0, position: PseudoBadgePosition.TopRight, badgeColor: color, pad: 6)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })

            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLineWithPad(num: 0, position: PseudoBadgePosition.BottomRight, badgeColor: color, pad: 6)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })

            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLineWithPad(num: 60, position: PseudoBadgePosition.TopRight, badgeColor: color, pad: 6)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })

            ForEach(Array<UInt32>([0xb23132, 0x48d281, 0x0147ff]), itemGeneratorFunc: { color: UInt32, index: Int64 =>
                PseudoBadgeLineWithPad(num: 989, position: PseudoBadgePosition.TopRight, badgeColor: color, pad: 6)
            }, keyGeneratorFunc: { color: UInt32, index: Int64 => "pseudoBadgeLine-${index}" })
        }
    }
}