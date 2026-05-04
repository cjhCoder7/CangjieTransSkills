package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

// ============================================================================
// Web Demo Page - 企业级合规分发工作流演示
// ============================================================================
// 注：由于仓颉Web组件API可能尚未完全绑定，此页面使用原生UI组件展示
// 完整的HTML演示请在浏览器中打开 docs/mockup/interactive_demo.html

@Component
public class WebDemoPage {
    @State var currentStep: Int64 = 0
    @State var showInfo: Bool = false
    
    func build() {
        Column {
            // 标题区
            Column {
                Text("交互演示")
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0x1A1A2E)
                    .margin(bottom: 8)
                
                Text("企业级合规分发工作流")
                    .fontSize(14)
                    .fontColor(0x666666)
            }
            .width(100.percent)
            .padding(20)
            .backgroundColor(0xFFFFFF)
            
            // 功能卡片列表
            Scroll {
                Column {
                    // 核心流程展示
                    this.buildFeatureCard("[1]", "发布状态机", "Draft -> Published -> Revoked\n管理员可发布脱敏版纪要")
                    this.buildFeatureCard("[2]", "签收确认", "保密承诺书 + 一次性访问码\n成员必须签收才能查看")
                    this.buildFeatureCard("[3]", "一次性访问码", "OTP验证(10分钟有效)\n防止转发给未授权人员")
                    this.buildFeatureCard("[4]", "撤回控制", "管理员可随时撤回访问权限\n撤回后成员无法再查看")
                    this.buildFeatureCard("[5]", "动态水印", "显示用户ID + 时间戳\n截屏可追责")
                    this.buildFeatureCard("[6]", "全链路审计", "发布/签收/访问/撤回\n每一步都留痕")
                    
                    // 说明区
                    Column {
                        Text("完整演示文件")
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0x1A1A2E)
                            .margin(bottom: 12)
                        
                        Text("docs/mockup/interactive_demo.html")
                            .fontSize(13)
                            .fontColor(0x00D4AA)
                            .padding(12)
                            .backgroundColor(0xF0FDF9)
                            .borderRadius(8)
                            .width(100.percent)
                        
                        Text("请在浏览器中打开此文件进行完整的\n交互演示和视频录制")
                            .fontSize(12)
                            .fontColor(0x888888)
                            .margin(top: 12)
                            .textAlign(TextAlign.Center)
                    }
                    .width(100.percent)
                    .padding(20)
                    .margin(top: 16)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(16)
                }
                .width(100.percent)
                .padding(left: 16, right: 16, top: 8, bottom: 20)
            }
            .layoutWeight(1)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xF5F7FA)
    }
    
    @Builder
    func buildFeatureCard(icon: String, title: String, desc: String) {
        Row {
            // 图标
            Column {
                Text(icon)
                    .fontSize(28)
            }
            .width(56)
            .height(56)
            .backgroundColor(0xF0FDF9)
            .borderRadius(14)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            
            // 内容
            Column {
                Text(title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0x1A1A2E)
                    .margin(bottom: 4)
                
                Text(desc)
                    .fontSize(12)
                    .fontColor(0x888888)
                    .lineHeight(18)
            }
            .layoutWeight(1)
            .margin(left: 14)
            .alignItems(HorizontalAlign.Start)
        }
        .width(100.percent)
        .padding(16)
        .backgroundColor(0xFFFFFF)
        .borderRadius(14)
        .margin(bottom: 10)
    }
}
