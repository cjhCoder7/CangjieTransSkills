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

---

## 非沉浸式应用窗口需要主动避让系统栏

**问题**: API 10 及以上默认全屏窗口中，ArkUI 页面标题与状态栏时间、信号图标重叠。
**原因**: 主窗口调用了 `setWindowLayoutFullScreen(true)`，内容区域会延伸到状态栏和导航栏。
**解决方案**: 在 `loadContent` 前获取主窗口并设置非沉浸式布局：
```cangjie
let mainWindow = windowStage.getMainWindow()
mainWindow.setWindowLayoutFullScreen(false)
windowStage.loadContent("HomePage")
```

---

## NetworkKit 回调更新 ArkUI 状态前切回 UI 线程

**问题**: HTTP 请求成功进入回调后直接修改 `@State`，运行时只记录 `An exception has occurred`，随后应用进程退出。
**原因**: NetworkKit 异步回调不保证运行在 UI 线程，而 ArkUI 状态修改属于 UI 逻辑。
**解决方案**: 在回调中使用 `spawn(UIThread)` 调度状态更新，不要等待返回值：
```cangjie
request.request(url, options, { error, response =>
    let message = parseResult(error, response)
    spawn(UIThread) { this.status = message }
    request.destroy()
})
```

---

## @Builder 的普通值参数不适合承载持续变化的状态

**问题**: 父组件状态已经变化，页面背景等直接读取 `this.state` 的属性已刷新，但 `@Builder` 普通参数生成的数字或开关文案仍停留在初始值。
**原因**: 普通值参数不是状态数据源，Builder 片段不会因该参数内部值变化自动建立状态依赖。
**解决方案**: 动态 Builder 直接读取所属组件的 `@State`、`@Prop` 或 `@Link` 字段；仅把静态标题等作为普通参数。
```cangjie
@Builder
func fontSizeRow() {
    Text("${Int64(this.fontSize)}")
    Button("+").onClick({ _ => this.onFontLarger() })
}
```
