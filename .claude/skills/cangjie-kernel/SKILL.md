---
name: cangjie-kernel
description: "仓颉编程语言核心文档。涉及仓颉语法、类型系统、标准库、集合、并发、宏、错误处理、网络等语言层面问题时使用"
---

# 仓颉编程语言特性目录

> 请按需查阅相关文档

语法、类型或标准库的只读查询不创建 LoopX Goal。若用户要求依据这些知识修改项目、编写实现或修复代码，先加载 `cangjie-loopx-management`，在获准的 Goal/Todo 边界内执行并写回验证结果。

- [基本概念](./basic_concepts/README.md): 介绍仓颉编程语言的关键字、标识符、程序结构、变量定义(let/var/const)、值类型与引用类型、作用域规则、表达式(if/while/for-in/break/continue)、函数等基本概念和规则
- [基本数据类型](./basic_data_type/README.md): 介绍仓颉语言的整数、浮点、布尔、字符(Rune)、字符串(String)、Unit、Nothing、元组(Tuple)、数组(Array/VArray)、区间(Range)类型以及基本运算符的语法和规则
- [字符串/String](./string/README.md): 介绍仓颉标准库 String 类型的构造、搜索、替换、分割、拼接、裁剪、大小写转换、编码处理、下标访问、迭代等操作的完整 API 和用法
- [for-in 迭代](./for/README.md): 介绍仓颉语言 for-in 循环语法、Iterable/Iterator 接口、Range 区间类型、迭代控制（break/continue/where）、元组解构、自定义迭代器、迭代最优实践等特性
- [函数/function](./function/README.md): 介绍仓颉语言的函数定义、调用、命名参数、默认值、函数类型、Lambda表达式、闭包、嵌套函数、函数重载、运算符重载、尾随Lambda、管道运算符(|>)、组合运算符(~>)、变长参数等特性
- [常量/const](./const/README.md): 介绍仓颉语言的 const 变量定义、const 表达式、const 函数、编译时求值、const init 构造函数等特性

- [类/class](./class/README.md): 介绍仓颉语言的类定义、抽象类、构造函数(init/主构造函数)、终结器(~init)、继承(单继承/sealed)、重写(override)、重定义(redef)、成员变量、成员函数、属性(prop)、访问修饰符、This类型、对象创建等特性
- [结构体/struct](./struct/README.md): 介绍仓颉语言的struct定义、构造函数(init/主构造函数)、值语义、成员访问与修改规则、mut函数及其限制等特性
- [接口/interface](./interface/README.md): 介绍仓颉语言的接口定义、接口实现(单个/多个)、接口继承、默认实现(实例/静态)、sealed接口、泛型成员、Any类型、属性(prop)在接口中的使用、菱形继承解决方案等特性
- [枚举/enum](./enum/README.md): 介绍仓颉语言的enum定义规则、构造器（有参/无参/同名/非穷举）、枚举的使用与名称冲突、枚举成员函数和属性、递归枚举、枚举实现Equatable接口等特性
- [泛型/generic](./generic/README.md): 介绍仓颉语言的泛型函数、泛型类、泛型接口、泛型结构体、泛型枚举、泛型约束(where)、泛型子类型关系、型变(不变/协变/逆变)等特性
- [类型系统](./type_system/README.md): 介绍仓颉语言的子类型关系（继承/接口实现/元组/函数类型）、型变规则（协变/逆变/不型变）、类型转换（is/as操作符）、数值类型转换、Rune转换、Nothing/Any/Object等基础类型关系、类型别名(type)等特性
- [扩展/extend](./extend/README.md): 介绍仓颉语言的直接扩展(extend)、接口扩展、泛型扩展、扩展中的访问规则、孤儿规则、导出与导入规则等特性

- [Option 类型](./option/README.md): 介绍仓颉语言 Option\<T\> 定义与用法、?T 简写、自动包装、模式匹配解构、coalescing 操作符(??)、问号操作符(?.)、getOrThrow()、if-let 条件解构、while-let 循环解构等特性
- [模式匹配](./pattern_match/README.md): 介绍仓颉语言 match 表达式、模式类型（常量/通配符/绑定/元组/类型/枚举）、模式嵌套、模式守卫(where)、穷举性、模式可反驳性、if-let 条件匹配、while-let 循环匹配、模式在变量定义和 for-in 中的使用等特性
- [错误处理](./error_handle/README.md): 介绍仓颉语言的异常层次(Error/Exception)、自定义异常、throw、try/catch/finally、try-with-resources、CatchPattern、Option类型错误处理(?./??/getOrThrow)、内置运行时异常等错误处理特性

- [并发编程](./concurrency/README.md): 介绍仓颉语言的M:N线程模型、spawn创建线程、sleep、原子操作(Atomic)、互斥锁(Mutex)、条件变量(Condition)、synchronized、Future、线程取消、ThreadLocal等并发编程特性
- [宏/macro](./macro/README.md): 介绍仓颉语言宏与元编程，包括Token/Tokens类型、quote表达式与插值、非属性宏、属性宏、嵌套宏与通信、std.ast包与语法节点解析
- [反射与注解](./reflect_and_annotation/README.md): 介绍仓颉语言的整数溢出注解(@OverflowThrowing/@OverflowWrapping/@OverflowSaturating)、自定义注解(@Annotation)、反射(TypeInfo)等特性

- [包机制/package](./package/README.md): 介绍仓颉语言的包声明(package)、程序入口(main)、包导入(import)、重新导出(public import)、顶层访问修饰符(private/internal/protected/public)等特性
- [项目管理/cjpm](./project_management/README.md): 介绍仓颉项目管理工具 cjpm 的用法，包括创建项目、项目配置(cjpm.toml)、管理依赖、构建、运行、测试、清理、安装、工作区、交叉编译、构建脚本(build.cj)、增量编译、环境变量替换等

- [集合类型](./collections/README.md): 介绍仓颉集合数据类型，包括Array/ArrayList/HashMap/HashSet
- [网络编程](./network/README.md): 介绍仓颉网络编程，包括socket/tcp/udp/tls/http/https/websocket

- [C 互操作/CFFI](./cffi/README.md): 介绍仓颉程序与C程序互操作，包括foreign声明、CFunc、inout参数、unsafe块、调用约定、类型映射(基础类型/结构体/CPointer/VArray/CString)、C回调仓颉、内存管理等特性
