# 自定义组件成员属性访问限定符使用限制

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在状态管理中，当组件开发者封装了自定义组件后，由于组件没有明确的输入输出标识，使得调用方无法按照统一的标准判断传入哪些变量作为组件入参。在状态管理中，不可以使用限定符修饰状态变量。

仓颉会校验自定义组件的成员变量访问限定符类型，若未按规定使用private、public或protected，则生成相应日志记录。

在阅读本文档前，建议提前阅读：[状态管理概述](../state_management/cj-state-management-overview.md)。

## 使用限制

- [@State](../state_management/cj-macro-state.md)/[@Prop](../state_management/cj-macro-prop.md)/[@Provide](../state_management/cj-macro-provide-and-consume.md)/[@BuilderParam](./cj-macro-builderparam.md)/常规成员变量(不涉及更新的普通变量)的初始化规则为可以被外部初始化。

- [@StorageLink](../state_management/cj-appstorage.md#storagelink)/[@StorageProp](../state_management/cj-appstorage.md#storageprop)/[@LocalStorageLink](../state_management/cj-localstorage.md#localstoragelink)/[@LocalStorageProp](../state_management/cj-localstorage.md#localstorageprop)/[@Consume](../state_management/cj-macro-provide-and-consume.md)变量的初始化规则为不可以被外部初始化。

- [@Link](../state_management/cj-macro-link.md)变量的初始化规则为必须被外部初始化，禁止本地初始化。

## 使用场景

1. 当成员变量被private访问限定符和@State/@Prop/@Provide/@BuilderParam宏同时修饰，仓颉会进行校验并产生报错。

    【反例】

    <!-- code_check_manual -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*

    @Entry
    @Component
    class EntryView {
        func build() {
            Column {
                ComponentChild(state_value: "Hello", prop_value: "Hello", provide_value: "Hello", builder_value: buildTest,
                    regular_value: "Hello")
            }.width(100.percent)
        }
    }

    @Component
    class ComponentChild {
        // 此处使用private修饰符时会出现报错
        @State
        private var state_value: String = "Hello"
        // 此处使用private修饰符时会出现报错
        @Prop
        private var prop_value: String
        // 此处使用private修饰符时会出现报错
        @Provide
        private var provide_value: String = "Hello"
        // 此处使用private修饰符时会出现报错
        @BuilderParam
        private var builder_value: () -> Unit = buildTest
        // 此处写法正确
        private var regular_value: String = "Hello"

        func build() {
            Column() {
                Text("Hello")
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
            }
        }
    }

    @Builder
    func buildTest() {
        Text("Child builder")
    }
    ```

    【正例】

    <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*

    @Entry
    @Component
    class EntryView {
        func build() {
            Column {
                ComponentChild(state_value: "Hello", prop_value: "Hello", provide_value: "Hello", builder_value: buildTest,
                    regular_value: "Hello")
            }.width(100.percent)
        }
    }

    @Component
    class ComponentChild {
        @State
        var state_value: String = "Hello"
        @Prop
        var prop_value: String
        @Provide
        var provide_value: String = "Hello"
        @BuilderParam
        var builder_value: () -> Unit = buildTest
        var regular_value: String = "Hello"

        func build() {
            Column() {
                Text("Hello")
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
            }
        }
    }

    @Builder
    func buildTest() {
        Text("Child builder")
    }
    ```

2. 当成员变量被public访问限定符和@StorageLink/@StorageProp/@LocalStorageLink/@LocalStorageProp/@Consume宏同时修饰，仓颉会进行校验并产生报错。

    【反例】

    <!-- code_check_manual -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*

    let storage = LocalStorage()

    @Entry[storage]
    @Component
    class EntryView {
        @Provide var consume_value: String = "Hello"

        func build() {
            Column {
                ComponentChild()
            }
            .width(100.percent)
        }
    }

    @Component
    class ComponentChild {
        // 此处使用public修饰符时会出现报错
        @LocalStorageProp["sessionLocalProp"] public let local_prop_value: String = "Hello"
        // 此处使用public修饰符时会出现报错
        @LocalStorageLink["sessionLocalLink"] public var local_link_value: String = "Hello"
        // 此处使用public修饰符时会出现报错
        @StorageProp["sessionProp"] public let storage_prop_value: String = "Hello"
        // 此处使用public修饰符时会出现报错
        @StorageLink["sessionLink"] public var storage_link_value: String = "Hello"
        // 此处使用public修饰符时会出现报错
        @Consume public var consume_value: String = "Hello"

        func build() {
            Column {
                Text("Hello")
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
            }
        }
    }
    ```

    【正例】

    <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*

    let storage = LocalStorage()

    @Entry[storage]
    @Component
    class EntryView {
        @Provide var consume_value: String = "Hello"

        func build() {
            Column {
                ComponentChild()
            }
            .width(100.percent)
        }
    }

    @Component
    class ComponentChild {
        @LocalStorageProp["sessionLocalProp"] let local_prop_value: String = "Hello"
        @LocalStorageLink["sessionLocalLink"] var local_link_value: String = "Hello"
        @StorageProp["sessionProp"] let storage_prop_value: String = "Hello"
        @StorageLink["sessionLink"] var storage_link_value: String = "Hello"
        @Consume var consume_value: String = "Hello"

        func build() {
            Column {
                Text("Hello")
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
            }
        }
    }
    ```

3. 当成员变量被private访问限定符和@Link宏同时修饰，仓颉会进行校验并产生报错。

    【反例】

    <!-- code_check_manual -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*

    @Entry
    @Component
    class EntryView {
        @State var link_value: String = "Hello"

        func build() {
            Column {
                ComponentChild(link_value: this.link_value)
            }
            .width(100.percent)
        }
    }

    @Component
    class ComponentChild {
        // 此处使用private修饰符时会出现报错
        @Link private var link_value: String

        func build() {
            Column {
                Text("Hello")
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
            }
        }
    }
    ```

    【正例】

     <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*

    @Entry
    @Component
    class EntryView {
        @State var link_value: String = "Hello"

        func build() {
            Column {
                ComponentChild(link_value: this.link_value)
            }
            .width(100.percent)
        }
    }

    @Component
    class ComponentChild {
        @Link var link_value: String

        func build() {
            Column {
                Text("Hello")
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
            }
        }
    }
    ```
