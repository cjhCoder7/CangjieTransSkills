# 支持单复数

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

翻译过程中，不同语言对名词或单位表达式的单复数格式要求有所不同，有些语言不区分单复数，而有些语言则有多种形式。例如，在英语中，名词支持单复数两种形式；而在中文中，名词不分单复数，通过量词来表达数量的不同。

国际上常用以下类别来区分单复数：

- zero：0或者0结尾
- one：单数或者1结尾
- two：2结尾
- few：数值较小的数
- many：数值较大的数
- other：其他情况

例如，在阿拉伯语中，单复数规则如下：

- zero：0
- one：1
- two：2
- few：3 ~ 10、103 ~ 110、1003...
- many：11 ~ 26、111、1011...
- other：100 ~ 102、200 ~ 202、1000、10000...

## 开发步骤

接口的具体使用方法请参见[getPluralStringValue](../reference/LocalizationKit/cj-apis-resource_manager.md#func-getpluralstringvalueuint32-int64)的API接口文档。
