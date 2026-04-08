# 安全区域

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

安全区域是指页面的显示区域，默认不与系统设置的非安全区域比如状态栏、导航栏区域重叠，默认情况下开发者开发的界面都被布局在安全区域内。提供属性方法允许开发者设置组件绘制内容突破安全区域的限制，通过[expandSafeArea](./cj-universal-attribute-expandsafearea.md#func-expandsafeareaarraysafeareatype-arraysafeareaedge)属性支持组件不改变布局情况下扩展其绘制区域至安全区外。页面中有标题栏等文字不希望和非安全区重叠时，建议对组件设置expandSafeArea属性达到沉浸式效果，也可以直接通过窗口接口[setWindowLayoutFullScreen](./cj-apis-window.md#)设置沉浸式。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func expandSafeArea(?Array\<SafeAreaType>, ?Array\<SafeAreaEdge>)

```cangjie
func expandSafeArea(types!: ?Array<SafeAreaType>, edges!: ?Array<SafeAreaEdge>): T
```

**功能：** 控制组件扩展其安全区域。

> **说明：**
>
> - 设置expandSafeArea属性进行组件绘制扩展时，建议组件尺寸不要设置固定宽高（百分比除外），当设置固定宽高时，扩展安全区域的方向只支持[SafeAreaEdge.TOP, SafeAreaEdge.START]，扩展后的组件尺寸保持不变。
> - 安全区域不会限制内部组件的布局和大小，不会裁剪内部组件。
> - 当父容器是滚动容器时，设置expandSafeArea属性不生效。
> - 设置expandSafeArea()时，不传参，按默认值处理；设置expandSafeArea([],[])时，相当于入参是空数组，此时设置expandSafeArea属性不生效。
> - 组件设置expandSafeArea之后生效的条件为：
> - 1.type为SafeAreaType.KEYBOARD时默认生效，组件不避让键盘。
> - 2.设置其他type，组件的边界与安全区域重合时组件能够延伸到安全区域下。例如：设备顶部状态栏高度100，那么组件在屏幕中的绝对位置需要为0 <= y <= 100。
> - 组件延伸到避让区时，在避让区的事件如点击事件等可能会被系统拦截，优先给状态栏等系统组件响应。
> - 滚动类容器内的组件不建议设置expandSafeArea属性，如果设置，需要按照组件嵌套关系，将当前节点到滚动类祖先容器间所有直接节点设置expandSafeArea属性，否则expandSafeArea属性在滚动后可能会失效，写法参考示例。
> - expandSafeArea属性仅作用于当前组件，不会向父组件或子组件传递，因此使用过程中，所有相关组件均需配置。
> - 在同时设置了expandSafeArea和position属性时，position属性会先生效，expandSafeArea属性会后生效。对于未设置position、offset等绘制属性的组件，如果组件边界没有和避让区重叠，设置expandSafeArea属性不生效，如弹窗和半模态组件。
> - 对于expandSafeArea属性无法生效的场景，若要将组件部署在避让区，需要手动调整组件的坐标。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :--- | :--- | :--- | :--- | :--- |
| types | ?Array\<[SafeAreaType](./cj-common-types.md#enum-safeareatype)> | 是 | - | **命名参数。**  配置扩展安全区域的类型。 <br/>初始值：[SafeAreaType.System, SafeAreaType.Cutout, SafeAreaType.Keyboard]。 |
| edges | ?Array\<[SafeAreaEdge](./cj-common-types.md#enum-safeareaedge)> | 是 | - | **命名参数。**  配置扩展安全区域的方向。 <br/>初始值：[SafeAreaEdge.Top, SafeAreaEdge.Bottom, SafeAreaEdge.Start, SafeAreaEdge.End]。|
