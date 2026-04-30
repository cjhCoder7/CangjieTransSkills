## 依赖决策记录

| 依赖 | 决策 | 说明 |
|------|------|------|
| Swift 标准库 | replace | 仓颉 std 库覆盖基本类型和集合 |
| Swift Foundation | drop | Splash 不依赖 Foundation |
| std.collection (HashMap/ArrayList) | replace | 仓颉 std.collection 等价替换 |
| std.fs / std.io | replace | 文件读写替代 Swift 的 String(contentsOf:) |
| std.unittest | replace | 测试框架替代 XCTest |
| XCTest | drop | 不适用仓颉环境 |

Splash 零外部依赖，翻译后也保持零外部依赖，仅使用仓颉标准库。
