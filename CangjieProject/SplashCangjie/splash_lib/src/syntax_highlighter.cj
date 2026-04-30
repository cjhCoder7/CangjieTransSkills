package splash_lib

/// 高亮器内部状态
class HighlightState {
    var token: String
    var tokenType: ?TokenType
    init(token: String, tokenType: ?TokenType) {
        this.token = token
        this.tokenType = tokenType
    }
}

/// 语法高亮器主入口
public class SyntaxHighlighter {
    private let format: OutputFormat
    private let grammar: Grammar
    private let tokenizer = Tokenizer()

    public init(format: OutputFormat, grammar: Grammar) {
        this.format = format
        this.grammar = grammar
    }

    /// 高亮给定代码
    public func highlight(code: String): String {
        var builder = format.makeBuilder()
        var state: ?HighlightState = None

        for (segment in tokenizer.segmentsByTokenizing(code, grammar)) {
            let token = segment.tokens.current
            let whitespace = segment.trailingWhitespace

            if (token.isEmpty()) {
                if (let Some(ws) <- whitespace) {
                    builder.addWhitespace(ws)
                }
                continue
            }

            let tokenType = typeOfToken(segment)

            if (let Some(currentState) <- state) {
                if (!optionTokenTypeEqual(currentState.tokenType, tokenType)) {
                    builder.addToken(currentState.token, currentState.tokenType)
                    state = HighlightState(token, tokenType)
                    if (let Some(ws) <- whitespace) {
                        builder.addToken(token, tokenType)
                        builder.addWhitespace(ws)
                        state = None
                    }
                    continue
                }

                currentState.token = currentState.token + token
                if (let Some(ws) <- whitespace) {
                    builder.addToken(currentState.token, tokenType)
                    builder.addWhitespace(ws)
                    state = None
                }
            } else {
                state = HighlightState(token, tokenType)
                if (let Some(ws) <- whitespace) {
                    builder.addToken(token, tokenType)
                    builder.addWhitespace(ws)
                    state = None
                }
            }
        }

        if (let Some(lastState) <- state) {
            builder.addToken(lastState.token, lastState.tokenType)
        }

        builder.build()
    }

    private func typeOfToken(segment: Segment): ?TokenType {
        for (rule in grammar.syntaxRules) {
            if (rule.matches(segment)) {
                return rule.tokenType
            }
        }
        None
    }
}

/// 比较 ?TokenType 是否相等
func optionTokenTypeEqual(a: ?TokenType, b: ?TokenType): Bool {
    match (a) {
        case Some(ta) =>
            match (b) {
                case Some(tb) => ta == tb
                case None => false
            }
        case None =>
            match (b) {
                case Some(_) => false
                case None => true
            }
    }
}
