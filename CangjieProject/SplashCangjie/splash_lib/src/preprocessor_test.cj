package splash_lib

import std.unittest.*

@Test
func testPreprocessing() {
    let components = highlightToComponents("#if os(iOS)\ncall()\n#endif")
    let expected = [
        MockComponent.token("#if", TokenType.preprocessing),
        MockComponent.whitespace(" "),
        MockComponent.token("os(iOS)", TokenType.preprocessing),
        MockComponent.whitespace("\n"),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace("\n"),
        MockComponent.token("#endif", TokenType.preprocessing)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSelector() {
    let components = highlightToComponents("addObserver(self, selector: #selector(function(_:)))")
    let expected = [
        MockComponent.token("addObserver", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("selector:"),
        MockComponent.whitespace(" "),
        MockComponent.token("#selector", TokenType.keyword),
        MockComponent.plainText("("),
        MockComponent.token("function", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.plainText(":)))")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionAttribute() {
    let components = highlightToComponents("@NSApplicationMain class AppDelegate {}")
    let expected = [
        MockComponent.token("@NSApplicationMain", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("AppDelegate"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAvailabilityCheck() {
    let components = highlightToComponents("if #available(iOS 13, *) {}")
    let expected = [
        MockComponent.token("if", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("#available", TokenType.keyword),
        MockComponent.plainText("(iOS"),
        MockComponent.whitespace(" "),
        MockComponent.token("13", TokenType.number),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("*)"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testWarningDirective() {
    let components = highlightToComponents("#warning(\"Hey!\")")
    let expected = [
        MockComponent.token("#warning", TokenType.preprocessing),
        MockComponent.plainText("("),
        MockComponent.token("\"Hey!\"", TokenType.string),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testErrorDirective() {
    let components = highlightToComponents("#error(\"No!\")")
    let expected = [
        MockComponent.token("#error", TokenType.preprocessing),
        MockComponent.plainText("("),
        MockComponent.token("\"No!\"", TokenType.string),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
