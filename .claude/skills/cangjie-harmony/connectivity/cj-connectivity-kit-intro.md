# Connectivity Kit简介

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## Connectivity Kit开发概述

移动终端设备已经深入人民日常生活的方方面面，如连接蓝牙耳机听音乐、连接WIFI上网、使用NFC进行一碰开门等已成为终端用户日常生活中常见的行为。

当用户处于这些丰富的使用场景中时，蓝牙提供基于蓝牙连接的基础能力，如音乐/通话/分享等，WIFI提供基础的无线连接能力，NFC提供基础的靠近刷卡和读卡能力。

对于开发者，设计基础通信的体验服务，可以使应用的使用体验更贴近每个终端用户的日常生活。

### 蓝牙简介

蓝牙技术是一种无线通信技术，可以在短距离内传输数据。可以用于连接手机、耳机、音箱、键盘、鼠标、打印机等各种设备。特点是低功耗、低成本、简单易用。目前已经发展到了第五代，支持更高的数据传输速率和更广的覆盖范围。
下面简介几种常见的蓝牙涉及的模块：

- **BLE模块（低功耗蓝牙）**

  BLE是Bluetooth Low Energy的缩写，意为“低功耗蓝牙”。它是一种能够在低功耗情况下进行通信的蓝牙技术，与传统蓝牙相比，BLE的功耗更低，适用于需要长时间运行的低功耗设备。

  详情请参见[ohos.bluetooth.ble API参考](../reference/ConnectivityKit/cj-apis-bluetooth-ble.md)。

- **A2DP模块（高级音频分发配置文件）**

  A2DP是Advanced Audio Distribution Profile的缩写，即高级音频分发配置文件。它是一种蓝牙协议，允许无线传输高品质音频流，例如音乐或语音通话，同时支持双向通信，因此可以用于耳机、扬声器、汽车音响等设备。

  详情请参见[ohos.bluetooth.a2dp API参考](../reference/ConnectivityKit/cj-apis-bluetooth-a2dp.md)。

相关开发指南请参见：[蓝牙开发指南](./bluetooth/cj-bluetooth-overview.md)。

### WLAN简介

无线局域网（Wireless Local Area Networks，WLAN），是通过无线电、红外光信号或者其他技术发送和接收数据的局域网，用户可以通过WLAN实现结点之间无物理连接的网络通讯。常用于用户携带可移动终端的办公、公众环境中。

WLAN系统为用户提供接入WLAN网络功能（STA模式）、点对点的数据传输功能（P2P模式）和热点分享功能（AP模式），让应用可以通过WLAN和其他设备互联互通。

- **STA模式**
  STA模式即工作站模式，可以理解为某网络中的一个工作站即客户端。当某设备具备该功能时，它可以连到另外的一个路由网络中，如家用路由器，通常用于提供网络的数据上行服务。

  详情请参见[ohos.wifiManager API参考](../reference/ConnectivityKit/cj-apis-wifi_manager.md)。

- **P2P模式**
  P2P模式即为Wi-Fi Direct；Wi-Fi Direct 是一种点对点连接技术，它可以在两台 STA 之间直接建立 TCP/IP 链接，并不需要AP的参与；其中一台STA会起到传统意义上的AP的作用，称为Group Owner(GO)，另外一台station则称为Group Client(GC)，像连接AP一样连接到GO。

  详情请参见[ohos.wifiManager API参考](../reference/ConnectivityKit/cj-apis-wifi_manager.md)。

- **AP模式**
  AP模式为加入无线局域网的成员设备（即客户端）提供下行数据业务，它提供以无线方式组建无线局域网WLAN，相当于WLAN的中心设备。

  详情请参见[ohos.wifiManager API参考](../reference/ConnectivityKit/cj-apis-wifi_manager.md)。

### 运作机制

Connectivity能力作为系统为应用提供的一种基础通信服务，需要在应用使用场景中打开相应开关/连接等处理，在业务结束时主动结束连接等。

### 约束与限制

使用设备的相关能力，需要用户主动授权打开开关。否则系统不会向三方应用提供服务。
