# 通用错误码

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 201 权限校验失败

**错误信息**

Permission verification failed. The application does not have the permission required to call the API.

**错误描述**

权限校验失败，应用无权限使用该API，需要申请权限。

**可能原因**

该错误码表示权限校验失败，通常是因为没有权限却调用了需要权限的API。

**处理步骤**

请检查是否有调用API的权限。

## 202 系统API权限校验失败

**错误信息**

Permission verification failed. A non-system application calls a system API.

**错误描述**

权限校验失败，非系统应用使用了系统API。

**可能原因**

请确认非系统应用是否使用了系统API，并进行校验。

**处理步骤**

请检查是否调用了系统API，如果调用了请移除。

## 401 参数检查失败

**错误信息**

Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.

**错误描述**

1. 必填参数为空。

2. 参数类型不正确。

3. 参数校验失败。

**可能原因**

1. 必填参数没有传入。

2. 参数类型错误 (Type Error)。

3. 参数数量错误 (Argument Count Error)。

4. 空参数错误 (Null Argument Error)。

5. 参数格式错误 (Format Error)。

6. 参数值范围错误 (Value Range Error)。

**处理步骤**

请检查必填参数是否传入，或者传入的参数类型是否正确。对于参数校验失败的情况，阅读参数规格约束，按照可能原因进行排查。

## 801 该设备不支持此API

**错误信息**

Capability not supported. Failed to call the API due to limited device capabilities.

**错误描述**

当设备支持SysCap但不支持特定API时，会出现此错误，表明设备只能处理该SysCap的部分API。

**可能原因**

该设备不支持此API。

**处理步骤**

请检查设备是否支持使用的API。
