package core.mtproto

import std.collection.*

public enum AuthKeyState {
    | None
    | Created
}

public class SessionInfo {
    public let dcId: Int32
    public var authKey: ?Array<UInt8>
    public var authKeyId: ?Array<UInt8>
    public var serverSalt: ?Array<UInt8>
    public var authKeyState: AuthKeyState
    public var sessionId: ?Array<UInt8>
    public var seqNo: Int32

    public init(
        dcId: Int32,
        authKey: ?Array<UInt8>,
        authKeyId: ?Array<UInt8>,
        serverSalt: ?Array<UInt8>,
        authKeyState: AuthKeyState,
        sessionId: ?Array<UInt8>,
        seqNo: Int32
    ) {
        this.dcId = dcId
        this.authKey = authKey
        this.authKeyId = authKeyId
        this.serverSalt = serverSalt
        this.authKeyState = authKeyState
        this.sessionId = sessionId
        this.seqNo = seqNo
    }

    public func generateSessionId(): Unit {
        this.sessionId = Some(buildSessionIdBytes(this))
    }
}

public class MTProtoConfig {
    public static let USE_TEST_DC: Bool = true
    public static let API_ID: Int32 = 17349
    public static let CONNECTION_TIMEOUT: Int32 = 10000
}

private let SESSION_STORE = HashMap<Int32, SessionInfo>()
private var USE_TEST_DC_RUNTIME_FLAG: Bool = true

public class SessionManager {
    public static func getSession(dcId: Int32): SessionInfo {
        match (SESSION_STORE.get(dcId)) {
            case Some(saved) => cloneSession(saved)
            case None => defaultSession(dcId)
        }
    }

    public static func getSession(dcId: Int64): SessionInfo {
        return getSession(Int32(dcId))
    }

    public static func saveSession(_session: SessionInfo): Unit {
        let snapshot = cloneSession(_session)
        if (snapshot.sessionId.isNone()) {
            snapshot.generateSessionId()
        }
        SESSION_STORE[snapshot.dcId] = snapshot
    }
}

func configuredDcId(): Int32 {
    if (USE_TEST_DC_RUNTIME_FLAG) {
        2
    } else {
        1
    }
}

func defaultSession(dcId: Int32): SessionInfo {
    let session = SessionInfo(
        dcId,
        None,
        None,
        None,
        AuthKeyState.None,
        None,
        0
    )
    if (dcId == 2) {
        USE_TEST_DC_RUNTIME_FLAG = true
    }
    session
}

func cloneSession(session: SessionInfo): SessionInfo {
    SessionInfo(
        session.dcId,
        cloneOptionalBytes(session.authKey),
        cloneOptionalBytes(session.authKeyId),
        cloneOptionalBytes(session.serverSalt),
        session.authKeyState,
        cloneOptionalBytes(session.sessionId),
        session.seqNo
    )
}

func cloneOptionalBytes(value: ?Array<UInt8>): ?Array<UInt8> {
    match (value) {
        case Some(bytes) => Some(Array<UInt8>(bytes.size, { index: Int64 => bytes[index] }))
        case None => None
    }
}

func buildSessionIdBytes(session: SessionInfo): Array<UInt8> {
    [
        UInt8(Int64(session.dcId) & 0xff),
        UInt8(Int64(session.seqNo) & 0xff),
        UInt8(authStateMarker(session.authKeyState)),
        UInt8(optionalBytesLength(session.authKey) & 0xff),
        UInt8(optionalBytesLength(session.authKeyId) & 0xff),
        UInt8(optionalBytesLength(session.serverSalt) & 0xff),
        UInt8(optionalBytesChecksum(session.authKey) & 0xff),
        UInt8(optionalBytesChecksum(session.serverSalt) & 0xff)
    ]
}

func authStateMarker(state: AuthKeyState): Int64 {
    match (state) {
        case AuthKeyState.Created => 1
        case _ => 0
    }
}

func optionalBytesLength(value: ?Array<UInt8>): Int64 {
    match (value) {
        case Some(bytes) => bytes.size
        case None => 0
    }
}

func optionalBytesChecksum(value: ?Array<UInt8>): Int64 {
    match (value) {
        case Some(bytes) => checksumBytes(bytes)
        case None => 0
    }
}

func checksumBytes(bytes: Array<UInt8>): Int64 {
    var checksum: Int64 = 0
    for (byte in bytes) {
        checksum = (checksum + Int64(byte)) & 0xff
    }
    checksum
}
