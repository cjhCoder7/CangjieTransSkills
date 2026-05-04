/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry.page.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app

@Component
public class homeBody {
    @State
    var turntableTitle: String = "今天学习什么!!"
    @State
    var resultOfLuckyDraw: String = ""

    func build() {
        Column() {
            //转盘标题
            Column(15) {
                Row(15) {
                    Image(@rawfile("ic_thinking_face.png")).width(24).height(24)
                    Text(this.turntableTitle).fontSize(22).fontWeight(FontWeight.Bold)
                }
                Row {
                    Text(this.resultOfLuckyDraw).fontSize(20).fontWeight(FontWeight.Bold)
                }
            }.width(100.percent).height(120.vp).justifyContent(FlexAlign.Start)
            turntable(resultOfLuckyDraw: resultOfLuckyDraw)
            Row(){
                Image(@rawfile("ic_square_and_pencil.png"))
                .width(24).height(24)
                Text("编辑")
                .fontSize(18).fontWeight(FontWeight.Medium)
            }.turntabel_edit()

        }.margin(top: 30).height(100.percent).justifyContent(FlexAlign.Start)
    }
}
