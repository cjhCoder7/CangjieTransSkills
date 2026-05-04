package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class MTProtoConfigBehaviorTests {
    @TestCase
    public func saveSessionShouldPersistLifecycleStateAndGenerateSessionId(): Unit {
        let authKey: Array<UInt8> = [0x11, 0x22]
        let authKeyId: Array<UInt8> = [0x33, 0x44]
        let serverSalt: Array<UInt8> = [0x55, 0x66]
        let saved = SessionInfo(
            7,
            Some(authKey),
            Some(authKeyId),
            Some(serverSalt),
            AuthKeyState.Created,
            None,
            9
        )

        SessionManager.saveSession(saved)
        let restored = SessionManager.getSession(7)

        assertEqual("save/get 后 dcId 应保持一致", "", 7, restored.dcId)
        assertEqual("save/get 后 seqNo 应保持一致", "", 9, restored.seqNo)
        assertEqual(
            "save/get 后 authKeyState 应保持 Created",
            "",
            true,
            isCreatedState(restored.authKeyState)
        )
        assertOptionalBytesEqual("save/get 后 authKey 应保持一致", Some(authKey), restored.authKey)
        assertOptionalBytesEqual("save/get 后 authKeyId 应保持一致", Some(authKeyId), restored.authKeyId)
        assertOptionalBytesEqual("save/get 后 serverSalt 应保持一致", Some(serverSalt), restored.serverSalt)
        assertEqual("saveSession 应为缺失的 sessionId 补齐生命周期标识", "", false, restored.sessionId.isNone())
    }
}

func isCreatedState(state: AuthKeyState): Bool {
    match (state) {
        case AuthKeyState.Created => true
        case _ => false
    }
}

func assertOptionalBytesEqual(message: String, expected: ?Array<UInt8>, actual: ?Array<UInt8>): Unit {
    match (expected) {
        case Some(left) => match (actual) {
            case Some(right) => assertBytesEqual(message, left, right)
            case None => assertEqual("${message} option", "", true, false)
        }
        case None => match (actual) {
            case Some(_) => assertEqual("${message} option", "", true, false)
            case None => assertEqual("${message} option", "", true, true)
        }
    }
}
