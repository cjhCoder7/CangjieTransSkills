# 焦点事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 基础概念与规范

### 基础概念

#### 焦点、焦点链和走焦

- 焦点：指向当前应用界面上唯一的一个可交互元素，当用户使用键盘等非指向性输入设备与应用程序进行间接交互时，基于焦点的导航和交互是重要的输入手段。
- 焦点链：在应用的组件树形结构中，当一个组件获得焦点时，从根节点到该组件节点的整条路径上的所有节点都会被视为处于焦点状态，形成一条连续的焦点链。
- 走焦：指焦点在应用内的组件之间转移的行为。这一过程对用户是透明的，但开发者可以通过监听[onFocus](../reference/arkui-cj/cj-universal-event-focus.md#func-onfocus---unit)（焦点获取）和[onBlur](../reference/arkui-cj/cj-universal-event-focus.md#func-onblur---unit)（焦点失去）事件来捕捉这些变化。关于走焦的具体方式和规则，请参见[走焦规范](#走焦规范)。

#### 焦点态

用来指向当前获焦组件的样式。

- 显示规则：默认情况下焦点态不会显示，只有当应用进入激活态后，焦点态才会显示。因此，虽然获得焦点的组件不一定显示焦点态（取决于是否处于激活态），但显示焦点态的组件必然是获得焦点的。大部分组件内置了焦点态样式，开发者同样可以使用样式接口进行自定义，一旦自定义，组件将不再显示内置的焦点态样式。在焦点链中，若多个组件同时拥有焦点态，系统将采用子组件优先的策略，优先显示子组件的焦点态，并且仅显示一个焦点态。
- 进入激活态：使用外接键盘按下TAB键/使用FocusController的activate(true)方法才会进入焦点的激活态，进入激活态后，才可以使用键盘TAB键/方向键进行走焦。首次用来激活焦点态的TAB键不会触发走焦。
- 退出激活态：当应用收到FocusController的active(false)方法/点击事件时（包括手指触屏的按下事件和鼠标左键的按下事件），焦点的激活态会退出。

#### 层级页面

层级页面是焦点框架中特定容器组件的统称，涵盖Page、Dialog、SheetPage、ModalPage、Menu、Popup、Dialog、NavBar、NavDestination等。这些组件通常具有以下关键特性：

- 视觉层级独立性：从视觉呈现上看，这些组件独立于其他页面内容，并通常位于其上方，形成视觉上的层级差异。
- 焦点跟随：此类组件在首次创建并展示之后，会立即将应用内焦点抢占。
- 走焦范围限制：当焦点位于这些组件内部时，用户无法通过键盘按键将焦点转移到组件外部的其他元素上，焦点移动仅限于组件内部。

在一个应用程序中，任何时候都至少存在一个层级页面组件，并且该组件会持有当前焦点。当该层级页面关闭或不再可见时，焦点会自动转移到下一个可用的层级页面组件上，确保用户交互的连贯性和一致性。

> **说明：**
>
> - [Popup](./cj-popup-and-menu-components-popup.md)组件在[focusable](../reference/arkui-cj/cj-universal-attribute-focus.md#func-focusablebool)属性（组件属性，非通用属性）为false的时候，不会有第2条特性。
> - NavBar、[NavDestination](../reference/arkui-cj/cj-navigation-switching-navdestination.md)没有第3条特性，对于它们的走焦范围，是与它们的首个父层级页面相同的。

#### 根容器

根容器是层级页面内的概念，当某个层级页面首次创建并展示时，根据层级页面的特性，焦点会立即被该页面抢占。此时，该层级页面所在焦点链的末端节点将成为默认焦点，而这个默认焦点通常位于该层级页面的根容器上。

在缺省状态下，层级页面的默认焦点位于其根容器上，但开发者可以通过defaultFocus属性来自定义这一行为。

当焦点位于根容器时，首次按下TAB键不仅会使焦点进入激活状态，还会触发焦点向子组件的传递。如果子组件本身也是一个容器，则焦点会继续向下传递，直至到达叶子节点。传递规则是：优先传递给上一次获得焦点的子节点，如果不存在这样的节点，则默认传递给第一个子节点。

### 走焦规范

根据走焦的触发方式，可以分为主动走焦和被动走焦。

#### 主动走焦

指开发者/用户主观行为导致的焦点移动，包括：使用外接键盘的按键走焦（TAB键/Shift+TAB键/方向键）、使用[requestFocus](../reference/arkui-cj/cj-universal-attribute-focus.md#static-func-requestfocusstring)申请焦点、[focusOnTouch](../reference/arkui-cj/cj-universal-attribute-focus.md#func-focusontouchbool)点击申请焦点等接口导致的焦点转移。

- 按键走焦

    - 前提：当前应用需处于焦点激活态。
    - 范围限制：按键走焦仅在当前获得焦点的层级页面内进行，详情请参见层级页面中的“走焦范围限制”部分。
    - 按键类型：
        - TAB键：遵循Z字型遍历逻辑，完成当前范围内所有叶子节点的遍历，到达当前范围内的最后一个组件后，继续按下TAB键，焦点将循环至范围内的第一个可获焦组件，实现循环走焦。
        - Shift+TAB键：与TAB键具有相反的焦点转移效果。方向键（上、下、左、右）：遵循十字型移动策略，在单层容器中，焦点的转移由该容器的特定走焦算法决定。若算法判定下一个焦点应落在某个容器组件上，系统将采用中心点距离优先的算法来进一步确定容器内的目标子节点。
    - 走焦算法：每个可获焦的容器组件都有其特定的走焦算法，用于定义焦点转移的规则。
    - 子组件优先：当子组件处理按键走焦事件，父组件将不再介入。

- requestFocus

    详情请参见[主动获焦失焦](#主动获焦失焦)，可以主动将焦点转移到指定组件上。

    不可跨窗口，不可跨ArkUI实例申请焦点，可以跨层级页面申请焦点。

- focusOnTouch

    详情请参见[focusOnTouch](../reference/arkui-cj/cj-universal-attribute-focus.md#func-focusontouchbool)，使绑定组件具备点击后获得焦点的能力。若组件本身不可获焦，则此功能无效。若绑定的是容器组件，点击后优先将焦点转移给上一次获焦的子组件，否则转移给第一个可获焦的子组件。

#### 被动走焦

被动走焦是指组件焦点因系统或其他操作而自动转移，无需开发者直接干预，这是焦点系统的默认行为。

目前会被动走焦的机制有：

- 组件删除：当处于焦点状态的组件被删除时，焦点框架首先尝试将焦点转移到相邻的兄弟组件上，遵循先向后再向前的顺序。若所有兄弟组件均不可获焦，则焦点将释放，并通知其父组件进行焦点处理。
- 属性变更：若将处于焦点状态的组件的focusable或enabled属性设置为false，或者将visibility属性设置为不可见，焦点框架将自动转移焦点至其他可获焦组件。焦点框架首先尝试将焦点转移到相邻的兄弟组件上，遵循先向后再向前的顺序。若所有兄弟组件均不可获焦，则焦点将释放，并通知其父组件进行焦点处理。
- 层级页面切换：当发生层级页面切换时，如从一个页面跳转到另一个页面，当前页面的焦点将自动释放，新页面可能会根据预设逻辑自动获得焦点。
- Web组件初始化：对于Web组件，当其被创建时，若其设计需要立即获得焦点（如某些弹出框或输入框），则可能触发焦点转移至该Web组件，其行为属于组件自身的行为逻辑，不属于焦点框架的规格范围。

### 走焦算法

在焦点管理系统中，每个可获焦的容器都配备有特定的走焦算法，这些算法定义了当使用TAB键、Shift+TAB键或方向键时，焦点如何从当前获焦的子组件转移到下一个可获焦的子组件。

容器采用何种走焦算法取决于其UX（用户体验）规格，并由容器组件进行适配。目前，焦点框架支持三种走焦算法：线性走焦、投影走焦和自定义走焦。

#### 线性走焦算法

线性走焦算法是默认的走焦策略，它基于容器中子节点在节点树中的挂载顺序进行走焦，常用于单方向布局的容器，如Row、Column和Flex容器。运行规则如下：

- 顺序依赖：走焦顺序完全基于子节点在节点树中的挂载顺序，与它们在界面上的实际布局位置无关。
- TAB键走焦：使用TAB键时，焦点将按照子节点的挂载顺序依次遍历。
- 方向键走焦：当使用与容器定义方向垂直的方向键时，容器不接受该方向的走焦请求。例如，在横向的Row容器中，无法使用方向键进行上下移动。
- 边界处理：当焦点位于容器的首尾子节点时，容器将拒绝与当前焦点方向相反的方向键走焦请求。例如，焦点在一个横向的Row容器的第一个子节点上时，该容器无法处理方向键左的走焦请求。

#### 投影走焦算法

投影走焦算法基于当前获焦组件在走焦方向上的投影，结合子组件与投影的重叠面积和中心点距离进行胜出判定。该算法特别适用于子组件大小不一的容器，目前仅有配置了wrap属性的Flex组件。运行规则如下：

- 规则1：方向键走焦时，判断投影与子组件区域的重叠面积，在所有面积不为0的子组件中，计算它们与当前获焦组件的中心点直线距离，距离最短的胜出。若存在多个备选，则节点树上更靠前的胜出。若无任何子组件与投影由重叠，说明该容器已经无法处理该方向键的走焦请求。
- 规则2：TAB键走焦时，先根据规则1，按照方向键右进行判定，若找到则成功退出。若无法找到，则将当前获焦子组件的位置模拟往下移动该获焦子组件的高度，然后再按照方向键左进行投影判定，有投影重叠且中心点直线距离最远的子组件胜出，若无投影重叠的子组件，则表示该容器无法处理本次TAB键走焦请求。
- 规则3：Shift+TAB键走焦时，先根据规则1，按照方向键左进行判定，找到则成功退出。若无法找到，则将当前获焦子组件的位置模拟向上移动该获焦子组件的高度，然后再按照方向键右进行投影判定，有投影重叠且中心点直线距离最远的子组件胜出，若无投影重叠的子组件，则表示该容器无法处理本次的Shift+TAB键走焦请求。

#### 自定义走焦算法

由组件自定义的走焦算法，规格由组件定义。

## 获焦/失焦事件

```cangjie
public func onFocus(event: ?() -> Unit): T
```

获焦事件回调，绑定该接口的组件获焦时，回调响应。

```cangjie
public func onBlur(event: ?() -> Unit): T
```

失焦事件回调，绑定该接口的组件失焦时，回调响应。

onFocus和onBlur两个接口通常成对使用，来监听组件的焦点变化。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var oneButtonColor: Color = Color.Gray
    @State var twoButtonColor: Color = Color.Gray
    @State var threeButtonColor: Color = Color.Gray
    func build() {
        Column(space: 20) {
        // 通过外接键盘的上下键可以让焦点在三个按钮间移动，按钮获焦时颜色变化，失焦时变回原背景色
        Button("First Button")
            .backgroundColor(oneButtonColor)
            .width(260)
            .height(70)
            .fontColor(Color.Black)
            // 监听第一个组件的获焦事件，获焦后改变颜色
            .onFocus({ =>
                oneButtonColor = Color(0x64BB5C)
            })
            // 监听第一个组件的失焦事件，失焦后改变颜色
            .onBlur({=>
                oneButtonColor = Color.Gray
            })
        Button("Second Button")
            .backgroundColor(twoButtonColor)
            .width(260)
            .height(70)
            .fontColor(Color.Black)
            // 监听第二个组件的获焦事件，获焦后改变颜色
            .onFocus({=>
                twoButtonColor = Color(0x64BB5C)
            })
            // 监听第二个组件的失焦事件，失焦后改变颜色
            .onBlur({=>
                twoButtonColor = Color.Gray
            })
        Button("Third Button")
            .backgroundColor(threeButtonColor)
            .width(260)
            .height(70)
            .fontColor(Color.Black)
            // 监听第三个组件的获焦事件，获焦后改变颜色
            .onFocus({=>
                threeButtonColor = Color(0x64BB5C)
            })
            // 监听第三个组件的失焦事件，失焦后改变颜色
            .onBlur({=>
                threeButtonColor = Color.Gray
            })
        }.width(100.percent).margin(top: 20)
    }
}
```

![onFocus](figures/onFocus.gif)

上述示例包含以下3步：

- 应用打开，按下TAB键激活走焦，“First Button”显示焦点态样式：组件外围有一个蓝色的闭合框，onFocus回调响应，背景色变成绿色。
- 按下TAB键，触发走焦，“Second Button”获焦，onFocus回调响应，背景色变成绿色；“First Button”失焦，onBlur回调响应，背景色变回灰色。
- 按下TAB键，触发走焦，“Third Button”获焦，onFocus回调响应，背景色变成绿色；“Second Button”失焦，onBlur回调响应，背景色变回灰色。

## 设置组件是否可获焦

```cangjie
public func focusable(value: ?Bool): T
```

设置组件是否可获焦。

按照组件的获焦能力可大致分为三类：

- 默认可获焦的组件，通常是有交互行为的组件，例如Button、Checkbox、TextInput组件，此类组件无需设置任何属性，默认即可获焦。

- 有获焦能力，但默认不可获焦的组件，典型的是Text、Image组件，此类组件缺省情况下无法获焦，若需要使其获焦，可使用通用属性focusable(true)使能。对于没有配置focusable属性，有获焦能力但默认不可获焦的组件，为其配置onClick或是单指单击的Tap手势，该组件会隐式地成为可获焦组件。如果其focusable属性被设置为false，即使配置了上述事件，该组件依然不可获焦。

- 无获焦能力的组件，通常是无任何交互行为的展示类组件，例如Blank、Circle组件，此类组件即使使用focusable属性也无法使其可获焦。

```cangjie
public func enabled(value: ?Bool): T
```

设置组件可交互性属性[enabled](../reference/arkui-cj/cj-universal-attribute-enable.md#func-enabledbool)为`false`，则组件不可交互，无法获焦。

```cangjie
public func visibility(value: ?Bool): T
```

设置组件可见性属性[visibility](../reference/arkui-cj/cj-universal-attribute-visibility.md#func-visibilityvisibility)为`Visibility.None`或`Visibility.Hidden`，则组件不可见，无法获焦。

```cangjie
public func focusOnTouch(value: ?Bool): T
```

设置当前组件是否支持点击获焦能力。

> **说明：**
>
> 当某组件处于获焦状态时，将其的focusable属性或enabled属性设置为false，会自动使该组件失焦，然后焦点按照[走焦规范](#走焦规范)将焦点转移给其他组件。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var textFocusable: Bool = true
    @State var textEnabled: Bool = true
    @State var color1: Color = Color(0xFFFF00)
    @State var color2: Color = Color(0xFFFF00)
    @State var color3: Color = Color(0xFFFF00)

    func build() {
        Column(space: 5) {
            // 第一个Text组件未设置focusable属性，默认不可获焦
            Text("Default Text")
                .borderColor(color1)
                .borderWidth(2)
                .width(300)
                .height(70)
                .onFocus({ =>
                    color1 = Color.Blue
                })
                .onBlur({ =>
                    color1 = Color(0xFFFF00)
                })

            Divider()

            // 第二个Text设置了focusable初始为true，focusableOnTouch为true
            Text("focusable: " + textFocusable.toString())
                .borderColor(color2)
                .borderWidth(2)
                .width(300)
                .height(70)
                .focusable(textFocusable)
                .focusOnTouch(true)
                .onFocus({ =>
                    color2 = Color.Blue
                })
                .onBlur({ =>
                    color2 = Color(0xFFFF00)
                })

            // 第三个Text设置了focusable为true，enabled初始为true
            Text("enabled: " + textEnabled.toString())
                .borderColor(color3)
                .borderWidth(2)
                .width(300)
                .height(70)
                .focusable(true)
                .enabled(textEnabled)
                .focusOnTouch(true)
                .onFocus({ =>
                    color3 = Color.Blue
                })
                .onBlur({ =>
                    color3 = Color(0xFFFF00)
                })

            Divider()

            Row() {
                Button("Button1")
                    .width(140).height(70).margin(right: 20)
                Button("Button2")
                    .width(140).height(70)
            }

            Divider()
            Button("Button3")
                .width(300).height(70)

            Divider()
        }
        .width(100.percent)
        .justifyContent(FlexAlign.Center)
        .onKeyEvent({ e =>
            // 绑定onKeyEvent，在该Column组件获焦时，按下'F'键，可将第二个Text的focusable置反
            if (e.keyCode == 2022 && e.keyType == KeyType.Down) {
                textFocusable = !textFocusable
            }
            // 绑定onKeyEvent，在该Column组件获焦时，按下'G'键，可将第三个Text的enabled置反
            if (e.keyCode == 2023 && e.keyType == KeyType.Down) {
                textEnabled = !textEnabled
            }
        })
    }
}
```

运行效果：

![focus-1.gif](figures/focus-1.gif)

上述示例包含以下步骤：

1. 第一个Text组件没有设置focusable(true)属性，该Text组件无法获焦。
2. 点击第二个Text组件，由于设置了focusOnTouch(true)，第二个组件获焦。按下TAB键，触发走焦，仍然是第二个Text组件获焦。按键盘F键，触发onKeyEvent，focusable置为false，第二个Text组件变成不可获焦，焦点自动转移，会自动从Text组件寻找下一个可获焦组件，焦点转移到第三个Text组件上。
3. 按键盘G键，触发onKeyEvent，enabled置为false，第三个Text组件变成不可获焦，焦点自动转移，使焦点转移到Row容器上，容器中使用的是默认配置，会转移到Button1上。

## 默认焦点

### 页面的默认焦点

```cangjie
public func defaultFocus(value: ?Bool): T
```

设置当前组件是否为当前页面上的默认焦点。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var oneButtonColor: Color = Color.Gray
    @State var twoButtonColor: Color = Color.Gray
    @State var threeButtonColor: Color = Color.Gray

    func build() {
        Column(space: 20) {
            // 通过外接键盘的上下键可以让焦点在三个按钮间移动，按钮获焦时颜色变化，失焦时变回原背景色
            Button("First Button")
                .width(260)
                .height(70)
                .backgroundColor(oneButtonColor)
                .fontColor(Color.Black)
                // 监听第一个组件的获焦事件，获焦后改变颜色
                .onFocus({ =>
                    oneButtonColor = Color(0x64BB5C)
                })
                // 监听第一个组件的失焦事件，失焦后改变颜色
                .onBlur({ =>
                    oneButtonColor = Color.Gray
                })

            Button("Second Button")
                .width(260)
                .height(70)
                .backgroundColor(twoButtonColor)
                .fontColor(Color.Black)
                // 监听第二个组件的获焦事件，获焦后改变颜色
                .onFocus({ =>
                    twoButtonColor = Color(0x64BB5C)
                })
                // 监听第二个组件的失焦事件，失焦后改变颜色
                .onBlur({ =>
                    twoButtonColor = Color.Gray
                })

            Button("Third Button")
                .width(260)
                .height(70)
                .backgroundColor(threeButtonColor)
                .fontColor(Color.Black)
                // 设置默认焦点
                .defaultFocus(true)
                // 监听第三个组件的获焦事件，获焦后改变颜色
                .onFocus({ =>
                    threeButtonColor = Color(0x64BB5C)
                })
                // 监听第三个组件的失焦事件，失焦后改变颜色
                .onBlur({ =>
                    threeButtonColor = Color.Gray
                })
        }
        .width(100.percent)
        .margin(top: 20)
    }
}
```

![defaultFocus.gif](figures/defaultFocus.gif)

上述示例包含以下2步：

- 在第三个Button组件上设置了defaultFocus(true)，进入页面后第三个Button默认获焦，显示为绿色。
- 按下TAB键，触发走焦，第三个Button正处于获焦状态，会出现焦点框。

### 页面/容器整体获焦时的焦点链

#### 整体获焦与非整体获焦

- 整体获焦是[页面](#基础概念)/容器自身作为焦点链的叶节点获焦，获焦后再把焦点链叶节点转移到子孙组件。例如，[页面](#基础概念)切换、Navigation组件中的路由切换、焦点组走焦、容器组件主动调用requestFocusById等。

- 非整体获焦是某个组件作为焦点链叶节点获焦，导致其祖先节点跟着获焦。例如TextInput组件主动获取焦点、Tab键在非焦点组场景下走焦等。

#### 整体获焦的焦点链形成

1.[页面](#基础概念)首次获焦：

- 焦点链叶节点为配置了defaultFocus的节点。
- 未配置defaultFocus时，焦点停留在[页面](#基础概念)的根容器上。

2.[页面](#基础概念)非首次获焦：由上次获焦的节点获焦。

3.获焦链上存在配置了获焦优先级的组件和容器：

- 容器内存在优先级大于PREVIOUS的组件，由优先级最高的组件获焦。
- 容器内不存在优先级大于PREVIOUS的组件，由上次获焦的节点获焦。例如，窗口失焦后重新获焦。

## 主动获焦/失焦

使用focusControl中的方法：

```cangjie
public static func requestFocus(value: ?String): Bool
```

调用此接口可以主动让焦点转移至参数指定的组件上，焦点转移生效时间为下一个帧信号。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var btColor: UInt32 = 0x2787d9
    @State var btColor2: UInt32 = 0x2787d9

    func build() {
        Column(space: 20) {
            Column(space: 5) {
                Button("Button")
                    .width(200)
                    .height(70)
                    .fontColor(Color.White)
                    .focusOnTouch(true)
                    .backgroundColor(0x2787d9)
                    .onFocus({ =>
                        btColor = 0xd5d5d5
                    })
                    .onBlur({ =>
                        btColor = 0x2787d9
                    })
                    .id("testButton")

                Button("Button")
                    .width(200)
                    .height(70)
                    .fontColor(Color.White)
                    .focusOnTouch(true)
                    .backgroundColor(btColor2)
                    .onFocus({ =>
                        btColor2 = 0xd5d5d5
                    })
                    .onBlur({ =>
                        btColor2 = 0x2787d9
                    })
                    .id("testButton2")

                Divider()
                    .vertical(false)
                    .width(80.percent)
                    .backgroundColor(0x707070)
                    .height(10)
                //点击focusControl.requestFocus按钮，第二个Button获焦。
                Button("FocusControl.requestFocus")
                    .width(200)
                    .height(70)
                    .fontColor(Color.White)
                    .onClick({ evt =>
                        FocusControl.requestFocus("testButton2")
                    })
                    .backgroundColor(0xff2787d9)
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
}
```

![focus-2](figures/focus-2.gif)

## 焦点与按键事件

当组件获焦且存在点击事件（`onClick`）或单指单击事件（`TapGesture`）时，回车和空格会触发对应的事件回调。

> **说明：**
>
> - 点击事件（`onClick`）或单指单击事件（`TapGesture`）在回车、空格触发对应事件回调时，默认不冒泡传递，即父组件对应[按键事件](../reference/arkui-cj/cj-universal-event-key.md)不会被同步触发。
> - 按键事件（`onKeyEvent`）默认冒泡传递，即同时会触发父组件的按键事件回调。
> - 组件同时存在点击事件（`onClick`）和按键事件（`onKeyEvent`），在回车、空格触发时，两者都会响应。
> - 获焦组件响应点击事件（`onClick`），与焦点激活态无关。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var count: Int = 0
    @State var name: String = "Button"

    func build() {
        Column {
            Button(name)
                .fontSize(30)
                .onClick({ evt =>
                    count++
                    if (count <= 0) {
                        name = "count is negative number"
                    } else if (count % 2 == 0) {
                        name = "count is even number"
                    } else {
                        name = "count is odd number"
                    }
                })
                .height(60)
        }
        .height(100.percent).width(100.percent).justifyContent(FlexAlign.Center)
    }
}
```

![focus-4](figures/focus-4.gif)

## 组件获焦能力说明

基础组件获焦能力如下表所示：

| 基础组件                                     | 是否有获焦能力 | focusable默认值 |
| :---------------------------------------- | :------- | :------------ |
| [AlphabetIndexer](../reference/arkui-cj/cj-information-display-alphabetindexer.md) | 是       | true         |
| [Blank](../reference/arkui-cj/cj-blank-divider-blank.md) | 否       | false        |
| [Button](../reference/arkui-cj/cj-button-picker-button.md) | 是       | true         |
| [Checkbox](../reference/arkui-cj/cj-button-picker-checkbox.md) | 是       | true         |
| [CheckboxGroup](../reference/arkui-cj/cj-button-picker-checkboxgroup.md) | 是       | true         |
| [DataPanel](../reference/arkui-cj/cj-information-display-datapanel.md) | 是       | false        |
| [DatePicker](../reference/arkui-cj/cj-button-picker-datepicker.md) | 是       | true         |
| [Divider](../reference/arkui-cj/cj-blank-divider-divider.md) | 是       | false        |
| [Gauge](../reference/arkui-cj/cj-information-display-gauge.md) | 是       | false        |
| [Image](../reference/arkui-cj/cj-image-video-image.md) | 是       | false        |
| [ImageSpan](../reference/arkui-cj/cj-text-input-imagespan.md)                 | 否       | false        |
| [LoadingProgress](../reference/arkui-cj/cj-information-display-loadingprogress.md) | 是       | true        |
| [Navigation](../reference/arkui-cj/cj-navigation-switching-navigation.md) | 是       | true         |
| [PatternLock](../reference/arkui-cj/cj-information-display-patternlock.md) | 是       | true        |
| [Progress](../reference/arkui-cj/cj-information-display-progress.md) | 是       | true        |
| [QRCode](../reference/arkui-cj/cj-information-display-qrcode.md) | 是       | true        |
| [Radio](../reference/arkui-cj/cj-button-picker-radio.md) | 是       | true         |
| [Rating](../reference/arkui-cj/cj-button-picker-rating.md) | 是       | true         |
| [RichEditor](../reference/arkui-cj/cj-text-input-richeditor.md) | 是       | true         |
| [RichText](../reference/arkui-cj/cj-text-input-richtext.md) | 否       | false        |
| [ScrollBar](../reference/arkui-cj/cj-scroll-swipe-scrollbar.md) | 否       | false        |
| [Search](../reference/arkui-cj/cj-text-input-search.md) | 是       | true         |
| [Select](../reference/arkui-cj/cj-button-picker-select.md) | 是       | true         |
| [Slider](../reference/arkui-cj/cj-button-picker-slider.md) | 是       | true         |
| [Span](../reference/arkui-cj/cj-text-input-span.md) | 否       | false        |
| [Stepper](../reference/arkui-cj/cj-navigation-switching-stepper.md) | 是       | true         |
| [StepperItem](../reference/arkui-cj/cj-navigation-switching-stepperitem.md) | 是       | true         |
| [Text](../reference/arkui-cj/cj-text-input-text.md) | 是       | false        |
| [TextArea](../reference/arkui-cj/cj-text-input-textarea.md) | 否       | false         |
| [TextClock](../reference/arkui-cj/cj-information-display-textclock.md) | 否       | false        |
| [TextInput](../reference/arkui-cj/cj-text-input-textinput.md) | 是       | true         |
| [TextPicker](../reference/arkui-cj/cj-button-picker-textpicker.md) | 是       | true         |
| [TextTimer](../reference/arkui-cj/cj-information-display-texttimer.md) | 否       | false        |
| [Toggle](../reference/arkui-cj/cj-button-picker-toggle.md) | 是       | true         |

容器组件获焦能力如下表所示：

| 容器组件                                     | 是否可获焦 | focusable默认值 |
| :---------------------------------------- | :------- | :------------ |
| [Badge](../reference/arkui-cj/cj-information-display-badge.md) | 否     | false        |
| [Column](../reference/arkui-cj/cj-row-column-stack-column.md) | 是     | true         |
| [Flex](../reference/arkui-cj/cj-row-column-stack-flex.md) | 是     | true         |
| [GridCol](../reference/arkui-cj/cj-grid-layout-gridcol.md) | 是     | true         |
| [GridRow](../reference/arkui-cj/cj-grid-layout-gridrow.md) | 是     | true         |
| [Grid](../reference/arkui-cj/cj-scroll-swipe-grid.md) | 是     | true         |
| [GridItem](../reference/arkui-cj/cj-scroll-swipe-griditem.md) | 是     | true         |
| [List](../reference/arkui-cj/cj-scroll-swipe-list.md) | 是     | true         |
| [ListItem](../reference/arkui-cj//cj-scroll-swipe-listitem.md) | 是     | true         |
| [ListItemGroup](../reference/arkui-cj/cj-scroll-swipe-listgroup.md) | 是     | true         |
| [Navigator](../reference/arkui-cj/cj-navigation-switching-navigation.md) | 是     | true         |
| [Refresh](../reference/arkui-cj/cj-scroll-swipe-refresh.md) | 是     | true        |
| [RelativeContainer](../reference/arkui-cj/cj-row-column-stack-relativecontainer.md) | 否     | false         |
| [Row](../reference/arkui-cj/cj-row-column-stack-row.md) | 是    | true         |
| [RowSplit](../reference/arkui-cj/cj-grid-layout-rowsplit.md) | 是     | true         |
| [Scroll](../reference/arkui-cj/cj-scroll-swipe-scroll.md) | 是     | true         |
| [SideBarContainer](../reference/arkui-cj/cj-grid-layout-sidebar.md) | 是     | true         |
| [Stack](../reference/arkui-cj/cj-row-column-stack-stack.md) | 是     | true         |
| [Swiper](../reference/arkui-cj/cj-scroll-swipe-swiper.md) | 是     | true         |
| [Tabs](../reference/arkui-cj/cj-navigation-switching-tabs.md) | 是     | true         |

媒体组件获焦能力如下表所示：

| 媒体组件                                     | 是否可获焦 | focusable默认值 |
| :---------------------------------------- | :------- | :------------ |
| [Video](../reference/arkui-cj/cj-image-video-video.md) | 是     | true         |
