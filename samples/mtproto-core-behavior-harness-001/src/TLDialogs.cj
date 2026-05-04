package core.mtproto

/**
 * TLUser defines the contract for a Telegram User object.
 * Properties are exposed as getters to comply with Cangjie interface constraints.
 */
public interface TLUser {
    func getId(): Int64
    func getAccessHash(): Option<Int64>
    func getFirstName(): Option<String>
}

/**
 * Internal implementation holding the storage for TLUser.
 * This class is not part of the public API surface.
 */
internal class TLUserImpl <: TLUser {
    private let id: Int64
    private let accessHash: Option<Int64>
    private let firstName: Option<String>

    public init(id: Int64, accessHash: Option<Int64>, firstName: Option<String>) {
        this.id = id
        this.accessHash = accessHash
        this.firstName = firstName
    }

    public func getId(): Int64 {
        this.id
    }

    public func getAccessHash(): Option<Int64> {
        this.accessHash
    }

    public func getFirstName(): Option<String> {
        this.firstName
    }
}

/**
 * TLChannel defines the contract for a Telegram Channel object.
 */
public interface TLChannel {
    func getId(): Int64
    func getAccessHash(): Option<Int64>
}

/**
 * Internal implementation holding the storage for TLChannel.
 */
internal class TLChannelImpl <: TLChannel {
    private let id: Int64
    private let accessHash: Option<Int64>

    public init(id: Int64, accessHash: Option<Int64>) {
        this.id = id
        this.accessHash = accessHash
    }

    public func getId(): Int64 {
        this.id
    }

    public func getAccessHash(): Option<Int64> {
        this.accessHash
    }
}
