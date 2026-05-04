/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.utils

import std.collection.*

public class CalculateUtils {

    public static func tokenize(expression: String): ArrayList<String> {
        let tokens: ArrayList<String> = ArrayList()
        let n = expression.size
        var i = 0
        while (i < n) {
            var ch = expression[i]
            if (StringUtils.isDigit(ch)) {
                var j = i + 1
                while (j < n && StringUtils.isDigit(expression[j])) {
                    j++
                }
                tokens.append(expression[i..j])
                i = j
            } else if ('+-*x/÷()'.indexOf(ch) != None) {
                tokens.append(if ('÷'.indexOf(ch) != None) { i++; '/' } else { '${Rune(ch)}' })
                i++
            } else {
                i++
            }
        }
        tokens
    }

    public static func infixToPostFix(expression: String) {
        let output: ArrayList<String> = ArrayList()
        let opStack: Stack<String> = Stack()
        let precedence: Map<String, Int64> = HashMap([
            ('+', 1), ('-', 1), ('*', 2),
            ('x', 2), ('/', 2), ('÷', 2),
            ('(', -100), (')', -100)
        ])

        func comparePrecedence(op1: String, op2: String) {
            return precedence[op1] >= precedence[op2]
        }

        for (token in tokenize(expression)) {
            if (StringUtils.isDigit(token[0])) {
                output.append(token)
            } else if (token == '(') {
                opStack.push(token)
            } else if (token == ')') {
                while (opStack.peek() != '(') {
                    output.append(opStack.pop())
                }
                opStack.pop()
            } else {
                while (!opStack.isEmpty() && comparePrecedence(opStack.peek(), token)) {
                    output.append(opStack.pop())
                }
                opStack.push(token)
            }
        }
        while (!opStack.isEmpty()) {
            output.append(opStack.pop())
        }
        output
    }

    public static func evalInFix(expression: String) {
        let stack: Stack<Float64> = Stack()
        for (token in infixToPostFix(expression)) {
            if (StringUtils.isDigit(token[0])) {
                stack.push(StringUtils.stringToFloat(token))
            } else {
                if (stack.size() < 2) { continue }
                let b = stack.pop()
                let a = stack.pop()
                match (token) {
                    case '+' => stack.push(a + b);
                    case '-' => stack.push(a - b);
                    case '*' | 'x' => stack.push(a * b);
                    case _ => stack.push(a / b); // '/' | '÷'
                }
            }
        }
        StringUtils.floatToString(if (stack.size() == 0) { 0.0 } else { stack.pop() })
    }
}