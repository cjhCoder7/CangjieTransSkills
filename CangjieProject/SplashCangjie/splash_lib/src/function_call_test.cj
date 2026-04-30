package splash_lib

import std.unittest.*

@Test
func testFunctionCallWithIntegers() {
    let components = highlightToComponents("add(1, 2)")
    let expected = [
        MockComponent.token("add", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("1", TokenType.number),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.token("2", TokenType.number),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionCallWithNil() {
    let components = highlightToComponents("handler(nil)")
    let expected = [
        MockComponent.token("handler", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("nil", TokenType.keyword),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testImplicitInitializerCall() {
    let components = highlightToComponents("let string = String()")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("string"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testExplicitInitializerCall() {
    let components = highlightToComponents("let string = String.init()")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("string"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("."),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testExplicitInitializerCallUsingTrailingClosureSyntax() {
    let components = highlightToComponents("let task = Task.init {}")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("task"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("Task", TokenType.`type`),
        MockComponent.plainText("."),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testDotSyntaxInitializerCall() {
    let components = highlightToComponents("let string: String = .init()")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("string:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAccessingPropertyAfterFunctionCallWithoutArguments() {
    let components = highlightToComponents("call().property")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()."),
        MockComponent.token("property", TokenType.property)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAccessingPropertyAfterFunctionCallWithArguments() {
    let components = highlightToComponents("call(argument).property")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("(argument)."),
        MockComponent.token("property", TokenType.property)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCallingStaticMethodOnGenericType() {
    let components = highlightToComponents("Array<String>.call()")
    let expected = [
        MockComponent.token("Array", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(">."),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPassingTypeToFunction() {
    let components = highlightToComponents("call(String.self)")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("."),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPassingBoolToUnnamedArgument() {
    let components = highlightToComponents("setCachingEnabled(true)")
    let expected = [
        MockComponent.token("setCachingEnabled", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("true", TokenType.keyword),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testIndentedFunctionCalls() {
    let components = highlightToComponents("variable\n    .callOne()\n    .callTwo()")
    let expected = [
        MockComponent.plainText("variable"),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("."),
        MockComponent.token("callOne", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("."),
        MockComponent.token("callTwo", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testXCTAssertCalls() {
    let components = highlightToComponents("XCTAssertTrue(variable)")
    let expected = [
        MockComponent.token("XCTAssertTrue", TokenType.call),
        MockComponent.plainText("(variable)")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testUsingTryKeywordWithinFunctionCall() {
    let components = highlightToComponents("XCTAssertThrowsError(try function())")
    let expected = [
        MockComponent.token("XCTAssertThrowsError", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("try", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("function", TokenType.call),
        MockComponent.plainText("())")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCallingFunctionsWithProjectedPropertyWrapperValues() {
    let components = highlightToComponents("call($value)\ncall(self.$value)")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("$value", TokenType.property),
        MockComponent.plainText(")"),
        MockComponent.whitespace("\n"),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("("),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.plainText("."),
        MockComponent.token("$value", TokenType.property),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCallingFunctionWithInoutProjectedPropertyWrapperValue() {
    let components = highlightToComponents("call(&$value)")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("(&"),
        MockComponent.token("$value", TokenType.property),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCallingMethodWithSameNameAsKeywordWithTrailingClosureSyntax() {
    let components = highlightToComponents("publisher.catch { error in }")
    let expected = [
        MockComponent.plainText("publisher."),
        MockComponent.token("catch", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("error"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
