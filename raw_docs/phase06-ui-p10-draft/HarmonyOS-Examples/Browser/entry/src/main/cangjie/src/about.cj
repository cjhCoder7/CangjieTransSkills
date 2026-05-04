package ohos_app_cangjie_entry

internal import cj_res_entry.app
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.router.*
internal import ohos.state_manage.*
internal import ohos.webview.*
import ohos.state_macro_manage.*

@Entry
@Component
class About {
    func build() {
        Column {
            Row {
                Image(@r(app.media.chevron_left)).height(60.percent).fillColor(@r(app.color.foreground)).margin(left: 10.fp).onClick({_ => Router.back()})
                Text(@r(app.string.about)).margin(left: 10.fp).fontSize(17).fontWeight(FontWeight.W300)
            }.width(100.percent).height(10.percent)
            Column {
                Image(@r(app.media.app_icon)).width(100.fp)
                Text(@r(app.string.app_name)).fontSize(24).margin(top: 10.fp)
                Text(@r(app.string.EntryAbility_desc)).fontSize(17).fontWeight(FontWeight.W200).margin(top: 10.fp)
            }.width(100.percent).height(90.percent).justifyContent(FlexAlign.Center).align(Alignment.Center)
        }.width(100.percent).height(100.percent).backgroundColor(@r(app.color.background)).foregroundColor(
            @r(app.color.foreground)).expandSafeArea()
    }
}
