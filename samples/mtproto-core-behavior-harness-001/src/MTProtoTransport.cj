package core.mtproto

public enum TransportState {
    | Disconnected
    | Connecting
    | Connected
    | Error
}

public interface TransportCallback {
    func onConnected(): Unit
    func onDisconnected(): Unit
    func onData(data: Array<UInt8>): Unit
    func onError(error: Error): Unit
}

public class TCPTransport {
    private var state: TransportState = TransportState.Disconnected
    private var callback: ?TransportCallback = None

    public init() {}

    public func setCallback(callback: TransportCallback): Unit {
        this.callback = Some(callback)
    }

    public func clearCallback(): Unit {
        this.callback = None
    }

    public func connect(): Future<Unit> {
        spawn {
            if (isConnectedState(this.state)) {
                ()
            } else {
                this.state = TransportState.Connected
                match (this.callback) {
                    case Some(cb) => cb.onConnected()
                    case None => ()
                }
                ()
            }
        }
    }

    public func disconnect(): Future<Unit> {
        spawn {
            let wasConnected = isConnectedState(this.state)
            this.state = TransportState.Disconnected
            if (wasConnected) {
                match (this.callback) {
                    case Some(cb) => cb.onDisconnected()
                    case None => ()
                }
            }
            ()
        }
    }

    public func send(data: Array<UInt8>): Future<Unit> {
        spawn {
            if (!isConnectedState(this.state)) {
                throw IllegalStateException("Not connected")
            }
            let payload = cloneTransportBytes(data)
            match (this.callback) {
                case Some(cb) => cb.onData(payload)
                case None => ()
            }
            ()
        }
    }
}

public class TransportManager {
    private let transport: TCPTransport = TCPTransport()

    public init() {}

    public func getTransport(): TCPTransport {
        this.transport
    }
}

func cloneTransportBytes(data: Array<UInt8>): Array<UInt8> {
    Array<UInt8>(data.size, { index: Int64 => data[index] })
}

func isConnectedState(state: TransportState): Bool {
    match (state) {
        case TransportState.Connected => true
        case _ => false
    }
}
