package mail_importer.gmail

// 链式 HTTP 响应处理器。按顺序执行 handler，直到某个返回 true 表示支持重试。
// 原版: UnsuccessfulResponseHandlerChainer
public class ResponseHandlerChainer {
    public init() {}

    // handler 签名: (request, response, supportsRetry) -> Bool
    // 返回组合后的 handler
    public func chain(handlers: Array<(Any, Any, Bool) -> Bool>): (Any, Any, Bool) -> Bool {
        return { request, response, supportsRetry =>
            var retry = false
            var i = 0
            while (i < handlers.size && !retry) {
                retry = handlers[i](request, response, supportsRetry)
                i++
            }
            retry
        }
    }
}
