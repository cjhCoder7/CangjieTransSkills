/**
 * Created on 2025/7/23
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app

@Component
public class BackRow {
    public func build() {
        // 返回按钮+第几周  组件
        Row {
            Image(@r(app.media.back))
                .width(42)
                .margin(right: 8)
            Text('第8周')
                .fontSize(22)
                .fontWeight(FontWeight.W800)
                .lineHeight(27)
        }
        .margin(left: 32, bottom: 8, top: 12)
        .height(80)
        .width(100.percent)
        .justifyContent(FlexAlign.Start)
        .padding(top: 40)
    }
}