# ArkTS → 仓颉翻译经验（Telegram 项目实战）

> 来源：TelegramHarmony (ArkTS) → TelegramCangjie (仓颉+ArkTS 混合) 完整翻译，73 文件 / 16,948 行

## 推荐架构：仓颉业务逻辑 + ArkTS UI

**结论**: 纯仓颉 UI（V1 @Component）有严重限制，推荐**混合架构**：

| 层 | 语言 | 原因 |
|----|------|------|
| UI 页面/组件 | **ArkTS** | @Component/@State/@Prop/@Link/@Builder 全部可用，无跨包限制 |
| 互操作桥接 | 仓颉 `@Interop[ArkTS]` | 导出函数，返回 JSON 字符串 |
| 业务逻辑 | **仓颉** | ViewModel、Service、Model、状态管理 |
| 数据层 | **仓颉** | 响应式框架、Mock/Real 服务 |

---

## 核心类型映射表

> 常见类型的运行时陷阱（Option 解包、Array/ArrayList 区别、Rune 转换等）详见 [`evolution/cangjie/syntax.md`](../../../evolution/cangjie/syntax.md)。

| ArkTS | 仓颉 | 注意事项 |
|-------|------|---------|
| `number` | `Int64` / `Float64` | ID/计数用 Int64，小数用 Float64 |
| `string` | `String` | |
| `boolean` | `Bool` | |
| `T \| null` / `T?` | `?T` (Option) | 用 `if (let Some(v) <- x)` 解包，不能用 `!= None` |
| `T[]` / `Array<T>` | `ArrayList<T>` | 动态数组用 ArrayList，完成后 `.toArray()` |
| `Map<K,V>` | `HashMap<K,V>` | `import std.collection.HashMap` |
| `Set<T>` | `ArrayList<T>` + 手动去重 | HashSet 需 Hashable，引用类型通常不满足 |
| `Promise<T>` | 同步返回（调用方用 `spawn`） | 或 `@Interop[ArkTS, Async]` 自动包装为 Promise |
| `interface`（数据形状） | `class` | 仓颉 interface 仅用于行为契约 |
| `interface`（行为契约） | `interface` | |
| `enum`（数字枚举） | `enum` | |
| `enum`（字符串枚举） | `enum <: ToString` | 实现 `toString()` 方法 |
| `@ObservedV2/@Trace` | `@Observed/@Publish` 或普通类 | @Observed 禁止自定义 init |
| `struct`（组件） | `class`（仓颉组件） | 但建议 UI 用 ArkTS |

---

## ArkTS 构造函数 → 仓颉 init 参数

ArkTS 接口字面量 `{ key: value }` → 仓颉需要显式构造函数。**强烈建议所有参数加 `!` 做命名参数**：

```cangjie
// 推荐：全命名参数
public init(
    id!: PeerId,
    firstName!: String,
    lastName!: ?String = None,
    phone!: ?String = None
) { ... }

// 调用
let user = CurrentUser(id: pid, firstName: "Alice", phone: "+86xxx")
```

不加 `!` 的是位置参数，调用时不能写参数名。混用时**位置参数必须在命名参数前面**。

---

## async/await → spawn + sleep

```typescript
// ArkTS
async sendCode(phone: string): Promise<Result> {
    await this.delay(1000)
    return result
}
```
```cangjie
// 仓颉 — 服务接口方法改为同步
public func sendCode(phoneNumber: String): SendCodeResult {
    sleep(Duration.millisecond * 1000)
    return result
}

// 调用方用 spawn 异步执行
spawn {
    let result = authService.sendCode(phone)
    // 更新 UI 状态...
}
```

---

## setTimeout/setInterval → spawn + sleep 循环

```typescript
// ArkTS
this.timer = setInterval(() => { this.count-- }, 1000)
```
```cangjie
// 仓颉
this.timerRunning = true
spawn {
    while (this.timerRunning && this.count > 0) {
        sleep(Duration.second * 1)
        if (this.timerRunning) { this.count-- }
    }
}
// 停止
func stop() { this.timerRunning = false }
```

---

## 翻译顺序建议

实践证明的最佳翻译顺序（按依赖关系）：

```
1. Models（数据类、枚举）— 零外部依赖
2. SignalKit/工具库 — 仅依赖标准库
3. Service 接口 — 依赖 Models + SignalKit
4. Mock 服务实现 — 依赖以上全部
5. AppState + ViewModel — 依赖服务层
6. Interop 导出层 — 聚合所有业务逻辑
7. ArkTS UI 页面 — 最后，通过 .so import 调用仓颉
```

每层完成后立即 `/build` 验证。

---

## 纯仓颉 UI 层已知限制（V1 @Component 宏）

> 各限制的完整编译器报错和解决方案详见 [`evolution/cangjie/arkui.md`](../../../evolution/cangjie/arkui.md)。

如果仍需要纯仓颉 UI，注意以下限制：
1. **@Prop 不能有默认值** — 会导致宏展开失败
2. **build() 中 this.xxx() 被当作组件** — 不能在 build() 里调用辅助方法
3. **跨包组件不可用** — 不同子包的 @Component 类无法相互实例化
4. **@Builder 可能导致宏失败** — 在 @Component 内部使用有风险
5. **constraintSize 的 None 歧义** — 多个 Option 参数时 None 类型推断失败

**因此推荐混合架构**：仓颉做业务，ArkTS 做 UI。

---

## Interop 数据传递模式

> 对应的编译器报错和具体陷阱（Array 类型限制、lambda 捕获、阻塞问题等）详见 [`evolution/cangjie/interop.md`](../../../evolution/cangjie/interop.md)。

### 同步 vs 异步调用规则

| 操作类型 | 仓颉注解 | ArkTS 调用方式 | 典型场景 |
|---------|---------|---------------|---------|
| 快速查询 | `@Interop[ArkTS]` | `const result = func() as string` | `isLoggedIn()`, `getCurrentUserJson()`, `getChatListSnapshot()` |
| 耗时操作 | `@Interop[ArkTS, Async]` | `const result = await func() as string` | `sendCode()`, `verifyCode()`, `getMessages()`, `logout()` |

**关键陷阱**：同步函数内如果有 `sleep()` 会阻塞 ArkTS 主线程，导致 UI 冻结。含 Mock 延迟的服务方法必须用 `Async`。

### JSON 字符串传递模式

`@Interop` 不支持 `Array<Class>` 返回类型，所有复杂数据通过 JSON 字符串传递：

```cangjie
// 仓颉侧：手动拼 JSON
@Interop[ArkTS]
public func getData(): String {
    var items = ArrayList<String>()
    for (item in data) {
        items.add("{\"id\":\"${item.id}\",\"name\":\"${escapeJson(item.name)}\"}")
    }
    // 拼接数组
    var result = "["
    for (i in 0..items.size) {
        if (i > 0) { result += "," }
        result += items[i]
    }
    return result + "]"
}
```

```typescript
// ArkTS 侧：定义本地接口 + JSON.parse
interface DataItem {
  id: string
  name: string
}
const jsonStr: string = getData() as string
const items: DataItem[] = JSON.parse(jsonStr) as DataItem[]
```

**注意**：ArkTS 严格模式禁止 `any` 类型，`JSON.parse()` 结果必须用 `as Type` 显式标注。

### AppStorage 跨页面传参

ArkTS 页面间传递选择结果（如国家选择器 → 登录页）使用 `AppStorage`：

```typescript
// 写入（选择页）
AppStorage.setOrCreate('selectedCountryName', country.name)
AppStorage.setOrCreate('countrySelected', true)
router.back()

// 读取（来源页）
@StorageLink('countrySelected') countrySelected: boolean = false

onPageShow(): void {
    if (this.countrySelected) {
        const name = AppStorage.get<string>('selectedCountryName')
        // 使用数据...
        AppStorage.setOrCreate('countrySelected', false)  // 重置标记
    }
}
```

---

## ArkTS UI 层最佳实践

### @Builder 拆分粒度

对齐原版 TelegramHarmony 的经验：一个页面应拆分为 5-10 个 `@Builder` 方法：

```
ChatListPage @Builder 拆分：
├── NavigationBar()      — 导航栏（菜单/标题/新建）
├── SearchBar()          — 搜索输入栏
├── ChatList()           — 聊天列表（含 ForEach）
├── ChatListItem(item)   — 单个列表项
├── LoadingView()        — 加载状态
├── EmptyView()          — 空状态
└── ActionSheet()        — 长按操作面板

ChatPage @Builder 拆分：
├── NavigationBar()      — 返回/头像/标题/更多
├── MessageList()        — 消息列表
├── MessageBubble(msg)   — 单条消息气泡
├── InputBar()           — 输入栏（附件/文本/发送）
├── ReplyPreviewBar()    — 回复引用条
├── AttachmentPanel()    — 附件选择面板
├── ContextMenuOverlay() — 消息长按菜单
├── LoadingView()        — 加载中
└── EmptyView()          — 无消息
```

### 头像渲染模式

所有页面统一使用 `Stack` + `Circle` + `Text` 实现彩色首字母头像：

```typescript
Stack() {
    Circle().width(50).height(50).fill(avatarColor)
    Text(initials).fontSize(18).fontWeight(FontWeight.Medium).fontColor(Color.White)
}
```

颜色由仓颉层 `getPeerAvatarColor()` 生成，基于用户 ID 的哈希值分配 8 种预设色。

### 设置页菜单项模式

每个设置项使用统一结构：彩色圆形背景图标 + 标题 + 副标题 + 右箭头：

```typescript
Row() {
    // 图标（彩色圆形背景）
    Stack() {
        Circle().width(30).height(30).fill(iconBgColor)
        Image(iconRes).width(18).height(18)
    }
    // 文字
    Column() {
        Text(title).fontSize(16)
        if (subtitle) Text(subtitle).fontSize(13).fontColor('#8E8E93')
    }.layoutWeight(1)
    // 箭头
    Image($r('app.media.ic_chevron_right')).width(16).height(16)
}
```

---

## 项目规模参考

最终项目统计（可作为类似翻译项目的工作量参考）：

| 层 | 文件数 | 代码行数 | 说明 |
|----|-------|---------|------|
| 仓颉 Models | 4 | ~1,800 | 数据类、枚举、工具函数 |
| 仓颉 SignalKit | 3 | ~1,200 | 响应式框架 |
| 仓颉 Services | 6 | ~600 | 接口 + ServiceLocator |
| 仓颉 Mock | 6 | ~2,000 | 模拟服务实现 |
| 仓颉 ViewModel | 3 | ~750 | 视图模型 |
| 仓颉 App/Bridge | 2 | ~200 | 全局状态 + 服务初始化 |
| 仓颉 Interop | 1 | ~550 | @Interop[ArkTS] 导出 |
| ArkTS 页面 | 33 | ~8,400 | UI 页面（含 EntryAbility） |
| PNG 图标 | 77 | — | Pillow 生成 |
| **合计** | **73+** | **~16,950** | |
