/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry.page.home

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.router.*

extend Image {
    //顶部图标属性
    func topImg() {
        this.width(40).height(40).backgroundColor(@r(app.color.home_top_img_bg_color)).padding(5).borderRadius(50)
    }

    //点击路由跳转到相关页面
    func redirect(url: String, label: String) {
        this.onClick({
            e => Router.push(url: url, params: label)
        })
    }
}

extend Column {

    //首页属性
    func home() {
        this.width(100.percent).height(100.percent).padding(top: 15, right: 10, left: 10)
    }

    //转盘属性
    func turntabel() {
        this.width(90.percent).height(90.percent).borderRadius(50).backgroundColor(@r(app.color.turntable_bg_color))
    }
}

extend Row {
    //转盘页面编辑按钮属性
    func turntabel_edit() {
        this.borderRadius(30).backgroundColor(@r(app.color.editor_button_color)).padding(top: 8, right: 15, bottom: 8,
            left: 15).justifyContent(FlexAlign.Center).onClick({
            e => Router.push(url: "PublicPage", params: "编辑")
        })
    }
}
