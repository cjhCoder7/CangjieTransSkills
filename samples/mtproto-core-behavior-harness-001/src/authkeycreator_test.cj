package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class AuthKeyCreatorBehaviorTests {
    @TestCase
    public func createAuthKeyShouldFollowDeterministicPayloadFlow(): Unit {
        let transport = TCPTransport()
        let callback = RecordingTransportCallback()
        transport.setCallback(callback)
        transport.connect().get()

        let result = AuthKeyCreator(transport).createAuthKey().get()

        assertEqual("握手前必须先建立一次连接", "", 1, callback.connectedCount())
        assertEqual("createAuthKey 应发送三段握手 payload", "", 3, callback.dataCount())
        assertEqual("确定性握手不应触发 transport error", "", 0, callback.errorCount())
        assertBytesEqual("第一段 payload 必须是 req_pq_multi", expectedReqPqPayload(), callback.firstPayload())
        assertBytesEqual("第二段 payload 必须是 req_DH_params", expectedReqDhParamsPayload(), callback.secondPayload())
        assertBytesEqual("第三段 payload 必须是 set_client_DH_params", expectedSetClientDhParamsPayload(), callback.thirdPayload())
        assertEqual("authKey 长度必须稳定为 32", "", 32, result.authKey.size)
        assertEqual("authKeyId 长度必须稳定为 8", "", 8, result.authKeyId.size)
        assertEqual("serverSalt 长度必须稳定为 8", "", 8, result.serverSalt.size)
        assertEqual("timeOffset 当前应为确定性的 0", "", 0, result.timeOffset)
        assertBytesEqual("authKey 必须保持当前确定性派生结果", expectedAuthKey(), result.authKey)
        assertBytesEqual("authKeyId 必须保持当前确定性派生结果", expectedAuthKeyId(), result.authKeyId)
        assertBytesEqual("serverSalt 必须保持当前确定性派生结果", expectedServerSalt(), result.serverSalt)
    }
}

func expectedReqPqPayload(): Array<UInt8> {
    [0x50, 0x51, 0x00, 0x01, 0xdf]
}

func expectedReqDhParamsPayload(): Array<UInt8> {
    concatHarnessBytes([0x44, 0x48, 0x00, 0x02], expectedReqPqPayload())
}

func expectedSetClientDhParamsPayload(): Array<UInt8> {
    concatHarnessBytes([0x43, 0x4c, 0x00, 0x03], expectedReqDhParamsPayload())
}

func expectedAuthKey(): Array<UInt8> {
    let authMaterial = concatHarnessBytes(
        concatHarnessBytes(expectedReqPqPayload(), expectedReqDhParamsPayload()),
        expectedSetClientDhParamsPayload()
    )
    deriveHarnessBytes(authMaterial, 32, 0x6d)
}

func expectedAuthKeyId(): Array<UInt8> {
    deriveHarnessBytes(expectedAuthKey(), 8, 0x13)
}

func expectedServerSalt(): Array<UInt8> {
    deriveHarnessBytes(
        concatHarnessBytes(expectedSetClientDhParamsPayload(), expectedReqPqPayload()),
        8,
        0x42
    )
}

func concatHarnessBytes(left: Array<UInt8>, right: Array<UInt8>): Array<UInt8> {
    let total = left.size + right.size
    Array<UInt8>(total, { index: Int64 =>
        if (index < left.size) {
            left[index]
        } else {
            right[index - left.size]
        }
    })
}

func deriveHarnessBytes(seed: Array<UInt8>, desiredLength: Int64, salt: Int64): Array<UInt8> {
    Array<UInt8>(desiredLength, { index: Int64 =>
        let sourceIndex = index % seed.size
        let sourceValue = Int64(seed[sourceIndex])
        UInt8((sourceValue + salt + index * 29 + seed.size) & 0xff)
    })
}
