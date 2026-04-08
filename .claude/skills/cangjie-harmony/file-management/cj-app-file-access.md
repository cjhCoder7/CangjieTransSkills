# 应用文件访问

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

应用需要对应用文件目录下的应用文件进行查看、创建、读写、删除、移动、复制、获取属性等访问操作，下文介绍具体方法。

## 接口说明

开发者通过基础文件操作接口（[ohos.file_fs](../reference/CoreFileKit/cj-apis-file_fs.md)）实现应用文件访问能力，主要功能如下表所示。

| 接口名       | 功能                   | 接口类型 |
| ------------ | ---------------------- | -------- |
| access       | 检查文件是否存在       | 方法     |
| close        | 关闭文件               | 方法     |
| copyFile     | 复制文件               | 方法     |
| createStream | 基于文件路径打开文件流 | 方法     |
| listFile     | 列出文件夹下所有文件名 | 方法     |
| mkdir        | 创建目录               | 方法     |
| moveFile     | 移动文件               | 方法     |
| open         | 打开文件               | 方法     |
| read         | 从文件读取数据         | 方法     |
| rename       | 重命名文件或文件夹     | 方法     |
| rmdir        | 删除整个目录           | 方法     |
| stat         | 获取文件详细属性信息   | 方法     |
| unlink       | 删除单个文件           | 方法     |
| write        | 将数据写入文件         | 方法     |
| Stream.close | 关闭文件流             | 方法     |
| Stream.flush | 刷新文件流             | 方法     |
| Stream.write | 将数据写入流文件       | 方法     |
| Stream.read  | 从流文件读取数据       | 方法     |
| File.fd      | 获取文件描述符         | 属性     |
| OpenMode     | 设置文件打开标签       | 属性     |
| Filter       | 设置文件过滤配置项     | 类型     |

## 开发示例

在对应用文件开始访问前，开发者需要获取应用文件路径。以从AbilityContext获取HAP级别的文件路径为例进行说明，AbilityContext的获取方式请参见[获取UIAbility的上下文信息](../application-models/cj-uiability-usage.md#获取uiability的上下文信息)。

下面介绍几种常用操作示例。

### 新建并读写一个文件

以下示例代码演示了如何新建一个文件并对其读写。

<!-- compile -->

```cangjie
// xxx.cj
import kit.CoreFileKit.*
import kit.AbilityKit.*

// 见获取UIAbility的上下文信息章节
let context = getContext()
// 获取应用文件路径
let filesDir = context.filesDir

func createFile(): Unit {
    // 文件不存在时创建并打开文件，文件存在时打开文件
    let file = FileIo.open(filesDir + '/test.txt', mode: OpenMode.READ_WRITE | OpenMode.CREATE)
    // 写入一段内容至文件
    let writeLen = FileIo.write(file.fd, "Try to write str.")
    Hilog.info(1, "info", "The length of str is: ${writeLen}")
    let bufSize = 4096
    var readSize = 0
    // 创建一个大小为1024字节的Array<Byte>对象，用于存储从文件中读取的数据
    let array = Array<Byte>(1024, repeat: 0)
    // 设置读取的偏移量和长度
    let readOptions = ReadOptions(
        offset: readSize,
        length: UIntNative(bufSize)
    )
    // 读取文件内容到ArrayBuffer对象中，并返回实际读取的字节数
    let readLen = FileIo.read(file.fd, array, options: readOptions)
    Hilog.info(1, "info", "the content of file: ${String.fromUtf8(array[..readLen])}")
    // 关闭文件
    FileIo.close(file)
}
```

### 读取文件内容并写入到另一个文件

以下示例代码演示了如何从一个文件读写内容到另一个文件。

<!-- compile -->

```cangjie
// xxx.cj
import kit.CoreFileKit.*
import kit.AbilityKit.*

// 见获取UIAbility的上下文信息章节
let context = getContext()
// 获取应用文件路径
let filesDir = context.filesDir

func readWriteFile() {
    // 打开文件
    let srcFile = FileIo.open(filesDir + '/test.txt', mode: OpenMode.READ_WRITE | OpenMode.CREATE)
    let destFile = FileIo.open(filesDir + '/destFile.txt', mode: OpenMode.READ_WRITE | OpenMode.CREATE)
    // 读取源文件内容并写入至目的文件
    let bufSize = 4096
    var readSize = 0
    let buf = Array<Byte>(bufSize, repeat: 0)
    var readOptions = ReadOptions(
        offset: readSize,
        length: UIntNative(bufSize)
    )
    var readLen = FileIo.read(srcFile.fd, buf, options: readOptions)
    while (readLen > 0) {
        readSize += readLen
        let writeOptions = WriteOptions(
            length: UIntNative(readLen)
        )
        FileIo.write(destFile.fd, buf, options: writeOptions)
        readOptions.offset = readSize
        readLen = FileIo.read(srcFile.fd, buf, options: readOptions)
    }
    // 关闭文件
    FileIo.close(srcFile)
    FileIo.close(destFile)
}
```

> **说明：**
>
> 使用读写接口时，需注意可选项参数offset的设置。对于已存在且读写过的文件，文件偏移指针默认在上次读写操作的终止位置。

### 以流的形式读写文件

以下示例代码演示了如何使用流接口读取test.txt的文件内容并写入到destFile.txt文件中。

<!-- compile -->

```cangjie
// xxx.cj
import kit.CoreFileKit.*
import kit.AbilityKit.*

// 见获取UIAbility的上下文信息章节
let context = getContext()
// 获取应用文件路径
let filesDir = context.filesDir

func readWriteFileWithStream() {
    // 创建并打开输入文件流
    let inputStream = FileIo.createStream(filesDir + '/test.txt', 'r+')
    // 创建并打开输出文件流
    let outputStream = FileIo.createStream(filesDir + '/destFile.txt', "w+")

    let bufSize = 4096
    var readSize = 0
    let buf = Array<Byte>(bufSize, repeat: 0)
    var readOptions = ReadOptions(
        offset: readSize,
        length: UIntNative(bufSize)
    )
    // 以流的形式读取源文件内容并写入到目标文件
    var readLen = inputStream.read(buf, options: readOptions)
    readSize += readLen
    while (readLen > 0) {
        outputStream.write(buf[0..readLen])
        readOptions.offset = readSize
        readLen = inputStream.read(buf, options: readOptions)
        readSize += readLen
    }
    // 关闭文件流
    inputStream.close()
    outputStream.close()
}
```

> **说明：**
>
> 使用流接口时，需注意流的及时关闭。流接口不支持并发读写。

### 查看文件列表

以下示例代码演示了如何查看文件列表。

<!-- compile -->

```cangjie
import kit.CoreFileKit.*
import kit.PerformanceAnalysisKit.Hilog

// 见获取UIAbility的上下文信息章节
let context = getContext()
// 获取应用文件路径
let filesDir = context.filesDir

// 查看文件列表
func getListFile() {
    let listFileOption = ListFileOptions(
        recursion: false,
        listNum: 0,
        filter: Filter(
            suffix: [".png", ".jpg", ".txt"],
            displayName: ["test*"],
            fileSizeOver: 0,
            lastModifiedAfter: 10000.0
        )
    )
    let files = FileIo.listFile(filesDir, options: listFileOption)
    for (item in files) {
        Hilog.info(1, "info", "The name of file: ${item}")
    }
}
```
<!--Del-->
## 示例代码

[查询文件列表](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/FileManagement/FileList)
<!--DelEnd-->
