# Basic Services Kit简介

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Basic Services Kit（基础服务）作为基础服务套件，为应用开发者提供常用的基础能力。比如常用的剪贴板读写、文件上传下载、文件压缩、文件打印、进程间/线程间通信、设备管理、应用账号管理等能力都由本Kit提供。

## 使用场景

Basic Services Kit为开发者提供了多种基础能力，满足开发者不同场景的开发需求。

典型使用场景举例：

- 剪贴板读写：
    - 本地复制粘贴：比如在A应用中复制一段文字，粘贴到其他应用中。
    - 跨设备复制粘贴：比如在A设备浏览器复制一段文本，粘贴到B设备的备忘录中。

- 文件上传下载：
    - 小文件前台上传下载：发布社交动态（图片、短视频等）、发送文件给好友、保存图片到本地等，通常数据量较小，要给用户即时反馈。
    - 大文件后台上传下载：云盘数据同步、下载电影，通常数据量较大，可后台执行，支持断点续传。

- 进程间/线程间通信：
    - 进程间通信：比如ExtensionAbility发送事件给主进程。
    - 线程间通信：比如worker线程处理完网络请求后将事件传递回UI主线程。

## 能力范围

根据不同使用场景分类，本Kit主要包含如下能力：

- 数据文件处理：
    - [压缩](../reference/AbilityKit/cj-apis-bundle_manager.md)：提供文件压缩解压缩的能力。
    - [上传下载](../reference/BasicServicesKit/cj-apis-request-agent.md)：提供文件上传下载、后台传输代理的基础能力。

- 进程间/线程间通信：
    - [公共事件](../reference/BasicServicesKit/cj-apis-common_event_manager.md)：提供进程间通信的能力，包括订阅、发布、退订公共事件等，相关开发指南请参考[公共事件简介](./common-event/cj-common-event-overview.md)。

- 设备管理：
    - [设备信息](../reference/BasicServicesKit/cj-apis-device_info.md)：提供查询产品信息的能力，比如查询设备类型、设备品牌名称、产品系列、产品版本号等。
    - [设置数据项](../reference/BasicServicesKit/cj-apis-settings.md)：提供查询系统设置数据项的能力，比如查询是否启用飞行模式、是否启用触摸浏览等。
    - [电量信息查询](../reference/BasicServicesKit/cj-apis-battery_info.md)：提供查询电量信息的能力。

- 其他：
    - [时间时区](../reference/BasicServicesKit/cj-apis-system_date_time.md)：提供获取系统时间以及系统时区的能力。

## 与其他kit的关系

- [Ability Kit](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md)：Ability Kit中的进程间通信需要使用本Kit中的公共事件。

- [Core File Kit](../reference/CoreFileKit/cj-apis-file_fs.md)：与Core File Kit的使用场景不同，Core File Kit主要提供访问和管理文件的能力，开发者可以在应用文件访问和文件分享、应用数据备份恢复等场景使用Core File Kit进行开发，而涉及到文件压缩、文件上传下载、文件打印等场景时需要使用本Kit进行开发。
