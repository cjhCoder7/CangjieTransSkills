/**
 * Created on 2024/8/1
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.state_manage.*
import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import std.collection.ArrayList
import ohos_app_cangjie_entry.utils.*

@Builder
public func RowSelectionBand<T>(selectOptions: ArrayList<(String,T)>, onSelected: (T) -> Unit) : Unit {
  Scroll() {
    Row() {
      ForEach(selectOptions, { option: (String,T), index: Int64 =>
        Text(option[0]).textAlign(TextAlign.Center)
          .fontSize(20.fp).lineHeight(30.fp)
          .height(30.fp).padding(left:10, right:10)
          .onClick({ e: ClickEvent => onSelected(option[1]) })
      })
    }.padding(10)
    .borderRadius(10)
  }.scrollable(ScrollDirection.Horizontal)
}

@Component
public class SelectBar {
  // 标题
  @Prop var title: String

  // 要显示的值
  @Prop var content: String

  // 值列表
  @Prop var options: ArrayList<String>

  // 选中以后的结果
  @Prop var onSelect: (String) -> Unit

  // 高度
  @State var height: Int64 = 0

  func onVisible() {
    if (this.height == 0) {
      this.height = SELECT_BAR_HEIGHT
    } else {
      this.height = 0
    }
  }

  func build() {
    Column(BAR_INNER_GRID_SIZE) {
      Row() {
        labelText(title)
        Text(content)
      }.padding(top:10, bottom: 10)
      .onClick({ e: ClickEvent => this.onVisible() })


      Column() {
        Scroll() {
          Row() {
            ForEach(options, { option: String, index: Int64 =>
              Text(option).textAlign(TextAlign.Center)
                .fontSize(20.fp).lineHeight(30.fp)
                .height(30.fp).padding(left:10, right:10)
                .onClick({ e: ClickEvent => onSelect(option) })
            })
          }.padding(10)
          .borderRadius(10)
        }.scrollable(ScrollDirection.Horizontal)
      }.animationStart(animation)
      .height(height)
      .animationEnd()
    }.width(100.percent)
    .alignItems(HorizontalAlign.Start)
  }
}