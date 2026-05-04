package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class MTProtoTransportBehaviorTests {
    @TestCase
    public func connectSendAndDisconnectShouldPreserveLoopbackPayload(): Unit {
        let transport = TCPTransport()
        let callback = RecordingTransportCallback()
        transport.setCallback(callback)

        transport.connect().get()
        let payload = buildTransportLoopbackPayload()
        transport.send(payload).get()
        transport.disconnect().get()

        assertEqual("connect 应只触发一次 onConnected", "", 1, callback.connectedCount())
        assertEqual("send 应只触发一次 onData", "", 1, callback.dataCount())
        assertEqual("disconnect 应只触发一次 onDisconnected", "", 1, callback.disconnectedCount())
        assertEqual("整个 loopback 流程不应触发 onError", "", 0, callback.errorCount())
        assertBytesEqual("loopback 返回的字节必须与发送载荷完全一致", payload, callback.lastPayload())
    }
}

func buildTransportLoopbackPayload(): Array<UInt8> {
    [0x10, 0x20, 0x30, 0x40, 0x5a]
}
