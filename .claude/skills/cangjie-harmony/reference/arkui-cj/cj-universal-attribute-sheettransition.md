# 半模态转场

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

通过bindSheet属性为组件绑定半模态页面，在组件插入时可通过设置自定义或默认的内置高度确定半模态大小。

> **说明：**
>
> 不支持路由跳转。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func bindSheet(?Bool, CustomBuilder, ?SheetOptions)

```cangjie
func bindSheet(isShow: ?Bool, builder: CustomBuilder, options!: ?SheetOptions): T
```

**功能：** 给组件绑定半模态页面，点击后显示模态页面。

> **说明：**
>
> - 在半模态单档位向上拖拽或是多档位上滑换挡情况下，内容在拖拽结束或换档结束后更新显示区域。
> - 半模态是一个严格和宿主节点绑定在一起的弹窗。若是想实现类似"页面显示的瞬间就弹出半模态"的效果，请确认宿主节点是否已挂载上树。若宿主节点还没上树就将isShow置为true，半模态将不生效。建议使用[onAppear](./cj-universal-event-appear.md#func-onappear---unit)函数，确保在宿主节点挂载后再显示半模态。
> - 尤其是 [SheetMode](./cj-common-types.md#enum-sheetmode) = Embedded 时，除宿主节点外，还需确保对应的页面节点成功挂载。
> - 半模态页面的离场动效不支持打断，动效执行期间无法响应其他手势动作。目前离场动效使用弹簧曲线，该动画曲线存在视觉上并不明显的拖尾动画。因此，在半模态退出时，视觉上半模态页面已经消失，但此时动效可能还未结束，若想再次点击拉起半模态页面则不会响应。需要等动效完全结束后，才可以再次拉起。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| isShow | ?Bool |是|-| 是否显示半模态页面。 <br>初始值：false。|
| builder | [CustomBuilder](./cj-common-types.md#type-custombuilder) | 是 | - | 配置半模态页面内容。 |
| options | ?[SheetOptions](./cj-common-types.md#class-sheetoptions) | 是 | - | **命名参数。**  配置半模态页面的可选属性。 <br/>初始值：SheetOptions()。 |

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
