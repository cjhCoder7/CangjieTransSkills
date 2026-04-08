# 仓颉语言 — ArkUI 组件与布局

## @Builder 方法内禁止非 UI 语句

**问题**: `@Builder` 中使用 `for` 循环、`var` 赋值等语句时报 `Only UI component syntax can be written in build method`
**原因**: `@Builder` 宏要求方法体只能包含声明式 UI 组件描述，不允许命令式语句
**解决方案**: 计算逻辑抽到普通方法，`@Builder` 内用 `let` 接收结果：
```cangjie
func calcTotal(): Float64 { ... }

@Builder
func buildLegend() {
    let total = this.calcTotal()
    Text("${total}")
}
```

---

## CustomDialogController 的 API 名称

**问题**: `controller.close()` / `controller.open()` 报方法不存在
**原因**: 仓颉版 ArkUI 的 `CustomDialogController` API 名称与 ArkTS 版不同
**解决方案**:
- 打开弹窗: `dialogController.openDialog()`
- 关闭弹窗（弹窗内部）: `controller?.releaseSelf()`
```cangjie
@CustomDialog
class MyDialog {
    var controller: Option<CustomDialogController> = Option.None
    func build() {
        Button("关闭").onClick({ _ => controller?.releaseSelf() })
    }
}
```

---

## List.divider 接受对象参数而非命名参数

**问题**: `.divider(strokeWidth: 1, color: ...)` 报 `extra arguments given`
**原因**: `divider` 方法签名接受单个 `ListDividerOptions` 对象
**解决方案**:
```cangjie
.divider(ListDividerOptions(strokeWidth: 1, color: 0xFFF0F0F0, startMargin: 60, endMargin: 10))
```

---

## Tabs.onChange 回调参数类型是 Int32

**问题**: `.onChange` 回调用 `Int64` 参数时报类型不匹配
**原因**: Tabs 组件 `onChange` 回调参数类型为 `Int32`，而非 `Int64`
**解决方案**:
```cangjie
.onChange({ index: Int32 => this.currentTab = Int64(index) })
```
