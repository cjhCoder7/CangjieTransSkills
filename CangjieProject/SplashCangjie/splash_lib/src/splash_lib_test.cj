package splash_lib

import std.unittest.*

@Test
func testHTMLOutputFormat() {
    let format = HTMLOutputFormat()
    let builder = format.makeBuilder()
    builder.addToken("class", TokenType.keyword)
    builder.addWhitespace(" ")
    builder.addToken("MyClass", TokenType.`type`)
    let result = builder.build()
    @Expect(result, "<span class=\"keyword\">class</span> <span class=\"type\">MyClass</span>")
}

@Test
func testHTMLOutputFormatWithPrefix() {
    let format = HTMLOutputFormat("splash-")
    let builder = format.makeBuilder()
    builder.addToken("class", TokenType.keyword)
    let result = builder.build()
    @Expect(result, "<span class=\"splash-keyword\">class</span>")
}

@Test
func testHTMLEscaping() {
    let result = escapingHTMLEntities("a < b && c > d & e")
    @Expect(result, "a &lt; b &amp;&amp; c &gt; d &amp; e")
}

@Test
func testIsNumber() {
    @Expect(isNumber("123"), true)
    @Expect(isNumber("0"), true)
    @Expect(isNumber("abc"), false)
    @Expect(isNumber("12a"), false)
    @Expect(isNumber(""), false)
}

@Test
func testIsCapitalized() {
    @Expect(isCapitalized("MyClass"), true)
    @Expect(isCapitalized("String"), true)
    @Expect(isCapitalized("myClass"), false)
    @Expect(isCapitalized(""), false)
}

@Test
func testTokenTypeGetString() {
    @Expect(TokenType.keyword.getString(), "keyword")
    @Expect(TokenType.string.getString(), "string")
    @Expect(TokenType.`type`.getString(), "type")
    @Expect(TokenType.custom("myType").getString(), "myType")
}

@Test
func testTokenTypeEquality() {
    @Expect(TokenType.keyword == TokenType.keyword, true)
    @Expect(TokenType.keyword != TokenType.string, true)
    @Expect(TokenType.custom("a") == TokenType.custom("a"), true)
    @Expect(TokenType.custom("a") != TokenType.custom("b"), true)
}

@Test
func testHighlightSimpleCode() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let result = highlighter.highlight("class MyClass")
    @Expect(result.contains("<span class=\"keyword\">class</span>"), true)
    // MyClass after 'class' is not highlighted as type (declaration keyword excludes it)
}

@Test
func testHighlightTypeUsage() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let result = highlighter.highlight("var x: MyClass")
    @Expect(result.contains("<span class=\"type\">MyClass</span>"), true)
}

@Test
func testHighlightString() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let result = highlighter.highlight("\"hello\"")
    @Expect(result.contains("<span class=\"string\">"), true)
}

@Test
func testHighlightNumber() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let result = highlighter.highlight("42")
    @Expect(result.contains("<span class=\"number\">"), true)
}

@Test
func testHighlightComment() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let result = highlighter.highlight("// comment")
    @Expect(result.contains("<span class=\"comment\">"), true)
}

@Test
func testMarkdownDecorator() {
    let decorator = MarkdownDecorator()
    let markdown = "Before\n```\nclass MyClass\n```\nAfter"
    let result = decorator.decorate(markdown)
    @Expect(result.contains("<pre class=\"splash\"><code>"), true)
    @Expect(result.contains("</code></pre>"), true)
    @Expect(result.contains("<span class=\"keyword\">class</span>"), true)
    @Expect(result.contains("Before"), true)
    @Expect(result.contains("After"), true)
}
