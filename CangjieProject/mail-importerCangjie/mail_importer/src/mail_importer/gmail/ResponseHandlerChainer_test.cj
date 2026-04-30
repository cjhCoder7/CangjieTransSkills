package mail_importer.gmail

// 用 Cell 包装可变状态，避免 lambda 捕获可变变量
class BoolCell {
    var value: Bool = false
    public init() {}
}

@Test
class ResponseHandlerChainerTest {

    @TestCase
    func testChainOfZero(): Unit {
        let chainer = ResponseHandlerChainer()
        let handler = chainer.chain([])

        let result = handler((), (), true)
        @Expect(result, false)
    }

    @TestCase
    func testChainOfOne(): Unit {
        let chainer = ResponseHandlerChainer()
        let handler1Called = BoolCell()
        let handler1 = { _: Any, _: Any, _: Bool =>
            handler1Called.value = true
            false
        }

        let handler = chainer.chain([handler1])
        handler((), (), true)

        @Expect(handler1Called.value, true)
    }

    @TestCase
    func testChainOfTwo(): Unit {
        let chainer = ResponseHandlerChainer()
        let handler1Called = BoolCell()
        let handler2Called = BoolCell()
        let handler1 = { _: Any, _: Any, _: Bool =>
            handler1Called.value = true
            false
        }
        let handler2 = { _: Any, _: Any, _: Bool =>
            handler2Called.value = true
            false
        }

        let handler = chainer.chain([handler1, handler2])
        handler((), (), true)

        @Expect(handler1Called.value, true)
        @Expect(handler2Called.value, true)
    }

    @TestCase
    func testChainOnlyCallsUntilTrue(): Unit {
        let chainer = ResponseHandlerChainer()
        let handler1Called = BoolCell()
        let handler2Called = BoolCell()
        let handler1 = { _: Any, _: Any, _: Bool =>
            handler1Called.value = true
            true
        }
        let handler2 = { _: Any, _: Any, _: Bool =>
            handler2Called.value = true
            false
        }

        let handler = chainer.chain([handler1, handler2])
        handler((), (), true)

        @Expect(handler1Called.value, true)
        @Expect(handler2Called.value, false)
    }
}
