# SysCap（系统能力）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

系统能力（SystemCapability，简称SysCap），指操作系统中每一个相对独立的特性。不同的设备对应不同的系统能力集，每个系统能力对应一个或多个API。开发者可根据系统能力来判断是否可以使用某接口。

## func canIUse(String)

```cangjie
public func canIUse(syscap: String): Bool
```

**功能：** 查询系统是否具备某个系统能力。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|syscap|String|是|-|待查询的系统能力名称。|

**返回值：**

|类型|说明|
|:---|:---|
|Bool|系统能力查询结果，true表示系统具备该能力，false表示系统不具备。|
