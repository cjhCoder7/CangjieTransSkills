# 仓颉-ArkTS 互操作概述

在 OpenHarmony 系统上，为复用 ArkTS 生态，仓颉支持与 ArkTS 进行相互调用，该相互调用称为仓颉- ArkTS 互操作。仓颉- ArkTS 互操作基于仓颉 CFFI  (C Foreign Function Interface)与 ArkTS 运行时接口，为用户提供库级别的互操作能力。

仓颉- ArkTS 互操作从使用场景上分为仓颉应用中使用 ArkTS 及 ArkTS 应用中使用仓颉两种情况。从调用方式上区分，可以分为 ArkTS 调用仓颉，以及仓颉调用ArkTS。 ArkTS 调用仓颉可以分为用互操作宏进行开发以及用互操作库及进行开发。仓颉调用 ArkTS分为两种情况，调用 ArkTS 系统库和调用 ArkTS 三方库，调用系统库通过动态导入的方式进行开发，调用三方库通过HLE工具的方式进行开发。区分如下表：

在介绍所有用法之前，首先介绍一下互操作库。互操作库是辅助互操作功能实现的标准库，其主要包含 ArkTS 在仓颉中对应的一些类型表示以及类型中的 API。互操作库的几个核心的类型（非全部）为：

1. JSValue: 代表统一的 ArkTS 数据类型，其作用为在跨语言调用中做传参。
2. JSContext: 代表 ArkTS 运行时上下文，其作用为辅助 JSValue 转换成仓颉数据。
3. JSCallInfo: 代表 ArkTS 函数调用的参数集合，包含所有的入参和 this 指针。
4. JSRuntime: 代表由仓颉创建的 ArkTS 运行时。
