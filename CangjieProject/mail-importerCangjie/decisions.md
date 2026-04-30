## 决策点记录

### [决策点 1] Guice 依赖注入如何处理

- 现状：源码使用 Guice（AbstractModule、@Inject、Provider、CheckedProvider、ThrowingProviderBinder）进行依赖注入。三个 Module：FlagsModule、ThunderbirdModule、GmailServiceModule。
- 选项：A. 尝试在仓颉中实现简易 DI 容器 / B. 移除 DI，改为手动构造函数传参 / C. 用全局单例
- 推荐：**B** — 项目规模小（仅约 10 个需注入的类），手动组装比引入 DI 框架更简洁。Importer 构造函数显式接收所有依赖。
- 用户确认：[x] 按默认方案执行

### [决策点 2] javax.mail.Folder/Message 的全量 API 是否翻译

- 现状：JavaxMailFolder 继承 javax.mail.Folder，实现约 50 个方法；JavaxMailMessage 继承 Message，实现约 40 个方法。实际被业务代码调用的仅约 10 个方法。
- 选项：A. 翻译全部 90 个方法 / B. 仅翻译实际使用的方法子集
- 推荐：**B** — 仅翻译业务代码和测试实际调用的方法，减少无意义代码量。未使用方法以注释标明。
- 用户确认：[x] 按默认方案执行

### [决策点 3] Multimap 如何替代

- 现状：Mailbox 和 GmailSyncer 使用 Guava Multimap<LocalMessage, Message>
- 选项：A. 用 HashMap<K, ArrayList<V>> 手动实现 / B. port 一个简化版 Multimap
- 推荐：**A** — 用 `HashMap<LocalMessage, ArrayList<Message>>` 替代，封装简单的 put/get/entries 方法
- 用户确认：[x] 按默认方案执行

### [决策点 4] Gmail API 批处理如何处理

- 现状：Mailbox 大量使用 Gmail BatchRequest API 进行批量操作
- 选项：A. 定义 BatchRequest interface 占位 / B. 用循环单条请求替代
- 推荐：**A** — 定义 interface 占位，标注 TODO。批处理逻辑保留结构但实际 HTTP 调用需平台实现
- 用户确认：[x] 按默认方案执行

### [决策点 5] RuntimeMessagingException 的设计

- 现状：Java 版将 checked MessagingException 包装为 unchecked RuntimeMessagingException
- 选项：A. 仓颉中直接用 Exception（仓颉无 checked/unchecked 区分）/ B. 定义自定义 MessagingException
- 推荐：**B** — 定义 `MessagingException <: Exception`，仓颉异常模型统一为 unchecked，不需要包装层
- 用户确认：[x] 按默认方案执行

### [决策点 6] 测试中 Mockito mock 如何替代

- 现状：测试大量使用 Mockito mock
- 选项：A. 手写 stub/fake 类 / B. 仅翻译不依赖 mock 的测试 / C. port 简易 mock 框架
- 推荐：**A** — 手写 stub 类（如 FakeLocalMessage、FakeMailFolder 等），保持测试可运行
- 用户确认：[x] 按默认方案执行
