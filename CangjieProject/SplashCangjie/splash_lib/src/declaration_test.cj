package splash_lib

import std.unittest.*

@Test
func testFunctionDeclaration() {
    let components = highlightToComponents("func hello(world: String) -> Int")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello(world:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testRequiredFunctionDeclaration() {
    let components = highlightToComponents("required func hello()")
    let expected = [
        MockComponent.token("required", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPublicFunctionDeclarationWithDocumentationEndingWithDot() {
    let components = highlightToComponents("/// Documentation.\npublic func hello()")
    let expected = [
        MockComponent.token("///", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Documentation.", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("public", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello()")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithEmptyExternalLabel() {
    let components = highlightToComponents("func a(_ b: B)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("a("),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("b:"),
        MockComponent.whitespace(" "),
        MockComponent.token("B", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithKeywordArgumentLabel() {
    let components = highlightToComponents("func a(for b: B)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("a(for"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("b:"),
        MockComponent.whitespace(" "),
        MockComponent.token("B", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithKeywordArgumentLabelOnNewLine() {
    let components = highlightToComponents("func a(\n    for b: B\n)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("a("),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("for"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("b:"),
        MockComponent.whitespace(" "),
        MockComponent.token("B", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericFunctionDeclarationWithKeywordArgumentLabel() {
    let components = highlightToComponents("func perform<O: AnyObject>(for object: O) {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("perform<O:"),
        MockComponent.whitespace(" "),
        MockComponent.token("AnyObject", TokenType.`type`),
        MockComponent.plainText(">(for"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("object:"),
        MockComponent.whitespace(" "),
        MockComponent.token("O", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericFunctionDeclarationWithoutConstraints() {
    let components = highlightToComponents("func hello<A, B>(a: A, b: B)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello<A,"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("B>(a:"),
        MockComponent.whitespace(" "),
        MockComponent.token("A", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("b:"),
        MockComponent.whitespace(" "),
        MockComponent.token("B", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericFunctionDeclarationWithSingleConstraint() {
    let components = highlightToComponents("func hello<T: AnyObject>(t: T)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello<T:"),
        MockComponent.whitespace(" "),
        MockComponent.token("AnyObject", TokenType.`type`),
        MockComponent.plainText(">(t:"),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericFunctionDeclarationWithMultipleConstraints() {
    let components = highlightToComponents("func hello<A: AnyObject, B: Sequence>(a: A, b: B)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello<A:"),
        MockComponent.whitespace(" "),
        MockComponent.token("AnyObject", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("B:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Sequence", TokenType.`type`),
        MockComponent.plainText(">(a:"),
        MockComponent.whitespace(" "),
        MockComponent.token("A", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("b:"),
        MockComponent.whitespace(" "),
        MockComponent.token("B", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericFunctionDeclarationWithGenericParameter() {
    let components = highlightToComponents("func value<T>(at keyPath: KeyPath<Element, T>) -> T? {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value<T>(at"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("keyPath:"),
        MockComponent.whitespace(" "),
        MockComponent.token("KeyPath", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("Element", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText(">)"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText("?"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithGenericReturnType() {
    let components = highlightToComponents("func array() -> Array<Element> { return [] }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("array()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Array", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("Element", TokenType.`type`),
        MockComponent.plainText(">"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("return", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("[]"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericStructDeclaration() {
    let components = highlightToComponents("struct MyStruct<A: Hello, B> {}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyStruct<A:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Hello", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("B>"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClassDeclaration() {
    let components = highlightToComponents("class Hello {\n    var required: String\n    var optional: Int?\n}")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("required:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("optional:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.plainText("?"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testCompactClassDeclarationWithInitializer() {
    let components = highlightToComponents("class Foo { init(hello: Int) {} }")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Foo"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.plainText("(hello:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClassDeclarationWithDeinit() {
    let components = highlightToComponents("class Foo { deinit {} }")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Foo"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("deinit", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testClassDeclarationWithMultipleProtocolConformances() {
    let components = highlightToComponents("class MyClass: ProtocolA, ProtocolB {}")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyClass:"),
        MockComponent.whitespace(" "),
        MockComponent.token("ProtocolA", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.token("ProtocolB", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSubclassDeclaration() {
    let components = highlightToComponents("class ViewController: UIViewController { }")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("ViewController:"),
        MockComponent.whitespace(" "),
        MockComponent.token("UIViewController", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericSubclassDeclaration() {
    let components = highlightToComponents("class Promise<Value>: Future<Value> {}")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Promise<Value>:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Future", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.plainText(">"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testProtocolDeclaration() {
    let components = highlightToComponents("protocol Hello {\n    var property: String { get set }\n    func method()\n}")
    let expected = [
        MockComponent.token("protocol", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("get", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("set", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("method()"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testProtocolDeclarationWithAssociatedTypes() {
    let components = highlightToComponents("protocol Task {\n    associatedtype Input\n    associatedtype Error: Swift.Error\n}")
    let expected = [
        MockComponent.token("protocol", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Task"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("associatedtype", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Input"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("associatedtype", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Error:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Swift", TokenType.`type`),
        MockComponent.plainText("."),
        MockComponent.token("Error", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testExtensionDeclaration() {
    let components = highlightToComponents("extension UIViewController { }")
    let expected = [
        MockComponent.token("extension", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("UIViewController", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testExtensionDeclarationWithConvenienceInitializer() {
    let components = highlightToComponents("extension Node { convenience init(name: String) { self.init() } }")
    let expected = [
        MockComponent.token("extension", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Node", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("convenience", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.plainText("(name:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("self", TokenType.keyword),
        MockComponent.plainText("."),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testExtensionDeclarationWithConstraint() {
    let components = highlightToComponents("extension Hello where Foo == String, Bar: Numeric { }")
    let expected = [
        MockComponent.token("extension", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Hello", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.token("where", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Foo", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("=="),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.token("Bar", TokenType.`type`),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("Numeric", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testLazyPropertyDeclaration() {
    let components = highlightToComponents("struct Hello {\n    lazy var property = 0\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("lazy", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("0", TokenType.number),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testDynamicPropertyDeclaration() {
    let components = highlightToComponents("class Hello {\n    @objc dynamic var property = 0\n}")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("@objc", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("dynamic", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("0", TokenType.number),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericPropertyDeclaration() {
    let components = highlightToComponents("class Hello { var array: Array<String> = [] }")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("array:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Array", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(">"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("[]"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyDeclarationWithWillSet() {
    let components = highlightToComponents("struct Hello {\n    var property: Int { willSet { } }\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("willSet", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyDeclarationWithDidSet() {
    let components = highlightToComponents("struct Hello {\n    var property: Int { didSet { } }\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("didSet", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyWithCommentedDidSet() {
    let components = highlightToComponents("struct Hello {\n    var property: Int {\n        // Comment.\n        didSet { }\n    }\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n        "),
        MockComponent.token("//", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("Comment.", TokenType.comment),
        MockComponent.whitespace("\n        "),
        MockComponent.token("didSet", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n    "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyWithSetterAccessLevel() {
    let components = highlightToComponents("struct Hello {\n    private(set) var property: Int\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Hello"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("private(set)", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("property:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyDeclarationAfterCommentEndingWithVarKeyword() {
    let components = highlightToComponents("// var\nvar number = 7")
    let expected = [
        MockComponent.token("//", TokenType.comment),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.comment),
        MockComponent.whitespace("\n"),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("number"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("7", TokenType.number)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyDeclarationWithStaticPropertyDefaultValue() {
    let components = highlightToComponents("class ViewModel {\n    var state = LoadingState<Output>.idle\n}")
    let expected = [
        MockComponent.token("class", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("ViewModel"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("state"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("LoadingState", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("Output", TokenType.`type`),
        MockComponent.plainText(">."),
        MockComponent.token("idle", TokenType.property),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testSubscriptDeclaration() {
    let components = highlightToComponents("extension Collection {\n    subscript(key: Key) -> Value? { return nil }\n}")
    let expected = [
        MockComponent.token("extension", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Collection", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("subscript", TokenType.keyword),
        MockComponent.plainText("(key:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Key", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.plainText("?"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("return", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("nil", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericSubscriptDeclaration() {
    let components = highlightToComponents("extension Collection {\n    subscript<T>(key: Key<T>) -> T? { return nil }\n}")
    let expected = [
        MockComponent.token("extension", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Collection", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("subscript", TokenType.keyword),
        MockComponent.plainText("<T>(key:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Key", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText(">)"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText("?"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("return", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("nil", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testDeferDeclaration() {
    let components = highlightToComponents("func hello() { defer {} }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("hello()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("defer", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithInOutParameter() {
    let components = highlightToComponents("func swapValues(value1: inout Int, value2: inout Int) { }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("swapValues(value1:"),
        MockComponent.whitespace(" "),
        MockComponent.token("inout", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value2:"),
        MockComponent.whitespace(" "),
        MockComponent.token("inout", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithIgnoredParameter() {
    let components = highlightToComponents("func perform(with _: Void) {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("perform(with"),
        MockComponent.whitespace(" "),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("Void", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithNonEscapedKeywordAsName() {
    let components = highlightToComponents("func get() -> Int { return 7 }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("get()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("return", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("7", TokenType.number),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithEscapedKeywordAsName() {
    let components = highlightToComponents("func `public`() -> Int { return 7 }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("`public`()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("return", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("7", TokenType.number),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithPreProcessors() {
    let components = highlightToComponents("func log(_ file: StaticString = #file, _ function: StaticString = #function) {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("log("),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("file:"),
        MockComponent.whitespace(" "),
        MockComponent.token("StaticString", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("#file", TokenType.keyword),
        MockComponent.plainText(","),
        MockComponent.whitespace(" "),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("function:"),
        MockComponent.whitespace(" "),
        MockComponent.token("StaticString", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("#function", TokenType.keyword),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testNonMutatingFunction() {
    let components = highlightToComponents("struct MyStruct {\n    nonmutating func doNotChangeState() { }\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyStruct"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("nonmutating", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("doNotChangeState()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testRethrowingFunctionDeclaration() {
    let components = highlightToComponents("func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("map<T>("),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("transform:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("("),
        MockComponent.token("Element", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.token("throws", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.token("rethrows", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("["),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText("]")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithOpaqueReturnType() {
    let components = highlightToComponents("func make() -> some View { Text(\"!\") }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("make()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("some", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("View", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("Text", TokenType.`type`),
        MockComponent.plainText("("),
        MockComponent.token("\"!\"", TokenType.string),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithAnyParameter() {
    let components = highlightToComponents("func process(value: any Value)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("process(value:"),
        MockComponent.whitespace(" "),
        MockComponent.token("any", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.plainText(")")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithGenericAnyParameter() {
    let components = highlightToComponents("func process(collection: any Collection<any Value>)")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("process(collection:"),
        MockComponent.whitespace(" "),
        MockComponent.token("any", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Collection", TokenType.`type`),
        MockComponent.plainText("<"),
        MockComponent.token("any", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.plainText(">)")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testFunctionDeclarationWithAnyDictionary() {
    let components = highlightToComponents("func process(dictionary: [String: any Value])")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("process(dictionary:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("["),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(":"),
        MockComponent.whitespace(" "),
        MockComponent.token("any", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.plainText("])")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPrefixFunctionDeclaration() {
    let components = highlightToComponents("prefix func !(rhs: Bool) -> Bool { !rhs }")
    let expected = [
        MockComponent.token("prefix", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("!(rhs:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Bool", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Bool", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("!rhs"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testEnumDeclarationWithSomeCase() {
    let components = highlightToComponents("enum MyEnum { case some }")
    let expected = [
        MockComponent.token("enum", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyEnum"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("some"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testIndirectEnumDeclaration() {
    let components = highlightToComponents("indirect enum Content {\n    case single(String)\n    case collection([Content])\n}")
    let expected = [
        MockComponent.token("indirect", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("enum", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Content"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("single("),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("case", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("collection(["),
        MockComponent.token("Content", TokenType.`type`),
        MockComponent.plainText("])"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPropertyWrapperDeclaration() {
    let components = highlightToComponents("@propertyWrapper\nstruct Wrapped<Value> {\n    var wrappedValue: Value\n}")
    let expected = [
        MockComponent.token("@propertyWrapper", TokenType.keyword),
        MockComponent.whitespace("\n"),
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Wrapped<Value>"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("wrappedValue:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Value", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testWrappedPropertyDeclarations() {
    let components = highlightToComponents("struct User {\n    @Persisted(key: \"name\") var name: String\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("User"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("@Persisted", TokenType.keyword),
        MockComponent.plainText("(key:"),
        MockComponent.whitespace(" "),
        MockComponent.token("\"name\"", TokenType.string),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("name:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testWrappedPropertyDeclarationUsingNestedType() {
    let components = highlightToComponents("struct User {\n    @Persisted.InMemory var name: String\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("User"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("@Persisted", TokenType.keyword),
        MockComponent.plainText("."),
        MockComponent.token("InMemory", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("name:"),
        MockComponent.whitespace(" "),
        MockComponent.token("String", TokenType.`type`),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testWrappedPropertyDeclarationUsingExplicitType() {
    let components = highlightToComponents("struct Model {\n    @Wrapper<Bool>(key: \"setting\")\n    var setting\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Model"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("@Wrapper", TokenType.keyword),
        MockComponent.plainText("<"),
        MockComponent.token("Bool", TokenType.`type`),
        MockComponent.plainText(">(key:"),
        MockComponent.whitespace(" "),
        MockComponent.token("\"setting\"", TokenType.string),
        MockComponent.plainText(")"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("setting"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testGenericInitializerDeclaration() {
    let components = highlightToComponents("struct Box {\n    init<T: Model>(model: T) {}\n}")
    let expected = [
        MockComponent.token("struct", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("Box"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("init", TokenType.keyword),
        MockComponent.plainText("<T:"),
        MockComponent.whitespace(" "),
        MockComponent.token("Model", TokenType.`type`),
        MockComponent.plainText(">(model:"),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testNonThrowingAsyncFunctionDeclaration() {
    let components = highlightToComponents("func test() async {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("test()"),
        MockComponent.whitespace(" "),
        MockComponent.token("async", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testNonThrowingAsyncFunctionDeclarationWithReturnValue() {
    let components = highlightToComponents("func test() async -> Int { 0 }")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("test()"),
        MockComponent.whitespace(" "),
        MockComponent.token("async", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("Int", TokenType.`type`),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace(" "),
        MockComponent.token("0", TokenType.number),
        MockComponent.whitespace(" "),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testThrowingAsyncFunctionDeclaration() {
    let components = highlightToComponents("func test() async throws {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("test()"),
        MockComponent.whitespace(" "),
        MockComponent.token("async", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("throws", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testDeclaringGenericFunctionNamedAwait() {
    let components = highlightToComponents("func await<T>(_ function: () -> T) {}")
    let expected = [
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("await<T>("),
        MockComponent.token("_", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("function:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("->"),
        MockComponent.whitespace(" "),
        MockComponent.token("T", TokenType.`type`),
        MockComponent.plainText(")"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testActorDeclaration() {
    let components = highlightToComponents("actor MyActor {\n    var value = 0\n    func action() {}\n}")
    let expected = [
        MockComponent.token("actor", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyActor"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{"),
        MockComponent.whitespace("\n    "),
        MockComponent.token("var", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("value"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("0", TokenType.number),
        MockComponent.whitespace("\n    "),
        MockComponent.token("func", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("action()"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPublicActorDeclaration() {
    let components = highlightToComponents("public actor MyActor {}")
    let expected = [
        MockComponent.token("public", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.token("actor", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("MyActor"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("{}")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testDeclaringAndMutatingLocalVariableNamedActor() {
    let components = highlightToComponents("let actor = Actor()\nactor.position = scene.center")
    let expected = [
        MockComponent.token("let", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("actor"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.token("Actor", TokenType.`type`),
        MockComponent.plainText("()"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("actor."),
        MockComponent.token("position", TokenType.property),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("scene."),
        MockComponent.token("center", TokenType.property)
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}

@Test
func testPassingAndReferencingLocalVariableNamedActor() {
    let components = highlightToComponents("prepare(actor: actor)\nscene.add(actor)\nlatestActor = actor\nreturn actor")
    let expected = [
        MockComponent.token("prepare", TokenType.call),
        MockComponent.plainText("(actor:"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("actor)"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("scene."),
        MockComponent.token("add", TokenType.call),
        MockComponent.plainText("(actor)"),
        MockComponent.whitespace("\n"),
        MockComponent.plainText("latestActor"),
        MockComponent.whitespace(" "),
        MockComponent.plainText("="),
        MockComponent.whitespace(" "),
        MockComponent.plainText("actor"),
        MockComponent.whitespace("\n"),
        MockComponent.token("return", TokenType.keyword),
        MockComponent.whitespace(" "),
        MockComponent.plainText("actor")
    ]
    @Expect(assertComponentsEqual(components, expected), true)
}
