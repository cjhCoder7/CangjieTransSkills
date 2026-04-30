package splash_lib

import std.unittest.*

@Test
func testEnumDotSyntaxInAssignment() {
    let components = highlightToComponents("let value: Enum = .aCase")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Enum", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("aCase", TokenType.dotAccess)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testEnumDotSyntaxAsArgument() {
    let components = highlightToComponents("call(.aCase)")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("(."),
        MockComponent.token("aCase", TokenType.dotAccess),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testEnumDotSyntaxWithAssociatedValueTreatedAsCall() {
    let components = highlightToComponents("call(.error(error))")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("(."),
        MockComponent.token("error", TokenType.call),
        MockComponent.plainText("(error))")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testUsingEnumInSubscript() {
    let components = highlightToComponents("dictionary[.key]")
    let expected = [
        MockComponent.plainText("dictionary[."),
        MockComponent.token("key", TokenType.dotAccess),
        MockComponent.plainText("]")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
