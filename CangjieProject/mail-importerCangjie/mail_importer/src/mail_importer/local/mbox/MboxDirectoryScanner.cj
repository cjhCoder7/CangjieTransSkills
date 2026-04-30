package mail_importer.local.mbox

import std.collection.ArrayList
import std.collection.HashMap
import std.fs.*
import mail_importer.local.FolderConstants

// 扫描 Thunderbird 邮件目录结构
// Thunderbird 使用 mbox 文件存储邮件，.sbd 子目录存储子文件夹
public class MboxDirectoryScanner {
    let parser: MboxParser

    public init() {
        this.parser = MboxParser()
    }

    public func scan(rootPath: String): MboxMailFolder {
        let rootName = getPathLastName(rootPath)
        let rootFolder = MboxMailFolder(rootName, rootPath,
            FolderConstants.HOLDS_MESSAGES | FolderConstants.HOLDS_FOLDERS)
        scanDirectory(rootPath, rootFolder, rootPath)
        rootFolder
    }

    // 递归扫描目录
    func scanDirectory(dirPath: String, parentFolder: MboxMailFolder, rootPath: String): Unit {
        // 用 walk 遍历目录
        let fileInfos = try {
            Directory.readFrom(dirPath)
        } catch (e: Exception) {
            return  // 目录不可读则跳过
        }

        // 先收集 mbox 文件和 .sbd 目录
        let mboxFiles = ArrayList<String>()
        let sbdDirs = HashMap<String, String>()  // baseName -> sbdPath

        for (info in fileInfos) {
            let entryPath = info.path.toString()
            let name = getPathLastName(entryPath)
            if (name.endsWith(".sbd")) {
                // .sbd 子目录，如 "Inbox.sbd"
                let baseName = name[0..(name.size - 4)]  // 去掉 ".sbd"
                sbdDirs[baseName] = entryPath
            } else if (name.endsWith(".msf")) {
                // 索引文件，忽略
            } else {
                // 普通文件，可能是 mbox 文件
                mboxFiles.add(entryPath)
            }
        }

        // 处理每个 mbox 文件
        for (mboxPath in mboxFiles) {
            let fileName = getPathLastName(mboxPath)
            let relativePath = relativizePath(mboxPath, rootPath)

            // 解析 mbox 文件
            let messages = parseMboxFile(mboxPath)

            var folderType = FolderConstants.HOLDS_MESSAGES
            // 如果有对应的 .sbd 目录，也标记为 HOLDS_FOLDERS
            if (sbdDirs.contains(fileName)) {
                folderType = folderType | FolderConstants.HOLDS_FOLDERS
            }

            let folder = MboxMailFolder(fileName, relativePath, folderType)
            for (msg in messages) {
                folder.messages.add(msg)
            }

            // 递归处理子目录
            if (let Some(subDirPath) <- sbdDirs.get(fileName)) {
                scanDirectory(subDirPath, folder, rootPath)
            }

            parentFolder.subFolders.add(folder)
        }
    }

    // 解析单个 mbox 文件
    func parseMboxFile(path: String): ArrayList<MboxRawMessage> {
        let content = File.readFrom(path)
        parser.parseBytes(bytesToUInt8Array(content))
    }

    // Array<Byte> -> Array<UInt8>
    func bytesToUInt8Array(bytes: Array<Byte>): Array<UInt8> {
        let result = ArrayList<UInt8>()
        for (b in bytes) {
            result.add(UInt8(b))
        }
        result.toArray()
    }

    // 获取路径最后一部分
    func getPathLastName(path: String): String {
        if (let Some(idx) <- path.lastIndexOf("/")) {
            if (idx + 1 < path.size) {
                path[idx + 1..]
            } else {
                path
            }
        } else {
            path
        }
    }

    // 计算相对路径
    func relativizePath(fullPath: String, rootPath: String): String {
        if (fullPath.startsWith(rootPath) && fullPath.size > rootPath.size) {
            let start = rootPath.size + 1
            if (start < fullPath.size) {
                fullPath[start..]
            } else {
                fullPath
            }
        } else {
            fullPath
        }
    }
}
