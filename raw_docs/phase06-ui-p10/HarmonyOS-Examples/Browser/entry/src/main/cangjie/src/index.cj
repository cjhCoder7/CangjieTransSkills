package ohos_app_cangjie_entry

internal import ohos.{base.*, component.*, resource_manager.*, router.*, state_manage.*, webview.*}
import ohos.state_macro_manage.*
import std.{convert.*, regex.*}

@Entry
@Component
class MainView {
    // 黑暗页面注入脚本
    var darkmodeScript = "!function(){window.location.hostname;new class{constructor(){this.init()}init(){this.addStyle(\"\\n        html, body {\\n          background-color: #202020 !important;\\n        }\\n        * {\\n          color: #CCD1D9 !important;\\n          box-shadow: none !important;\\n        }\\n        *:after, *:before {\\n          border-color: #1e1e1e !important;\\n          color: #CCD1D9 !important;\\n          box-shadow: none !important;\\n          background-color: transparent !important;\\n        }\\n        a, a > *{\\n          color: #66C9FF !important;\\n        }\\n        [data-change-border-color][data-change-border-color-important] {\\n          border-color: #1e1e1e !important;\\n        }\\n        [data-change-background-color][data-change-background-color-important] {\\n          background-color: #202020 !important;\\n        }\\n      \"),this.selectAllNodes((e=>{if(1!==e.nodeType)return;const t=window.getComputedStyle(e,null),o=[\"rgba(0, 0, 0, 0)\",\"transparent\"],r=t.getPropertyValue(\"background-color\"),n=t.getPropertyValue(\"border-color\");o.indexOf(r)<0&&(this.isWhiteToBlack(r)?(e.dataset.changeBackgroundColor=\"\",e.dataset.changeBackgroundColorImportant=\"\"):(delete e.dataset.changeBackgroundColor,delete e.dataset.changeBackgroundColorImportant)),o.indexOf(n)<0&&(this.isWhiteToBlack(n)?(e.dataset.changeBorderColor=\"\",e.dataset.changeBorderColorImportant=\"\"):(delete e.dataset.changeBorderColor,delete e.dataset.changeBorderColorImportant)),n.indexOf(\"rgb(255, 255, 255)\")>=0&&(delete e.dataset.changeBorderColor,delete e.dataset.changeBorderColorImportant,e.style.borderColor=\"transparent\")}))}addStyle(e=\"\"){const t=document.createElement(\"style\");t.innerHTML=e,document.head.appendChild(t)}isWhiteToBlack(e=\"\"){let t=!1;const o=e.match(/rgb.+?\\)/g);return!o||0===o.length||(o.forEach((e=>{const o=/rgb[a]*?\\(([0-9]+),.*?([0-9]+),.*?([0-9]+).*?\\)/g.exec(e),r=o[1],n=o[2],a=o[3];Math.max(r,n,a)-Math.min(r,n,a)<=20&&(t=!0)})),t)}selectAllNodes(e=(()=>{})){const t=document.querySelectorAll(\"*\");Array.from(t,(t=>{e(t)})),this.observe({targetNode:document.documentElement,config:{attributes:!1},callback(t,o){const r=document.querySelectorAll(\"*\");Array.from(r,(t=>{e(t)}))}})}observe({targetNode:e,config:t={},callback:o=(()=>{})}){if(!e)return;t=Object.assign({attributes:!0,childList:!0,subtree:!0},t);new MutationObserver(o).observe(e,t)}}}();"
    // 页面模式检测
    let _colorMode = Environment.envProp<ColorMode>("colorMode", ColorMode.Light)
    @StorageProp["colorMode"] let color: ColorMode = ColorMode.Light
    // 当前页面 url
    @State
    var url: String = "https://m.baidu.com/"
    // 全局 webview 控制器
    var webviewController: WebviewController = WebviewController()
    // 正则判断是否为合法 url（无后缀检验）
    func isUrl(text: String): Bool {
        let regex = Regex("^[a-zA-Z0-9-.]+.[a-zA-Z]{2,}$")
        match (regex.matches(text)) {
            case Some(r) => true
            case None => false
        }
    }
    // 页面逻辑
    func build() {
        Column {
            // 顶栏
            Row {
                Search(placeholder: "搜索或输入网址", value: this.url).onSubmit(
                    {
                        content =>
                        if (isUrl(content)) {
                            this.url = content
                        } else {
                            this.url = "https://baidu.com/s?wd=" + content
                        }
                        this.webviewController.loadUrl(this.url)
                    }
                ).width(80.percent)
                Image("/resources/base/media/arrow_clockwise.svg").fillColor(@r(app.color.foreground)).width(5.percent).
                    margin(left: 5.percent).onClick({_ => this.webviewController.refresh()})
            }.width(100.percent).height(8.percent).justifyContent(FlexAlign.Center)
            // 网页
            Row {
                Web(src: this.url, controller: webviewController).onPageBegin(
                    {
                    _ => this.webviewController.setCustomUserAgent(
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
                    )
                }).onPageEnd(
                    {
                        event =>
                        this.url = event.url
                        match(this.color) {
                            case ColorMode.Light => { => ()}()
                            case ColorMode.Dark => this.webviewController.runJavaScript(darkmodeScript, {_, _ => ()})
                        }
                    }
                )
            }.width(100.percent).height(84.percent)
            // 功能栏
            Row {
                // 上一页
                Row {
                    Image(@r(app.media.chevron_left)).fillColor(@r(app.color.foreground)).height(40.percent)
                }.width(20.percent).height(100.percent).justifyContent(FlexAlign.Center).onClick(
                    {
                    _ => if (this.webviewController.accessBackward()) {
                        this.webviewController.backward()
                    }
                })
                // 下一页
                Row {
                    Image(@r(app.media.chevron_right)).fillColor(@r(app.color.foreground)).height(40.percent)
                }.width(20.percent).height(100.percent).justifyContent(FlexAlign.Center).onClick(
                    {_ => this.webviewController.forward()})
                // 回到首页
                Row {
                    Image(@r(app.media.house)).fillColor(@r(app.color.foreground)).height(40.percent)
                }.width(20.percent).height(100.percent).justifyContent(FlexAlign.Center).onClick(
                    {_ => this.webviewController.loadUrl("https://m.baidu.com/")})
                // 多标签页（暂不支持）
                Row {
                    Image(@r(app.media.rectangle_on_rectangle)).fillColor(@r(app.color.foreground)).height(40.percent)
                }.width(20.percent).height(100.percent).justifyContent(FlexAlign.Center)
                // 设置
                Row {
                    Image(@r(app.media.dot_grid_2x2)).fillColor(@r(app.color.foreground)).height(40.percent)
                }.width(20.percent).height(100.percent).justifyContent(FlexAlign.Center).bindMenu(builder: settingMenu)
            }.width(100.percent).height(8.percent)
        }.width(100.percent).height(100.percent).backgroundColor(@r(app.color.background)).foregroundColor(
            @r(app.color.foreground)).expandSafeArea()
    }

    @Builder
    func selectEngine() {
        Row {
            Text("搜索引擎").margin(left: 15)
            Select(
                Array<SelectOption>(
                [SelectOption("百度", icon: @r(app.media.baidu)), SelectOption("必应", icon: @r(app.media.bing))]))
        }.width(90.percent).justifyContent(FlexAlign.SpaceBetween)
    }

    // 设置菜单
    @Builder
    func settingMenu() {
        Menu {
            // TODO: 用户自定义 暗色模式 与 AdBlocker 是否启用
            MenuItem(startIcon: @r(app.media.gearshape), content: @r(app.string.setting), endIcon: CJResource(0, 0, ""), labelInfo: @r(app.string.empty)).enabled(false)
            MenuItem(startIcon: @r(app.media.info_circle), content: @r(app.string.about), endIcon: CJResource(0, 0, ""), labelInfo: @r(app.string.empty)).onClick({_ => Router.push(url: "About")})
        }
    }
}
