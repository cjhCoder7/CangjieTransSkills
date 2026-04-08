# Font

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

注册自定义字体的信息。

> **说明：**
>
> 以下API需先使用[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)中的[getFont()](./cj-apis-uicontext-uicontext.md#func-getfont)方法获取Font实例，再通过此实例调用对应方法。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class Font

```cangjie
public class Font {}
```

**功能：** 字体类，提供字体注册、获取系统字体列表和根据字体名称获取字体信息等功能。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func getFontByName(String)

```cangjie
public func getFontByName(fontName: String): ?FontInfo
```

**功能：** 根据字体名称获取字体详细信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fontName|String|是|-|字体名称。|

**返回值：**

|类型|说明|
|:----|:----|
|?[FontInfo](#class-fontinfo)|返回字体信息，如果找不到对应字体则返回None。|

### func getSystemFontList()

```cangjie
public func getSystemFontList(): Array<String>
```

**功能：** 获取系统支持的字体列表。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|系统字体名称列表。|

### func registerFont(ResourceStr, ResourceStr)

```cangjie
public func registerFont(familyName!: ResourceStr, familySrc!: ResourceStr): Unit
```

**功能：** 在字体管理中注册自定义字体。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|familyName|[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** 字体名称。|
|familySrc|[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** 字体资源路径。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码|说明|
  |:----|:----|
  |401|Invalid input parameter|
  |100001|Internal error.|

## class FontInfo

```cangjie
public class FontInfo {
    public var path: String
    public var postScriptName: String
    public var fullName: String
    public var family: String
    public var subfamily: String
    public var weight: UInt32
    public var width: UInt32
    public var italic: Bool
    public var monoSpace: Bool
    public var symbolic: Bool
}
```

**功能：** 字体的详细信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var family

```cangjie
public var family: String
```

**功能：** 字体家族。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var fullName

```cangjie
public var fullName: String
```

**功能：** 字体完整名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var italic

```cangjie
public var italic: Bool
```

**功能：** 是否为斜体。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var monoSpace

```cangjie
public var monoSpace: Bool
```

**功能：** 是否为等宽字体。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var path

```cangjie
public var path: String
```

**功能：** 字体文件路径。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var postScriptName

```cangjie
public var postScriptName: String
```

**功能：** PostScript名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var subfamily

```cangjie
public var subfamily: String
```

**功能：** 字体子族名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var symbolic

```cangjie
public var symbolic: Bool
```

**功能：** 是否支持符号字体。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var weight

```cangjie
public var weight: UInt32
```

**功能：** 字体粗细。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: UInt32
```

**功能：** 字体宽度。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## 示例代码

### 示例1（注册自定义字体）

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource_manager.*

@Entry
@Component
class EntryView {
    protected func onAppear() {
        getUIContext().getFont().registerFont(
            familyName: "Deyihei",
            familySrc: "/resources/rawfile/SmileySans-Oblique.ttf"
        )
    }

    func build() {
        Row {
            Column {
                Text("HelloWorld").fontFamily("Deyihei")
                Text("HelloWorld")
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

![font1](figures/registerFont.png)

### 示例2（获取系统字体列表）

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hilog.*

@Entry
@Component
class EntryView {
    func build() {
        Row {
            Column {
                Button("HelloWorld")
                .onClick({evt =>
                    let list = getUIContext().getFont().getSystemFontList()
                    Hilog.info(0, "AppLogCj", "${list.size}")
                })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

![font2](figures/uicontextFont.PNG)

### 示例3（获取字体详细信息）

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hilog.*

@Entry
@Component
class EntryView {
    func build() {
        Row {
            Column {
                Button("HelloWorld")
                .onClick({evt =>
                    let info = getUIContext().getFont().getFontByName("HarmonyOS Sans Italic")
                    match (info) {
                        case Some(v) =>
                            Hilog.info(0, "AppLogCj", "${v.path}")
                            Hilog.info(0, "AppLogCj", "${v.postScriptName}")
                            Hilog.info(0, "AppLogCj", "${v.fullName}")
                            Hilog.info(0, "AppLogCj", "${v.family}")
                            Hilog.info(0, "AppLogCj", "${v.subfamily}")
                            Hilog.info(0, "AppLogCj", "${v.weight}")
                            Hilog.info(0, "AppLogCj", "${v.width}")
                            Hilog.info(0, "AppLogCj", "${v.italic}")
                            Hilog.info(0, "AppLogCj", "${v.monoSpace}")
                            Hilog.info(0, "AppLogCj", "${v.symbolic}")
                        case None => Hilog.error(0, "AppLogCj", "None")
                    }
                })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

![font2](./figures/uicontextFont2.PNG)
