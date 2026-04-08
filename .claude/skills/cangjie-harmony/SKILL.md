---
name: cangjie-harmony
description: "仓颉语言 HarmonyOS 应用开发文档。涉及 ArkUI 组件、Ability Kit、ArkData、系统 API、权限、互操作等平台开发问题时使用"
---

# 仓颉语言 HarmonyOS 应用开发文档目录

> 请按需查阅相关文档。本文档覆盖使用仓颉语言进行 HarmonyOS 应用开发的各个方面。

## 入门

- [应用开发导读](./cj-start-application-development-overview.md): HarmonyOS 仓颉应用开发的整体学习路径与文档结构导读
- [快速入门与基础知识](./cj-start/README_zh.md): 开发准备、构建第一个 OpenHarmony 应用、应用程序包概述与结构(Stage模型)、HAP/HAR 包开发与使用、应用安装卸载与更新、app.json5/module.json5 配置文件、资源分类与访问、应用程序包常见问题与术语

## 应用框架

- [Ability Kit（程序框架服务）](./application-models/README_zh.md): Ability Kit 简介与应用模型概述、Stage模型应用组件配置、UIAbility 组件（概述/生命周期/启动模式/基本用法/组件间交互）、Want 信息传递载体（概述/显式与隐式 Want 匹配规则/常见 action 与 entities）、应用间跳转（拉起文件处理类应用）、Stage模型应用配置文件
- [ArkUI（方舟UI框架）](./arkui-cj/README_zh.md): 声明式 UI 开发范式概述、基本语法与自定义组件（创建/生命周期/访问限定）、组件扩展（@Builder/@BuilderParam/@Reusable 宏）、状态管理 V1（@State/@Prop/@Link/@Provide/@Consume/@Observed/@Publish/@Watch 宏、LocalStorage/AppStorage/PersistentStorage/Environment、MVVM 模式与最佳实践）、渲染控制（if/else 条件渲染/ForEach 循环渲染/LazyForEach 数据懒加载）、组件导航与页面路由（Navigation/导航转场）、布局（Row/Column/Stack/Flex/RelativeContainer/GridRow/GridCol/List/Grid/Swiper/Tabs）、文本（Text/Span/TextInput/TextArea/RichEditor）、媒体展示（Image/Video）、表单选择（Button/Radio/Toggle）、进度条（Progress）、弹窗（Dialog/CustomDialog/Menu/Popup/Toast/半模态/全模态）、几何图形绘制（Shape）、交互事件（事件分发/触屏/键鼠/焦点）、动画（属性动画/转场动画/共享元素转场/旋转屏动画/组件动画/动画曲线/动画衔接/模糊/阴影/色彩效果/帧动画）、Canvas 自定义绘制、混合开发、镜像能力、深浅色适配
- [ArkData（方舟数据管理）](./database/README_zh.md): ArkData 简介与架构、UTD 标准化数据定义（预置列表）、应用数据持久化（Preferences 用户首选项/键值型数据库 KV-Store/关系型数据库 RDB）、跨设备数据同步（分布式关系型数据库同步）、数据可靠性与安全性（备份恢复/数据库加密/基于设备分类和数据分级的访问控制）
- [ArkWeb（方舟Web）](./web/README_zh.md): ArkWeb 组件概述、User-Agent 配置、深色模式设置、Web 组件嵌套滚动与内容滚动、坚盾守护模式（安全与隐私）、页面加载与浏览记录管理、PDF 文档预览、安全区域计算与避让适配、DevTools 调试、crashpad 崩溃信息收集
- [仓颉-ArkTS 互操作](./learn-cj/FFI/README_zh.md): 仓颉语言简介、构建仓颉与 ArkTS 混合应用、在已有 ArkTS 工程中增量使用仓颉、互操作概述与场景（ArkTS 应用中使用仓颉/仓颉应用中使用 ArkTS）、互操作用法（声明式互操作宏/互操作库/ArkTS 侧导入导出）、使用案例（数据访问/仓颉多线程中使用互操作库/调用 ArkTS 三方模块/互操作对象生命周期管理）、互操作辅助库与开发规范
- [Core File Kit（文件基础服务）](./file-management/README_zh.md): 文件基础服务简介、应用文件（概述/沙箱目录/文件访问与管理/向沙箱推送文件/文件分享）、用户文件概述
- [Localization Kit（本地化开发服务）](./internationalization/README_zh.md): 国际化和本地化概述、国际化界面设计、日历和历法设置、时区与夏令时（夏令时跳变）、本地化时区名称、翻译场景与单复数支持、语言测试

## 窗口与屏幕

- [窗口管理](./windowmanager/README_zh.md): 管理应用窗口（Stage模型）
- [屏幕管理](./displaymanager/README_zh.md): 使用 Display 实现屏幕属性查询及状态监听

## 系统 — 安全

- [程序访问控制](./security/AccessToken/README_zh.md): 访问控制概述、应用权限管控（选择申请方式/声明权限/向用户申请授权/单次授权/受限权限申请）、应用权限列表（开放权限-系统授权/开放权限-用户授权/受限开放权限/系统应用可用权限/企业类应用权限/MDM应用权限）、应用权限组列表
- [Crypto Architecture Kit（加解密算法框架服务）](./security/CryptoArchitectureKit/README_zh.md): 加解密框架简介、对称密钥生成与转换（随机生成/二进制数据转换）、加解密算法（对称密钥 AES GCM/CCM/CBC/ECB 模式、AES GCM 分段加解密、3DES ECB 模式、SM4 ECB/CBC/GCM 模式及分段加解密、非对称密钥加解密规格）、消息摘要计算（SHA256/MD5）、消息认证码（HMAC）、安全随机数生成
- [Universal Keystore Kit（密钥管理服务）](./security/UniversalKeystoreKit/README_zh.md): 密钥管理简介与基础概念、密钥生成（算法规格/生成密钥）、密钥导入（明文导入/加密导入）、密钥使用（加解密/签名验签/密钥协商/密钥派生/HMAC，各含算法规格与开发指导）、密钥删除、密钥证明（匿名/非匿名）、查询密钥是否存在/获取密钥属性/密钥导出

## 系统 — 网络

- [Connectivity Kit（短距通信服务）](./connectivity/README_zh.md): 短距通信简介与术语、蓝牙服务开发（设备查找/BLE 开发指导/GATT 连接与数据传输）
- [Network Kit（网络服务）](./network/README_zh.md): 网络服务简介、HTTP 数据请求、网络连接管理
- [Telephony Kit（蜂窝通信服务）](./telephony/README_zh.md): 拨打电话功能

## 系统 — 基础功能与硬件

- [Basic Services Kit（基础服务）](./basic-services/README_zh.md): 基础服务简介、公共事件进程间通信（动态订阅/取消订阅/发布公共事件）、应用文件上传下载
- [Sensor Service Kit（传感器服务）](./device/sensor/README_zh.md): 传感器开发简介、传感器开发概述与使用指导

## 调测调优

- [Performance Analysis Kit（性能分析服务）](./dfx/README_zh.md): 性能分析简介、故障检测（Cangjie Crash 进程崩溃分析/AppFreeze 应用无响应分析）、HiLog 日志打印、HiAppEvent 事件订阅（应用事件/崩溃事件/冻屏事件订阅与事件上报）、HiTraceMeter 性能跟踪、错误管理
- [Test Kit（应用测试服务）](./application-test/README_zh.md): 应用测试简介、ArkXTest 自动化测试框架使用指导
- [调试命令与工具](./tools/README_zh.md): aa/bm/cem/anm/atm/param/restool/power-shell 工具、打包工具与拆包工具、扫描工具、hdc/hilog/hidumper/hitrace/hiperf 命令行工具、toybox/mediatool/devicedebug 工具

## 媒体

- [Camera Kit（相机服务）](./media/camera/README_zh.md): 相机简介与开发准备、相机管理（设备管理/设备输入/会话管理）、手电筒使用
- [Image Kit（图片处理服务）](./media/image/README_zh.md): 图片处理简介、图片解码（ImageSource）、图像变换与位图操作（PixelMap）、EXIF 信息编辑、图片编码（ImagePacker）
- [Media Kit（媒体服务）](./media/media/README_zh.md): AVImageGenerator 视频指定时间图像提取、AVCodec 支持格式列表
- [Media Library Kit（媒体文件管理服务）](./media/medialibrary/README_zh.md): 系统相册资源使用指导（受限开放能力）

## 图形

- [ArkGraphics 2D（方舟2D图形服务）](./graphics/README_zh.md): 2D 图形服务简介、可变帧率能力简介、请求动画绘制帧率

## 应用服务

- [Location Kit（位置服务）](./location/README_zh.md): 位置服务简介、申请位置权限开发指导、获取设备位置信息开发指导

---

## API 参考

- [API 参考总览](./reference/README_zh.md): API 开发说明、SystemCapability 使用指南与列表（Phone/Tablet）、API 标签化管控、通用错误码、仓颉标准库 API

### 应用框架 API

- [Ability Kit API](./reference/AbilityKit/): ohos.app.ability 系列 API（UIAbility/Want/AbilityStage/AbilityConstant/ContextConstant/DialogRequest/StartOptions/WantConstant/ErrorManager 等）、ohos.ability_access_ctrl 访问控制、ohos.bundle.bundle_manager 包管理、错误码（元能力/包管理/访问控制/锁屏敏感数据管理）
- [ArkData API](./reference/ArkData/): ohos.data.data_share_predicates 数据共享谓词、ohos.data.distributed_kv_store 分布式键值数据库、ohos.data.preferences 用户首选项、ohos.data.relational_store 关系型数据库、ohos.data.values_bucket 数据集、错误码（RDB/KV-Store/Preferences）
- [ArkUI API](./reference/arkui-cj/): UI 界面 API（ComponentUtils/Shape/Curves/UIContext 系列）、通用事件（点击/触摸/按键/焦点/鼠标/悬浮/区域变化/可见区域变化/快捷键）、通用属性（尺寸/位置/布局/边框/背景/透明度/显隐/Z序/图形变换/图像效果/裁剪/渐变/Popup/菜单/焦点/拖拽/模态转场/安全区域等）、组件 API（行列堆叠/栅格分栏/滚动滑动/导航切换/按钮选择/文本输入/图片视频/信息展示/空白分隔/Canvas 画布/图形绘制/菜单/动画/弹窗/Web/自定义组件/状态管理渲染控制）、窗口管理 ohos.window/屏幕管理 ohos.display、公共定义（基础类型/像素单位）、线程控制、框架接口、错误码（动画/屏幕/窗口）
- [ArkWeb API](./reference/ArkWeb/): ohos.web.webview Webview API、Webview 错误码
- [仓颉-ArkTS 互操作 API](./reference/arkinterop/): ohos.ark_interop ArkTS 互操作库、ohos.ark_interop_helper 公共辅助功能、ohos.ark_interop_macro 互操作宏、ohos.business_exception 通用异常、ohos.callback_invoke 通用回调、错误码
- [Core File Kit API](./reference/CoreFileKit/): ohos.file.fileuri 文件 URI、ohos.file.fs 文件管理、文件管理错误码
- [IPC Kit API](./reference/IPCKit/): ohos.rpc RPC 进程间通信、RPC 错误码
- [Localization Kit API](./reference/LocalizationKit/): ohos.i18n 国际化、ohos.resource_manager 资源管理、ohos.raw_file_descriptor/ohos.resource、错误码（I18n/资源管理）

### 系统 API

- [Crypto Architecture Kit API](./reference/CryptoArchitectureKit/): ohos.security.crypto_framework 加解密算法库框架、错误码
- [Universal Keystore Kit API](./reference/UniversalKeystoreKit/): ohos.security.huks 通用密钥库系统、HUKS 错误码
- [Connectivity Kit API](./reference/ConnectivityKit/): ohos.bluetooth 蓝牙系列 API（a2dp/ble/base_profile/constant/hfp）、ohos.wifi_manager WLAN、错误码（蓝牙/WIFI/NFC/SecureElement）
- [Network Kit API](./reference/NetworkKit/): ohos.net.connection 网络连接管理、ohos.net.http HTTP 数据请求、错误码（HTTP/网络连接管理）
- [Basic Services Kit API](./reference/BasicServicesKit/): ohos.battery_info 电量信息、ohos.device_info 设备信息、ohos.request 上传下载、ohos.common_event_manager 公共事件、ohos.system_date_time 系统时间时区、ohos.settings 设置数据项、错误码（上传下载/时间时区/事件/电源管理/账号管理/设置数据项）
- [Sensor Service Kit API](./reference/SensorServiceKit/): ohos.sensor 传感器、传感器错误码
- [Telephony Kit API](./reference/TelephonyKit/): ohos.telephony.call 拨打电话、电话子系统错误码
- [Performance Analysis Kit API](./reference/PerformanceAnalysisKit/): ohos.hiviewdfx.hi_app_event 应用事件打点、ohos.hilog 日志打印、ohos.hi_trace_meter 性能打点、错误码（HiAppEvent/Hidebug CpuUsage）
- [Test Kit API](./reference/TestKit/): ohos.app.ability.ability_delegator_registry AbilityDelegatorRegistry、ohos.ui_test UI 测试、uitest 错误码

### 媒体与图形 API

- [Camera Kit API](./reference/CameraKit/): ohos.multimedia.camera 相机管理、Camera 错误码
- [Image Kit API](./reference/ImageKit/): ohos.multimedia.image 图片处理、Image 错误码
- [Media Kit API](./reference/MediaKit/): ohos.multimedia.media 媒体服务、Media 错误码
- [Media Library Kit API](./reference/MediaLibraryKit/): ohos.file.photo_access_helper 相册管理模块
- [ArkGraphics 2D API](./reference/ArkGraphics2D/): ohos.graphics.color_space_manager 色彩管理、色彩管理错误码

### 应用服务 API

- [Location Kit API](./reference/LocationKit/): ohos.geo_location_manager 位置服务、位置服务错误码
