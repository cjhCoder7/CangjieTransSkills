# 使用HiLog打印日志

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在应用开发过程中，可在关键代码处输出日志信息。在运行应用后，通过查看日志信息来分析应用执行情况（如应用是否正常运行、代码运行时序、运行逻辑分支是否正常等）。

## 接口说明

HiLog中定义了DEBUG、INFO、WARN、ERROR、FATAL五种日志级别，并提供了对应的方法输出不同级别的日志，接口如下表所示，具体说明可查阅[API参考文档](../reference/PerformanceAnalysisKit/cj-apis-hilog.md)。

| 接口名 | 功能描述 |
| -------- | -------- |
| isLoggable(domain: UInt32, tag: String, level: LogLevel): Bool | 在打印日志前调用该接口，检查指定领域标识、日志标识和级别的日志是否可以打印。 |
| debug(domain: UInt32, tag: String, format: String, args: Array\<String>): Unit | 输出DEBUG级别日志。仅用于应用/服务调试。<br/>在DevEco Studio的terminal窗口或cmd里，通过命令“hdc shell hilogcat”设置可打印日志的等级为DEBUG。 |
| info(domain: UInt32, tag: String, format: String, args: Array\<String>): Unit | 输出INFO级别日志。表示普通的信息。 |
| warn(domain: UInt32, tag: String, format: String, args: Array\<String>): Unit | 输出WARN级别日志。表示存在警告。 |
| error(domain: UInt32, tag: String, format: String, args: Array\<String>): Unit | 输出ERROR级别日志。表示存在错误。 |
| fatal(domain: UInt32, tag: String, format: String, args: Array\<String>): Unit | 输出FATAL级别日志。表示出现致命错误、不可恢复错误。 |

### 参数解析

> **说明：**
>
> - isLoggable()和具体日志打印接口使用的domain和tag应保持一致。
>
> - isLoggable()使用的level，应和具体日志打印接口级别保持一致。

- **domain**：用于指定输出日志所对应的业务领域，取值范围为0x0000~0xFFFF，开发者可以根据需要进行自定义。

- **tag**：用于指定日志标识，可以为任意字符串，建议标识调用所在的类或者业务行为。tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。

- **level**：用于指定日志级别。取值见[LogLevel](../reference/PerformanceAnalysisKit/cj-apis-hilog.md#enum-loglevel)。

- **format**：格式字符串，用于日志的格式化输出。

- **args**: 格式化字符串的参数。

## 约束与限制

日志最多打印4096字节，超出限制文本将被截断。

## 开发示例

在按钮中增加一个单击事件，单击按钮时打印一条日志。

1. 新建一个工程，选择“[Cangjie] Empty Ability”。

2. 在**Project**窗口单击entry &gt; src &gt; main &gt; cangjie，打开工程中的index.cj文件，添加一个按钮，单击按钮打印日志。

   示例代码如下：

   <!-- compile -->

   ```cangjie
    // index.cj

    import kit.PerformanceAnalysisKit.*
    import kit.ArkUI.Button

    @Entry
    @Component
    class EntryView {
        @State
        var message: String = "Hello World"

        func build() {
            Row {
                Column {
                    Button(this.message)
                        .fontSize(50)
                        .fontWeight(FontWeight.Bold)
                        .onClick ({
                            evt => this.message = "Hello Cangjie"
                            Hilog.isLoggable(0xFF00, "testTag", LogLevel.Info)
                            Hilog.info(0xFF00, "testTag", "hello world")
                            // 设置应用日志最低打印级别，设置完成后，低于Warn级别的日志将无法打印
                            Hilog.info(0x0000, 'testTag', 'this is an info level log')
                            Hilog.error(0x0000, 'testTag', 'this is an error level log')
                        })
                }.width(100.percent)
            }.height(100.percent)
        }
    }
   ```

   以输出一条INFO级别的信息为例，表示输出一条普通信息，格式字符串为：

   ```txt
   hello world
   ```

3. 在真机上运行该工程，单击应用/服务界面上的“Next”按钮。

4. 在DevEco Studio的底部，切换到“Log”窗口，设置日志的过滤条件。

   选择当前的设备及进程，日志级别选择Verbose，搜索内容设置为“testTag”。此时窗口仅显示符合条件的日志。

   打印日志结果为:

   ```txt
   01-02 08:18:24.947   30988-30988   A0ff00/testTag                  com.example.hilogdemo  I     hello World
   01-02 08:18:24.947   30988-30988   A00000/testTag                  com.example.hilogdemo  E     this is an error level log
   ```
