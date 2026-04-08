# 资源分类与访问

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

应用开发过程中，经常需要用到颜色、字体、间距、图片等资源，在不同的设备或配置中，这些资源的值可能不同。

- 应用资源：借助资源文件能力，开发者在应用中自定义资源，自行管理这些资源在不同的设备或配置中的表现。
- 系统资源：开发者直接使用系统预置的资源定义（即分层参数，同一资源ID在设备类型、深浅色等不同配置下有不同的取值）。

## 资源分类

应用开发中使用的各类资源文件，需要放入特定子目录中存储管理。资源目录的示例如下所示，base目录、限定词目录、rawfile目录、resfile目录称为资源目录，element、media、profile称为资源组目录。

> **说明：**
>
> stage模型在多工程情况下，共有的资源文件将会放到AppScope下的resources目录。

资源目录示例：

```text
resources
|---base
|   |---element
|   |   |---string.json
|   |---media
|   |   |---icon.png
|   |---profile
|   |   |---test_profile.json
|---en_US  // 默认存在的目录，设备语言环境是美式英文时，优先匹配此目录下资源
|   |---element
|   |   |---string.json
|   |---media
|   |   |---icon.png
|   |---profile
|   |   |---test_profile.json
|---zh_CN  // 默认存在的目录，设备语言环境是简体中文时，优先匹配此目录下资源
|   |---element
|   |   |---string.json
|   |---media
|   |   |---icon.png
|   |---profile
|   |   |---test_profile.json
|---en_GB-vertical-car-mdpi // 自定义限定词目录示例，由开发者创建
|   |---element
|   |   |---string.json
|   |---media
|   |   |---icon.png
|   |---profile
|   |   |---test_profile.json
|---rawfile
|---resfile // 可以自由放置各类资源文件，由开发者创建
```

### 资源目录

**base目录**

base目录是默认存在的目录，二级子目录element用于存放字符串、颜色、布尔值等基础元素，media、profile存放媒体、动画、布局等资源文件。

目录中的资源文件会被编译成二进制文件，并赋予资源文件ID。通过指定资源类型（type）和资源名称（name）引用。

**限定词目录**

en_US和zh_CN是默认存在的两个限定词目录，其余限定词目录需要开发者根据开发需要自行创建。二级子目录element、media、profile用于存放字符串、颜色、布尔值等基础元素，以及媒体、动画、布局等资源文件。

同样，目录中的资源文件会被编译成二进制文件，并赋予资源文件ID。通过指定资源类型（type）和资源名称（name）来引用。

**限定词目录的命名要求**

限定词目录可以由一个或多个表征应用场景或设备特征的限定词组合而成，包括移动国家码和移动网络码、语言、文字、国家或地区、横竖屏、设备类型、颜色模式和屏幕密度等维度，限定词之间通过下划线（\_）或者中划线（-）连接。开发者在创建限定词目录时，需要遵守限定词目录的命名规则。

- 限定词的组合顺序：\_移动国家码\_移动网络码-语言\_文字\_国家或地区-横竖屏-设备类型-颜色模式-屏幕密度\_。开发者可以根据应用的使用场景和设备特征，选择其中的一类或几类限定词组成目录名称。
- 限定词的连接方式：语言、文字、国家或地区之间采用下划线（\_）连接，移动国家码和移动网络码之间也采用下划线（\_）连接，除此之外的其他限定词之间均采用中划线-连接。例如：**zh_Hant_CN**、**zh_CN-car-ldpi**。
- 限定词的取值范围：每类限定词的取值必须符合限定词取值要求表中的条件，如下表所示。否则，将无法匹配目录中的资源文件。

| **限定词类型**            | **含义与取值说明** |
| ----------------------- | -------------------------------------------------------- |
| 移动国家码和移动网络码 | 移动国家码（MCC）和移动网络码（MNC）的值取自设备注册的网络。<br>MCC可与MNC合并使用，使用下划线（_）连接，也可以单独使用。例如：mcc460表示中国，mcc460_mnc00表示中国_中国移动。<br>详细取值范围，请查阅<a href="https://www.itu.int/rec/T-REC-E.212">ITU-T E.212</a>（国际电联相关标准）。 |
| 语言 | 表示设备使用的语言类型，由2~3个小写字母组成。例如：zh表示中文，en表示英语，mai表示迈蒂利语。<br>详细取值范围，请查阅<a href="https://www.iso.org/iso-639-language-code">ISO 639</a>（ISO制定的语言编码标准）。 |
| 文字 | 表示设备使用的文字类型，由1个大写字母（首字母）和3个小写字母组成。例如：Hans表示简体中文，Hant表示繁体中文。<br>详细取值范围，请查阅<a href="https://www.iso.org/standard/81905.html">ISO 15924</a>（ISO制定的文字编码标准）。 |
| 国家或地区 | 表示用户所在的国家或地区，由2~3个大写字母或者3个数字组成。例如：CN表示中国，GB表示英国。<br>详细取值范围，请查阅<a href="https://www.iso.org/iso-3166-country-codes.html">ISO 3166-1</a>（ISO制定的国家和地区编码标准）。 |
| 横竖屏 | 表示设备的屏幕方向，取值如下：<br>- vertical：竖屏。<br>- horizontal：横屏。 |
| 设备类型 | 表示设备的类型，取值如下：<br>- car：车机。<br>- tablet：平板。<br>- tv：智慧屏。<br>- wearable：智能穿戴。 |
| 颜色模式 | 表示设备的颜色模式，取值如下：<br>- dark：深色模式。<br>- light：浅色模式。 |
| 屏幕密度 | 表示设备的屏幕密度（单位为dpi），取值如下：<br>- sdpi：表示小规模的屏幕密度（Small-scale Dots Per Inch），适用于dpi取值为(0, 120]的设备。<br>- mdpi：表示中规模的屏幕密度（Medium-scale Dots Per Inch），适用于dpi取值为(120, 160]的设备。<br>- ldpi：表示大规模的屏幕密度（Large-scale Dots Per Inch），适用于dpi取值为(160, 240]的设备。<br>- xldpi：表示特大规模的屏幕密度（Extra Large-scale Dots Per Inch），适用于dpi取值为(240, 320]的设备。<br>- xxldpi：表示超大规模的屏幕密度（Extra Extra Large-scale Dots Per Inch），适用于dpi取值为(320, 480]的设备。<br>- xxxldpi：表示超特大规模的屏幕密度（Extra Extra Extra Large-scale Dots Per Inch），适用于dpi取值为(480, 640]的设备。 |

**rawfile目录**

支持创建多层子目录，子目录名称可以自定义，文件夹内可以自由放置各类资源文件。

目录中的资源文件会被直接打包进应用，不经过编译，也不会被赋予资源文件ID。通过指定文件路径和文件名引用。

**resfile目录**

支持创建多层子目录，子目录名称可以自定义，文件夹内可以自由放置各类资源文件。

目录中的资源文件会被直接打包进应用，不经过编译，也不会被赋予资源文件ID。应用安装后，resfile资源会被解压到应用沙箱路径，通过Context属性resourceDir获取到resfile资源目录后，可通过文件路径访问。

### 资源组目录

资源组目录包括element、media、profile三种类型的资源文件，用于存放特定类型资源。

资源组目录说明如下表所示。

| **目录类型** | **说明** | **资源文件** |
| ---------- | ------------------------- | --------------------------------- |
| element  | 表示元素资源，以下每一类数据都采用相应的JSON文件来表征（目录下仅支持文件类型）。<br>- boolean，布尔型<br>- color，颜色<br>- float，浮点型，范围是-2^128-2^128<br>- intarray，整型数组<br>- integer，整型，范围是-2^31-2^31-1<br>- plural，复数形式<br>- strarray，字符串数组<br>- string，字符串 | element目录中的文件名称建议与下面的文件名保持一致。每个文件中只能包含同一类型的数据。<br>- boolean.json<br>- color.json<br>- float.json<br>- intarray.json<br>- integer.json<br>- plural.json<br>- strarray.json<br>- string.json |
| media    | 表示媒体资源，包括图片、音频、视频等非文本格式的文件（目录下只支持文件类型）。<br>图片和音视频的类型说明见表4和表5。 | 文件名可自定义，例如：icon.png。 |
| profile  | 表示自定义配置文件，其文件内容可通过包管理接口获取（目录下只支持json文件类型）。 | 文件名可自定义，例如：test_profile.json。 |

**媒体资源类型说明**

图片资源类型说明如下表所示。

| 格式 | 文件后缀名 |
| ---- | ---------- |
| JPEG | .jpg       |
| PNG  | .png       |
| GIF  | .gif       |
| SVG  | .svg       |
| WEBP | .webp      |
| BMP  | .bmp       |

音视频资源类型说明如下表所示。

| 格式                  | 支持的文件类型 |
| --------------------- | -------------- |
| H.264 AVC             | .3gp           |
| Baseline Profile (BP) | .mp4           |

**资源文件示例**

color.json文件的内容如下：

```json
{
    "color": [
        {
            "name": "color_hello",
            "value": "#ffff0000"
        },
        {
            "name": "color_world",
            "value": "#ff0000ff"
        }
    ]
}
```

float.json文件的内容如下：

```json
{
    "float":[
        {
            "name":"font_hello",
            "value":"28.0fp"
        },
    {
            "name":"font_world",
            "value":"20.0fp"
        }
    ]
}
```

string.json文件的内容如下：

```json
{
    "string":[
        {
            "name":"string_hello",
            "value":"Hello"
        },
        {
            "name":"string_world",
            "value":"World"
        },
        {
            "name":"message_arrive",
            "value":"We will arrive at %1$s."
        },
        {
          "name":"message_notification",
          "value":"Hello, %1$s!,You have %2$d new messages"
        }
    ]
}
```

plural.json文件的内容如下：

```json
{
    "plural":[
        {
            "name":"eat_apple",
            "value":[
                {
                    "quantity":"one",
                    "value":"%d apple"
                },
                {
                    "quantity":"other",
                    "value":"%d apples"
                }
            ]
        }
    ]
}
```

## 创建资源目录和资源文件

在resources目录下，可按照限定词目录命名规则，以及资源组目录支持的文件类型和说明，创建资源目录和资源组目录，添加特定类型资源。DevEco Studio支持同时创建资源目录和资源文件，也支持单独创建资源目录或资源文件。

### 创建资源目录和资源文件

在resources目录右键菜单选择“New > Resource File”，可同时创建资源目录和资源文件，文件默认创建在base目录的对应资源组。如果选择了限定词，则会按照命名规范自动生成限定词和资源组目录，并将文件创建在限定词目录中。

图中File name为需要创建的文件名。Resource type为资源组类型，默认是Element。Root element为资源类型。Avaliable qualifiers为供选择的限定词目录，通过右侧的小箭头可添加或者删除。

创建的目录名自动生成，格式固定为“限定词.资源组”，例如：创建一个限定词为dark的element目录，自动生成的目录名称为“dark.element”。

![newResFolder](../figures/newResFolder.png)

### 创建资源目录

在resources目录右键菜单选择“New > Resource Directory”，可创建资源目录，默认创建的是base目录。如果选择了限定词，则会按照命名规范自动生成限定词和资源组目录。确定限定词后，选择资源组类型，当前资源组类型支持Element、Media、Profile三种，创建后生成资源目录。

![newResFolder2](../figures/newResFolder2.png)

### 创建资源文件

在base>element资源目录的右键菜单选择“New > Element Resource File”，即可创建Element Resource File。

![newResFile](../figures/newResFile.png)

## 资源可翻译特性

### 功能介绍

资源需要翻译时，可使用attr属性标记字符串翻译范围和翻译状态。attr属性不参与资源编译，只标记字符串是否翻译。

未配置attr属性，默认需要翻译。

```json
"attr": {
  "translatable": false|true
  "priority": "code|translate|LT|customer"
}
```

**attr支持属性**

| **名称** | **类型** | **说明** |
| ---------- | ------------------------- | --------------------------------- |
| translatable  | boolean。 | 标记字符串是否需要翻译。<br>true：需要翻译。<br>false：不需要翻译。 |
| media  | 表示媒体资源，包括图片、音频、视频等非文本格式的文件（目录下只支持文件类型）。<br>图片和音视频的类型说明见表4和表5。 | 文件名可自定义，例如：icon.png。 |
| priority  | string。 | 标记字符串翻译状态。<br>code：未翻译。<br>translate：翻译未验证。<br>LT：翻译已验证。<br>customer：用户定制字符串。 |

### 使用约束

可翻译特性使能范围：base目录下string、strarray、plural类型资源。

```text
resources
|---base
|   |---element
|   |   |---string.json
|   |   |---strarray.json
|   |   |---plural.json
```

### 示例

string资源配置attr属性示例如下：

```json
{
  "string": [
    {
      "name": "string1",
      "value": "1",
      "attr": {
        "translatable": false
      }
    },
    {
      "name": "string2",
      "value": "Hello world!",
      "attr": {
        "translatable": true,
        "priority": "LT"
      }
    }
  ]
}
```

## 资源访问

### 应用资源

定义在资源文件中的每个资源会在新建项目时生成唯一的id值。这些资源名称与对应id的映射储存在cj_res_entry模块的cj_res_entry包中，包含sys和app两个主要类，分别对应系统默认的资源和开发者可修改的resource目录资源。

- 对于资源，在工程中通过`import kit.LocalizationKit.*`引入资源管理模块，再通过"@r(app.type.name)"形式调用具体内容。其中，app为resources目录中定义的资源；type为资源类型或资源的存放位置；name为资源名，开发者定义资源时确定。

  对于string.json中使用多个占位符的情况，通过@r(app.string.label, 'aaa', 1, 1.0)形式访问。

- 对于rawfile目录资源，通过"@rawfile("filename")"形式引用。其中，filename为rawfile目录下文件的相对路径，文件名需要包含后缀，路径开头不能以"/"开头。

- 对于rawfile目录的descriptor，可通过资源管理的getRawFd接口引用，其返回值descriptor.fd为hap包的fd。此时，访问rawfile文件需要结合{fd, offset, length}一起使用。

资源组目录下的“资源文件示例”显示了.json文件内容，包含color.json文件、string.json文件和plural.json文件，访问应用资源时需先了解.json文件的使用规范。

<!-- compile -->

```cangjie
Text(@r(app.string.string_hello))
  .fontColor(@r(app.color.color_hello))
  .fontSize(@r(app.float.font_hello))

// 引用string.json资源，@r的第二个参数用于替换%1$s，value为"We will arrive at five of the clock"
Text(@r(app.string.message_arrive, "five of the clock"))
  .fontColor(@r(app.color.color_hello))
  .fontSize(@r(app.float.font_hello))

// 引用plural$资源，第一个指定plural资源，第二个参数指定单复数的数量quantity，此处第三个数字为对%d的替换
// 单数下value为"5 apple"，复数下value为"5 apples"
Text(@r(app.plural.eat_apple, 5, 5))
  .fontColor(@r(app.color.color_hello))
  .fontSize(@r(app.float.font_hello))

Image(@r(app.media.my_background_image)) // media资源的@r引用

Image(@rawfile("test.png")) // rawfile@r引用rawfile目录下图片

Image(@rawfile("newDir/newTest.png")) // rawfile@r引用rawfile目录下图片
```

### 系统资源

系统资源包含色彩、圆角、字体、间距、字符串及图片等。通过使用系统资源，不同的开发者可以开发出具有相同视觉风格的应用。

开发者可以通过`@r(sys.type.resource_id)`的形式引用系统资源。sys代表是系统资源；type代表资源类型，可以取“color”、“float”、“string”、“media”；resource_id代表资源id。

<!-- compile -->

```cangjie
Text("Hello")
  .fontColor(@r(sys.color.ohos_id_color_emphasize))
  .fontSize(@r(sys.float.ohos_id_text_size_headline1))
  .fontFamily(@r(sys.string.ohos_id_text_font_family_medium))
  .backgroundColor(@r(sys.color.ohos_id_color_palette_aux1))

Image(@r(sys.media.ohos_app_icon))
  .border({
    color: @r(sys.color.ohos_id_color_palette_aux1),
    radius: @r(sys.float.ohos_id_corner_radius_button), width: 2
  })
  .margin({
    top: @r(sys.float.ohos_id_elements_margin_horizontal_m),
    bottom: @r(sys.float.ohos_id_elements_margin_horizontal_l)
  })
  .height(200)
  .width(300)
```

## 资源匹配

应用使用某资源时，系统会根据当前设备状态优先从相匹配的限定词目录中寻找该资源。只有当resources目录中没有与设备状态匹配的限定词目录，或者在限定词目录中找不到该资源时，才会去base目录中查找。rawfile是原始文件目录，不会根据设备状态去匹配不同的资源。

限定词目录与设备状态的匹配规则如下：

- 在为设备匹配对应的资源文件时，限定词目录匹配的优先级从高到低依次为：移动国家码和移动网络码 > 区域（可选组合：语言、语言_文字、语言_国家或地区、语言_文字_国家或地区）> 横竖屏 > 设备类型 > 颜色模式 > 屏幕密度。

- 如果限定词目录中包含移动国家码和移动网络码、语言、文字、横竖屏、设备类型、颜色模式限定词，则对应限定词的取值必须与当前的设备状态完全一致，该目录才能够参与设备的资源匹配。例如，限定词目录“zh_CN-car-ldpi”不能参与“en_US”设备的资源匹配。

应用界面加载资源规则，更多请参考国际化和本地化文档。

## 限制与说明

- 当前资源名称不能使用仓颉语言保留关键字，例如func和main等。仓颉保留关键字，参见<!--RP1-->[《仓颉编程语言开发指南》-附录-关键字](https://gitcode.com/Cangjie/cangjie_docs/blob/main/docs/dev-guide/source_zh_cn/Appendix/keyword.md)<!--RP1End-->章节。
- 应用资源中的color不支持透明色。当color.json中传入"#00000000"（透明色）时，会被处理为黑色（#000000），即不提供透明色的能力。如需使用透明色，请在应用开发程序中调用[Color.Transparent](../../reference/arkui-cj/cj-common-types.md#static-let-transparent)设置透明色。