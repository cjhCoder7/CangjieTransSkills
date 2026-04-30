package splash_lib

/// 输出构建器接口
public interface OutputBuilder {
    func addToken(token: String, tokenType: TokenType): Unit
    func addToken(token: String, tokenType: ?TokenType): Unit
    func addPlainText(text: String): Unit
    func addWhitespace(whitespace: String): Unit
    func build(): String
}

/// 输出格式接口
public interface OutputFormat {
    func makeBuilder(): OutputBuilder
}

/// HTML 输出格式
public class HTMLOutputFormat <: OutputFormat {
    public var classPrefix: String = ""

    public init() {}
    public init(classPrefix: String) {
        this.classPrefix = classPrefix
    }

    public func makeBuilder(): OutputBuilder {
        HTMLBuilder(classPrefix)
    }
}

/// 待处理标记
class PendingToken {
    var str: String
    var ttype: TokenType
    init(str: String, ttype: TokenType) {
        this.str = str
        this.ttype = ttype
    }
}

/// HTML 输出构建器
public class HTMLBuilder <: OutputBuilder {
    private let classPrefix: String
    private var html: String = ""
    private var pendingToken: ?PendingToken = None
    private var pendingWhitespace: ?String = None

    init(classPrefix: String) {
        this.classPrefix = classPrefix
    }

    public func addToken(token: String, tokenType: TokenType): Unit {
        if (let Some(pending) <- pendingToken) {
            if (pending.ttype == tokenType) {
                if (let Some(ws) <- pendingWhitespace) {
                    pending.str = pending.str + ws + token
                    pendingWhitespace = None
                    return
                }
                pending.str = pending.str + token
                return
            }
        }
        appendPending()
        pendingToken = PendingToken(token, tokenType)
    }

    public func addToken(token: String, tokenType: ?TokenType): Unit {
        if (let Some(t) <- tokenType) {
            addToken(token, t)
        } else {
            addPlainText(token)
        }
    }

    public func addPlainText(text: String): Unit {
        appendPending()
        html = html + escapingHTMLEntities(text)
    }

    public func addWhitespace(whitespace: String): Unit {
        if (let Some(_) <- pendingToken) {
            if (let Some(existing) <- pendingWhitespace) {
                pendingWhitespace = existing + whitespace
            } else {
                pendingWhitespace = whitespace
            }
        } else {
            html = html + whitespace
        }
    }

    public func build(): String {
        appendPending()
        html
    }

    private func appendPending(): Unit {
        if (let Some(pending) <- pendingToken) {
            html = html + "<span class=\"" + classPrefix + pending.ttype.getString() + "\">"
            html = html + escapingHTMLEntities(pending.str)
            html = html + "</span>"
            pendingToken = None
        }
        if (let Some(ws) <- pendingWhitespace) {
            html = html + ws
            pendingWhitespace = None
        }
    }
}

/// Markdown 装饰器
public class MarkdownDecorator {
    private let highlighter: SyntaxHighlighter
    private let skipHighlightingPrefix: String = "no-highlight"

    public init() {
        highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    }

    public init(classPrefix: String, grammar: Grammar) {
        highlighter = SyntaxHighlighter(HTMLOutputFormat(classPrefix), grammar)
    }

    /// 装饰 Markdown 字符串中的所有代码块
    public func decorate(markdown: String): String {
        let components = markdown.split("```")
        var output = StringBuilder()
        var index: Int64 = 0

        for (component in components) {
            if (index % Int64(2) != Int64(0)) {
                var code = component.trimStart(" \t\n\r").trimEnd(" \t\n\r")
                if (code.startsWith(skipHighlightingPrefix)) {
                    let prefix = skipHighlightingPrefix + "\n"
                    code = removing(code, prefix)
                    code = escapingHTMLEntities(code)
                } else {
                    code = highlighter.highlight(code)
                }
                output.append("<pre class=\"splash\"><code>")
                output.append(code)
                output.append("</code></pre>")
            } else {
                output.append(component)
            }
            index += 1
        }

        output.toString()
    }
}
