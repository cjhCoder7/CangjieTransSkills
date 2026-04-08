# 本地化时区名称

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 使用场景

在多语言环境中，不同地区的用户对时区的称呼可能有所不同。例如，在中文环境中，中部时区称为“中部时区”，而在英文环境中，则称为“Central Time Zone”。为了确保时区展示符合当地人的语言使用习惯，需要本地化时区名称。

## 开发步骤

接口具体使用方法和说明请参见[getDisplayName](../reference/LocalizationKit/cj-apis-i18n.md#func-getdisplaynamestring)的API接口文档。

1. 导入模块。

   <!-- compile -->

   ```cangjie
   import kit.LocalizationKit.*
   ```

2. 本地化时区名称，以美洲/圣保罗为例。

   <!-- compile -->

   ```cangjie
    let calendar: Calendar = getCalendar('America/Sao_Paulo')
    let timezone = calendar.getTimeZone()
    let timeZoneName: String = calendar.getDisplayName(timezone)
   ```
