/**
 * Created on 2025/7/16
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import cj_res_entry.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*

@Component
public class Title {
    func build() {
        Column {
            Row {
                Image(@r(app.media.back))
                    .width(25)
                    .position(x: 10, y: 0)

                Text(DataConstants.TITLE)
                    .fontSize(18)
                    .offset(x: 0, y: 2)
            }
            .margin(10)
            .width(StyleConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.Center)

            Row {
                ForEach(DataConstants.AREALIST, { i: AreaInfo, _: Int64 =>
                    Tag(info: i)
                })
            }
            .margin(top: 17, bottom: 3)
            .width(StyleConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceEvenly)

            Column {
                Image(@r(app.media.img)).width(200)

                Text(DataConstants.PLACE)
                    .fontSize(13)
                    .offset(x: 0, y: -5)
                    .fontColor(Color(0X999999))
            }
            .margin(top: 15, left: 20)
        }
    }
}
