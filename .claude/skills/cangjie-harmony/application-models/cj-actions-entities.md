# 常见action与entities（不推荐使用）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## action

表示调用方要执行的通用操作（如查看、分享、应用详情）。在被调用方应用配置文件的[skills字段](../cj-start/basic-knowledge/cj-module-configuration-file.md#skills标签)内声明actions表示该应用支持声明操作。常见的action如下所示。

**常见action:**

- ACTION_HOME：启动应用入口组件的动作，需要和ENTITY_HOME配合使用；系统桌面应用图标是显式的入口组件，点击是启动入口组件的动作；入口组件可以配置多个。
- ACTION_CHOOSE：选择本地资源数据，例如联系人、相册等；系统一般对不同类型的数据有对应的Picker应用，例如联系人和图库。
- ACTION_VIEW_DATA：查看数据，当使用网址uri时，则表示显示该网址对应的内容。具体操作流程请见[通过startAbility拉起文件处理类应用](./cj-file-processing-apps-startup.md)。
- ACTION_VIEW_MULTIPLE_DATA：发送多个数据记录的操作。

## entities

表示目标应用组件的类别信息（如浏览器、视频播放器）。在被调用方应用配置文件的[skills字段](../cj-start/basic-knowledge/cj-module-configuration-file.md#skills标签)内声明entities表示该应用支持的类别。常见的entities如下。

**常见entities:**

- ENTITY_DEFAULT：默认类别无实际意义。
- ENTITY_HOME：主屏幕有图标点击入口类别。
- ENTITY_BROWSABLE：指示浏览器类别。
