package modalwindow

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*

import modalwindow.model.*

/**
 * 模态转场是新的界面覆盖在旧的界面上，旧的界面不消失的一种转场方式。
 * 通过bindContentCover属性为Button组件绑定全屏模态页面，点击Button后显示模态页面，模态页面内容自定义，
 * 包含默认一键登录页面和其他登录方式页面。
 */
@Entry
@Component
public class ModalWindowView {
    // 是否显示全屏模态页面
    @State var isPresent: Bool = false

    @Builder
    func loginBuilder() {
        Column() {
            DefaultLogin(isPresentInLoginView: this.isPresent)  // 通过@State和@Link使isPresentInLoginView和isPresent产生关联
        }
    }

    func build() {
        Column() {
            // TODO：需求：增加其他登录方式，如半模态窗口
            Button("点击跳转到全屏登录页")
                .fontColor(Color.WHITE)
                .borderRadius(8)
                 /**
                 * ButtonType为Normal时，按钮圆角通过通用属性borderRadius设置。不同ButtonType下borderRadius属性是否生效，详见：
                 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-button-0000001815086854-V5#ZH-CN_TOPIC_0000001815086854__buttontype枚举说明
                 */
                .shape(ShapeType.Normal)    //FIXME: 差异点：ArkTS 对应属性名为 .type，参数类型为 ButtonType
                .backgroundColor(0x222222)
                .width(100.percent)
                 /**
                 * TODO: 知识点: 通过bindContentCover属性为组件绑定全屏模态页面
                 * isPresent：是否显示全屏模态页面
                 * loginBuilder：配置全屏模态页面内容
                 */
                .bindContentCover(
                    this.isPresent,
                    this.loginBuilder,
                    ContentCoverOptions(modalTransition: ModalTransition.DEFAULT, onDisappear: {=> this.isPresent = false})
                )
                .onClick({ event =>
                  this.isPresent = true; // 当isPresent为true时显示模态页面，反之不显示
                })
        }
        .size(width: 100.percent, height: 100.percent)
        .padding(12)
        .justifyContent(FlexAlign.Center)
    }
}