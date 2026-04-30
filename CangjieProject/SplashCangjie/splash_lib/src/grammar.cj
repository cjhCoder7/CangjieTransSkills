package splash_lib

/// 定义语法高亮所用语言文法的接口
public interface Grammar {
    prop delimiters: DelimiterSet
    prop syntaxRules: Array<SyntaxRule>
    func isDelimiter(a: Rune, b: Rune): Bool
}

/// 定义语法规则的接口
public interface SyntaxRule {
    prop tokenType: TokenType
    func matches(segment: Segment): Bool
}
