# ohos.business_exception（通用异常信息）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

本模块定义了接口调用过程中出现的常见异常信息。

## 导入模块

```cangjie
import ohos.business_exception.*
```

> **说明：**
>
> 当前暂不支持Kit化的导入方式，预计在下个版本支持。

## class BusinessException

```cangjie
public class BusinessException <: Exception {
    public let code: Int32
}
```

**功能：** 业务异常类，继承自Exception类。

**起始版本：** 22

**父类型：**

- Exception

### let code

```cangjie
public let code: Int32
```

**功能：** 错误码。

**类型：** Int32

**读写能力：** 只读

**起始版本：** 22

### func getData\<T>()

```cangjie
public func getData<T>(): ?T
```

**功能：** 获取异常中携带的自定义数据信息。

**起始版本：** 22

**返回值：**

| 类型 | 说明    |
|:----|:------|
| ?T | 额外补充的异常信息。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取错误信息字符串。

**起始版本：** 22

**返回值：**

| 类型 | 说明    |
|:----|:------|
| String | 错误信息。|

## type AsyncCallback\<T>

```cangjie
public type AsyncCallback<T> = (Option<BusinessException>, Option<T>) -> Unit
```

**功能：** 定义了异步回调类型。
