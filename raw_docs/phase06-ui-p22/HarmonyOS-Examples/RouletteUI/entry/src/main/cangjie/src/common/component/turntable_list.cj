/**
 * Created on 2024/9/7
 */
package ohos_app_cangjie_entry.common.component

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.Router
import cj_res_entry.app
import std.collection.ArrayList

//转盘列表
@Component
public class TurnTableList {
    @State
    var currentIndex: Int64 = 0

    let textList: ArrayList<String> = ArrayList<String>(["历史转盘", "转盘模板"])

    let historyList: ArrayList<String> = ArrayList<String>(["今天学什么！！", "明天学什么！！"])
    let templateList: ArrayList<String> = ArrayList<String>(["今天学什么！！", "明天学什么！！", "后天学什么 ！！"])

    func build() {
        Column() {
            List(space:15) {
                ForEach(
                    textList,
                    itemGeneratorFunc: {
                        item: String, index: Int64 => ListItem() {
                            titleItem(item, index)
                        }
                    }
                )
            }.listDirection(Axis.Horizontal).alignListItem(ListItemAlign.Center).height(60)
            List(space: this.changeListSpace()) {
                ForEach(
                    this.matchTitle(),
                    itemGeneratorFunc: {
                        item: String, index: Int64 => ListItem() {
                            this.textListItem(item)
                        }
                    }
                )
            }.listDirection(Axis.Vertical)
        }.width(100.percent).height(100.percent)
    }

    //类别item
    @Builder
    func titleItem(label: String, index: Int64) {
        Row() {
            Text(label).fontSize(14).fontColor(this.changeTextColor(index)).fontWeight(FontWeight.Bold)
        }.padding(bottom: 10).borderWidth(EdgeWidths(bottom: 3.vp)).borderColor(this.changeDividerColor(index)).onClick(
            {evt => this.currentIndex = index})
    }

    //对应的类别转盘文本列表
    @Builder
    func textListItem(text: String) {
        Row() {
            Text(text).fontSize(18).fontWeight(this.changeTextFontWeightForTitle())
        }.width(100.percent).padding(15).borderRadius(10.vp).backgroundColor(@r(app.color.home_background_color))
    }

    //修改文字颜色
    private func changeTextColor(index: Int64): CJResource {
        match (this.currentIndex == index) {
            case true => @r(app.color.home_table_sel)
            case _ => @r(app.color.public_text_color)
        }
    }

    //修改导航条的颜色
    private func changeDividerColor(index: Int64): Color {
        match (this.currentIndex == index) {
            case true => Color.RED
            case _ => Color.TRANSPARENT
        }
    }

    //根据用户点击类别展示对应的数据
    private func matchTitle(): ArrayList<String> {
        match (this.currentIndex) {
            case 0 => this.historyList
            case 1 => this.templateList
            case _ => ArrayList<String>([])
        }
    }

    //根据点击类型修改数据文本颜色
    private func changeTextFontWeightForTitle(): FontWeight {
        match (this.currentIndex) {
            case 0 => FontWeight.Bold
            case 1 => FontWeight.Medium
            case _ => FontWeight.Regular
        }
    }

    //根据用户点修改List各子组件之间的距离
    private func changeListSpace():Int64 {
        match (this.currentIndex) {
        	case 0 => 20
            case 1 => 10
            case _ => 0
        }
    }
}
