/**
 * Created on 2024/9/5
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.display.*
import ohos.state_macro_manage.*

public func formatExpression(expression: String): String {
    return expression.replace("*", "×").replace("/", "÷")
}

@Component
public class Expression {
    @StorageLink["expression"] var expression: String = ""

    func build() {
        TextArea(text: formatExpression(expression))
        .width(100.percent)
        .fontSize(36)
        .textAlign(TextAlign.Start)
        .borderRadius(0)
        .padding(10.vp)
        .backgroundColor(0xFFFFFF)
        .borderRadius(10.vp)
    }
}