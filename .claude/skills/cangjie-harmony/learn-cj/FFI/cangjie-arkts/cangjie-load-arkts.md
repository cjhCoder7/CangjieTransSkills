# 在仓颉代码里导入ArkTS模块

## 场景介绍

ArkTS互操作库里的JSContext.requireArkModule接口可以加载ArkTS模块，当模块被加载后，可以通过互操作接口来访问导出的变量和调用导出的接口。

## 函数说明

```cangjie
public func requireArkModule(path: String): JSValue
```

## 使用限制

* 只能在ArkTS绑定线程使用该接口
* 禁止在全局变量初始化过程和模块导出流程中使用该接口
* 对于部分系统模块（如：ohos.router）只在主运行时上提供，在worker线程导入将产生错误

> **注意：**
>
> 当前在spawn(UIThread)或context.postJSTask的回调里直接调用该接口将失败，该限制计划在后续的版本里移除。

## 支持场景

| 场景        | path 格式                                             | 说明                                         |
|:----------|:----------------------------------------------------|:-------------------------------------------|
| 系统模块      | @ohos.\*，@system.\*，@hms.\*和@kit.\*，如："@ohos.hilog" | /                                          |
| hap模块里的文件 | 模块名/模块下路径，如："entry/src/main/ets/Index"              | 支持.ets、.ts和.js格式的文件。path不带后缀（适用于所有场景）      |
| har模块里的文件 | 模块名/模块下路径，如："myhar/src/main/ets/Index"              | 支持（本地 \| 远程 \| ohpm）（源码 \| 二进制）har（需要额外配置） |
| hsp模块里的文件 | 模块名/模块下路径，如："@ohos/lottie/src/main/js/main"         | 支持（远程 \| ohpm）hsp                          |
| native模块  | lib模块名.so，如："libentry.so"                           | 支持（har\|本地hsp\|hap）里带的（napi\|仓颉）模块         |

### 加载系统模块

<!-- compile -->
```cangjie
func loadModule(context: JSContext): Unit {
    // 1. 使用requireArkModule导入模块"@ohos.hilog"
    let module = context.requireArkModule("@ohos.hilog")
    // 2. 把导入的模块转换为JSObject
    let hilog = module.asObject()
    // 3. 调用对象的info方法
    hilog.callMethod("info", [
        context.number(0).toJSValue(),
        context.string("test").toJSValue(),
        context.string("load hilog success").toJSValue()
    ])
}
```

### 加载hap模块里的文件

当加载hap里的文件时，如以下ArkTS代码：

```typescript
// entry/src/main/ets/Test.ets
export function test() {
    console.log("call hap file")
}
export let value = 123
```

1. 需要在模块的build-profile.json5里进行以下配置

    ```json5
    {
      "buildOption": {
        "arkOptions": {
          "runtimeOnly": {
            "sources": [
              "./src/main/ets/Test.ets"
            ]
          }
        }
      }
    }
    ```

2. 导入Test.ets文件和调用导出的接口

    <!-- compile -->
    ```cangjie
    func loadModule(context: JSContext): Unit {
        // 1. 使用requireArkModule导入模块
        let module = context.requireArkModule("entry/src/main/ets/Test")
        // 2. 把导入内容转换为JSObject
        let test = module.asObject()
        // 3. 读取导出的value变量
        let value = test["value"].toNumber()
        Hilog.info("value is ${value}")
        // 4. 写value变量
        test["value"] = context.number(2).toJSValue()
        // 5. 调用导出的test方法
        test.callMethod("test")
    }
    ```

### 加载har模块里的文件

1. 模块依赖配置

    ```json5
    // 模块下的 oh-package.json5
    {
      "name": "entry",
      "version": "1.0.0",
      "dependencies": {
        "localhar": "file:../localhar",                 // 本地har，在同一个工程下，用相对路径指向模块根目录
        "remotehar": "file:../prebuilts/remotehar.har", // 远程har，预编译为har（不区分源码har和二进制har），用路径指向har文件
        "@ohos/lottie": "^2.0.0"                        // ohpm har，已发布到ohpm的har，指定版本即可
      },
    }
    ```

2. 在模块的build-profile.json5里进行以下配置

    ```json5
    {
      "buildOption": {
        "arkOptions": {
          "runtimeOnly": {
            "packages": [
              "localhar",
              "remotehar",
              "@ohos/lottie"
            ]
          }
        }
      }
    }
    ```

3. 导入和调用导出的接口

    <!-- compile -->
    ```cangjie
    func loadModule(context: JSContext): Unit {
        // 1. 使用requireArkModule导入模块
        let module = context.requireArkModule("localhar/src/main/ets/Test")     // 导入本地har里的文件
        let module = context.requireArkModule("remotehar/src/main/ets/Test")    // 导入远程har里的文件
        let module = context.requireArkModule("@ohos/lottie/src/main/js/main")  // 导入ohpm har里的文件
        // 2. 把导入内容转换为JSObject
        let test = module.asObject()
        // 3. 读取导出的value变量
        let value = test["value"].toNumber()
        Hilog.info("value is ${value}")
        // 4. 写value变量
        test["value"] = context.number(2).toJSValue()
        // 5. 调用导出的test方法
        test.callMethod("test")
    }
    ```

> **注意：**
>
> 在ArkTS静态导入里存在整包导入的机制，例如：`import * as localhar from "localhar"`。
> 这种导入机制本质上仍然是导入一个文件，在每个(har | hsp)模块的oh-package.json里有一个字段main，
> 该字段指向一个源码文件，整包导入时实际上就是导入该文件。
> 例如localhar的oh-package.json配置为`main: "Index.ets"`，那么用该接口应该这样导入：`context.importArkModule("localhar/Index")`

### 加载hsp模块里的文件

build-profile.json5无需配置，导入和调用方式如下：

<!-- compile -->
```cangjie
func loadModule(context: JSContext): Unit {
    // 1. 使用requireArkModule导入模块
    let module = context.requireArkModule("localhsp/src/main/ets/Test")     // 导入本地hsp里的文件
    // 2. 把导入内容转换为JSObject
    let test = module.asObject()
    // 3. 读取导出的value变量
    let value = test["value"].toNumber()
    Hilog.info("value is ${value}")
    // 4. 写value变量
    test["value"] = context.number(2).toJSValue()
    // 5. 调用导出的test方法
    test.callMethod("test")
}
```

### 加载native模块

针对hap、har和本地hsp里定义的native（napi | 仓颉）模块，都可以通过生成的二进制名称进行加载。

<!-- compile -->
```cangjie
func loadModule(context: JSContext): Unit {
    // 1. 使用requireArkModule导入模块
    let module = context.requireArkModule("libentry.so")     // 导入native模块
    // 2. 把导入内容转换为JSObject
    let test = module.asObject()
    // 3. 读取导出的value变量
    let value = test["value"].toNumber()
    Hilog.info("value is ${value}")
    // 4. 写value变量
    test["value"] = context.number(2).toJSValue()
    // 5. 调用导出的test方法
    test.callMethod("test")
}
```

