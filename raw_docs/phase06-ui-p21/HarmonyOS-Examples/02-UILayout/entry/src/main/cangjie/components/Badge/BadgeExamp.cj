/**
 * Created on 2025/8/5
 */
package ohos_app_cangjie_entry.components.Badge

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app


let BADGE_FONT_SIZE: Int64 = 22
let BADGE_SIZE: Int64 = 26
let AVATAR_LIST: Array<CJResource> = [
    @r(app.media.avatar_2),
    @r(app.media.avatar_3),
    @r(app.media.avatar_4),
    @r(app.media.avatar_5)
]


@Component
public class BadgeItem {
    @Prop var count: Int32
    @Prop var position: BadgePosition
    @Prop var iconSrc: CJResource

    let badgeFontColor: UInt32 = 0xffffff
    let size: Int64 = 90

    func build() {
        Badge(
            BadgeParams(count: count, style: BadgeStyle(
                    color: Color(badgeFontColor),
                    fontSize: BADGE_FONT_SIZE,
                    badgeSize: BADGE_SIZE,
                    badgeColor: Color(0xd44647)
                ),
                position: position,
                maxCount: 99
            )
        ) {
            Image(iconSrc).width(size.lpx).height(size.lpx).borderRadius((size / 2).lpx)
        }
    }
}


@Component
public class BadgeLine {
    @Prop var count: Int32
    @Prop var position: BadgePosition

    let space: Int64 = 60

    func build() {
        Row(space.lpx) {
            ForEach(AVATAR_LIST, itemGeneratorFunc: { avatar: CJResource, index: Int64 =>
                BadgeItem(count: count, position: position, iconSrc: avatar)
            }, keyGeneratorFunc: { _: CJResource, index: Int64 => "badge-${index}"})
        }
    }
}


@Component
public class NumberBadgeBand {
    func build() {
        Column(20.lpx) {
            ForEach(Array<Int32>([6, 15, 99, 854]), itemGeneratorFunc: { count: Int32, index: Int64 =>
                BadgeLine(count: count, position: BadgePosition.RightTop)
            }, keyGeneratorFunc: { count: Int32, index: Int64 => "count-${index}" })
        }.margin(bottom: 40.lpx)
    }
}


@Component
public class PositionBadgeBand {
    func build() {
        Column(20.lpx) {
            ForEach([BadgePosition.RightTop, BadgePosition.Right, BadgePosition.Left],
                itemGeneratorFunc: { position: BadgePosition, index: Int64 =>
                    BadgeLine(count: 88, position: position)
                }, keyGeneratorFunc: { position: BadgePosition, index: Int64 => "position-${index}" }
            )
        }.margin(bottom: 40.lpx)
    }
}
