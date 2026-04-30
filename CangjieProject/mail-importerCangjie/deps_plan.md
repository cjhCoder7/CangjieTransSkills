## 依赖决策记录

| 源依赖 | 版本 | 决策 | 仓颉替代/动作 | 备注 |
|--------|------|------|--------------|------|
| guice | 5.1.0 | **drop** | 仓颉无 DI 框架，用构造函数传参 | Guice Module、@Inject、Provider 等全部移除，改为手动组装 |
| guice-multibindings | 4.2.3 | **drop** | 同上 | |
| guice-throwingproviders | 5.1.0 | **drop** | `MailProvider<T>` 改为普通 interface | CheckedProvider 语义用仓颉异常表达 |
| guice-assistedinject | 5.1.0 | **drop** | 不需要 | 项目中未实际使用 |
| guava | 31.1-jre | **replace** | 仓颉 std 集合 + 手写工具 | ImmutableList→ArrayList, Verify→自定义断言, Iterators.filter→filter, Multimap→HashMap<K,ArrayList<V>>, Sets→HashSet, ByteStreams→copyStream, Charsets/CharSource→仓颉 String API, Resources→仓颉文件读取 |
| javax.mail (javamail) | — | **stub** | 定义 `MailFolder`/`MailMessage`/`MailStore` 接口 | 仓颉无 javax.mail 等价，核心邮件解析能力需平台提供或 port |
| mstor | 1.0.2 | **stub** | ThunderbirdMailbox 中 mbox 打开逻辑用接口占位 | 依赖 javax.mail + mbox 格式解析 |
| google-api-client | 2.2.0 | **stub** | 定义 GmailService 接口占位 | OAuth2/HTTP 客户端需平台 API 替代 |
| google-api-services-gmail | v1-rev | **stub** | 定义 Mailbox/GmailSyncer 依赖的 Gmail API 接口 | Gmail REST API 需仓颉 HTTP 客户端调用 |
| google-http-client-jackson | 1.29.2 | **stub** | 同上 | |
| jackson-core | 2.15.0-rc1 | **stub** | 仓颉 JSON 解析用 `encoding.json.*` | Gmail API 响应解析 |
| args4j | 2.33 | **port** | 简易命令行解析，50 行内可 port | 或用仓颉标准参数解析 |
| slf4j-simple | 2.0.7 | **replace** | 仓颉 `logging` 包或 `print` | 简单日志输出 |
| javax.annotation-api | 1.3.2 | **drop** | 仓颉注解体系不同 | @NotThreadSafe 等用注释替代 |
| auto-value | 1.10.1 | **drop** | User 类手写 | 仓颉值类型手写即可 |
| truth (测试) | 1.1.3 | **replace** | 仓颉 `@Test` + `assert` | |
| mockito (测试) | 5.18.0 | **stub** | 手写 mock/stub 类 | 仓颉无 mock 框架 |
| byte-buddy (测试) | 1.17.5 | **drop** | Mockito 依赖，一并移除 | |

### stub 策略说明

1. **javax.mail 等价**：定义 `MailFolder`、`MailMessage`、`MailStore` 三个 interface，包含源码中实际使用的方法子集（非 javax.mail.Folder 全量 API）。ThunderbirdMailbox 的 `get()` 方法标注 `TODO: 需要 mbox 解析实现`。

2. **Gmail API 等价**：定义 `GmailService` interface 提供 `getServiceWithRetries()` 返回 `GmailClient` interface；`GmailClient` 定义 `users()` → `UsersResource` → 扁平化核心方法。实际 HTTP 调用标注 TODO。

3. **OAuth2**：`Authorizer` 保留接口，OAuth2 流程标注 TODO 需平台安全 API。
