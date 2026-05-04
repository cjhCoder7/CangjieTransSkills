package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
internal import ohos.{router.*, prompt_action.*}
import ohos.state_macro_manage.*
import cj_res_entry.app

extend Column {
    func expand() {
        this.width(100.percent).height(100.percent).expandSafeArea(types: [SafeAreaType.SYSTEM])
    }
    func centerAlign() {
        this.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    }
}

extend TextInput {
    func style() {
        this.height(48).backgroundColor(@r(app.color.input_back)).placeholderColor(@r(app.color.sub_text)).fontColor(
            @r(app.color.primary)).trans()
    }
    func password() {
        this.style().setType(InputType.Password)
    }
    func trans() {
        this.transition(
            TransitionEffect.asymmetric(
            TransitionEffect.OPACITY,
            TransitionEffect.IDENTITY
        ).animation(AnimateParam(duration: 500, curve: Curve.Ease)))
    }
}

extend Button {
    func style() {
        this.fontSize(18).height(48)
    }
    func primary() {
        this.style().fontColor(@r(app.color.white)).backgroundColor(@r(app.color.primary))
    }
    func sub() {
        this.style().fontColor(@r(app.color.primary)).backgroundColor(@r(app.color.sub))
    }
}

@Entry
@Component
class MyView {
    @State
    var url: String = ""
    @State
    var verify: Bool = false
    @State
    var user: String = ""
    @State
    var password: String = ""
    func build() {
        Column(56) {
            Text("OPDS for Next").fontSize(40).fontColor(@r(app.color.primary)).fontWeight(FontWeight.Medium)
            Column(16) {
                TextInput(placeholder: '输入OPDS地址', text: this.url).style().onChange(
                    {
                    value: String => this.url = value
                }).onSubmit({
                    key => this.enterContent()
                }).geometryTransition("address").transition(TransitionEffect.OPACITY)
                if (verify) {
                    TextInput(placeholder: '用户名', text: this.user).style().onChange(
                        {
                        value: String => this.user = value
                    })
                    TextInput(placeholder: '密码', text: this.password).password().onChange(
                        {
                        value: String => this.password = value
                    }).onSubmit({
                        key => this.enterContent()
                    })
                }
            }
            Row(32) {
                Button("验证方式").onClick {
                    evt => verify = !verify
                }.sub()
                Button("访问链接").onClick {
                    evt => this.enterContent()
                }.primary()
            }
        }.padding(32).backgroundColor(@r(app.color.white)).expand().centerAlign()
    }

    func enterContent() {
        AppStorage.setOrCreate("user", user)
        AppStorage.setOrCreate("password", password)
        if (this.url != "") {
            Router.push(url: "Content", params: this.url)
        } else {
            PromptAction.showToast(message: "地址不应为空")
        }
    }
}
