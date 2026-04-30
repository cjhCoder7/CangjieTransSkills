## 不可直译项决策

### [决策点 1] 接口关联类型 → 具体返回类型

- 现状：Swift 的 `OutputFormat` 协议使用 `associatedtype Output`，`OutputBuilder` 协议使用 `associatedtype Output`
- 选项：A) 使用仓颉泛型接口 B) 简化为具体返回类型
- 推荐：B — 简化为具体返回类型 `OutputBuilder` / `String`
- 理由：仓颉接口不支持关联类型，且实际使用中所有实现都返回 `String`，泛型接口会增加不必要的复杂度
- 用户确认：[x] 已实施

### [决策点 2] Array.suffix / Array.append 不可用

- 现状：Swift 的 `Array.suffix(n)` 和 `Array.append()` 在仓颉中不存在
- 选项：A) 使用 `Array.slice()` 手动实现 B) 改用 `ArrayList`
- 推荐：混合使用 — `suffix` 用 `slice` 封装为 `arraySuffix`；`append` 用 `ArrayList.add` + `toArray()`
- 理由：保持数组语义不变，ArrayList 仅在构建阶段使用
- 用户确认：[x] 已实施

### [决策点 3] String 下标返回 UInt8 非 Rune

- 现状：仓颉 `String` 实现了 `Collection<Byte>`，`s[0]` 返回 `UInt8` 字节而非 `Rune` 字符
- 选项：A) 每次使用 `s.toRuneArray()` B) 封装 `runeAt(s, idx)` 函数
- 推荐：B — 使用 `runeAt` 和 `toRuneArray()` 按需转换
- 理由：减少重复代码，保持安全访问
- 用户确认：[x] 已实施

### [决策点 4] TokenType 枚举 == 运算符

- 现状：仓颉枚举不支持自动合成 `==` / `!=`
- 选项：A) 手动实现 `operator func ==` 和 `!=` B) 使用 `match` 手动比较
- 推荐：A — 手动实现 `operator func ==` 和 `!=`
- 理由：代码中多处使用 `TokenType` 比较，运算符重载更符合语言习惯
- 用户确认：[x] 已实施

### [决策点 5] 命名元组 → 辅助类

- 现状：Swift 使用命名元组 `(token: String, tokenType: TokenType)`，仓颉元组不支持命名字段
- 选项：A) 使用索引访问 `t[0]`、`t[1]` B) 创建辅助类
- 推荐：B — 创建 `PendingToken` 和 `HighlightState` 辅助类
- 理由：索引访问可读性差，辅助类保持代码清晰
- 用户确认：[x] 已实施
