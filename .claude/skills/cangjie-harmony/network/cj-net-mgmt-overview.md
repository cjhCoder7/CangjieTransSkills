# Network Kit简介

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Network Kit（网络服务）主要提供以下功能：

- [HTTP数据请求](./cj-http-request.md)：通过HTTP发起一个数据请求。
- [网络连接管理](./cj-net-connection-manager.md)：网络连接管理提供管理网络一些基础能力，包括WiFi、蜂窝、Ethernet等多网络连接优先级管理、网络质量评估、订阅默认或指定网络连接状态变化、查询网络连接信息、DNS解析等功能。

## 约束与限制

使用网络管理模块的相关功能时，需要请求相应的权限。

在申请权限前，请确保符合[权限使用的基本原则](../security/AccessToken/cj-app-permission-mgmt-overview.md#权限使用的基本原则)。然后参考[访问控制-声明权限](../security/AccessToken/cj-declare-permissions.md)声明对应权限。

| 权限名                           | 说明                                   |
| -------------------------------- | -------------------------------------- |
| ohos.permission.GET_NETWORK_INFO | 获取网络连接信息。                     |
| ohos.permission.INTERNET         | 允许程序打开网络套接字，进行网络连接。 |
