package splash_lib

import std.collection.*

// ============= 关键字集合 =============

let accessControlKeywords: Array<String> = [
    "public", "internal", "fileprivate", "private"
]

let declarationKeywords: Array<String> = [
    "class", "struct", "enum", "func",
    "protocol", "typealias", "import",
    "associatedtype", "subscript", "init",
    "actor"
]

let allKeywords: Array<String> = [
    "final", "class", "struct", "enum", "protocol",
    "extension", "let", "var", "func", "typealias",
    "init", "guard", "if", "else", "return", "get",
    "throw", "throws", "rethrows", "for", "in", "open", "weak",
    "import", "mutating", "nonmutating", "associatedtype",
    "case", "switch", "static", "do", "try", "catch", "as",
    "super", "self", "set", "true", "false", "nil",
    "override", "where", "_", "default", "break",
    "#selector", "required", "willSet", "didSet",
    "lazy", "subscript", "defer", "inout", "while",
    "continue", "fallthrough", "repeat", "indirect",
    "deinit", "is", "#file", "#line", "#function",
    "dynamic", "some", "#available", "convenience", "unowned",
    "async", "await", "actor", "any",
    "public", "internal", "fileprivate", "private"
]

// ============= Segment 辅助函数 =============

func isWithinStringLiteral(segment: Segment, start: String, end: String): Bool {
    if (segment.tokens.current.startsWith(start)) { return true }
    if (segment.tokens.current.endsWith(end)) { return true }

    var startCount: Int64 = 0
    var endCount: Int64 = 0
    var prev: ?String = None

    for (token in segment.tokens.onSameLine) {
        if (token.startsWith("(") || token.startsWith("#(") || token.startsWith("\"")) {
            if (let Some(p) <- prev) {
                if (p == "\\") {
                    prev = token
                    continue
                }
            }
        }
        if (token == start) {
            if (start != end || startCount == endCount) { startCount += 1 } else { endCount += 1 }
        } else if (token == end && start != end) {
            endCount += 1
        } else {
            if (token.startsWith(start)) { startCount += 1 }
            if (token.endsWith(end)) { endCount += 1 }
        }
        prev = token
    }
    startCount != endCount
}

func isWithinStringInterpolation(segment: Segment): Bool {
    let delimiter = "\\("
    if (segment.tokens.current == delimiter || segment.tokens.previous == delimiter) { return true }
    let parts = splitJoinedArray(segment.tokens.onSameLine, delimiter)
    if (parts.size <= 1) { return false }
    let suffix = parts[parts.size - 1]
    var parenCount: Int64 = 1
    parenCount += countCharInString(suffix, r'(')
    parenCount -= countCharInString(suffix, r')')
    parenCount <= 0
}

func isWithinRawStringInterpolation(segment: Segment): Bool {
    let cur = segment.tokens.current
    if (cur == "\\") { return segment.tokens.previous != "\\" && segment.tokens.next == "#" }
    if (cur == "#") { return segment.tokens.previous == "\\" && segment.tokens.next == "(" }
    if (cur == "(") {
        let s = arraySuffix(segment.tokens.onSameLine, 2)
        s.size == 2 && s[0] == "\\" && s[1] == "#"
    } else if (cur == ")") {
        let s = arraySuffix(segment.tokens.onSameLine, 4)
        s.size >= 3 && s[s.size - 3] == "\\" && s[s.size - 2] == "#" && s[s.size - 1] == "("
    } else {
        let s = arraySuffix(segment.tokens.onSameLine, 3)
        s.size == 3 && s[0] == "\\" && s[1] == "#" && s[2] == "(" && segment.tokens.next == ")"
    }
}

func prefixedByDotAccess(segment: Segment): Bool {
    segment.tokens.previous == "(." || segment.prefix.endsWith(" .")
}

func isValidSymbol(segment: Segment): Bool {
    if (segment.tokens.current.isEmpty()) { return false }
    let firstRune = segment.tokens.current.toRuneArray()
    if (firstRune.size == 0) { return false }
    firstRune[0] == r'_' || firstRune[0] == r'$' || isLetter(firstRune[0])
}

// ============= Swift 文法 =============

public class SwiftGrammar <: Grammar {
    private var _delimiters: DelimiterSet = DelimiterSet()
    private var _syntaxRules: Array<SyntaxRule> = Array<SyntaxRule>()

    public prop delimiters: DelimiterSet {
        get() { _delimiters }
    }

    public prop syntaxRules: Array<SyntaxRule> {
        get() { _syntaxRules }
    }

    public init() {
        _delimiters = DelimiterSet()
        _syntaxRules = [
            PreprocessingRule(),
            CommentRule(),
            RawStringRule(),
            MultiLineStringRule(),
            SingleLineStringRule(),
            AttributeRule(),
            NumberRule(),
            TypeRule(),
            CallRule(),
            KeyPathRule(),
            PropertyRule(),
            DotAccessRule(),
            KeywordRule()
        ]
    }

    public func isDelimiter(a: Rune, b: Rune): Bool {
        if (a == r'\\' && b == r'(') { return true }
        if (a == r'\\') { return false }
        if (b == r'\\') { return false }
        if (a == r')') { return false }
        if (a == r'/' && b == r'/') { return true }
        if (a == r'/' && b == r'*') { return true }
        if (a == r'*' && b == r'/') { return true }
        if (a == r'/') { return false }
        if (a == r'(' && b != r'.') { return false }
        if (a == r'.' && b == r'/') { return false }
        if (a == r',' && b == r'/') { return false }
        if (a == r'{' && b == r'/') { return false }
        if (a == r'}' && b == r'/') { return false }
        if (a == r'[' && b == r'/') { return false }
        if (a == r']' && b == r'/') { return false }
        if (a == r'>' && b == r'/') { return false }
        if (a == r'?' && b == r'/') { return false }
        true
    }
}

// ============= 语法规则实现 =============

class PreprocessingRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.preprocessing }
    }
    private let controlFlowTokens: Array<String> = ["#if", "#endif", "#elseif", "#else"]
    private let directiveTokens: Array<String> = ["#warning", "#error"]

    public func matches(segment: Segment): Bool {
        if (isAnyOf(segment.tokens.current, controlFlowTokens)) { return true }
        if (isAnyOf(segment.tokens.current, directiveTokens)) { return true }
        containsAnyOf(segment.tokens.onSameLine, controlFlowTokens)
    }
}

class CommentRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.comment }
    }

    public func matches(segment: Segment): Bool {
        if (segment.tokens.current.startsWith("/*") && segment.tokens.current.endsWith("*/")) { return true }
        if (segment.tokens.current.startsWith("//")) { return true }
        if (containsAnyOf(segment.tokens.onSameLine, ["//", "///"])) { return true }
        if (isAnyOf(segment.tokens.current, ["/*", "/**", "*/"])) { return true }
        let mlStart = segment.tokens.count("/*") + segment.tokens.count("/**")
        mlStart != segment.tokens.count("*/")
    }
}

class AttributeRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.keyword }
    }

    public func matches(segment: Segment): Bool {
        if (segment.tokens.current.startsWith("@")) { return true }
        if (segment.tokens.previous == ".") {
            let s = arraySuffix(segment.tokens.onSameLine, 2)
            if (s.size != 2) { return false }
            s[0].startsWith("@")
        } else { false }
    }
}

class RawStringRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.string }
    }

    public func matches(segment: Segment): Bool {
        if (isWithinRawStringInterpolation(segment)) { return false }
        if (isWithinStringLiteral(segment, "#\"", "\"#")) { return true }
        segment.tokens.count("#\"\"\"") != segment.tokens.count("\"\"\"#")
    }
}

class MultiLineStringRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.string }
    }

    public func matches(segment: Segment): Bool {
        if (isEven(segment.tokens.count("\"\"\""))) { return false }
        !isWithinStringInterpolation(segment)
    }
}

class SingleLineStringRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.string }
    }

    public func matches(segment: Segment): Bool {
        if (segment.tokens.current.startsWith("\"") && segment.tokens.current.endsWith("\"")) { return true }
        if (!isWithinStringLiteral(segment, "\"", "\"")) { return false }
        !isWithinStringInterpolation(segment) && !isWithinRawStringInterpolation(segment)
    }
}

class NumberRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.number }
    }

    public func matches(segment: Segment): Bool {
        if (let Some(previous) <- segment.tokens.previous) {
            if (previous.endsWith("$")) { return false }
        }
        if (isNumber(removing(segment.tokens.current, "_"))) { return true }
        if (segment.tokens.current != ".") { return false }
        if (let Some(previous) <- segment.tokens.previous) {
            if (let Some(next) <- segment.tokens.next) {
                return isNumber(previous) && isNumber(next)
            }
        }
        false
    }
}

class CallRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.call }
    }
    private let keywordsToAvoid: Array<String>
    private let callLikeKeywords: Array<String>
    private let controlFlowTokens: Array<String> = ["if", "&&", "||", "for", "switch"]

    init() {
        var avoid = ArrayList<String>()
        for (kw in allKeywords) {
            if (kw != "return" && kw != "try" && kw != "throw" && kw != "if" && kw != "in" && kw != "await") {
                avoid.add(kw)
            }
        }
        keywordsToAvoid = avoid.toArray()
        var callLike = ArrayList<String>()
        for (kw in accessControlKeywords) { callLike.add(kw) }
        callLike.add("subscript")
        callLike.add("init")
        callLikeKeywords = callLike.toArray()
    }

    public func matches(segment: Segment): Bool {
        let token = segment.tokens.current.trimStart("_").trimEnd("_")
        if (!startsWithLetter(token)) { return false }
        if (token == "init") { return false }
        if (isAnyOf(segment.tokens.current, callLikeKeywords)) {
            if (let Some(nextToken) <- segment.tokens.next) {
                if (nextToken.startsWith("(")) { return false }
            }
        }
        if (let Some(previousToken) <- segment.tokens.previous) {
            if (isAnyOf(previousToken, keywordsToAvoid)) { return false }
            if (previousToken == ".") {
                let pt = segment.tokens.onSameLine
                if (pt.size > 1) {
                    let last = pt[pt.size - 2]
                    if (last == "case" || last.endsWith(",")) { return false }
                }
            }
        }
        if (segment.trailingWhitespace != None) {
            if (let Some(nextToken) <- segment.tokens.next) {
                if (!isAnyOf(nextToken, ["{", "{}"])) { return false }
            } else {
                return false
            }
            if (segment.tokens.previous != "." || segment.tokens.onSameLine.isEmpty()) {
                if (isAnyOf(segment.tokens.current, allKeywords)) { return false }
            }
            return !containsAnyOf(segment.tokens.onSameLine, controlFlowTokens)
        }
        if (let Some(next) <- segment.tokens.next) { next.startsWith("(") } else { false }
    }
}

class KeywordRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.keyword }
    }

    public func matches(segment: Segment): Bool {
        if (segment.tokens.current == "_") { return true }
        if (segment.tokens.current == "prefix" && segment.tokens.next == "func") { return true }
        if (isAnyOf(segment.tokens.current, ["some", "any"])) {
            if (segment.tokens.previous == "case") { return false }
        }
        if (segment.tokens.next == ":" && segment.tokens.current != "nil") {
            if (segment.tokens.current != "default") { return false }
        }
        if (segment.trailingWhitespace == None) {
            if (!isAnyOf(segment.tokens.current, ["self", "super"])) {
                if (segment.tokens.next == ".") { return false }
            }
        }
        if (let Some(previousToken) <- segment.tokens.previous) {
            if (!segment.tokens.onSameLine.isEmpty()) {
                if (segment.tokens.current != "self") {
                    if (isAnyOf(previousToken, ["let", "var"])) { return false }
                    if (segment.tokens.current == "actor") {
                        if (isAnyOf(previousToken, accessControlKeywords)) { return true }
                        return !previousToken.isEmpty() && runeAt(previousToken, 0) == r'@'
                    }
                }
            }
            if (!isAnyOf(segment.tokens.current, declarationKeywords)) {
                if (segment.tokens.current == "(" && isAnyOf(previousToken, accessControlKeywords)) { return true }
                if (segment.tokens.current == "set" && previousToken == "(") { return true }
                if (segment.tokens.current == ")" && previousToken == "set") { return true }
                if (!isAnyOf(segment.tokens.current, ["self", "let", "var", "true", "false", "inout", "nil", "try", "actor"])) {
                    if (isAnyOf(previousToken, ["(", ",", ">("])) { return false }
                }
                if (isAnyOf(previousToken, ["func", "`"])) { return false }
            }
        }
        isAnyOf(segment.tokens.current, allKeywords)
    }
}

class TypeRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.`type` }
    }

    public func matches(segment: Segment): Bool {
        if (let Some(previousToken) <- segment.tokens.previous) {
            if (isAnyOf(previousToken, declarationKeywords)) { return false }
        }
        let token = segment.tokens.current.trimStart("_").trimEnd("_")
        if (!isCapitalized(token)) { return false }
        if (prefixedByDotAccess(segment)) { return false }
        if (token.startsWith("XCTAssert")) { return false }
        if (let Some(prev) <- segment.tokens.previous) {
            if (isAnyOf(prev, ["<", ",", "*/"])) {
                var foundOpen = false
                let rev = arrayReversed(segment.tokens.all)
                for (tk in rev) {
                    if (isAnyOf(tk, ["->", ">", ">:"])) { return true }
                    if (!foundOpen && tk == "<") { foundOpen = true }
                    if (foundOpen && (tk == ":" || tk.startsWith("@"))) { return true }
                    if (isAnyOf(tk, declarationKeywords)) { return !foundOpen }
                    if (isAnyOf(tk, ["=", "==", "(", "_", "@escaping"])) { return true }
                }
            }
        }
        true
    }
}

class DotAccessRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.dotAccess }
    }
    public func matches(segment: Segment): Bool {
        if (segment.tokens.onSameLine.isEmpty()) { return false }
        if (!isValidSymbol(segment)) { return false }
        if (let Some(prev) <- segment.tokens.previous) {
            if (!isAnyOf(prev, [".", "(.", "[."])) { return false }
        } else {
            return false
        }
        if (isAnyOf(segment.tokens.current, ["self", "init"])) { return false }
        segment.tokens.onSameLine[0] != "import"
    }
}

class KeyPathRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.property }
    }
    public func matches(segment: Segment): Bool {
        if (let Some(prev) <- segment.tokens.previous) {
            isAnyOf(prev, ["\\.", "(\\."])
        } else { false }
    }
}

class PropertyRule <: SyntaxRule {
    public prop tokenType: TokenType {
        get() { TokenType.property }
    }
    public func matches(segment: Segment): Bool {
        let ct = segment.tokens.current
        if (!ct.isEmpty() && runeAt(ct, 0) == r'$') {
            if (ct.size < 2) { return false }
            let secondRune = runeAt(ct, 1)
            if (let Some(r) <- secondRune) { return isLetter(r) }
            return false
        }
        if (segment.tokens.onSameLine.isEmpty()) { return false }
        if (!isValidSymbol(segment)) { return false }
        if (let Some(prev) <- segment.tokens.previous) {
            if (!isAnyOf(prev, [".", "?.", "().", ").", ">."])) { return false }
        } else {
            return false
        }
        if (isAnyOf(ct, ["self", "init"])) { return false }
        if (prefixedByDotAccess(segment)) { return false }
        if (let Some(next) <- segment.tokens.next) { if (next.startsWith("(")) { return false } }
        segment.tokens.onSameLine[0] != "import"
    }
}
