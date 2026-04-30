## 决策点

### [决策点 1] JSON 解析

- 现状：Python tinydb 使用 `json.loads` / `json.dumps` 进行数据持久化。仓颉本地 SDK 无 JSON 标准库。
- 选项：A) 自行实现完整 JSON 解析器 B) 暂返回 None（仅内存模式可用）C) 引入第三方 JSON 库
- 推荐：B（当前已实现），后续可切换到 C
- 用户确认：[x] 暂用内存模式

### [决策点 2] Int64 哈希溢出

- 现状：Python 整数无溢出，仓颉 Int64 乘法溢出抛出 OverflowException
- 选项：A) 使用 XOR 代替乘法 B) 使用 checked 运算并截断 C) 不缓存查询
- 推荐：A（已实现），XOR + 移位的哈希组合方式不会溢出
- 用户确认：[x]

### [决策点 3] `where` 保留字

- 现状：`where` 是仓颉保留字，不能直接用作函数名
- 选项：A) 反引号转义 B) 改名为 `query` / `field`
- 推荐：A（已实现），保持与 Python tinydb API 一致
- 用户确认：[x]

### [决策点 4] Storage 三层嵌套类型

- 现状：数据模型为 tableName → docId → fieldName → value，需 `HashMap<String, HashMap<String, HashMap<String, Any>>>`
- 选项：A) 三层 HashMap 类型 B) 用 Any 包装中间层，到处 as 转型
- 推荐：A（已实现），类型安全，避免运行时转型失败
- 用户确认：[x]

### [决策点 5] 函数类型字段更新

- 现状：Python tinydb 的 `update` 方法 fields 参数可以是 dict 或 callable。仓颉 `Any` 类型需要同时支持两种。
- 选项：A) `fields: Any` + `_performUpdate` 中 `as` 转型判断 B) 重载 update 方法
- 推荐：A（已实现），与 Python 行为一致
- 用户确认：[x]
