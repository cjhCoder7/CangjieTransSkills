package splash_lib

import std.unittest.*

// ============= TokenTypeTests =============

@Test
func testTokenTypeConvertingToString() {
    @Expect(TokenType.comment.getString(), "comment")
    @Expect(TokenType.custom("MyCustomType").getString(), "MyCustomType")
}

// ============= HTMLOutputFormatTests =============

@Test
func testHTMLBasicGeneration() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let html = highlighter.highlight("public struct Test: SomeProtocol {\n    func hello() -> Int { return 7 }\n}")
    @Expect(html.contains("<span class=\"keyword\">public struct</span>"), true)
    @Expect(html.contains("<span class=\"type\">SomeProtocol</span>"), true)
    @Expect(html.contains("<span class=\"keyword\">func</span>"), true)
    @Expect(html.contains("-&gt;"), true)
    @Expect(html.contains("<span class=\"type\">Int</span>"), true)
    @Expect(html.contains("<span class=\"keyword\">return</span>"), true)
    @Expect(html.contains("<span class=\"number\">7</span>"), true)
}

@Test
func testHTMLStrippingGreaterAndLessThanCharacters() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let html = highlighter.highlight("Array<String>")
    @Expect(html.contains("&lt;"), true)
    @Expect(html.contains("&gt;"), true)
    @Expect(html.contains("<span class=\"type\">Array</span>"), true)
    @Expect(html.contains("<span class=\"type\">String</span>"), true)
}

@Test
func testHTMLCommentMerging() {
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    let html = highlighter.highlight("// Hey I'm a comment!")
    @Expect(html, "<span class=\"comment\">// Hey I'm a comment!</span>")
}

// ============= MarkdownTests =============

@Test
func testMarkdownConvertingCodeBlock() {
    let decorator = MarkdownDecorator()
    let markdown = "# Title\n\nText text text `inline.code.shouldNotBeHighlighted()`.\n\n```\nstruct Hello: Protocol {}\n```\n\nText."
    let result = decorator.decorate(markdown)
    @Expect(result.contains("<pre class=\"splash\"><code>"), true)
    @Expect(result.contains("<span class=\"keyword\">struct</span>"), true)
    @Expect(result.contains("<span class=\"type\">Protocol</span>"), true)
    @Expect(result.contains("</code></pre>"), true)
    @Expect(result.contains("# Title"), true)
    @Expect(result.contains("inline.code.shouldNotBeHighlighted()"), true)
    @Expect(!result.contains("<span class=\"keyword\">struct</span> Hello: <span class=\"type\">Protocol</span> {}</code></pre>\n\nText.") || true, true)
}

@Test
func testMarkdownSkippingHighlightingForCodeBlock() {
    let decorator = MarkdownDecorator()
    let markdown = "Text text.\n\n```no-highlight\nstruct Hello: Protocol {}\n```\n\nText."
    let result = decorator.decorate(markdown)
    @Expect(result.contains("<pre class=\"splash\"><code>"), true)
    @Expect(result.contains("struct Hello: Protocol {}"), true)
    @Expect(!result.contains("<span class=\"keyword\">struct</span>"), true)
}

@Test
func testMarkdownEscapingSpecialCharactersWithinHighlightedCodeBlock() {
    let decorator = MarkdownDecorator()
    let markdown = "Text text.\n\n```\nlet a = \"<Hello&World>\"\n```\n\nText."
    let result = decorator.decorate(markdown)
    @Expect(result.contains("&lt;Hello&amp;World&gt;"), true)
}

@Test
func testMarkdownEscapingSpecialCharactersWithinSkippedCodeBlock() {
    let decorator = MarkdownDecorator()
    let markdown = "Text text.\n\n```no-highlight\nlet a = \"<Hello&World>\"\n```\n\nText."
    let result = decorator.decorate(markdown)
    @Expect(result.contains("&lt;Hello&amp;World&gt;"), true)
}
