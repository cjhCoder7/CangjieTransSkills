package ohos_app_cangjie_entry.controllers

import ohos_app_cangjie_entry.models
/// 触觉反馈控制器 — HarmonyOS 使用 vibrator 实现
public class HapticController {
    public static func impact(): Unit {
        // HarmonyOS 暂用轻量振动反馈
        // 后续可接入 kit.MiscServices 的振动 API
    }
}
