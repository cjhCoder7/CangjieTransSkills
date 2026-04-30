package splash_lib

import std.unittest.*

@Test
func testTrailingClosureWithArguments() {
    let components = highlightToComponents("call() { arg in }")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("arg"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testTrailingClosureWithoutParanthesis() {
    let components = highlightToComponents("call { $0 }")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("$0"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testEmptyTrailingClosure() {
    let components = highlightToComponents("call {}")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureArgumentWithSingleArgument() {
    let components = highlightToComponents("func add(closure: (String) -> Void)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("add(closure:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("("),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureArgumentWithMultipleArguments() {
    let components = highlightToComponents("func add(closure: (String, Int) -> Void)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("add(closure:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("("),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testEscapingClosureArgument() {
    let components = highlightToComponents("func add(closure: @escaping () -> Void)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("add(closure:"),
        MockComponent.whitespace(" "),
        MockComponent.token("@escaping", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureWithInoutArgument() {
    let components = highlightToComponents("func add(closure: (inout Value) -> Void)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("add(closure:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("("),
        MockComponent.token("inout", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPassingClosureAsArgument() {
    let components = highlightToComponents("object.call({ $0 })")
    let expected = [
        MockComponent.plainText("object."),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("({"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("$0"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("})")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testNestedEscapingClosure() {
    let components = highlightToComponents("let closures = [(@escaping () -> Void) -> Void]()")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("closures"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("[("),
        MockComponent.token("@escaping", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText("]()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureArgumentShorthands() {
    let components = highlightToComponents("call {\n    print($0)\n    _ = $1\n    $2()\n}")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("print", TokenType.call),
        MockComponent.plainText("($0)"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("$1"),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("$2()"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureWithWeakSelfCaptureList() {
    let components = highlightToComponents("closure { [weak self] in }")
    let expected = [
        MockComponent.token("closure", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("["),
        MockComponent.token("weak", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.plainText("]"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureWithUnownedSelfCaptureList() {
    let components = highlightToComponents("closure { [unowned self] in }")
    let expected = [
        MockComponent.token("closure", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("["),
        MockComponent.token("unowned", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.plainText("]"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClosureWithSingleFunctionCall() {
    let components = highlightToComponents("closure { a in call(a) }")
    let expected = [
        MockComponent.token("closure", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("a"),
        MockComponent.whitespace(" "),
        MockComponent.token("in", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("(a)"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
