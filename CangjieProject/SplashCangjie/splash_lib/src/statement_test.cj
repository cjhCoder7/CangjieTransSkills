package splash_lib

import std.unittest.*

@Test
func testImportStatement() {
    let components = highlightToComponents("import UIKit")
    let expected = [
        MockComponent.token("import", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("UIKit")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testImportStatementWithSubmodule() {
    let components = highlightToComponents("import os.log")
    let expected = [
        MockComponent.token("import", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("os.log")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testChainedIfElseStatements() {
    let components = highlightToComponents("if condition { } else if call() { } else { \"string\" }")
    let expected = [
        MockComponent.token("if", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("condition"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace(" "),
        MockComponent.token("else", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("if", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace(" "),
        MockComponent.token("else", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("\"string\"", TokenType.string),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testIfLetStatementWithKeywordSymbolName() {
    let components = highlightToComponents("if let override = optional {}")
    let expected = [
        MockComponent.token("if", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("override"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("optional"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGuardStatementUnwrappingWeakSelf() {
    let components = highlightToComponents("guard let self = self else {}")
    let expected = [
        MockComponent.token("guard", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("else", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatement() {
    let components = highlightToComponents("switch variable {\ncase .one: break\ncase .two: callA()\ndefault:\n    callB()\n}")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("variable"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("one", TokenType.dotAccess),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("two", TokenType.dotAccess),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("callA", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace("\n"),
        MockComponent.token("default", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("callB", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatementWithSingleAssociatedValue() {
    let components = highlightToComponents("switch value {\ncase .one(let a): break\n}")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("one", TokenType.dotAccess),
        MockComponent.plainText("("),
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("a):"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatementWithMultipleAssociatedValues() {
    let components = highlightToComponents("switch value {\ncase .one(let a), .two(let b): break\n}")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("one", TokenType.dotAccess),
        MockComponent.plainText("("),
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("a),"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("two", TokenType.dotAccess),
        MockComponent.plainText("("),
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("b):"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatementWithFallthrough() {
    let components = highlightToComponents("switch variable {\ncase .one: fallthrough\ndefault:\n    callB()\n}")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("variable"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("."),
        MockComponent.token("one", TokenType.dotAccess),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("fallthrough", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.token("default", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("callB", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatementWithTypePatternMatching() {
    let components = highlightToComponents("switch variable {\ncase is MyType: break\ndefault: break\n}")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("variable"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("is", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("MyType", TokenType.`type`),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.token("default", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatementWithOptional() {
    let components = highlightToComponents("switch anOptional {\ncase nil: break\ncase \"value\"?: break\ndefault: break\n}")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("anOptional"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("nil", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("\"value\"", TokenType.string),
        MockComponent.plainText("?:"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.token("default", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSwitchStatementWithProperty() {
    let components = highlightToComponents("switch object.value { default: break }")
    let expected = [
        MockComponent.token("switch", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("object."),
        MockComponent.token("value", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("default", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("break", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testForStatementWithStaticProperty() {
    let components = highlightToComponents("for value in Enum.allCases { }")
    let expected = [
        MockComponent.token("for", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Enum", TokenType.`type`),
        MockComponent.plainText("."),
        MockComponent.token("allCases", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testForStatementWithContinue() {
    let components = highlightToComponents("for value in Enum.allCases { continue }")
    let expected = [
        MockComponent.token("for", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Enum", TokenType.`type`),
        MockComponent.plainText("."),
        MockComponent.token("allCases", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("continue", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testRepeatWhileStatement() {
    let components = highlightToComponents("var x = 5\nrepeat {\n    print(x)\n    x = x - 1\n} while x > 1")
    let expected = [
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("x"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("5", TokenType.number),
        MockComponent.whitespace("\n"),
        MockComponent.token("repeat", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("print", TokenType.call),
        MockComponent.plainText("(x)"),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("x"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("x"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("-"),
        MockComponent.whitespace(" "),
        MockComponent.token("1", TokenType.number),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}"),
        MockComponent.whitespace(" "),
        MockComponent.token("while", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("x"),
        MockComponent.whitespace(" "),
        MockComponent.plainText(">"),
        MockComponent.whitespace(" "),
        MockComponent.token("1", TokenType.number)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testInitializingTypeWithLeadingUnderscore() {
    let components = highlightToComponents("_MyType()")
    let expected = [
        MockComponent.token("_MyType", TokenType.`type`),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCallingFunctionWithLeadingUnderscore() {
    let components = highlightToComponents("_myFunction()")
    let expected = [
        MockComponent.token("_myFunction", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testTernaryOperationContainingNil() {
    let components = highlightToComponents("components.queryItems = queryItems.isEmpty ? nil : queryItems")
    let expected = [
        MockComponent.plainText("components."),
        MockComponent.token("queryItems", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("queryItems."),
        MockComponent.token("isEmpty", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("?"),
        MockComponent.whitespace(" "),
        MockComponent.token("nil", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("queryItems")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAwaitingFunctionCall() {
    let components = highlightToComponents("let result = await call()")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("result"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("await", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAwaitingVariable() {
    let components = highlightToComponents("let result = await value")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("result"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("await", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAwaitingAsyncSequenceElement() {
    let components = highlightToComponents("for await value in sequence {}")
    let expected = [
        MockComponent.token("for", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("await", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("sequence"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAwaitingThrowingAsyncSequenceElement() {
    let components = highlightToComponents("for try await value in sequence {}")
    let expected = [
        MockComponent.token("for", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("try", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("await", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("sequence"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testAsyncLetExpression() {
    let components = highlightToComponents("async let result = call()")
    let expected = [
        MockComponent.token("async", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("result"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
