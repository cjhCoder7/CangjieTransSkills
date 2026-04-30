## 公共 API 清单

| 源签名 (Swift) | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `TokenType` enum | `public enum TokenType` | `type` 成员需用反引号转义 |
| `TokenType.custom(String)` | `\| custom(String)` | 与原始语义相同 |
| `TokenType.getString() -> String` | `public func getString(): String` | 枚举内直接定义 |
| `SyntaxHighlighter` class | `public class SyntaxHighlighter` |  |
| `init(format:outputFormat, grammar: Grammar)` | `init(format: OutputFormat, grammar: Grammar)` | 移除外部参数标签 |
| `highlight(code: String) -> String` | `func highlight(code: String): String` | 返回类型语法不同 |
| `OutputFormat` protocol | `public interface OutputFormat` | 接口不支持关联类型 |
| `OutputFormat.makeBuilder() -> OutputBuilder` | `func makeBuilder(): OutputBuilder` | 返回具体类型非关联类型 |
| `OutputBuilder` protocol | `public interface OutputBuilder` |  |
| `OutputBuilder.addToken(_:String, as:TokenType)` | `func addToken(token: String, tokenType: TokenType): Unit` | 移除外部标签 |
| `OutputBuilder.build() -> String` | `func build(): String` |  |
| `HTMLOutputFormat` class | `public class HTMLOutputFormat` |  |
| `HTMLOutputFormat.init(classPrefix: String)` | `init(classPrefix: String)` | 位置参数 |
| `HTMLBuilder` class | `public class HTMLBuilder` |  |
| `MarkdownDecorator` class | `public class MarkdownDecorator` |  |
| `MarkdownDecorator.decorate(markdown: String) -> String` | `func decorate(markdown: String): String` |  |
| `SwiftGrammar` class | `public class SwiftGrammar` |  |
| `Grammar` protocol | `public interface Grammar` |  |
| `SyntaxRule` protocol | `public interface SyntaxRule` |  |
| `Segment` struct | `public struct Segment` |  |
| `Tokens` struct | `public struct Tokens` |  |
| `escapingHTMLEntities(s:) -> String` | `public func escapingHTMLEntities(s: String): String` |  |
| `isNumber(_:) -> Bool` | `public func isNumber(s: String): Bool` |  |
| `isCapitalized(_:) -> Bool` | `public func isCapitalized(s: String): Bool` |  |

## 内部 API（不对外导出）

- `DelimiterSet` — 分隔符字符集
- `arraySuffix(arr:n:)` — 数组尾部切片
- `arrayReversed(arr:)` — 数组反转
- `splitJoinedArray(arr:delimiter:)` — 字符串数组的 join+split
- `countCharInString(s:target:)` — 字符计数
- `runeAt(s:index:)` — 安全获取字符
- `isLetter(ch:)` — 字母判断
- `isValidSymbol(segment:)` — 有效标识符判断
- `isWithinStringLiteral(segment:start:end:)` — 字符串字面量内判断
- `isWithinStringInterpolation(segment:)` — 字符串插值内判断
- `isWithinRawStringInterpolation(segment:)` — 原始字符串插值内判断
