package splash_lib

import std.unittest.*

@Test
func testAssigningPropertyWithOptionalChaining() {
    let components = highlightToComponents("object?.property = true")
    let expected = [
        MockComponent.plainText("object?."),
        MockComponent.token("property", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("true", TokenType.keyword)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testReadingPropertyWithOptionalChaining() {
    let components = highlightToComponents("call(object?.property)")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("(object?."),
        MockComponent.token("property", TokenType.property),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCallingMethodWithOptionalChaining() {
    let components = highlightToComponents("object?.call()")
    let expected = [
        MockComponent.plainText("object?."),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
