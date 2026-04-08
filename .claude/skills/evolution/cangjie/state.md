# 仓颉语言 — 状态管理宏

## @Observed 类禁止自定义构造函数

**问题**: `@Observed` 类定义 `init()` 后报 `macro evaluation has failed for macro call 'Observed'`
**原因**: `@Observed` 宏会自动生成带命名参数的构造函数，不允许用户自定义 `init()`。所有 `@Publish` 字段必须指定类型和初始值
**解决方案**:
```cangjie
@Observed
class Model {
    @Publish var name: String = ""
    @Publish var value: Float64 = 0.0
}
// 使用时通过命名参数：Model(name: "hello", value: 1.0)
```
**替代方案**: 若不需要嵌套属性级别的响应式观察（仅需整体替换触发更新），可用普通类 + `@State` 整体赋值。

---

## 覆写生命周期方法需要 protected

**问题**: `@Component` 类中覆写 `aboutToAppear` 报 `a deriving member must be at least as visible as its base member`
**原因**: 基类 `CustomView` 中该方法声明为 `protected`，子类覆写的访问级别不能更低
**解决方案**:
```cangjie
protected func aboutToAppear() { ... }
```
