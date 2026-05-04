package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class TLSerializationBehaviorTests {
    @TestCase
    public func writeStringShouldEmitLengthPrefixedUtf8Bytes(): Unit {
        let serializer = TLSerializer()
        serializer.writeString("Hi")
        let actual = serializer.getBuffer()
        let expected: Array<UInt8> = [0x02, 0x48, 0x69]
        assertBytesEqual("writeString 应写出 length-prefixed UTF-8 字节流", expected, actual)
    }

    @TestCase
    public func readStringShouldRoundTripLengthPrefixedPayload(): Unit {
        let encoded: Array<UInt8> = [0x02, 0x48, 0x69]
        let actual = TLDeserializer(encoded).readString()
        assertEqual("readString 应还原 length-prefixed UTF-8 内容", "", "Hi", actual)
    }

    @TestCase
    public func readBytesShouldConsumeLengthAndReturnPayloadSlice(): Unit {
        let encoded: Array<UInt8> = [0x03, 0x41, 0x42, 0x43]
        let actual = TLDeserializer(encoded).readBytes()
        let expected: Array<UInt8> = [0x41, 0x42, 0x43]
        assertBytesEqual("readBytes 应消费长度并返回对应 payload", expected, actual)
    }
}
