# mail-importer 仓颉翻译报告

## 分流判定：lib / 继续本 skill

源项目是 CLI 工具库，无 UI 资源、无 HarmonyOS 应用入口，按 lib skill 翻译。

## 源项目概要

- **语言**: Java 8+
- **构建系统**: Maven
- **功能**: 将 Thunderbird mbox 邮件档案导入 Gmail，保留文件夹结构、已读/未读状态、星标标记
- **关键依赖**: Google Gmail API、Guice (DI)、Guava、javax.mail、Mockito

## 关键取舍

| 决策 | 说明 |
|------|------|
| Guice DI → 手动构造 | 仓颉无 DI 框架，改用构造函数注入 |
| javax.mail → 精简接口 | 仅保留业务代码实际使用的 MailFolder/MailMessage 接口 |
| Gmail API → 接口 stub | 方法体 throw Exception + TODO，待 API 可用时实现 |
| Guava Multimap → HashMap<String, ArrayList<GmailMessage>> | 用标准库集合替代 |
| Mockito → 手写 Fake 类 | 内联在 _test.cj 文件中 |
| stdx 不可用 → 内联实现 | SimpleLogger 替代 std.log、simpleBase64Encode 替代 std.encoding.base64 |
| init() → connect() | init 是仓颉构造函数保留字 |
| abstract func → open func + 默认实现 | 仓颉 abstract class 不支持 abstract func |
| 内部类 → 顶层类 | 仓颉不支持嵌套类，FolderIterator 等提取为顶层 |
| HashMap key 用 String | LocalMessage 接口不实现 Hashable，改用 messageId(String) 作 key |
| ByteArrayOutputStream → ByteArrayListStream | 仓颉 std.io 无 ByteArrayOutputStream，自定义 OutputStream 实现 |
| Mailbox open class + open func | 仓颉不支持 Mockito，需子类化 Mailbox 进行测试 |
| Importer.main() → Importer.run() | 仓颉 main() 只能是顶层函数且仅 executable 输出可用，库中用静态方法替代 |

## 已知遗留项

| 遗留 | 说明 | 后续方案 |
|------|------|---------|
| Gmail API 未实现 | Mailbox.loadLabels/uploadMessage/mapMessageIds 等 | 接入 HarmonyOS Google API 或替代 HTTP 客户端 |
| OAuth2 认证未实现 | Authorizer 是空壳 | 实现浏览器授权流程 |
| mbox 解析未实现 | ThunderbirdMailbox.get() 是 TODO | 需实现 mbox 格式解析器 |
| Base64 编码是简化版 | 仅用于 key 生成，非完整 RFC 4648 | stdx 可用时替换为 std.encoding.base64 |
| 日志是简化版 | SimpleLogger 仅输出到控制台 | stdx 可用时替换为 std.log.Logger |
| CorruptEmailFixer | 原版标注 "not actually used"，仅保留 TODO | 按需实现 |

## 验证结果

- **cjpm build**: 成功（static + dynamic）
- **cjpm test**: 全部通过
  - CommandLineArgumentsTest: 4 用例
  - XMozillaStatusTest: 5 用例
  - ThunderbirdLocalMessageTest: 12 用例
  - ThunderbirdMailStorageTest: 2 用例
  - MailStorageTest: 4 用例
  - GmailSyncerTest: 3 用例
  - ResponseHandlerChainerTest: 4 用例
  - ImporterTest: 2 用例
  - **总计: 36 用例，全部 PASSED**

## 产物清单

1. `mail_importer/src/` + `cjpm.toml` — cjpm 包源码（26 个 .cj 源文件 + 8 个 _test.cj 测试文件）
2. `mail_importer_api.md` — 公共 API 对照表
3. `deps_plan.md` — 依赖决策记录
4. `decisions.md` — 不可直译项决策点
5. 本文件 — 翻译报告
