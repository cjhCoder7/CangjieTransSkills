package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class InflateBehaviorTests {
    @TestCase
    public func decompressShouldDecodeStoredBlockPayload(): Unit {
        let compressed = buildStoredBlockZlibPayload()
        let actual = decompress(compressed)
        let expected = buildStoredBlockPlaintext()
        assertBytesEqual("stored-block zlib 应正确解出原始明文", expected, actual)
    }

    @TestCase
    public func decompressShouldFallbackForUnsupportedBlockType(): Unit {
        let unsupported = buildUnsupportedBlockPayload()
        let actual = decompress(unsupported)
        assertBytesEqual("不支持的 deflate block type 应安全回退原始输入", unsupported, actual)
    }
}

func buildStoredBlockPlaintext(): Array<UInt8> {
    [0x41, 0x42, 0x43]
}

func buildStoredBlockZlibPayload(): Array<UInt8> {
    [
        0x78, 0x01,
        0x01,
        0x03, 0x00,
        0xfc, 0xff,
        0x41, 0x42, 0x43,
        0x00, 0x00, 0x00, 0x00
    ]
}

func buildUnsupportedBlockPayload(): Array<UInt8> {
    [
        0x78, 0x01,
        0x03,
        0x03, 0x00,
        0xfc, 0xff,
        0x41, 0x42, 0x43,
        0x00, 0x00, 0x00, 0x00
    ]
}
