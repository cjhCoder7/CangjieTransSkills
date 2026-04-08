# 向用户申请单次授权

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

基于授权最小化的原则，防止应用获取和滥用用户数据，针对部分应用敏感权限，在弹窗向用户申请授权时，新增“允许本次使用”的授权选项。

开发者在开发应用时，无需额外配置，仍然调用requestPermissionsFromUser()[向用户申请授权](./cj-request-user-authorization.md)，系统会根据该能力[支持的权限](#支持范围)，弹出对应的弹窗。

授权弹窗如下图所示：

<!--RP1-->
![allow-this-time](figures/allow-this-time.png)

设置中的选项如下图所示：

![setting-allow-this](figures/setting-allow-this.png)

路径：设置 > 隐私 > 权限管理 > 应用 > 目标应用 > 位置信息
<!--RP1End-->

## 支持范围

当前仅支持下列权限，当应用向用户申请下列权限时，弹窗将会出现“允许本次使用”的授权选项，设置中修改权限将会出现“每次询问”授权选项。

- 剪切板：["ohos.permission.READ_PASTEBOARD"](./cj-restricted-permissions.md#ohospermissionread_pasteboard)
- 模糊位置：["ohos.permission.APPROXIMATELY_LOCATION"](./cj-permissions-for-all-user.md#ohospermissionapproximately_location)
- 位置：["ohos.permission.LOCATION"](./cj-permissions-for-all-user.md#ohospermissionlocation)
- 后台位置：["ohos.permission.LOCATION_IN_BACKGROUND"](./cj-permissions-for-all-user.md#ohospermissionlocation_in_background)

## 使用限制

- 当用户点击了“允许本次使用”按钮，将会对应用授予临时的权限。并启动计时器，十秒之后，取消临时权限，想要再次获取，需要重新授予。

- 当用户在权限设置中选择了“每次询问”按钮，将会对应用授予模糊位置与位置临时权限，取消临时授权同上。
