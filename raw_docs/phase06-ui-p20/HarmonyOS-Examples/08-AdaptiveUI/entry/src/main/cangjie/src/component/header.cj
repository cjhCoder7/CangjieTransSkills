/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.component

internal import cj_res_entry.app
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class Head {
    func build() {
        Row {
            Text("我的歌单").fontSize(20.fp).fontWeight(FontWeight.Medium)
            Blank()
            Button {
                Image(@r(app.media.dot_grid)).size(width: 24, height: 24)
            }
            .shape(ShapeType.Normal)
            .backgroundColor(Color.TRANSPARENT)
            .padding(5).borderRadius(10)
        }
        .width(100.percent)
        .height(7.percent)
        .padding(10)
        .justifyContent(FlexAlign.Center)
    }
}