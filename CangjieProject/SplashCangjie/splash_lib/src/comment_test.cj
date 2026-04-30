package splash_lib

import std.unittest.*

@Test
func testSingleLineComment() {
    let components = highlightToComponents("call() // Hello call() var \"string\"\ncall()")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.token("//", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Hello", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("call()", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("\"string\"", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testMultiLineComment() {
    let components = highlightToComponents("struct Foo {}\n/* Comment\n    Hello!\n*/ call()")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Foo"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace("\n"),
        MockComponent.token("/*", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Comment", TokenType.comment),
        MockComponent.whitespace("\n    "),
        MockComponent.token("Hello!", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("*/", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testMultiLineCommentWithDoubleAsterisks() {
    let components = highlightToComponents("struct Foo {}\n/** Comment\n    Hello!\n*/ call()")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Foo"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace("\n"),
        MockComponent.token("/**", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Comment", TokenType.comment),
        MockComponent.whitespace("\n    "),
        MockComponent.token("Hello!", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("*/", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("call", TokenType.call),
        MockComponent.plainText("()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testMutliLineDocumentationComment() {
    let components = highlightToComponents("/**\n *  Documentation\n */\nclass MyClass {}")
    let expected = [
        MockComponent.token("/**", TokenType.comment),
        MockComponent.whitespace("\n "),
        MockComponent.token("*", TokenType.comment),
        MockComponent.whitespace("  "),
        MockComponent.token("Documentation", TokenType.comment),
        MockComponent.whitespace("\n "),
        MockComponent.token("*/", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyClass"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentStartingWithPunctuation() {
    let components = highlightToComponents("//.call()")
    let expected = [
        MockComponent.token("//.call()", TokenType.comment)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentEndingWithComma() {
    let components = highlightToComponents("// Hello,\nclass World {}")
    let expected = [
        MockComponent.token("//", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Hello,", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("World"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentPrecededByComma() {
    let components = highlightToComponents("func find(\n    string: String,//TODO: Remove\n    options: Options\n)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("find("),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("string:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.token("//TODO:", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Remove", TokenType.comment),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("options:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Options", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentWithNumber() {
    let components = highlightToComponents("// 1")
    let expected = [
        MockComponent.token("//", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("1", TokenType.comment)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentWithNoWhiteSpaceToPunctuation() {
    let components = highlightToComponents("(/* Hello */)\n.// World\n(/**/)")
    let expected = [
        MockComponent.plainText("("),
        MockComponent.token("/*", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Hello", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("*/", TokenType.comment),
        MockComponent.plainText(")"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("."),
        MockComponent.token("//", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("World", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("("),
        MockComponent.token("/**/", TokenType.comment),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentsNextToCurlyBrackets() {
    let components = highlightToComponents("call {//commentA\n}//commentB")
    let expected = [
        MockComponent.token("call", TokenType.call),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.token("//commentA", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}"),
        MockComponent.token("//commentB", TokenType.comment)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentWithinGenericTypeList() {
    let components = highlightToComponents("struct Box<One, /*Comment*/Two: Equatable, Three> {}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Box<One,"),
        MockComponent.whitespace(" "),
        MockComponent.token("/*Comment*/", TokenType.comment),
        MockComponent.plainText("Two:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Equatable", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Three>"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentsNextToGenericTypeList() {
    let components = highlightToComponents("struct Box/*Start*/<Content>/*End*/ {}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Box"),
        MockComponent.token("/*Start*/", TokenType.comment),
        MockComponent.plainText("<Content>"),
        MockComponent.token("/*End*/", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentsNextToInitialization() {
    let components = highlightToComponents("/*Start*/Object()/*End*/")
    let expected = [
        MockComponent.token("/*Start*/", TokenType.comment),
        MockComponent.token("Object", TokenType.`type`),
        MockComponent.plainText("()"),
        MockComponent.token("/*End*/", TokenType.comment)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentsNextToProtocolName() {
    let components = highlightToComponents("struct Model<Value>: /*Start*/Equatable/*End*/ {}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Model<Value>:"),
        MockComponent.whitespace(" "),
        MockComponent.token("/*Start*/", TokenType.comment),
        MockComponent.token("Equatable", TokenType.`type`),
        MockComponent.token("/*End*/", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentsAfterOptionalTypes() {
    let components = highlightToComponents("struct Model {\n    var one: String?//One\n    var two: String?/*Two*/\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Model"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("one:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("?"),
        MockComponent.token("//One", TokenType.comment),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("two:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("?"),
        MockComponent.token("/*Two*/", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCommentsAfterArrayTypes() {
    let components = highlightToComponents("struct Model {\n    var one: [String]//One\n    var two: [String]/*Two*/\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Model"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("one:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("["),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("]"),
        MockComponent.token("//One", TokenType.comment),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("two:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("["),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText("]"),
        MockComponent.token("/*Two*/", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
