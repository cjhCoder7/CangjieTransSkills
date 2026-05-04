/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*
import ohos_app_cangjie_entry.utils.MyDataSource
import std.collection.ArrayList

@Component
public class IndexTab {
  let dataList = ArrayList<(String, String)>([
    ("原生智能化",
      "内嵌AgentDSL的编程框架，自然语言&编程语言有机融合；多Agent协同，简化符号表达，模式自由组合，支持各类智能应用开发。"),
    ("天生全场景",
      "轻量化可缩放运行时，模块化分层设计，内存再小也能装得下；全场景领域扩展，元编程和eDSL技术，支持面向领域声明式开发。"),
    ("高性能",
      "终端场景首款全并发 GC ，应用线程更流畅，响应更快。轻量化线程，并发性能更好，开销更少。")
  ])

  func build() {
    Column() {
      Text("Tabs").outerTitle()

      Column() {
        Tabs(BarPosition.Start) {
          ForEach(
            this.dataList,
            itemGeneratorFunc: {
              element: (String, String), index: Int64 =>
                TabContent() {
                  Row() {
                    Text(element[1])
                  }.height(120)
                }.tabBar(element[0])
            }
          )
        }.scrollable(true)  // 设置可以通过左右滑动来切换
        .width(100.percent)
        .height(280)
        .padding(10)
        .barMode(BarMode.Scrollable)  // 设置布局模式为可滑动
        .animationDuration(400)  // 滑动动画时长
      }.borderWidth(1).borderColor(0xe0e0e0)
    }.card().width(100.percent).padding(10)
    .redirect("TabsView")
  }
}

