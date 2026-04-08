# 开发准备

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

相机应用开发的主要流程包含开发准备、设备输入、会话管理、预览、拍照和录像等。

## 申请权限

在开发相机应用时，需要先申请相机相关权限，确保应用拥有访问相机硬件及其他功能的权限，需要的权限如下表。在申请权限前，请保证符合[权限使用的基本原则](../../security/AccessToken/cj-app-permission-mgmt-overview.md#权限使用的基本原则)。

- 使用相机拍摄前，需要申请**ohos.permission.CAMERA**相机权限。
- 当需要使用麦克风同时录制音频时，需要申请**ohos.permission.MICROPHONE**麦克风权限。
- 当需要拍摄的图片/视频显示地理位置信息时，需要申请**ohos.permission.MEDIA_LOCATION**，来访问用户媒体文件中的地理位置信息。

以上权限均需要通过弹窗向用户申请授权，具体申请方式及校验方式，请参见[向用户申请授权](../../security/AccessToken/cj-request-user-authorization.md)。

> **说明：**
>
> 仅应用需要克隆、备份或同步用户公共目录的图片、视频类文件时，可申请ohos.permission.READ_IMAGEVIDEO、ohos.permission.WRITE_IMAGEVIDEO权限来读写音频文件，申请方式请参见<!--RP1-->[申请受控权限](../../security/AccessToken/cj-declare-permissions-in-acl.md#申请使用受限权限)。<!--RP1End-->

## 开发指导

| 开发流程 | Cangjie开发指导 |
| ------- | ------------- |
| 设备输入 | [设备输入](./cj-camera-device-input.md) |
| 会话管理 | [会话管理](./cj-camera-session-management.md) |
| 元数据 | 元数据 |
