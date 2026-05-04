package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*

// ============================================================================
// LoginPage - 登录页面组件
// 支持用户选择和 PIN 码验证
// ============================================================================

@Component
class LoginPage {
    // 回调函数：登录成功后通知父组件
    private var onLoginSuccess: (ExtendedUser) -> Unit = { _ => () }
    
    @State var selectedUserIndex: Int64 = -1
    @State var pinInput: String = ""
    @State var errorMessage: String = ""
    @State var showPinInput: Bool = false
    @State var isLoading: Bool = false
    @State var userList: ArrayList<ExtendedUser> = ArrayList<ExtendedUser>()
    
    // 设置登录成功回调
    public func setOnLoginSuccess(callback: (ExtendedUser) -> Unit): LoginPage {
        this.onLoginSuccess = callback
        return this
    }
    
    func build() {
        Column {
            // Logo 和标题区域
            Column {
                Text("🔒")
                    .fontSize(64)
                    .margin(bottom: 16)
                
                Text("SecureMeet Guardian")
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0x1976D2)
                
                Text("安全会议助手")
                    .fontSize(16)
                    .fontColor(0x666666)
                    .margin(top: 8)
            }
            .margin(top: 60, bottom: 40)
            .alignItems(HorizontalAlign.Center)
            
            // 用户选择卡片区域
            if (!this.showPinInput) {
                Column {
                    Text("选择用户身份")
                        .fontSize(18)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                        .margin(bottom: 16)
                    
                    // 用户卡片列表
                    this.buildUserCards()
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(0xFFFFFF)
                .borderRadius(16)
            } else {
                // PIN 输入区域
                this.buildPinInputArea()
            }
            
            // 错误提示
            if (this.errorMessage.size > 0) {
                Text(this.errorMessage)
                    .fontSize(14)
                    .fontColor(0xF44336)
                    .margin(top: 16)
                    .padding(12)
                    .backgroundColor(0xFFEBEE)
                    .borderRadius(8)
            }
            
            // 底部版权信息
            Blank()
            
            Text("基于仓颉语言的鸿蒙应用")
                .fontSize(12)
                .fontColor(0x999999)
                .margin(bottom: 20)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xF5F5F5)
        .alignItems(HorizontalAlign.Center)
        .onAppear {
            initializeUsers()
            this.userList = getAllExtendedUsers()
        }
    }
    
    // 构建用户选择卡片 - 内联展开避免参数传递问题
    @Builder
    func buildUserCards() {
        Column {
            // 管理员
            Row {
                Column {
                    Text("A")
                        .fontSize(32)
                }
                .width(60)
                .height(60)
                .backgroundColor(0xFFEBEE)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                
                Column {
                    Text("管理员")
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                    Text("系统管理员")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(top: 4)
                    Text("完全权限")
                        .fontSize(12)
                        .fontColor(0xF44336)
                        .margin(top: 4)
                }
                .layoutWeight(1)
                .margin(left: 16)
                .alignItems(HorizontalAlign.Start)
                
                Text("PIN")
                    .fontSize(12)
                    .fontColor(0x999999)
            }
            .width(100.percent)
            .padding(16)
            .margin(bottom: 12)
            .backgroundColor(if (this.selectedUserIndex == 0) { 0xE3F2FD } else { 0xFAFAFA })
            .borderRadius(12)
            .onClick { evt =>
                this.selectedUserIndex = 0
                this.errorMessage = ""
                this.showPinInput = true
                this.pinInput = ""
            }
            
            // 安全专员
            Row {
                Column {
                    Text("M")
                        .fontSize(32)
                }
                .width(60)
                .height(60)
                .backgroundColor(0xFFF3E0)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                
                Column {
                    Text("安全专员")
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                    Text("安全审计员")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(top: 4)
                    Text("管理权限")
                        .fontSize(12)
                        .fontColor(0xFF9800)
                        .margin(top: 4)
                }
                .layoutWeight(1)
                .margin(left: 16)
                .alignItems(HorizontalAlign.Start)
                
                Text("PIN")
                    .fontSize(12)
                    .fontColor(0x999999)
            }
            .width(100.percent)
            .padding(16)
            .margin(bottom: 12)
            .backgroundColor(if (this.selectedUserIndex == 1) { 0xE3F2FD } else { 0xFAFAFA })
            .borderRadius(12)
            .onClick { evt =>
                this.selectedUserIndex = 1
                this.errorMessage = ""
                this.showPinInput = true
                this.pinInput = ""
            }
            
            // 普通成员
            Row {
                Column {
                    Text("U")
                        .fontSize(32)
                }
                .width(60)
                .height(60)
                .backgroundColor(0xE8F5E9)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                
                Column {
                    Text("普通成员")
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                    Text("张三")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(top: 4)
                    Text("基本权限")
                        .fontSize(12)
                        .fontColor(0x4CAF50)
                        .margin(top: 4)
                }
                .layoutWeight(1)
                .margin(left: 16)
                .alignItems(HorizontalAlign.Start)
                
                Text("PIN")
                    .fontSize(12)
                    .fontColor(0x999999)
            }
            .width(100.percent)
            .padding(16)
            .margin(bottom: 12)
            .backgroundColor(if (this.selectedUserIndex == 2) { 0xE3F2FD } else { 0xFAFAFA })
            .borderRadius(12)
            .onClick { evt =>
                this.selectedUserIndex = 2
                this.errorMessage = ""
                this.showPinInput = true
                this.pinInput = ""
            }
            
            // 访客
            Row {
                Column {
                    Text("G")
                        .fontSize(32)
                }
                .width(60)
                .height(60)
                .backgroundColor(0xECEFF1)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                
                Column {
                    Text("访客")
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                    Text("访客用户")
                        .fontSize(14)
                        .fontColor(0x666666)
                        .margin(top: 4)
                    Text("只读权限")
                        .fontSize(12)
                        .fontColor(0x9E9E9E)
                        .margin(top: 4)
                }
                .layoutWeight(1)
                .margin(left: 16)
                .alignItems(HorizontalAlign.Start)
                
                Text("GO")
                    .fontSize(12)
                    .fontColor(0x4CAF50)
            }
            .width(100.percent)
            .padding(16)
            .margin(bottom: 12)
            .backgroundColor(if (this.selectedUserIndex == 3) { 0xE3F2FD } else { 0xFAFAFA })
            .borderRadius(12)
            .onClick { evt =>
                this.selectedUserIndex = 3
                this.errorMessage = ""
                // 访客直接登录
                this.performLogin("")
            }
        }
        .width(100.percent)
    }
    
    // 构建 PIN 输入区域 - 使用简化的 TextInput
    @Builder
    func buildPinInputArea() {
        Column {
            // 返回按钮
            Row {
                Text("← 返回")
                    .fontSize(16)
                    .fontColor(0x1976D2)
                    .onClick { evt =>
                        this.showPinInput = false
                        this.pinInput = ""
                        this.errorMessage = ""
                        this.selectedUserIndex = -1
                    }
                Blank()
            }
            .width(100.percent)
            .margin(bottom: 20)
            
            // 用户信息
            Text(this.getSelectedUserName())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(0x333333)
                .margin(bottom: 8)
            
            Text(this.getSelectedUserRole())
                .fontSize(14)
                .fontColor(0x666666)
                .margin(bottom: 24)
            
            // PIN 输入提示
            Text("请输入 4 位 PIN 码")
                .fontSize(16)
                .fontColor(0x333333)
                .margin(bottom: 16)
            
            // 使用 TextInput 替代数字键盘
            TextInput(text: this.pinInput, placeholder: "输入PIN")
                .width(150)
                .height(50)
                .fontSize(24)
                .textAlign(TextAlign.Center)
                .backgroundColor(0xF5F5F5)
                .borderRadius(8)
                .onChange { value =>
                    this.pinInput = value
                    this.errorMessage = ""
                    if (value.size == 4) {
                        this.performLogin(value)
                    }
                }
            
            // 登录按钮
            Button("登录")
                .width(150)
                .height(44)
                .margin(top: 20)
                .backgroundColor(0x1976D2)
                .fontColor(0xFFFFFF)
                .onClick { evt =>
                    if (this.pinInput.size == 4) {
                        this.performLogin(this.pinInput)
                    } else {
                        this.errorMessage = "请输入 4 位 PIN 码"
                    }
                }
            
            // 默认 PIN 提示
            Text("提示：默认 PIN 为 1234 / 2345 / 3456")
                .fontSize(12)
                .fontColor(0x999999)
                .margin(top: 20)
        }
        .width(90.percent)
        .padding(24)
        .backgroundColor(0xFFFFFF)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)
    }
    
    // 执行登录
    func performLogin(pin: String): Unit {
        this.isLoading = true
        this.errorMessage = ""
        
        // 获取选中的用户
        let users = getAllExtendedUsers()
        if (this.selectedUserIndex >= 0 && this.selectedUserIndex < users.size) {
            let selectedUser = users[this.selectedUserIndex]
            
            // 尝试登录
            let result = loginWithCredentials(selectedUser.baseUser.name, pin)
            
            match (result) {
                case Some(user) =>
                    // 登录成功
                    this.isLoading = false
                    this.onLoginSuccess(user)
                case None =>
                    // 登录失败
                    this.isLoading = false
                    this.errorMessage = "PIN 码错误，请重试"
                    this.pinInput = ""
            }
        } else {
            this.isLoading = false
            this.errorMessage = "请选择用户"
        }
    }
    
    // 辅助函数
    func getRoleEmoji(role: UserRole): String {
        match (role) {
            case Admin => "A"
            case Manager => "M"
            case Member => "U"
            case Guest => "G"
        }
    }
    
    func getRoleBackgroundColor(role: UserRole): UInt32 {
        match (role) {
            case Admin => 0xFFEBEE
            case Manager => 0xFFF3E0
            case Member => 0xE8F5E9
            case Guest => 0xECEFF1
        }
    }
    
    func getSelectedUserName(): String {
        let users = getAllExtendedUsers()
        if (this.selectedUserIndex >= 0 && this.selectedUserIndex < users.size) {
            return users[this.selectedUserIndex].displayName
        }
        return ""
    }
    
    func getSelectedUserRole(): String {
        let users = getAllExtendedUsers()
        if (this.selectedUserIndex >= 0 && this.selectedUserIndex < users.size) {
            return getRoleName(users[this.selectedUserIndex].baseUser.role)
        }
        return ""
    }
}

