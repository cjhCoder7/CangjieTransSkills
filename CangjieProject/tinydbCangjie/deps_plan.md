## 依赖决策记录

| 依赖 | 决策 | 说明 |
|------|------|------|
| `json` (Python stdlib) | stub | JSON 解析器暂返回 None，序列化器已实现。仓颉标准库无 JSON 模块，需后续引入第三方或自行实现 |
| `re` (Python stdlib) | replace | 使用仓颉 `std.regex.Regex` 替代 |
| `os` (Python stdlib) | replace | 使用仓颉 `std.fs.*` 替代文件系统操作 |
| `collections.OrderedDict` | replace | 使用 `ArrayList<(K, V)>` 实现 LRU 缓存 |
