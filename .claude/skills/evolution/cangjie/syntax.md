# 仓颉语言 — 语法与编译器

## 元组成员访问语法不支持

**问题**: `item.0`、`item.1` 报 `unclosed delimiter` 或 `expected ';' or '<NL>', found literal '.1'`
**原因**: 编译器将 `.0`、`.1` 解析为浮点数字面量，而非元组索引
**解决方案**: 用自定义类替代元组：
```cangjie
// 错误
let name = data[0].0

// 正确
class Pair { var key: String; var value: Float64; ... }
let name = data[0].key
```

---

## import 语句必须在文件顶部

**问题**: 文件中间的 `import` 报 `expected declaration, found keyword 'import'`
**原因**: 仓颉要求 `import` 必须在 `package` 声明之后、所有其他声明之前
**解决方案**: 将全部 `import` 集中到文件开头。

---

## 值级别类型注解不支持

**问题**: `0: Int64` 报 `expected operator or end of expression, found ':'`
**原因**: 仓颉不支持 Rust 风格的 `expr: Type` 类型注解
**解决方案**: 通过变量声明指定类型：
```cangjie
// 错误
let x = if (cond) { 0: Int64 } else { 1: Int64 }

// 正确
let x: Int64 = if (cond) { 0 } else { 1 }
```

---

## Array 是固定大小，动态构建用 ArrayList

**问题**: `Array<T>.append()` 报 `'append' is not a member of struct 'Array<...>'`
**原因**: `Array<T>` 是固定大小值类型，无动态增删方法
**解决方案**: 用 `ArrayList<T>`（`std.collection`）的 `add()` 动态构建，完成后 `.toArray()` 转回：
```cangjie
import std.collection.ArrayList

var list = ArrayList<String>()
list.add("hello")
list.add("world")
let arr: Array<String> = list.toArray()
```
