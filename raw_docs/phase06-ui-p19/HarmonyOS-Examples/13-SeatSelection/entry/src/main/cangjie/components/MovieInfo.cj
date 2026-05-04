/**
 * Created on 2025/7/25
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*

extend Text {
    func movieInfoStyle() {
        this.fontSize(14)
            .margin(right: 5)
            .fontColor(0X999999)
    }
}

@Component
public class MovieInfo {
    func build() {
        Column {
            Text(DataConstants.MOVIE_NAME)
                .fontSize(16)
                .margin(bottom: 5)
                .width(StyleConstants.FULL_WIDTH)

            Row {
                Text(DataConstants.MOVIE_DATE).movieInfoStyle()
                Text(DataConstants.MOVIE_TIME).movieInfoStyle()
                Text(DataConstants.MOVIE_TYPE).movieInfoStyle()
            }
            .align(Alignment.Start)
            .width(StyleConstants.FULL_WIDTH)
        }
    }
}