package core.mtproto

public class ByteUtils {
    public static func toHex(_bytes: Array<UInt8>): String {
        var result = ""
        for (byte in _bytes) {
            let value = Int64(byte) & 0xff
            result = result + hexDigit((value >> 4) & 0x0f) + hexDigit(value & 0x0f)
        }
        result
    }
}

public class SHA1 {}

public class SHA256 {}

public class MTProtoCrypto {}

public interface EncryptedMessage {
    prop payload: Array<UInt8>
}

func hexDigit(value: Int64): String {
    match (value) {
        case 0 => "0"
        case 1 => "1"
        case 2 => "2"
        case 3 => "3"
        case 4 => "4"
        case 5 => "5"
        case 6 => "6"
        case 7 => "7"
        case 8 => "8"
        case 9 => "9"
        case 10 => "a"
        case 11 => "b"
        case 12 => "c"
        case 13 => "d"
        case 14 => "e"
        case _ => "f"
    }
}
