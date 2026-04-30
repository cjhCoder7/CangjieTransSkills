package mail_importer.local

// 简易日志接口，替代 std.log.Logger
// TODO: 当 std.log 可用时替换为 Logger
public interface SimpleLogger {
    func fine(message: String): Unit
    func info(message: String): Unit
    func error(message: String): Unit
}

// 控制台输出的默认实现
public class ConsoleLogger <: SimpleLogger {
    let name: String

    public init(name: String) {
        this.name = name
    }

    public func fine(message: String): Unit {
        println("[FINE][${name}] ${message}")
    }

    public func info(message: String): Unit {
        println("[INFO][${name}] ${message}")
    }

    public func error(message: String): Unit {
        println("[ERROR][${name}] ${message}")
    }
}
