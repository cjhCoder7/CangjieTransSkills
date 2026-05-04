package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class MTProtoClientBehaviorTests {
    @TestCase
    public func initializeShouldCreateAuthKeyAndPersistSessionState(): Unit {
        let client = MTProtoClient()

        client.initialize().get()

        let session = SessionManager.getSession(Int32(2))
        assertEqual("initialize 后 authKeyState 应为 Created", "", true, isCreatedState(session.authKeyState))
        assertOptionalBytesLength("initialize 后 authKey 长度应稳定为 32", session.authKey, 32)
        assertOptionalBytesLength("initialize 后 authKeyId 长度应稳定为 8", session.authKeyId, 8)
        assertOptionalBytesLength("initialize 后 serverSalt 长度应稳定为 8", session.serverSalt, 8)
        assertEqual("saveSession 应为握手后的 session 补齐 sessionId", "", false, session.sessionId.isNone())
    }

    @TestCase
    public func sendRequestShouldReturnLoopbackPayloadAfterInitConnection(): Unit {
        let client = MTProtoClient()
        let payload: Array<UInt8> = [0x21, 0x43, 0x65, 0x87]

        client.initialize().get()
        let response = client.sendRequest(payload).get()

        assertBytesEqual("sendRequest 应在当前 loopback harness 下返回原始 payload", payload, response)
    }

    @TestCase
    public func getMTProtoClientShouldReuseSingletonInstanceForCallbackDispatch(): Unit {
        let first = getMTProtoClient()
        let second = getMTProtoClient()
        let recorder = PayloadRecorder()
        let payload: Array<UInt8> = [0xaa, 0xbb, 0xcc]

        first.setUpdateCallback({ data: Array<UInt8> => recorder.record(data) })
        second.onData(payload)

        assertEqual("singleton 回调只应收到一次 payload", "", 1, recorder.count())
        assertBytesEqual("两次 getter 应复用同一实例的 callback 状态", payload, recorder.lastPayload())
    }
}

class PayloadRecorder {
    private var countValue: Int64 = 0
    private var lastPayloadValue: Array<UInt8> = []

    public func record(data: Array<UInt8>): Unit {
        this.countValue = this.countValue + 1
        this.lastPayloadValue = cloneRecorderBytes(data)
    }

    public func count(): Int64 {
        this.countValue
    }

    public func lastPayload(): Array<UInt8> {
        cloneRecorderBytes(this.lastPayloadValue)
    }
}

func cloneRecorderBytes(data: Array<UInt8>): Array<UInt8> {
    Array<UInt8>(data.size, { index: Int64 => data[index] })
}

func isCreatedState(state: AuthKeyState): Bool {
    match (state) {
        case AuthKeyState.Created => true
        case _ => false
    }
}

func assertOptionalBytesLength(message: String, value: ?Array<UInt8>, expectedLength: Int64): Unit {
    match (value) {
        case Some(bytes) => assertEqual(message, "", expectedLength, bytes.size)
        case None => assertEqual("${message} option", "", true, false)
    }
}
