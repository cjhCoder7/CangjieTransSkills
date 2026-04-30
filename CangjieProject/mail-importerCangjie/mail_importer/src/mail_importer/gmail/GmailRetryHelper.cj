package mail_importer.gmail

// 429 (TOO_MANY_CONCURRENT_REQUESTS_FOR_USER) 重试助手。
// 指数退避，最多 maxRetries 次。
public class GmailRetryHelper {
    let maxRetries: Int64
    let initialDelayMs: Int64

    public init() {
        this.maxRetries = 5
        this.initialDelayMs = 1000
    }

    public init(maxRetries: Int64, initialDelayMs: Int64) {
        this.maxRetries = maxRetries
        this.initialDelayMs = initialDelayMs
    }

    // 执行带重试的操作。遇到 429 状态码时自动重试。
    public func executeWithRetry(action: () -> Unit): Unit {
        var attempt = 0
        while (true) {
            try {
                action()
                return
            } catch (e: GmailApiException) {
                if (e.statusCode != 429) {
                    throw e
                }
                attempt++
                if (attempt > maxRetries) {
                    throw e
                }
                // 指数退避
                let delayMs = initialDelayMs * (1 << (attempt - 1))
                sleepMs(delayMs)
            }
        }
    }

    // 简易 sleep（仓颉无 Thread.sleep，用循环空转模拟）
    // 注意：真实实现应使用平台定时器
    func sleepMs(ms: Int64): Unit {
        var count: Int64 = 0
        let limit = ms * 10000  // 粗略延时
        while (count < limit) {
            count++
        }
    }
}
