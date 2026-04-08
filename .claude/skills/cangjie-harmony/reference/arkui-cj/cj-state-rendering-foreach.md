# ForEach

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ForEach接口基于数组类型数据来进行循环渲染。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class ForEach\<T>

```cangjie
public class ForEach<T> {
    public init(arr: CollectionEx<T>, itemGenerator!: ItemGeneratorFunc<T>,
        keyGenerator!: ?KeyGeneratorFunc<T> = None) {}
}
```

**功能：** 创建一个循环渲染组件。ForEach接口基于数组类型数据来进行循环渲染，需要与容器组件配合使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(CollectionEx\<T>, ItemGeneratorFunc\<T>, ?KeyGeneratorFunc\<T>)

```cangjie
public init(arr: CollectionEx<T>, itemGenerator!: ItemGeneratorFunc<T>, keyGenerator!: ?KeyGeneratorFunc<T> = None)
```

**功能：** 定义ForEach组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|arr|[CollectionEx\<T>](./cj-common-types.md#interface-collectionext)|是|-|用于UI中的数组集合。|
|itemGenerator|[ItemGeneratorFunc\<T>](./cj-common-types.md#type-itemgeneratorfunct)|是|-|**命名参数。** 组件生成函数。|
|keyGenerator|?[KeyGeneratorFunc\<T>](./cj-common-types.md#type-keygeneratorfunct)|否|None|**命名参数。** 键生成函数。|
