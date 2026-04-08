# 仓颉-ArkTS 声明式互操作宏

仓颉- ArkTS 声明式互操作宏通过解析被注解修饰的仓颉代码，自动生成 ArkTS 声明文件及互操作层代码，为开发者提供近原生调用的开发体验。

## 使用方法

DevEco Studio 的配置可参考[在 ArkTS 工程中添加仓颉模块](./add_cangjie_module.md)。配置完成后，可实现互操作模块。

目前针对希望被 ArkTS 调用的函数（含异步函数）、接口、类和枚举，可以使用互操作声明宏 `@Interop` 进行修饰。以下以普通函数场景作为演示示例，介绍声明式互操作宏的具体使用方法，异步函数、接口、类、枚举等示例请参考[场景详细说明](#场景详细说明)。

### 实现仓颉互操作模块

在 ArkTS 工程中成功插入仓颉互操作模块后，在生成的 index.cj 文件中，可以实现自定义方法。如下示例：

1. 用户实现一个名为 addF64 的仓颉函数，并使用 `@Interop[ArkTS]` 修饰，标注该函数为互操作使用的函数。假设下述文件名为 demo.cj，其内容如下所示：

   <!--compile-->
   ```cangjie
   // 定义包名，该包名需要和 cjpm.toml 的 package name 保持一致
   package ohos_app_cangjie_entry
   // 导入互操作库 ark_interop 和互操作宏
   import ohos.ark_interop.*
   import ohos.ark_interop_macro.*
   // 实现自定义的函数 addF64，入参接收两个number，返回相加后的结果
   @Interop[ArkTS]
   public func addF64(a: Float64, b!: Float64): Float64 {
       a + b
   }
   ```

2. 在 DevEco Studio 中选择上述所说的仓颉文件 demo.cj，在文件编辑界面中右键选择 **Generate... > Cangjie-ArkTS Interop API**，会在 **cangjie->types->libohos_app_cangjie_entry** 目录下生成 Index.d.ts 声明文件和 oh_package.json5 配置文件，以及会在 **cangjie -> ark_interop_api** 目录下生成 ark_interop_api.d.ts 声明文件和 oh_package.json5 配置文件。

    > **说明：**
    >
    > ark_interop_api 目录下生成的 .d.ts 为兼容需要运行在 OpenHarmony 12 Release以上应用生成，如果没有兼容性需求，则可以忽略此文件夹。

   types->libohos_app_cangjie_entry 目录下的 Index.d.ts 内容如下所示：

   ```typescript
   export declare function addF64(a: number, b: number): number
   ```

   types->libohos_app_cangjie_entry 目录下的 oh_package.json5 如下所示：

   ```json
   {
     "name": "libohos_app_cangjie_entry.so",
     "types": "./Index.d.ts",
     "version": "1.0.0",
     "description": ""
   }
   ```

   ark_interop 目录下的 ark_interop_api.d.ts 内容如下所示：

   ```typescript
   export declare interface CustomLib {
       addF64(a: number, b: number): number
   }
   ```

   ark_interop 目录下的 oh_package.json5 如下所示：

   ```json
   {
     "name": "libark_interop_api.so",
     "types": "./ark_interop_api.d.ts",
     "version": "1.0.0",
     "description": ""
   }
   ```

   并在 entry 的 oh-package.json5 文件中自动添加依赖：

   ```json
   "dependencies": {
     // ...
     "libohos_app_cangjie_entry.so": "file:./src/main/cangjie/types/libohos_app_cangjie_entry",
     "libark_interop_api.so": "file:./src/main/cangjie/ark_interop_api",
     // ...
   }
   ```

> **注意：**
>
> 在同一个仓颉模块中（同一个包及其子包中）需遵循如下规则，否则可能出现编译报错或符号覆盖：
>
> - 使用 `@Interop` 修饰的函数、interface、class 不能同名。
>
>   错误示例：
>
>   ```cangjie
>   @Interop[ArkTS]
>   public func addNumber() : Unit {}
>
>   @Interop[ArkTS]
>   public func addNumber(a: Float64) : Unit {} // 同一个包中会出现编译报错；父子包中可能会出现符号覆盖
>   ```
>
> - 使用 `@Interop` 修饰的函数、interface、class 和使用 JSModule.registerModule、JSModule.registerClass、JSModule.registerFunc 注册到 JSModule 中的函数、interface、class 不能同名。
>
>   错误示例：
>
>   ```cangjie
>   @Interop[ArkTS]
>   public func addNumber() : Unit {}
>
>   func addFloat() {}
>   let EXPORT_MODULE = JSModule.registerModule {
>       runtime, exports => exports["addNumber"] = runtime.function(addFloat).toJSValue() // 会覆盖使用 @Interop 修饰的同名函数 addNumber
>   }
>   ```

### ArkTS 代码中使用仓颉模块

仓颉互操作模块实现后，在 ArkTS 代码中导入仓颉 ohos_app_cangjie_entry 模块，即可加载自定义的仓颉互操作模块，并调用相关的接口。

在 ArkTS 应用中使用仓颉互操作模块提供的 addF64 函数示例如下：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { addF64 } from "libohos_app_cangjie_entry.so"

// 调用仓颉接口
console.log("result " + addF64(1, 2))
```

## 场景详细说明

声明式互操作宏可修饰范围包括函数（含异步函数）、接口、类和枚举，针对不同的场景使用建议如下表：

| 适用场景                          | 使用类型  | 修饰                                                                                       |
| :-------------------------------- | :-------- | :----------------------------------------------------------------------------------------- |
| ArkTS 调用仓颉函数                | 函数      | @Interop[ArkTS]                                                                            |
| ArkTS 调用耗时仓颉函数            | 异步函数  | @Interop[ArkTS, Async]                                                                     |
| 用于传递 ArkTS 侧创建的对象给仓颉 | interface | @Interop[ArkTS]                                                                            |
| 用于返回仓颉侧创建的对象给 ArkTS  | class     | @Interop[ArkTS] 修饰整个 class<br>@Interop[ArkTS, Invisible] 修饰 class 中不准备暴露的成员 |
| 用于仓颉和 ArkTS 互相传递枚举数据 | enum      | @Interop[ArkTS]                                                                            |

### 函数

对于声明式互操作宏修饰的函数，必须满足以下条件，不满足时将会编译报错：

- 必须由 public 修饰
- 不支持类型参数
- 支持命名参数，但 ArkTS 调用方法和非命名参数一致
- 不支持默认值

函数互操作使用示例请参见[使用方法](#使用方法)。

### 异步函数

对于声明式互操作宏修饰的异步函数，必须满足以下条件，不满足时将会编译报错：

- 必须由 public 修饰
- 不支持类型参数
- 支持命名参数，但 ArkTS 调用方法和非命名参数一致
- 不支持默认值
- `JSStringEx`、`JSArrayEx<T>` 和 `JSHashMapEx<K, V>` 三种类型不能在异步函数中使用

异步函数互操作使用示例：

<!--compile-->
```cangjie
// 仓颉侧创建互操作函数
package ohos_app_cangjie_entry

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

@Interop[ArkTS, Async]
public func doAsync(a: Float64, b: Float64): Float64 {
    a + b
}
```

自动生成的 ArkTS 接口：

```typescript
// Generate... > Cangjie-ArkTS Interop API 后自动生成 .d.ts
export declare function doAsync(a: number, b: number): Promise<number>
```

ArkTS 侧对于仓颉模块的调用：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { doAsync } from "libohos_app_cangjie_entry.so";

doAsync(1, 2).then(result => {
    console.log("result " + result);
});
```

### 接口

对于声明式互操作宏修饰的接口，必须满足以下条件，不满足时将会编译报错：

- 必须由 public 修饰
- 不支持类型参数
- 不支持继承其他接口
- 支持不带修饰符的成员函数，其他和函数限制一致
- 不支持操作符重载
- 支持成员属性，支持 mut 修饰符

接口互操作使用示例：

<!--compile-->
```cangjie
// 仓颉侧创建互操作函数
package ohos_app_cangjie_entry

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

@Interop[ArkTS]
public interface InterfaceDemo {
    mut prop id: Float64
    func foo(a!: Float64): Float64
}

@Interop[ArkTS]
public func doInterface(a: InterfaceDemo): Float64  {
    return a.foo(a: a.id)
}
```

自动生成的 ArkTS 接口：

```typescript
// Generate... > Cangjie-ArkTS Interop API 后自动生成 .d.ts
export declare interface InterfaceDemo {
    id: number
    foo: (a: number) => number
}

export declare function doInterface(a: InterfaceDemo): number
```

ArkTS 侧对于仓颉模块的调用：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { InterfaceDemo, doInterface } from "libohos_app_cangjie_entry.so";

let callbackInterface = (a: number): number => {
  return a + 1;
}
let inter: InterfaceDemo = {foo: callbackInterface, id: 6};
console.log("result " + doInterface(inter));
```

### 类

对于声明式互操作宏修饰的类，必须满足以下条件，不满足时将会编译报错：

- 必须由 public 修饰
- 不支持类型参数
- 支持继承其他类，但是不会展开
- 支持继承接口，但是不会展开
- 不支持静态初始化器
- 支持多个普通构造函数或主构造函数，修饰符必带 public，不支持其他修饰符，不支持成员变量形参，不支持参数默认值
- 不支持多个普通构造函数或主构造函数对应相同的 ArkTS 接口签名，此场景建议使用静态函数
- 成员变量可选默认值，修饰符必带 public，不支持其他修饰符，不可省略变量类型标注
- 不支持操作符重载
- 成员属性修饰符必带 public

> **注意：**
>
> class 的特性约束只针对准备暴露给 ArkTS 的部分，可以通过修饰符不带 `public` 和 `@Interop[ArkTS, Invisible]` 修饰的方式标记不准备暴露的成员。

类互操作使用示例：

<!--compile-->
```cangjie
// 仓颉侧创建互操作函数
package ohos_app_cangjie_entry

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

@Interop[ArkTS]
public class ClassDemo {
    public var value1: Float64 = 1.0
    public let value2: Float64 = 1.0
    @Interop[ArkTS, Invisible]
    public var value3: Float64 = 1.0

    public init(a: Float64) {
        value1 = a
    }

    public init(a: Float64, b: Float64) {
        value1 = a + b
    }

    public static func staticMethod(): Float64 {
        1.0
    }

    public func foo(a: Float64): Float64 {
        a
    }

    @Interop[ArkTS, Invisible]
    public func foo2(): Float64 {
        1.0
    }

    public mut prop id1: Float64 {
        get() {
            value1
        }
        set(value) {
            this.value1 = value
        }
    }

    public prop id2: Float64 {
        get() {
            value2
        }
    }

    @Interop[ArkTS, Invisible]
    public prop id3: Float64 {
        get() {
            value3
        }
    }
}
```

自动生成的 ArkTS 接口：

```typescript
// Generate... > Cangjie-ArkTS Interop API 后在自动生成 .d.ts
export declare class ClassDemo {
    value1: number
    value2: number
    static staticMethod(): number
    foo(a: number): number
    id1: number
    id2: number
    constructor(a: number)
    constructor(a: number, b: number)
}
```

ArkTS 侧对于仓颉模块的调用：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { ClassDemo } from "libohos_app_cangjie_entry.so";

let class1: ClassDemo = new ClassDemo(3);
let class2: ClassDemo = new ClassDemo(3, 3);

console.log("result " + class1.foo(5));
console.log("result " + class1.value1);
console.log("result " + class2.value1);
console.log("result " + ClassDemo.staticMethod());
```

### 枚举

对于声明式互操作宏修饰的枚举，必须满足以下条件，不满足时将会编译报错：

- 必须由 public 修饰
- 不支持带参数的构造器

枚举互操作使用示例：

<!--compile-->
```cangjie
// 仓颉侧创建互操作函数
package ohos_app_cangjie_entry

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

@Interop[ArkTS]
public enum EnumDemo {
    Red | Green | Blue
}

@Interop[ArkTS]
public func getEnum(e: EnumDemo): EnumDemo {
    return e
}
```

自动生成的 ArkTS 接口：

```typescript
// Generate... > Cangjie-ArkTS Interop API 后自动生成 .d.ts
export declare const enum EnumDemo {
    Red = 0,
    Green = 1,
    Blue = 2
}

export declare function getEnum(e: EnumDemo): EnumDemo
```

ArkTS 侧对于仓颉模块的调用：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { EnumDemo, getEnum } from "libohos_app_cangjie_entry.so";

let e = EnumDemo.Green;
console.log("result " + getEnum(e));
```

## 类型映射

声明式互操作宏支持转换的数据类型如下表。

| cangjie 类型                                                                        | ArkTS 对应类型 | 备注                                                                                                                  |
| :---------------------------------------------------------------------------------- | :------------- | :-------------------------------------------------------------------------------------------------------------------- |
| Int8、Int16、Int32、Int64、UInt8、UInt16、UInt32、UInt64、Float16、Float32、Float64 | number         | -                                                                                                                     |
| Bool                                                                                | boolean        | -                                                                                                                     |
| String、JSStringEx                                                                  | string         | -                                                                                                                     |
| Unit                                                                                | undefined      | -                                                                                                                     |
| Option\<T>                                                                          | T \| undefined | T 不支持 Option\<T> 类型和函数类型，如果 T 为自定义类型（class 或 interface 类型），该自定义类型必须被 Interop 宏修饰 |
| func                                                                                | function       | -                                                                                                                     |
| JSArrayEx\<T>                                                                       | Array\<T>      | T 不支持函数类型，如果 T 为自定义类型（class 或 interface 类型），该自定义类型必须被 Interop 宏修饰                   |
| JSHashMapEx\<K, V>                                                                  | Map\<K, V>     | V 不支持函数类型，如果 V 为自定义类型（class 或 interface 类型），该自定义类型必须被 Interop 宏修饰                   |
| Array\<Byte>                                                                        | ArrayBuffer    | -                                                                                                                     |
| enum                                                                                | const enum     | -                                                                                                                     |
| class                                                                               | class          | -                                                                                                                     |
| interface                                                                           | interface      | -                                                                                                                     |

> **注意：**
>
> - 在被 `Interop` 宏所应用的函数签名，和对成员变量和属性的类型标注中，不支持使用语法糖，比如 `Option<T>` 类型的语法糖 `?T`。
>
> - `JSStringEx`、`JSArrayEx<T>` 和 `JSHashMapEx<K, V>` 三种类型只能使用在被 `Interop` 宏所应用的函数、class 和 interface 中。
