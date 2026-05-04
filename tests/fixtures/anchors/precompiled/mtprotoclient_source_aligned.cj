package core.mtproto

import std.collection.*

class RPCCallback {
    public var resolve: (Array<UInt8>) -> Unit
    public var reject: (Error) -> Unit
    public var timeoutId: Int64

    public init(resolve: (Array<UInt8>) -> Unit, reject: (Error) -> Unit, timeoutId: Int64) {
        this.resolve = resolve
        this.reject = reject
        this.timeoutId = timeoutId
    }
}

public class MTProtoClient <: TransportCallback {
    private var transportManager: TransportManager
    private var session: SessionInfo
    private var pendingRPCs: HashMap<String, RPCCallback> = HashMap<String, RPCCallback>()
    private var updateCallback: ?((Array<UInt8>) -> Unit) = None
    private var connectionInitialized: Bool = false

    public init() {
        this.transportManager = TransportManager()
        let dcId = configuredDcId()
        this.session = SessionManager.getSession(dcId)
    }

    public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {
        this.updateCallback = Some(callback)
    }

    public func initialize(): Future<Unit> {
        return initialize(false)
    }

    public func initialize(forceNewAuthKey: Bool): Future<Unit> {
        spawn {
            let transport = this.transportManager.getTransport()
            transport.setCallback(this)

            if (forceNewAuthKey) {
                this.session.authKey = None
                this.session.authKeyState = AuthKeyState.None
            }

            transport.connect().get()

            if (this.session.authKey.isNone()) {
                this.createAuthKey().get()
            }
        }
    }

    private func createAuthKey(): Future<Unit> {
        spawn {
            let transport = this.transportManager.getTransport()
            let creator = AuthKeyCreator(transport)
            let result = creator.createAuthKey().get()
            this.session.authKey = result.authKey
            this.session.authKeyId = result.authKeyId
            this.session.serverSalt = result.serverSalt
            this.session.authKeyState = AuthKeyState.Created
            SessionManager.saveSession(this.session)
            ()
        }
    }

    public func sendRequest(data: Array<UInt8>): Future<Array<UInt8>> {
        spawn {
            if (!this.connectionInitialized) {
                this.initConnection().get()
            }
            let waiter = RPCWaiter()
            let key = "${this.pendingRPCs.size}"
            this.pendingRPCs[key] = RPCCallback(
                { arr: Array<UInt8> => waiter.setResult(arr) },
                { err: Error => waiter.setError(err) },
                Int64(0)
            )
            this.transportManager.getTransport().send(data)
            waiter.takeResult()
        }
    }

    private func initConnection(): Future<Unit> {
        spawn {
            let getConfig = HelpGetConfig()
            let initConn = InitConnection()
            initConn.query = getConfig.toBytes()
            let invokeWithLayer = InvokeWithLayer()
            invokeWithLayer.query = initConn.toBytes()
            let payload = invokeWithLayer.toBytes()
            this.transportManager.getTransport().send(payload).get()
            this.connectionInitialized = true
        }
    }

    public func onConnected(): Unit {}

    public func onDisconnected(): Unit {}

    public func onData(data: Array<UInt8>): Unit {
        let maybeCompressed = decompress(data)
        dispatchUpdate(maybeCompressed)
        resolveFirstRPC(maybeCompressed)
    }

    private func dispatchUpdate(data: Array<UInt8>): Unit {
        match (this.updateCallback) {
            case Some(cb) => cb(data)
            case None => ()
        }
    }

    private func resolveFirstRPC(data: Array<UInt8>): Unit {
        for ((_, rpc) in this.pendingRPCs) {
            rpc.resolve(data)
            return
        }
    }

    public func onError(error: Error): Unit {
        println("[MTProtoClient] transport error: ${error}")
    }
}

internal class RPCWaiter {
    private var result: ?Array<UInt8> = None
    private var error: ?Error = None
    private var completed: Bool = false

    public func setResult(arr: Array<UInt8>): Unit {
        this.result = Some(arr)
        this.completed = true
    }

    public func setError(err: Error): Unit {
        this.error = Some(err)
        this.completed = true
    }

    public func takeResult(): Array<UInt8> {
        while (!this.completed) {}
        match (this.error) {
            case Some(e) => throw e
            case None => match (this.result) {
                case Some(arr) => arr
                case None => []
            }
        }
    }
}

private var clientSingleton: ?MTProtoClient = None

private func initSingleton(): MTProtoClient {
    let client = MTProtoClient()
    clientSingleton = Some(client)
    client
}

public func getMTProtoClient(): MTProtoClient {
    match (clientSingleton) {
        case Some(client) => client
        case None => initSingleton()
    }
}
