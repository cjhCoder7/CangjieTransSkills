## 公共 API 清单

### errorstrategy 包

| 源签名 | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `interface ErrorStrategy` | `public interface ErrorStrategy` | |
| `ErrorStrategy.Result RETRY/SKIP/STOP` | `public enum Result { RETRY, SKIP, STOP }` | 枚举改为独立 enum |
| `Result handleError(LocalMessage, Exception)` | `func handleError(localMessage: LocalMessage, ex: Exception): Result` | |
| `class Fail implements ErrorStrategy` | `public class Fail <: ErrorStrategy` | |

### local 包

| 源签名 | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `interface LocalMessage` | `public interface LocalMessage` | |
| `String getMessageId()` | `func getMessageId(): String` | |
| `String getFromHeader()` | `func getFromHeader(): String` | |
| `List<String> getFolders()` | `func getFolders(): ArrayList<String>` | |
| `byte[] getRawContent()` | `func getRawContent(): Array<UInt8>` | |
| `boolean isUnread()` | `func isUnread(): Bool` | |
| `boolean isStarred()` | `func isStarred(): Bool` | |
| `interface LocalStorage extends Iterable<LocalMessage>` | `public interface LocalMessageStorage <: Iterable<LocalMessage>` | 避免与 std 库冲突 |
| `abstract class JavaxMailStorage implements LocalStorage` | `public abstract class MailStorage <: LocalMessageStorage` | 去掉 javax 前缀 |
| `class RuntimeMessagingException extends RuntimeException` | `public class MessagingException <: Exception` | 简化命名 |
| `interface MailProvider<T>` | `public interface MailProvider<T>` | |
| `T get() throws MessagingException` | `func get(): T` | 仓颉用异常而非 checked exception |

### local.thunderbird 包

| 源签名 | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `class XMozillaStatus` | `public class XMozillaStatus` | |
| `boolean isRead()` | `func isRead(): Bool` | |
| `boolean isMarked()` | `func isMarked(): Bool` | |
| `class XMozillaStatusParser` | `public class XMozillaStatusParser` | |
| `XMozillaStatus parse(JavaxMailMessage)` | `func parse(message: MailMessage): XMozillaStatus` | |
| `class ThunderbirdLocalMessage implements LocalMessage` | `public class ThunderbirdLocalMessage <: LocalMessage` | |
| `class ThunderbirdMailStorage extends JavaxMailStorage` | `public class ThunderbirdMailStorage <: MailStorage` | |
| `class ThunderbirdMailbox implements MailProvider<LocalStorage>` | `public class ThunderbirdMailbox <: MailProvider<LocalMessageStorage>` | |

### gmail 包

| 源签名 | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `class GmailSyncer` | `public class GmailSyncer` | |
| `void init()` | `func init(): Unit` | |
| `void sync(List<LocalMessage>)` | `func sync(messages: ArrayList<LocalMessage>): Unit` | |
| `class Mailbox` | `public class Mailbox` | |
| `class GmailService` | `public class GmailService` | |
| `class User` | `public class User` | AutoValue → 普通类 |
| `String getEmailAddress()` | `func getEmailAddress(): String` | |
| `String getEmailAddressAsKey()` | `func getEmailAddressAsKey(): String` | |
| `class UnsuccessfulResponseHandlerChainer` | `public class ResponseHandlerChainer` | 简化命名 |
| `class Authorizer` | `public class Authorizer` | |

### importer 包

| 源签名 | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `class CommandLineArguments` | `public class CommandLineArguments` | |
| `String mailboxFileName` | `var mailboxFileName: Option<String>` | |
| `String user` | `var user: String` | 默认 "me" |
| `Integer maxMessages` | `var maxMessages: Option<Int64>` | |
| `String clientSecretResourcePath` | `var clientSecretResourcePath: String` | |
| `class Importer` | `public class Importer` | |
| `void importMail()` | `func importMail(): Unit` | |
| `class FlagsModule` | 删除 | 仓颉无 Guice，DI 由构造函数处理 |

## 内部 API（不对外导出）

- `JavaxMailFolder` → `MailFolder`（内部包装类，仅 Thunderbird 模块内部使用）
- `JavaxMailMessage` → `MailMessage`（内部包装类）
- `JavaxMailStorage.FolderIterator` → `MailStorage.FolderIterator`（内部迭代器）
- `CorruptEmailFixer` → 保留但不导出（原文标注 not actually used）
- `FakeGmail` → 保留到测试包
