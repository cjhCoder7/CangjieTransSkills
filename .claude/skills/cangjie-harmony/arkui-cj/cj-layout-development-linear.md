# 线性布局（Row/Column）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 概述

线性布局（LinearLayout）是开发中最常用的布局，通过线性容器[Row](../reference/arkui-cj/cj-row-column-stack-row.md)和[Column](../reference/arkui-cj/cj-row-column-stack-column.md)构建。线性布局是其他布局的基础，其子元素在线性方向上（水平方向和垂直方向）依次排列。线性布局的排列方向由所选容器组件决定，Column容器内子元素按照垂直方向排列，Row容器内子元素按照水平方向排列。根据不同的排列方向，开发者可选择使用Row或Column容器创建线性布局。

**图1** Column容器内子元素排列示意图

![arrangement-child-elements-column](figures/arrangement-child-elements-column.png)

**图2** Row容器内子元素排列示意图

![arrangement-child-elements-row](figures/arrangement-child-elements-row.png)

## 基本概念

- 布局容器：具有布局能力的组件容器，可以承载其他元素作为其子元素，布局容器会对其子元素进行尺寸计算和布局排列。

- 布局子元素：布局容器内部的元素。

- 主轴：线性布局容器在布局方向上的轴线，子元素默认沿主轴排列。Row容器主轴为水平方向，Column容器主轴为垂直方向。

- 交叉轴：垂直于主轴方向的轴线。Row容器交叉轴为垂直方向，Column容器交叉轴为水平方向。

- 间距：布局子元素的间距。

## 布局子元素在排列方向上的间距

在布局容器内，可以通过space属性设置排列方向上子元素的间距，使各子元素在排列方向上有等间距效果。

### Column容器内排列方向上的间距

**图3** Column容器内排列方向的间距图

![arrangement-direction-column](figures/arrangement-direction-column.png)

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 20) {
            Text('space: 20').fontSize(15).fontColor(Color.Gray).width(90.percent)
            Row().width(90.percent).height(50).backgroundColor(0xF5DEB3)
            Row().width(90.percent).height(50).backgroundColor(0xD2B48C)
            Row().width(90.percent).height(50).backgroundColor(0xF5DEB3)
        }.width(100.percent)
    }
}
```

![arrangement-direction-column01](figures/arrangement-direction-column01.PNG)

### Row容器内排列方向上的间距

**图4** Row容器内排列方向的间距图

![arrangement-direction-row](figures/arrangement-direction-row.png)

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Row(space: 35) {
            Text('space: 35').fontSize(15).fontColor(Color.Gray)
            Row().width(10.percent).height(150).backgroundColor(0xF5DEB3)
            Row().width(10.percent).height(150).backgroundColor(0xD2B48C)
            Row().width(10.percent).height(150).backgroundColor(0xF5DEB3)
        }.width(90.percent)
    }
}
```

![image01](figures/image01.PNG)

## 布局子元素在交叉轴上的对齐方式

在布局容器内，可以通过alignItems属性设置子元素在交叉轴（排列方向的垂直方向）上的对齐方式。且在各类尺寸屏幕中，表现一致。其中，交叉轴为垂直方向时，取值为[VerticalAlign](../reference/arkui-cj/cj-common-types.md#enum-verticalalign)类型，水平方向取值为[HorizontalAlign](../reference/arkui-cj/cj-common-types.md#enum-horizontalalign)类型。

alignSelf属性用于控制单个子元素在容器交叉轴上的对齐方式，其优先级高于alignItems属性，如果设置了alignSelf属性，则在单个子元素上会覆盖alignItems属性。

### Column容器内子元素在水平方向上的排列

**图5** Column容器内子元素在水平方向上的排列图

![horizontal-arrangement-child-column](figures/horizontal-arrangement-child-column.png)

- HorizontalAlign.Start：子元素在水平方向左对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).alignItems(HorizontalAlign.Start).backgroundColor(0xF2F2F2)
      }
  }
  ```

  ![Column1](figures/Column1.PNG)

- HorizontalAlign.Center：子元素在水平方向居中对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).alignItems(HorizontalAlign.Center).backgroundColor(0xF2F2F2)
      }
  }
  ```

  ![Column2](figures/Column2.PNG)

- HorizontalAlign.End：子元素在水平方向右对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).alignItems(HorizontalAlign.End).backgroundColor(0xF2F2F2)
      }
  }
  ```

  ![Column3](figures/Column3.PNG)

### Row容器内子元素在垂直方向上的排列

**图6** Row容器内子元素在垂直方向上的排列图

![horizontal-arrangement-child-row](figures/horizontal-arrangement-child-row.png)

- VerticalAlign.Top：子元素在垂直方向顶部对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).alignItems(VerticalAlign.Top).backgroundColor(0xF2F2F2)
      }
  }
  ```

  ![Column4](figures/Column4.PNG)

- VerticalAlign.Center：子元素在垂直方向居中对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).alignItems(VerticalAlign.Center).backgroundColor(0xF2F2F2)
      }
  }
  ```

  ![Column5](figures/Column5.PNG)

- VerticalAlign.Bottom：子元素在垂直方向底部对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).alignItems(VerticalAlign.Bottom).backgroundColor(0xF2F2F2)
      }
  }
  ```

  ![Column6](figures/Column6.PNG)

## 布局子元素在主轴上的排列方式

在布局容器内，可以通过justifyContent属性设置子元素在容器主轴上的排列方式。可以从主轴起始位置开始排布，也可以从主轴结束位置开始排布，或者均匀分割主轴的空间。

### Column容器内子元素在垂直方向上的排列

**图7** Column容器内子元素在垂直方向上的排列图

![vertial-arrangement-child-column](figures/vertial-arrangement-child-column.png)

- justifyContent(FlexAlign.Start)：元素在垂直方向首端对齐，第一个元素与行首对齐，同时后续的元素与前一个对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(300).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.Start)
      }
  }
  ```

  ![Column7](figures/Column7.PNG)

- justifyContent(FlexAlign.Center)：元素在垂直方向中心对齐，第一个元素与行首的距离与最后一个元素与行尾距离相同。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(300).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.Center)
      }
  }
  ```

  ![Column8](figures/Column8.PNG)

- justifyContent(FlexAlign.End)：元素在垂直方向尾部对齐，最后一个元素与行尾对齐，其他元素与后一个对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(300).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.End)
      }
  }
  ```

  ![Column9](figures/Column9.PNG)

- justifyContent(FlexAlign.SpaceBetween)：垂直方向均匀分配元素，相邻元素之间距离相同。第一个元素与行首对齐，最后一个元素与行尾对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(300).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.SpaceBetween)
      }
  }
  ```

  ![Column10](figures/Column10.PNG)

- justifyContent(FlexAlign.SpaceAround)：垂直方向均匀分配元素，相邻元素之间距离相同。第一个元素到行首的距离和最后一个元素到行尾的距离是相邻元素之间距离的一半。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(300).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.SpaceAround)
      }
  }
  ```

  ![Column11](figures/Column11.PNG)

- justifyContent(FlexAlign.SpaceEvenly)：垂直方向均匀分配元素，相邻元素之间的距离、第一个元素与行首的间距、最后一个元素到行尾的间距都完全一样。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xD2B48C)
              Column() {
              }.width(80.percent).height(50).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(300).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.SpaceEvenly)
      }
  }
  ```

  ![Column12](figures/Column12.PNG)

### Row容器内子元素在水平方向上的排列

**图8** Row容器内子元素在水平方向上的排列图

![vertial-arrangement-child-row](figures/vertial-arrangement-child-row.png)

- justifyContent(FlexAlign.Start)：元素在水平方向首端对齐，第一个元素与行首对齐，同时后续的元素与前一个对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.Start)
      }
  }
  ```

  ![Column13](figures/Column13.PNG)

- justifyContent(FlexAlign.Center)：元素在水平方向中心对齐，第一个元素与行首的距离与最后一个元素与行尾距离相同。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.Center)
      }
  }
  ```

  ![Column14](figures/Column14.PNG)

- justifyContent(FlexAlign.End)：元素在水平方向尾部对齐，最后一个元素与行尾对齐，其他元素与后一个对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.End)
      }
  }
  ```

  ![Column15](figures/Column15.PNG)

- justifyContent(FlexAlign.SpaceBetween)：水平方向均匀分配元素，相邻元素之间距离相同。第一个元素与行首对齐，最后一个元素与行尾对齐。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.SpaceBetween)
      }
  }
  ```

  ![Column16](figures/Column16.PNG)

- justifyContent(FlexAlign.SpaceAround)：水平方向均匀分配元素，相邻元素之间距离相同。第一个元素到行首的距离和最后一个元素到行尾的距离是相邻元素之间距离的一半。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.SpaceAround)
      }
  }
  ```

  ![Column17](figures/Column17.PNG)

- justifyContent(FlexAlign.SpaceEvenly)：水平方向均匀分配元素，相邻元素之间的距离、第一个元素与行首的间距、最后一个元素到行尾的间距都完全一样。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Row() {
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xD2B48C)
              Column() {
              }.width(20.percent).height(30).backgroundColor(0xF5DEB3)
          }.width(100.percent).height(200).backgroundColor(0xF2F2F2).justifyContent(FlexAlign.SpaceEvenly)
      }
  }
  ```

  ![Column18](figures/Column18.PNG)

## 自适应拉伸

在线性布局下，常用空白填充组件[Blank](../reference/arkui-cj/cj-blank-divider-blank.md)，在容器主轴方向自动填充空白空间，达到自适应拉伸效果。Row和Column作为容器，只需要添加宽高为百分比，当屏幕宽高发生变化时，会产生自适应效果。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(){
            Row() {
                Text('Bluetooth').fontSize(18)
                Blank()
                Toggle(ToggleType.Switch,isOn: true)
            }.backgroundColor(0xFFFFFF).borderRadius(15).padding(left:12).width(100.percent)
        }.backgroundColor(0xEFEFEF).padding(20).width(100.percent)
    }
}
```

**图9** 自适应拉伸下的竖屏

![Column19](figures/Column19.PNG)

**图10** 自适应拉伸下的横屏

![Column20](figures/Column20.png)

## 自适应缩放

自适应缩放是指子元素随容器尺寸的变化而按照预设的比例自动调整尺寸，适应各种不同大小的设备。在线性布局中，可以使用以下两种方法实现自适应缩放。

- 父容器尺寸确定时，使用layoutWeight属性设置子元素和兄弟元素在主轴上的权重，忽略元素本身尺寸设置，使它们在任意尺寸的设备下自适应占满剩余空间。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Text('1:2:3').width(100.percent)
              Row() {
                  Column() {
                      Text('layoutWeight(1)').textAlign(TextAlign.Center)
                  }
                  .layoutWeight(1)
                  .backgroundColor(0xF5DEB3)
                  .height(100.percent)
                  Column() {
                      Text('layoutWeight(2)').textAlign(TextAlign.Center)
                  }
                  .layoutWeight(2)
                  .backgroundColor(0xD2B48C)
                  .height(100.percent)
                  Column() {
                      Text('layoutWeight(3)').textAlign(TextAlign.Center)
                  }
                  .layoutWeight(3)
                  .backgroundColor(0xF5DEB3)
                  .height(100.percent)
              }
              .backgroundColor(0xffd306)
              .height(30.percent)
              Text('2:5:3').width(100.percent)
              Row() {
                  Column() {
                      Text('layoutWeight(2)').textAlign(TextAlign.Center)
                  }
                  .layoutWeight(2)
                  .backgroundColor(0xF5DEB3)
                  .height(100.percent)
                  Column() {
                      Text('layoutWeight(5)').textAlign(TextAlign.Center)
                  }
                  .layoutWeight(5)
                  .backgroundColor(0xD2B48C)
                  .height(100.percent)
                  Column() {
                      Text('layoutWeight(3)').textAlign(TextAlign.Center)
                  }
                  .layoutWeight(3)
                  .backgroundColor(0xF5DEB3)
                  .height(100.percent)
              }
              .backgroundColor(0xffd306)
              .height(30.percent)
          }
      }
  }
  ```

  **图11** 自定义缩放下使用layoutWeight属性设置的横屏

  ![Column21](figures/Column21.png)

  **图12** 自定义缩放下使用layoutWeight属性设置的竖屏

  ![Column22](figures/Column22.png)

- 父容器尺寸确定时，使用百分比设置子元素和兄弟元素的宽度，使之在任意尺寸的设备下保持固定的自适应占比。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      func build() {
          Column() {
              Row() {
                  Column() {
                      Text('left width 20%').textAlign(TextAlign.Center)
                  }
                  .width(20.percent)
                  .backgroundColor(0xF5DEB3)
                  .height(100.percent)
                  Column() {
                      Text('center width 50%').textAlign(TextAlign.Center)
                  }
                  .width(50.percent)
                  .backgroundColor(0xD2B48C)
                  .height(100.percent)
                  Column() {
                      Text('right width 30%').textAlign(TextAlign.Center)
                  }
                  .width(30.percent)
                  .backgroundColor(0xF5DEB3)
                  .height(100.percent)
              }
              .backgroundColor(0xffd306)
              .height(30.percent)
          }
      }
  }
  ```

  **图13** 自定义缩放下使用百分比设置的横屏

  ![Column23](figures/Column23.png)

  **图14** 自定义缩放下使用百分比设置的竖屏

  ![Column24](figures/Column24.png)

## 自适应延伸

自适应延伸是指在不同尺寸设备下，当页面的内容超出屏幕大小而无法完全显示时，可以通过滚动条进行拖动展示。这种方法适用于线性布局中内容无法一屏展示的场景。通常有以下两种实现方式。

- [在List中添加滚动条](cj-layout-development-create-list.md)：当List子项过多一屏放不下时，可以将每一项子元素放置在不同的组件中，通过滚动条进行拖动展示。可以通过scrollBar属性设置滚动条的常驻状态。

- 使用Scroll组件：在线性布局中，开发者可以进行垂直方向或者水平方向的布局。当一屏无法完全显示时，可以在Column或Row组件的外层包裹一个可滚动的容器组件Scroll来实现可滑动的线性布局。

  垂直方向布局中使用Scroll组件：

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      let scroller: Scroller = Scroller()
      private var arr: Array<Int64> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      func build() {
          Scroll(this.scroller) {
              Column() {
                  ForEach(this.arr,itemGeneratorFunc: {
                      item: Int64, idx: Int64 => Text(item.toString())
                          .width(90.percent)
                          .height(150)
                          .backgroundColor(0xFFFFFF)
                          .borderRadius(15)
                          .fontSize(16)
                          .textAlign(TextAlign.Center)
                          .margin(top: 10)
                      },
                      keyGeneratorFunc: {item: Int64, idx: Int64 => idx.toString()}
                  )
              }.width(100.percent)
          }
          .backgroundColor(0xDCDCDC)
          .scrollable(ScrollDirection.Vertical) // 滚动方向为垂直方向
          .scrollBar(BarState.On) // 滚动条常驻显示
          .scrollBarColor(Color.Gray) // 滚动条颜色
          .scrollBarWidth(8.vp) // 滚动条宽度
      }
  }
  ```

  ![Column25](figures/Column25.gif)

  水平方向布局中使用Scroll组件：

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*

  @Entry
  @Component
  class EntryView {
      let scroller: Scroller = Scroller()
      private var arr: Array<Int64> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      func build() {
          Scroll(this.scroller) {
              Row() {
                  ForEach(this.arr,itemGeneratorFunc: {
                      item: Int64, idx: Int64 =>
                      Text(item.toString())
                          .width(150)
                          .height(90.percent)
                          .backgroundColor(0xFFFFFF)
                          .borderRadius(15)
                          .fontSize(16)
                          .textAlign(TextAlign.Center)
                          .margin(left: 10)
                      }
                  )
              }.height(100.percent)
          }
          .backgroundColor(0xDCDCDC)
          .scrollable(ScrollDirection.Horizontal) // 滚动方向为水平方向
          .scrollBar(BarState.On) // 滚动条常驻显示
          .scrollBarColor(Color.Gray) // 滚动条颜色
          .scrollBarWidth(8.vp) // 滚动条宽度
      }
  }
  ```

  ![Column26](figures/Column26.gif)
