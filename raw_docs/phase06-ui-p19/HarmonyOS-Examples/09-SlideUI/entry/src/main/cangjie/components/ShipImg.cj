/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app

@Component
public class ShipImg {

    @Link var isShow: Bool
    @Link var isShowDown: Bool
    public func build() {
        ListItemGroup(ListItemGroupParams()) {
            ListItem {
                Stack(Alignment.BottomEnd) {
                    Image(@r(app.media.ship1))
                    .width(100.percent)
                    .height(240)

                    Image(@r(app.media.ic_public_arrow_right))
                    .width(40)
                    .height(40)
                    .onClick{
                        evt =>
                        this.isShow = false
                        this.isShowDown = true
                    }
                    .margin(bottom: 190, right: 16)
                }
                .backgroundColor(Color.WHITE)
                .margin(bottom: 5)
            }
        }
    }
}