# 申请位置权限开发指导

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景概述

应用在使用[Location Kit](../reference/LocationKit/cj-apis-geo_location_manager.md)系统能力前，需要检查是否已经获取用户授权访问设备位置信息。如未获得授权，可以向用户申请需要的位置权限。

系统提供的定位权限有：

- ohos.permission.LOCATION：用于获取精准位置，精准度在米级别。

- ohos.permission.APPROXIMATELY_LOCATION：用于获取模糊位置，精确度为5公里。

Location Kit接口对权限的要求请参见：[Location Kit](../reference/LocationKit/cj-apis-geo_location_manager.md)。

## 开发步骤

1. 开发者可以在应用配置文件中声明所需要的权限并向用户申请授权，具体可参考[向用户申请授权](../security/AccessToken/cj-request-user-authorization.md)。

2. 当APP运行在前台，且访问设备位置信息时，申请位置权限的方式如下：

   | 申请位置权限的方式 | 是否允许申请 | 申请成功后获取的位置的精确度 |
   | -------- | -------- | -------- |
   | 申请ohos.permission.APPROXIMATELY_LOCATION | 是 | 获取到模糊位置，精确度为5公里。 |
   | 同时申请ohos.permission.APPROXIMATELY_LOCATION和ohos.permission.LOCATION | 是 | 获取到精准位置，精准度在米级别。 |
