/**
 * Created on 2024/8/29
 */
package ohos_app_cangjie_entry.Component

import cj_res_entry.app
import ohos_app_cangjie_entry.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import ohos.prompt_action.*

@Component
public class HomeHeader {
    @Consume
    var opacityValue: Float64
    @StorageLink["isLogin"]
    var isLoginCheck: Bool = false;
    @State var index0: Int32 = 0

    func LogoutClick(){
        let buttons: Array<ButtonInfo> = [
                    ButtonInfo("确认", Color.BLACK),
                    ButtonInfo("取消", Color.BLACK)
                ]
                PromptAction.showDialog(title: "登出", message: "确认要登出账号吗", buttons: buttons, callback: { err: Option<AsyncError>, i: Option<Int32> =>
                    try {
                        match (i) {
                            case Some(0) => this.isLoginCheck = false;
                                            Router.push(url: "MyView");
                            case _ => index0 = i.getOrThrow()
                        }

                    } catch (e: Exception) {
                        AppLog.error(e.toString())
                    }
    })
            }

    func build() {
        Row() {
            if (this.isLoginCheck) {
                Column() {
                    Image(@r(app.media.ic_home_quit)).width(24.vp).height(24.vp).margin(5.vp).objectFit(
                        ImageFit.Contain)
                    Text('退出').fontSize(12).fontWeight(FontWeight.W500)
                }.onClick({
                    event => this.LogoutClick()
                }).justifyContent(FlexAlign.Center)
            } else {
                Column() {
                    Image(@r(app.media.ic_home_login)).width(24.vp).height(24.vp).margin(5.vp).objectFit(
                        ImageFit.Contain)
                    Text('登录').fontSize(12).fontWeight(FontWeight.W500)
                }.onClick({
                    event => Router.push(url: "Login");
                }).justifyContent(FlexAlign.Center)
            }
            Stack(Alignment.End) {
                TextInput(placeholder: '搜索').placeholderColor(0xFF000000).placeholderFont(size: 16,
                    weight: FontWeight.W400).textAlign(TextAlign.Start).width(100.percent).height(40.vp).fontWeight(
                    W400).fontSize(14).backgroundColor(Color.WHITE)
                Image(@r(app.media.ic_public_search)).width(16.vp).height(16.vp).margin(right: 20.vp)
            }.height(56.vp).width(70.percent).onClick({event => Router.push(url: 'Search')})
            ForEach(
                HeaderIconList,
                itemGeneratorFunc: {
                    item: iconItem, index: Int64 => Column() {
                        Image(item.getImage()).width(24.vp).height(24.vp).margin(5.vp)
                        Text(item.getTitle()).fontSize(12).textAlign(TextAlign.Center).fontWeight(FontWeight.W500)
                    }
                }
            )
        }.justifyContent(FlexAlign.Start).height(100.percent).width(100.percent).backgroundColor(
            Color(241, 243, 245, alpha: Float32(this.opacityValue)))
    }
}
