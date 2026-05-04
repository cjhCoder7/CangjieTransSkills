/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.components.Badge

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app


let PSEUDO_BADGE_FONT_SIZE: Int64 = 20
let PSEUDO_BADGE_HEIGHT: Int64 = 28
let AVATAR_SIZE: Int64 = 90


public enum PseudoBadgePosition {
    TopRight | BottomRight
}


@Component
public class ChatAvatar {
    @Prop var iconSrc: CJResource
    @Prop var badgeColor: UInt32
    @Prop @Watch[numOnChange] var num: Int64
    @Prop @Watch[positionOnChange] var position: PseudoBadgePosition
    @Prop var pad: Int64
    @State var _num: String = ""
    @State var pseudoBadgeY: Int64 = 0

    let badgePadX: Int64 = 10
    var pseudoBadgeX: Int64 = AVATAR_SIZE / 4 * 3

    protected func aboutToAppear() {
        numOnChange()
        positionOnChange()
    }

    func numOnChange() {
        if (num == 0) {
            _num = ""
        } else if (num <= 99) {
            _num = "${num}"
        } else {
            _num = "99+"
        }
        return
    }

    func positionOnChange() {
        match (position) {
            case PseudoBadgePosition.TopRight =>
                pseudoBadgeY = 0
            case PseudoBadgePosition.BottomRight =>
                pseudoBadgeY = (AVATAR_SIZE - PSEUDO_BADGE_HEIGHT)
        }
    }

    func build() {
        Row() {
            Image(iconSrc).width(AVATAR_SIZE.lpx).height(AVATAR_SIZE.lpx)
                .borderRadius(AVATAR_SIZE.lpx)

            Row() {
                Row() {
                    Text(_num).fontSize(PSEUDO_BADGE_FONT_SIZE.lpx).fontColor(0xffffff)
                        .height(PSEUDO_BADGE_HEIGHT.lpx)
                }.padding(left: badgePadX.lpx, right: badgePadX.lpx).height(PSEUDO_BADGE_HEIGHT.lpx).backgroundColor(badgeColor)
                .borderRadius(PSEUDO_BADGE_HEIGHT.lpx).constraintSize(minWidth: PSEUDO_BADGE_HEIGHT.lpx)
            }.align(Alignment.TopStart).position(x: pseudoBadgeX.lpx, y: pseudoBadgeY.lpx).backgroundColor(0xffffff)
            .padding(pad.lpx).borderRadius((PSEUDO_BADGE_HEIGHT).lpx)
        }
    }
}