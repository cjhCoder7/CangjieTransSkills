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

@Component
public class PublicPageTop {
    @Prop
    var label: String

    func build() {
        Row {
            Row(20) {
                Image(@r(app.media.ic_chevron_left)).topImg(30, 30).padding(5).back(
                    //当label为"转盘列表时"返回按钮直接返回到主页
                    //否则时back到上一页
                    if (this.label == "转盘列表") {
                    "MyView"
                } else {
                    ""
                })
                Text(label).fontSize(22).fontWeight(FontWeight.Medium)
            }
            Blank()
            Image(this.changeListImg()).topImg(30, 30).redirect(
                //当label为"转盘列表"时，添加按钮会进入到创建选项页面
                //否则跳转到首页，这时图案为√
                if (this.label == "转盘列表") {
                ("PublicPage", "创建")
            } else if (this.label == "创建" || this.label == "编辑") {
                ("MyView", "首页")
            } else {
                ("", "")
            })
        }.width(100.percent).height(60)
    }

    //根据路由传过来的label显示不同的图片
    private func changeListImg(): CJResource {
        match (this.label) {
            case "转盘列表" => @r(app.media.ic_plus)
            case _ => @rawfile("ic_checkmark.png")
        }
    }
}
