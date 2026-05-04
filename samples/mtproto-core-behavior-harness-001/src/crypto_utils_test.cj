package core.mtproto

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class CryptoUtilsBehaviorTests {
    @TestCase
    public func toHexShouldEncodeEveryInputByteInLowercaseHex(): Unit {
        let input: Array<UInt8> = [0x00, 0x0f, 0xa5, 0xff]
        let actual = ByteUtils.toHex(input)
        assertEqual("toHex 应逐字节输出两位小写十六进制", "", "000fa5ff", actual)
    }
}
