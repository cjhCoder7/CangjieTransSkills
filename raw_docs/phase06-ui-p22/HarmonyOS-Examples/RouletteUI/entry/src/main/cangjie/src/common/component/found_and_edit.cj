/**
 * Created on 2024/9/7
 */
package ohos_app_cangjie_entry.common.component

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import std.core.ToString
import ohos.router.Router
import cj_res_entry.app
import ohos.hilog.Hilog

//创建模板或编辑模板
@Component
public class FoundAndEdit {
    @State
    var title: String = ""

    @Prop
    var label: String

    private let controller: TextInputController = TextInputController()

    protected override func aboutToAppear() {
        //只有当label为编辑时才获取
        if (this.label == "编辑") {
            this.title = AppStorage.get<String>("text").getOrThrow()
        }
    }

    func build() {
        Column(10) {
            this.titleBuilder()
            Options(label: label)
        }.width(100.percent).height(90.percent).padding(10)
    }

    //标题
    @Builder
    func titleBuilder() {
        Column(10) {
            Text('标题').fontSize(14).fontColor(@r(app.color.public_text_color))
            Row(10) {
                Image(@rawfile("ic_thinking_face.png")).width(24).aspectRatio(1)
                TextInput(placeholder: "不超过15个字", text: this.title, controller: this.controller).width(280).height(
                    40).backgroundColor(Color.TRANSPARENT).onChange({value: String => this.title = value})
            }.width(100.percent).padding(top: 7, bottom: 7, left: 15).borderRadius(10.vp).backgroundColor(
                @r(app.color.home_background_color)).alignItems(VerticalAlign.Center)
        }.alignItems(HorizontalAlign.Start)
    }
}

//选项
@Component
class Options {
    @State
    var textList: ObservedArrayList<String> = ObservedArrayList<String>([])

    @Prop
    var label: String

    protected override func aboutToAppear() {
        //只有当label为编辑时才获取
        if (this.label == "编辑") {
            this.textList = AppStorage.get<ObservedArrayList<String>>("textList").getOrThrow()
        }
    }

    func build() {
        Column(10) {
            Text("选项(${this.textList.size})").fontSize(14).fontColor(@r(app.color.public_text_color))
            List(space: 10) {
                ForEach(
                    this.textList,
                    itemGeneratorFunc: {
                        item: String, index: Int64 => ListItem() {
                            OptionItem(item: item)
                        }.editable(true)
                    }
                )
                ListItem() {
                    Row(10) {
                        Image(@r(app.media.ic_plus)).width(24).aspectRatio(1).borderRadius(12).borderWidth(2).fillColor(
                            Color.BLACK)
                        Text("添加新选项（不超过10个）").fontSize(16).fontWeight(FontWeight.Bold)
                    }.width(100.percent).padding(15).borderRadius(10.vp).backgroundColor(
                        @r(app.color.home_background_color)).onClick({
                        e => this.textList.append("仓颉")
                    })
                }
            }.id("optionList").height(90.percent).scrollBar(BarState.Off)
        }.height(100.percent).alignItems(HorizontalAlign.Start)
    }
}

//选项Item
@Component
class OptionItem {
    @State
    var item: String = ""

    func build() {
        Row() {
            Text(this.item).fontSize(16)
        }.width(100.percent).padding(15).borderRadius(10.vp).backgroundColor(@r(app.color.home_background_color))
    }
}
