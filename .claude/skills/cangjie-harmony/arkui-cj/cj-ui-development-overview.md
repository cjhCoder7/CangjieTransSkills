# UI开发（仓颉声明式开发范式）概述

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

基于仓颉的声明式开发范式的方舟开发框架是一套开发极简、高性能、支持跨设备的UI开发框架，提供了构建应用UI所必需的能力，主要包括：

- **仓颉**

  仓颉语言是主力应用开发语言，在应用开发领域其能力涵盖了声明式UI描述、自定义组件、动态扩展UI元素、状态管理和渲染控制等方面。状态管理作为仓颉语言的开发范式特色，基于声明式编程理念，通过功能多样化的装饰器给开发者提供了清晰的页面更新渲染流程和管道。状态管理不仅涉及UI组件状态，还包括应用程序状态，两者协作使开发者完整地构建应用的数据更新和UI渲染。关于仓颉语言的基础知识，您可以参考<!--RP1-->[初识仓颉语言](https://gitcode.com/Cangjie/cangjie_docs/blob/dev/docs/dev-guide/source_zh_cn/first_understanding/basic.md)<!--RP1End-->以获取更多信息。

- **布局**

  布局是UI的必要元素，它定义了组件在界面中的位置。ArkUI框架提供了多种布局方式，除了基础的线性布局、层叠布局、弹性布局、相对布局、栅格布局外，也提供了相对复杂的列表、宫格、轮播。

- **组件**

  组件是UI的必要元素，形成了在界面中的样子，由框架直接提供的称为**系统组件**，由开发者定义的称为**自定义组件**。系统内置组件包括按钮、单选框、进度条、文本等。开发者可以通过链式调用的方式设置系统内置组件的渲染效果。开发者可以将系统内置组件组合为自定义组件，通过这种方式将页面组件化为一个个独立的UI单元，实现页面不同单元的独立创建、开发和复用，具有更强的工程性。

- **页面路由和组件导航**

  应用可能包含多个页面，可通过页面路由实现页面间的跳转。一个页面内可能存在组件间的导航如典型的分栏，可通过导航组件实现组件间的导航。

- **图形**

  方舟开发框架提供了多种类型图片的显示能力和多种自定义绘制的能力，以满足开发者的自定义绘图需求，支持绘制形状、填充颜色、绘制文本、变形与裁剪、嵌入图片等。

- **动画**

  动画是UI的重要元素之一。优秀的动画设计能够极大地提升用户体验，框架提供了丰富的动画能力，除了组件内置动画效果外，还包括属性动画、显式动画、自定义转场动画以及动画API等，开发者可以通过封装的物理模型或者调用动画能力API来实现自定义动画轨迹。

- **交互事件**

  交互事件是UI和用户交互的必要元素。方舟开发框架提供了多种交互事件，除了触摸事件、鼠标事件、键盘按键事件、焦点事件等通用事件外，还包括基于通用事件进行进一步识别的手势事件。手势事件有单一手势如点击手势、长按手势、拖动手势、捏合手势、旋转手势、滑动手势，以及通过单一手势事件进行组合的组合手势事件。

- **自定义能力**

  自定义能力是UI开发框架提供给开发者对UI界面进行开发和定制化的能力。包括：自定义组合、自定义扩展、自定义节点和自定义渲染。

## 特点

- 开发效率高，开发体验好

    - 代码简洁：通过接近自然语义的方式描述UI，不必关心框架如何实现UI绘制和渲染。

    - 数据驱动UI变化：让开发者更专注自身业务逻辑的处理。当UI发生变化时，开发者无需编写在不同的UI之间进行切换的UI代码，开发人员仅需要编写引起界面变化的数据，具体UI如何变化交给框架。

    - 开发体验好：界面也是代码，让开发者的编程体验得到提升。

- 性能优越

    - 声明式UI前端和UI后端分层：UI后端采用C++语言构建，提供对应前端的基础组件、布局、动效、交互事件、组件状态管理和渲染管线。

    - 语言编译器和运行时的优化：统一字节码、高效FFI（Foreign Function Interface）、AOT（Ahead Of Time）、引擎极小化、类型优化等。

- 生态容易快速推进：
  能够借力主流语言生态快速推进，语言相对中立友好，有相应的标准组织可以逐步演进。

## 开发流程

使用UI开发框架开发应用时，主要涉及如下开发过程。

| 任务          | 简介                                  | 相关指导                                     |
| :----------- | :----------------------------------- | :---------------------------------------- |
|学习仓颉|介绍了仓颉的基本语法、状态管理和渲染控制的场景。| - [基本语法](./paradigm/cj-basic-syntax-overview.md)<br> - [状态管理](./state_management/cj-state-management-overview.md)<br> - [渲染控制](./rendering_control/cj-rendering-control-overview.md)|
| 开发布局| 介绍了几种常用的布局方式。| - [常用布局](./cj-layout-development-overview.md)<br/> |
| 添加组件| 介绍了几种常用的系统组件使用方法。 | - [常用组件](cj-common-components-button.md)<br/> - [自定义组件](./paradigm/cj-create-custom-components.md)|
| 使用文本 | 介绍了输入框、富文本等文本组件的使用方法。| - [文本](cj-text-introduction.md)<br/>- [文本显示](cj-common-components-text-display.md) <br/>- [文本输入](cj-common-components-text-input.md)<br/> - [富文本](./cj-common-components-richeditor.md)<br>|
| 使用弹窗 | 介绍了弹窗的应用场景与使用方法。 | - [弹窗](cj-dialog-overview.md)<br/>- [弹出框](cj-dialog-base-overview.md)<br> - [菜单控制](./cj-popup-and-menu-components-menu.md)<br/>- [不依赖UI组件的全局自定义弹出框](cj-uicontext-custom-dialog.md)<br/>- [固定样式弹出框](cj-fixes-style-dialog.md)<br/>- [气泡提示](cj-popup-and-menu-components-popup.md)<br> - [绑定模态页面](./cj-modal-overview.md)<br> - [即时反馈](./cj-create-toast.md)|
| 显示图形| 介绍了如何显示图片、绘制自定义几何图形以及使用画布绘制自定义图形。| - [几何图形](cj-shape-drawing.md)<br/>- [画布](cj-drawing-customization-on-canvas.md) |
| 使用动画| 介绍了组件和页面使用动画的典型场景。| - [动画](cj-animation.md)<br>- [属性动画](cj-attribute-animation-overview.md)<br>- [实现属性动画](cj-attribute-animation-apis.md)<br>- [转场动画](cj-transition-overview.md)<br>- [出现/消失转场](cj-enter-exit-transition.md)<br>- [模态转场](cj-modal-transition.md)<br>- [组件动画](cj-component-animation.md)<br>- [动画曲线](cj-curve-overview.md)<br>- [传统曲线](cj-traditional-curve.md)<br>- [动画衔接](cj-animation-smoothing.md)<br>- [模糊](cj-blur-effect.md)<br>- [阴影](cj-shadow-effect.md)<br>- [色彩](cj-color-effect.md)<br> - [帧动画](cj-animator.md)|
|绑定事件| 介绍了事件的基本概念和如何使用通用事件和手势事件。| - [交互事件](cj-event-overview.md)<br/>- [事件分发](cj-common-events-distribute.md)<br/>-&nbsp;[触屏事件](cj-common-events-touch-screen-event.md)<br/>- [键鼠事件](cj-common-events-device-input-event.md)<br/>- [焦点事件](cj-common-events-focus-event.md)|
|使用镜像能力|介绍了镜像能力的基本概念和如何使用镜像能力。| - [使用镜像能力](./cj-mirroring-display.md)|
|主题设置|介绍了应用级和页面级的主题设置能力。| - [应用深浅色适配](./cj-ui-dark-light-color-adaptation.md)|

## 通用规则

- **默认单位**

  表示长度的入参单位默认为vp，即入参为Int32类型、以及[Length](../reference/arkui-cj/cj-common-types.md#interface-length)类型中的Int64、Float64单位为vp。

- **异常值处理**

  输入的参数为无效值时，处理规则如下：

    - 对应参数有默认值，按默认值处理；

    - 对应参数无默认值，该参数对应的属性或接口不生效。

## 注意事项

**耗时操作**

  若在UI主线程或通过spawn(UIThread)调度的任务中执行如读取文件等耗时任务，可能导致UI主线程阻塞，引发界面延迟、卡顿、丢帧甚至冻结等问题。

  在应用开发实践中，应避免在UI主线程中执行冗余与耗时操作，提升界面响应速度与整体流畅度。