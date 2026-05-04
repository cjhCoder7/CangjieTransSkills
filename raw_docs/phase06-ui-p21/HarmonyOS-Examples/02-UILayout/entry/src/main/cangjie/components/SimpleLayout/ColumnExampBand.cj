/**
 * Created on 2025/8/3
 */
package ohos_app_cangjie_entry.components.SimpleLayout

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.components.utils.BlackDivider


@Component
public class ColumnExampSingleBand {
    @Prop var width: Int64

    func build() {
        Column(30.lpx) {
            Column(5.lpx) {
                BlackDivider()
                BlackDivider()
            }

            Image(@r(app.media.British_Museum)).width(width.lpx).height((Float64(width) / 1.333).lpx)
            Text("British Museum").fontSize(50.lpx).fontColor(0x000000).fontWeight(FontWeight.W200)
                .width(100.percent).textAlign(TextAlign.Center)
            Text("The British Museum is a public museum dedicated to human history, art and culture located in the Bloomsbury area of London. Its permanent collection of eight million works is the largest in the world. It documents the story of human culture from its beginnings to the present. Established in 1753, the British Museum was the first public national museum. In 2023, the museum received 5,820,860 visitors, 42% more than the previous year. At least one group rated it the most popular attraction in the United Kingdom.")
                .width(100.percent).fontSize(28.lpx)

            Column(5.lpx) {
                BlackDivider()
                BlackDivider()
            }
        }.width(100.percent)
    }
}