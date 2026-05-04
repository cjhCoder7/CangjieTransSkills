/**
 * Created on 2024/9/7
 */
package ohos_app_cangjie_entry.common.component

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.router.*

extend Image {
    //顶部图标属性
    func topImg(width: Int64, height: Int64) {
        this.width(width).height(height).backgroundColor(@r(app.color.home_top_img_bg_color)).padding(5).borderRadius(
            50)
    }

    //点击路由返回到相关页面
    func back(url: String) {
        this.onClick({
            e => if (url.size != 0) {
            	Router.back(url: url)
            }else {
            	Router.back()
            }
        })
    }

    //点击路由跳转到相关页面
    func redirect(tuple:(url: String, params: String)) {
        this.onClick({
            e => Router.push(url: tuple[0], params: tuple[1])
        })
    }
}
