/**
 * Created on 2024/9/5
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.display.*
import ohos.state_macro_manage.*

import cj_res_entry.app
import std.collection.ArrayList
import std.convert.Parsable

class Key {
    // 构造函数的简洁写法
    public Key(
        var text !: String = "",
        var fontSize !: Int64 = 16,
        var isHignLight !:Bool = false,
        var fontWeight !:FontWeight = FontWeight.Normal,
        var width !:Length = 23.5.percent,
        var height !:Length = 15.percent,
        var marginRight !:Length = 2.percent,
        var marginBottom !:Length = 2.percent,
        var shape !:ShapeType = ShapeType.Normal,
        var borderRadius !:Int64 = 10,
        var padding !:Int64 = 0
    ) {}
}



@Component
public class Keyboard {
    @StorageLink["history"] var history: ObservedArrayList<String> = ObservedArrayList<String>([])
    @StorageLink["historyIndex"] var historyIndex: Int64 = 0
    @StorageLink["themeIndex"] var themeIndex: Int64 = 0
    @StorageLink["expression"] var expression: String = ""
    @StorageLink["result"] var result: String = ""

    // let operators: Array<String> = ["+", "-", "×", "÷"]
    let operators: Array<String> = ["+", "-", "*", "/"]
    // 这里没有用 × 和 ÷ , 因为这两个字符非 UTF8 字符，会导致后面在获取算式的子串时抛出以下异常
    // An exception has occurred: IllegalArgumentException: Invalid utf8 byte sequence
    // 所以用 * 和 / 代替，到时为了没关再在计算器界面的显示上再转换一下即可

    let keys: Array<Key> = [
        Key(text: "主题颜色"),
        Key(text: "▲"),
        Key(text: "▼"),
        Key(text: "清除历史", marginRight: 0.percent),
        Key(text: "AC", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold),
        Key(text: "/", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold),
        Key(text: "*", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold),
        Key(text: "C", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold, marginRight: 0.percent),
        Key(text: "7", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "8", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "9", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "-", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold, marginRight: 0.percent),
        Key(text: "4", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "5", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "6", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "+", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold, marginRight: 0.percent),
        Key(text: "1", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "2", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "3", fontSize: 24, fontWeight: FontWeight.Bold),
        Key(text: "(", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold, marginRight: 0.percent),
        Key(text: "0", fontSize: 24, fontWeight: FontWeight.Bold, marginBottom: 0.percent),
        Key(text: ".", fontSize: 24, fontWeight: FontWeight.Bold, marginBottom: 0.percent),
        Key(text: "=", fontSize: 24, fontWeight: FontWeight.Bold, marginBottom: 0.percent),
        Key(text: ")", fontSize: 24, isHignLight: true, fontWeight: FontWeight.Bold, marginRight: 0.percent, marginBottom: 0.percent)
    ]

    func formatResult(result: String): String {
        let subStrs: Array<String> = result.split(".")
        var firstNonZeroIndex = -1

        for(i in subStrs[1].size-1..=0:-1) {
          if(subStrs[1][i..=i] != "0") {
              firstNonZeroIndex = i
              break
          }
        }

        if(firstNonZeroIndex == -1) {
          return subStrs[0]
        } else {
          return subStrs[0] + "." + subStrs[1][0..=firstNonZeroIndex]
        }
    }

    func hasExpressionError(): Int64 {
        let confirm = AlertDialogButtonOptions(
            value: "确定",
            action: {
                => AppLog.info("Button-clicking callback")
            }
        )
        let dialog = AlertDialogParamWithConfirm(
            "该算式无效哦,请仔细检查",
            title: "操作结果",
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            offset: Offset(0.vp, 0.vp),
            gridCount: 3,
            confirm: confirm,
            cancel: {
                => AppLog.info("Closed callbacks")
            }
        )
        AlertDialog.show(dialog)
        return 0
    }

    func operatorKey(`operator` : String): Int64 {
        if(`operator` == "+" || `operator` == "-") {
            return 1
        } else {
            return 2
        }
    }

    func calculate(numberStack: ArrayList<Float64>, operatorStack: ArrayList<String>) {
        let rightNumber = numberStack.remove(numberStack.size - 1)
        let leftNumber = numberStack.remove(numberStack.size - 1)
        let `operator` = operatorStack.remove(operatorStack.size - 1)
        var result: Float64 = 0.0
        if(`operator` == "+") {
            result = leftNumber + rightNumber
        } else if(`operator` == "-") {
            result = leftNumber - rightNumber
        } else if(`operator` == "*") {
            result = leftNumber * rightNumber
        } else if(`operator` == "/") {
            result = leftNumber / rightNumber
        }
        numberStack.append(result)
    }

    func getExpressionResult(expression: String): String {
        var exp: String = expression

        // 写法1
        /*
        if(exp.contains('(')) {
            try {
                let leftBracketIndex: Int64 = exp.indexOf('(').getOrThrow()
                let rightBracketIndex: Int64 = exp.indexOf(')').getOrThrow()
                let subExp = exp[leftBracketIndex+1..rightBracketIndex]
                let subRsult = getExpressionResult(subExp)
                exp = exp[0..leftBracketIndex] + subRsult + exp[rightBracketIndex+1..exp.size]
                return getExpressionResult(exp)
            } catch (_: Exception) {
                return "Error"
            }
        }
        */


        // 写法2
        if(let Some(leftBracketIndex) <- exp.indexOf('(')) {
            if(let Some(rightBracketIndex) <- exp.indexOf(')')) {
                let subExp = exp[leftBracketIndex+1..rightBracketIndex]
                let subRsult = getExpressionResult(subExp)
                exp = exp[0..leftBracketIndex] + subRsult + exp[rightBracketIndex+1..exp.size]
                return getExpressionResult(exp)
            } else {
                return "Error"
            }
        }

        var operatorStack: ArrayList<String> = ArrayList<String>(10)
        var numberStack: ArrayList<Float64> = ArrayList<Float64>(10)
        var number: String = ""

        for(i in 0..exp.size) {
            let char: String = exp[i..=i]
            if(operators.contains(char)) {
                // 运算符
                if(char == "-" && (i == 0 || exp[(i-1)..=(i-1)] == "(")) {
                    // 负数的情况
                    number += char
                    continue
                }
                numberStack.append(Float64.parse(number))
                number = ""
            } else {
                // 数字
                number += char
                continue
            }

            while (operatorStack.size > 0 && operatorKey(char) <= operatorKey(operatorStack[operatorStack.size - 1])) {
                calculate(numberStack, operatorStack)
            }

            operatorStack.append(char)
        }

        numberStack.append(Float64.parse(number))
        while(operatorStack.size > 0) {
            calculate(numberStack, operatorStack)
        }

        return formatResult(numberStack[0].toString())
    }

    func clickKey(key: Key, index: Int64) {
        if(index == 0) {
            // 切换主题颜色
            themeIndex = (themeIndex + 1) % themes.size
        } else if(index == 1) {
            // 历史上一个
            if(history.size > 0) {
                historyIndex = (historyIndex - 1) % history.size
                expression = history[historyIndex].split("=")[0]
            }
        } else if(index == 2) {
            // 历史下一个
            if(history.size > 0) {
                historyIndex = (historyIndex + 1) % history.size
                expression = history[historyIndex].split("=")[0]
            }
        } else if(index == 3) {
            // 清除历史
            history.clear()
            historyIndex = 0
        } else if(index == 4) {
            // 清除表达式
            expression = ""
        } else if(index == 7) {
            // 清除一个字符
            expression = expression[0..expression.size-1]
        } else if(index == 22) {
            // 等于
            if(expression.size > 0) {
                try {
                    result = getExpressionResult(expression)
                    if(result.indexOf("Error") != 0) {
                        expression += (key.text + result)
                        history.append(expression)
                        expression = result
                        historyIndex = history.size - 1;
                    } else {
                        hasExpressionError()
                    }
                } catch(_: Exception) {
                    hasExpressionError()
                }
            }
        } else {
            // 数字或者操作符
            expression += key.text
        }
    }

    func formatExpression(expression: String): String {
        return expression.replace("*", "×").replace("/", "÷")
    }
    func getKeyBackgroundColor(item: Key): Color {
        if(item.isHignLight) {
            return themes[themeIndex].foregroundColor
        }
        return Color(0xFFFFFF)
    }

    func getKeyFontColor(item: Key): Color {
        if(item.isHignLight) {
            return Color(0xFFFFFF)
        }
        return themes[themeIndex].foregroundColor
    }

    func build() {
        Flex(FlexParams(wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center, alignContent: FlexAlign.Center)) {
            ForEach(
                keys,
                {
                    item: Key, index: Int64 =>
                    Button(formatExpression(item.text))
                    .fontSize(item.fontSize)
                    .fontWeight(item.fontWeight)
                    .backgroundColor(getKeyBackgroundColor(item))
                    .fontColor(getKeyFontColor(item))
                    .width(item.width)
                    .height(item.height)
                    .margin(right: item.marginRight, bottom: item.marginBottom)
                    .shape(item.shape)
                    .borderRadius(item.borderRadius)
                    .padding(item.padding)
                    .onClick({
                        _ => clickKey(item, index)
                    })
                }
            )
        }
        .width(100.percent)
        .height(100.percent)

    }
}