# 绑定全模态页面（bindContentCover）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

[全模态页面（bindContentCover）](../reference/arkui-cj/cj-universal-attribute-bindcontentcover.md#func-bindcontentcoverbool-custombuilder-contentcoveroptions)是全屏模态形式的弹窗交互页面，完全覆盖底层父视图。适用于查看大图，全屏查看文稿等场景。

## 使用约束

全模态页面本质上是弹窗类组件，其交互层级默认为应用内顶层。

[Navigation](../reference/arkui-cj/cj-navigation-switching-navigation.md)导航转场时，新push的页面层级无法超出全模态，其效果仍然显示在模态页面之下。针对此类场景，建议将模态页面的内容迁移至转场页面中实现。例如，在上述情况下，可以使用NavDestination来替代拉起的模态页面，新push的页面层级低于全模态。

## 生命周期

全模态页面提供了生命周期函数，用于通知应用程序该弹窗的生命周期状态。生命周期的触发顺序依次为：onWillAppear -> onAppear -> onWillDisappear -> onDisappear。

| 名称            |类型| 说明                       |
| :----------------- | :------ | :---------------------------- |
| onWillAppear    | () -> Unit | 全模态页面显示（动画开始前）回调函数。 |
| onAppear    | () -> Unit | 全模态页面显示（动画结束后）回调函数。  |
| onWillDisappear | () -> Unit | 全模态页面回退（动画开始前）回调函数。 |
| onDisappear |() -> Unit  | 全模态页面回退（动画结束后）回调函数。     |

## 使用bindContentCover构建全屏模态内容覆盖半模态

全模态与半模态之间存在弹窗式的层级交互。后拉起的模态页面能够覆盖先前的模态页面。若开发者期望实现全屏转场，以覆盖半模态，并在全屏页面侧滑退出后，半模态页面仍保持显示，使用bindSheet结合bindContentCover可以满足这一场景诉求。

详情请参见[模态转场](./cj-modal-transition.md#使用bindcontentcover构建全屏模态转场效果)，了解使用bindContentCover构建全屏模态转场效果。

## 示例代码

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.*
import std.collection.*

struct PersonList{
    var name: String = ""
    var carnum: String = ""
    public init(name: String,carnum: String){
        this.name = name
        this.carnum = carnum
    }
}

@Entry
@Component
class EntryView {

    private var personlist: ArrayList<PersonList> = ArrayList<PersonList>(
        [PersonList("许**","123***456"),PersonList("王**","234***345"),PersonList("陈**","345**456")])

    // 半模态转场控制变量
    @State var isSheetShow: Bool = false
    // 全模态转场控制变量
    @State var isPresent: Bool = false
    public func onAppear() {
        Hilog.info(0, "cangjie", "BindContentCover onAppear.")
    }
    public func onDisappear() {
        Hilog.info(0, "cangjie", "BindContentCover onDisappear.")
    }

    @Builder
    public func MycontentCoverBulider(){
        Column(){
            Column(){
                Blank().height(20.percent)
                ForEach(this.personlist,itemGeneratorFunc:{item:PersonList,index: Int64 =>
                        Row(){
                            Column(){
                                if(index %2 == 0){
                                    Column()
                                    .width(20)
                                    .height(20)
                                    .border(width: 10, color: 0x007dfe)
                                    .backgroundColor(0x007dfe)
                                }else{
                                    Column()
                                    .width(20)
                                    .height(20)
                                }
                            }.width(20.percent)
                            Column(){
                                Text(item.name)
                                .fontColor(0x333333)
                                .fontSize(18)
                                Text(item.carnum)
                                .fontColor(0x666666)
                                .fontSize(14)
                            }.width(60.percent).alignItems(HorizontalAlign.Center)
                            Column(){
                                Text("编辑")
                                .fontColor(0x007dfe)
                                .fontSize(16)
                            }
                            .width(20.percent)
                        }
                        .padding(top:10,bottom:10)
                        .width(92.percent)
                        .backgroundColor(Color.White)
                        })
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            Button("确定")
            .width(400)
            .height(40)
            .fontColor(Color.Blue)
            .onClick({
                evt =>
                this.isPresent = !this.isPresent
            })
        }
        .backgroundColor(0xf5f5f5)
        .size(width: 100.percent,height: 80.percent)
    }

    @Builder
    public func TripInfo(){
        Row(){
            Column(){
                Text("00:25")
                Text("始发站")
            }.width(100)
            Column(){
                Text("G1234")
                Text("8时1分")
            }.width(100)
            Column(){
                Text("08:26")
                Text("终点站")
            }.width(100)
        }
    }
    // 第二步：定义半模态展示界面
    // 通过builder构建模态展示界面
    @Builder
    public func MySheetBuilder(){
        Column(){
            Column(){
                this.TripInfo()
            }.width(500)
            .margin(15)
            .backgroundColor(Color.White)
            .borderRadius(10)

            Column(){
                Button("+ 选择乘车人")
                .fontSize(18)
                .onClick({
                    evt =>
                    // 第三步：通过全模态接口调起全模态展示界面，新拉起的模态面板默认显示在最上层
                    this.isPresent = !this.isPresent
                })
                // 通过全模态接口，绑定模态展示界面MyContentCoverBuilder。
                .bindContentCover(this.isPresent,MycontentCoverBulider,options: ContentCoverOptions(
                          modalTransition: ModalTransition.Default,backgroundColor: Color.White,onAppear: onAppear,onDisappear:onDisappear)
                    )
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Color.White)
            .padding(60)
        }
    }

    func build() {
        Column(){
            Blank().height(20.percent)
            Text("确认订单")
            this.TripInfo()
            Column(){
                Button("选择乘车人")
                .onClick({
                    evt =>
                    this.isSheetShow = !this.isSheetShow
                })
                // 第一步：定义半模态转场效果
                .bindSheet(this.isSheetShow,MySheetBuilder)
            }
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(Color.White)
    }
}
```

![bindcontentcoverpage](./figures/bindContentCoverPage.gif)
