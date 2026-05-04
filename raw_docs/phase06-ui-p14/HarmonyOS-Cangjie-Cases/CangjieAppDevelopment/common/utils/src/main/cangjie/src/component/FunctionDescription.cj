/**
 * Created on 2024/9/12
 */
package utils.component

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

/**
 * 模块功能描述组件
 * @param title 标题
 * @param context 内容
 */
@Component
public class FunctionDescription {
    private var title: String = ""
    private var content: String = ""

    func build() {
        Column() {
            Row() {
                Text(this.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .textOverflow(TextOverflow.Ellipsis)
                    .maxLines(1)
            }
            .margin(bottom: 8)

            Row() {
                Text(this.content)
                    //.wordBreak(WordBreak.BREAK_ALL)   //FIXME: 仓颉Text组件暂不支持wordBreak属性
            }
            .width(100.percent)
        }
        .width(100.percent)
        .backgroundColor(0xF1F3F5)
        .borderRadius(12)
        .padding(12)
    }
}