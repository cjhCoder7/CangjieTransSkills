package splash_lib

import std.unittest.*

@Test
func testStringLiteral() {
    let components = highlightToComponents("let string = \"Hello, world!\"")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("string"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("\"Hello,", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("world!\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralPassedToFunction() {
    let components = highlightToComponents("call(\"Hello, world!\")")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("\"Hello,", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("world!\"", TokenType.string),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithEscapedQuote() {
    let components = highlightToComponents("\"Hello \\\" World\"; call()")
    let expected = [
        MockComponent.token("\"Hello", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("\\\"", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("World\"", TokenType.string),
        MockComponent.plainText(";"),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithAttribute() {
    let components = highlightToComponents("\"@escaping\"")
    let expected = [
        MockComponent.token("\"@escaping\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralInterpolation() {
    let components = highlightToComponents("\"Hello \\(variable) world \\(call())\"")
    let expected = [
        MockComponent.token("\"Hello", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\(variable"),
        MockComponent.token(")", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("world"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\("),
        MockComponent.token("call", TokenType.call),
        MockComponent.token("()", TokenType.string),
        MockComponent.plainText(")"),
        MockComponent.token("\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithInterpolatedClosureArgumentShorthand() {
    let components = highlightToComponents("\"\\($0)\"")
    let expected = [
        MockComponent.token("\"", TokenType.string),
        MockComponent.plainText("\\($0"),
        MockComponent.token(")\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithCustomIterpolation() {
    let components = highlightToComponents("\"Hello \\(label: a, b) world \\(label: call())\"")
    let expected = [
        MockComponent.token("\"Hello", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\(label"),
        MockComponent.token(":", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("a,", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("b)", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("world"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\(label"),
        MockComponent.token(":", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("call()", TokenType.string),
        MockComponent.plainText(")"),
        MockComponent.token("\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithInterpolationSurroundedByBrackets() {
    let components = highlightToComponents("\"[\\(text)]\"")
    let expected = [
        MockComponent.token("\"[", TokenType.string),
        MockComponent.plainText("\\(text"),
        MockComponent.token(")", TokenType.string),
        MockComponent.plainText("]"),
        MockComponent.token("\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithInterpolationPrefixedByPunctuation() {
    let components = highlightToComponents("\".\\(text)\"")
    let expected = [
        MockComponent.token("\".", TokenType.string),
        MockComponent.plainText("\\(text"),
        MockComponent.token(")\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralWithInterpolationContainingString() {
    let components = highlightToComponents("\"\\(name ?? \"name\")\"")
    let expected = [
        MockComponent.token("\"", TokenType.string),
        MockComponent.plainText("\\(name"),
        MockComponent.whitespace(" "),
        MockComponent.token("??", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("\"name\")\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testMultiLineStringLiteral() {
    let components = highlightToComponents("let string = \"\"\"\nHello \\(variable)\n\"\"\"")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("string"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("\"\"\"", TokenType.string),
        MockComponent.whitespace("\n"),
        MockComponent.token("Hello", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\(variable"),
        MockComponent.token(")", TokenType.string),
        MockComponent.whitespace("\n"),
        MockComponent.token("\"\"\"", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSingleLineRawStringLiteral() {
    let components = highlightToComponents("#\"A raw string \\(withoutInterpolation) yes\"#")
    let expected = [
        MockComponent.token("#\"A", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("raw", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("string", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("\\(withoutInterpolation)", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("yes\"#", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testMultiLineRawStringLiteral() {
    let components = highlightToComponents("#\"\"\"\nA raw string \\(withoutInterpolation)\nwith multiple lines. #\" Nested \"#\n\"\"\"#")
    let expected = [
        MockComponent.token("#\"\"\"", TokenType.string),
        MockComponent.whitespace("\n"),
        MockComponent.token("A", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("raw", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("string", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("\\(withoutInterpolation)", TokenType.string),
        MockComponent.whitespace("\n"),
        MockComponent.token("with", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("multiple", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("lines.", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("#\"", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("Nested", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("\"#", TokenType.string),
        MockComponent.whitespace("\n"),
        MockComponent.token("\"\"\"#", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testRawStringWithInterpolation() {
    let components = highlightToComponents("#\"Hello \\#(variable) world\"#")
    let expected = [
        MockComponent.token("#\"Hello", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\#(variable"),
        MockComponent.token(")", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.token("world\"#", TokenType.string)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testStringLiteralContainingOnlyNewLine() {
    let components = highlightToComponents("text.split(separator: \"\\n\")")
    let expected = [
        MockComponent.plainText("text."),
        MockComponent.token("split", TokenType.call),
        MockComponent.plainText("(separator:"),
        MockComponent.whitespace(" "),
        MockComponent.token("\"\\n\"", TokenType.string),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testDoubleLiteral() {
    let components = highlightToComponents("let double = 1.13")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("double"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("1.13", TokenType.number)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testIntegerLiteralWithSeparators() {
    let components = highlightToComponents("let int = 1_000_000")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("int"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("1_000_000", TokenType.number)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testKeyPathLiteral() {
    let components = highlightToComponents("let value = object[keyPath: \\.property]")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("object[keyPath:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\."),
        MockComponent.token("property", TokenType.property),
        MockComponent.plainText("]")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testKeyPathLiteralsAsArguments() {
    let components = highlightToComponents("user.bind(\\.name, to: \\.text)")
    let expected = [
        MockComponent.plainText("user."),
        MockComponent.token("bind", TokenType.call),
        MockComponent.plainText("(\\."),
        MockComponent.token("name", TokenType.property),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("to:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("\\."),
        MockComponent.token("text", TokenType.property),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
