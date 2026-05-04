/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.service

import ohos_app_cangjie_entry.utils.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Observed
public class DynamicParam {
    @Publish
    public var expressionTextSize: Int64 = 48
    @Publish
    public var resultTextSize: Int64 = 24
    @Publish
    public var expressionText: String = "0"
    @Publish
    public var resultText: String = "0"

    public func push(text: String) {
        setExpression(if (expressionText == "0") { text } else { expressionText + text })
    }

    public func pop() {
        setExpression(if (expressionText == "0" || expressionText.isEmpty()) {"0"} else { expressionText[0..expressionText.size-1] })
    }

    public func setExpression(expression: String) {
        expressionText = expression
        resultText = CalculateUtils.evalInFix(expression)
        resetIfZero()
    }

    public func clear() {
        expressionText = "0"
        resultText = "0"
    }

    public func resetSize(expressionTextSize: Int64, resultTextSize: Int64) {
        this.expressionTextSize = expressionTextSize
        this.resultTextSize = resultTextSize
    }

    private func resetIfZero() {
        expressionText = if (expressionText.isEmpty()) {
            "0"
        } else {
            expressionText
        }

        resultText = if (resultText.isEmpty()) {
            "0"
        } else {
            resultText
        }
    }

}