package splash_lib

import std.collection.*

/// 测试用组件类型
public enum MockComponent {
    | token(String, TokenType)
    | plainText(String)
    | whitespace(String)
}

/// 测试用 OutputBuilder 模拟
public class OutputBuilderMock <: OutputBuilder {
    private var components = ArrayList<MockComponent>()

    public func addToken(token: String, tokenType: TokenType): Unit {
        components.add(MockComponent.token(token, tokenType))
    }

    public func addToken(token: String, tokenType: ?TokenType): Unit {
        if (let Some(t) <- tokenType) {
            addToken(token, t)
        } else {
            addPlainText(token)
        }
    }

    public func addPlainText(text: String): Unit {
        components.add(MockComponent.plainText(text))
    }

    public func addWhitespace(whitespace: String): Unit {
        components.add(MockComponent.whitespace(whitespace))
    }

    public func build(): String {
        // 返回组件列表的字符串表示用于调试
        var sb = StringBuilder()
        for (c in components.toArray()) {
            match (c) {
                case token(t, tt) => sb.append("token(${t}, ${tt.getString()});")
                case plainText(t) => sb.append("plainText(${t});")
                case whitespace(t) => sb.append("whitespace(${t});")
            }
        }
        sb.toString()
    }

    public func getComponents(): Array<MockComponent> {
        components.toArray()
    }
}

/// 测试用 OutputFormat 模拟
public class OutputFormatMock <: OutputFormat {
    private let builder: OutputBuilderMock

    public init(builder: OutputBuilderMock) {
        this.builder = builder
    }

    public func makeBuilder(): OutputBuilder {
        builder
    }
}

/// 辅助函数：高亮代码并返回组件列表
public func highlightToComponents(code: String): Array<MockComponent> {
    let builder = OutputBuilderMock()
    let highlighter = SyntaxHighlighter(OutputFormatMock(builder), SwiftGrammar())
    highlighter.highlight(code)
    builder.getComponents()
}

/// 辅助函数：断言组件等于指定序列
public func assertComponentsEqual(actual: Array<MockComponent>, expected: Array<MockComponent>): Bool {
    if (actual.size != expected.size) {
        return false
    }
    for (i in 0..actual.size) {
        if (!mockComponentEqual(actual[i], expected[i])) {
            return false
        }
    }
    true
}

/// 辅助函数：比较两个 MockComponent 是否相等
public func mockComponentEqual(a: MockComponent, b: MockComponent): Bool {
    match (a) {
        case token(t1, tt1) =>
            match (b) {
                case token(t2, tt2) => t1 == t2 && tt1 == tt2
                case _ => false
            }
        case plainText(t1) =>
            match (b) {
                case plainText(t2) => t1 == t2
                case _ => false
            }
        case whitespace(t1) =>
            match (b) {
                case whitespace(t2) => t1 == t2
                case _ => false
            }
    }
}
