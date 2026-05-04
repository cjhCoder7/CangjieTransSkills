package core.mtproto

public class TLConstructors {
    public static let VECTOR: Int32 = 0x1cb5c415
    public static let RPC_RESULT: Int32 = -212046591 // 0xf35c6d01
    public static let RPC_ERROR: Int32 = 0x2144ca19
}

public class TLSerializer {
    private var bytes: Array<UInt8> = []

    public func writeInt32(value: Int32): Unit {
        // Source Alignment: Only write low 8 bits, matching source `this.bytes.push(value & 0xff)`
        this.bytes = appendByte(this.bytes, UInt8(value & 0xff))
    }

    public func writeInt64(value: Int64): Unit {
        // Source Alignment: Only write low 8 bits, matching source `this.bytes.push(Number(value & BigInt(0xff)))`
        this.bytes = appendByte(this.bytes, UInt8(value & 0xff))
    }

    public func writeBytes(value: Array<UInt8>): Unit {
        for (item in value) {
            this.bytes = appendByte(this.bytes, item)
        }
    }

    public func writeString(value: String): Unit {
        let encoded = value.toArray()
        this.bytes = appendByte(this.bytes, UInt8(Int64(encoded.size) & 0xff))
        for (item in encoded) {
            this.bytes = appendByte(this.bytes, item)
        }
    }

    public func getBuffer(): Array<UInt8> {
        this.bytes
    }
}

func appendByte(arr: Array<UInt8>, b: UInt8): Array<UInt8> {
    let newSize = arr.size + 1
    Array<UInt8>(newSize, { i: Int64 =>
        if (i < arr.size) {
            arr[i]
        } else {
            b
        }
    })
}

public class TLDeserializer {
    private var offset: Int64 = 0
    private let data: Array<UInt8>

    public init(data: Array<UInt8>) {
        this.data = cloneDeserializerBytes(data)
    }

    public func readInt32(): Int32 {
        if (this.offset >= this.data.size) {
            return 0
        }
        let value = Int32(this.data[this.offset])
        this.offset = this.offset + 1
        value
    }

    public func readInt64(): Int64 {
        Int64(readInt32())
    }

    public func readBytes(): Array<UInt8> {
        let length = Int64(readInt32())
        let available = remainingBytesCount(this.data, this.offset)
        let actualLength = if (length < available) { length } else { available }
        let start = this.offset
        this.offset = this.offset + actualLength
        Array<UInt8>(actualLength, { index: Int64 => this.data[start + index] })
    }

    public func readString(): String {
        String.fromUtf8(readBytes())
    }
}

func cloneDeserializerBytes(data: Array<UInt8>): Array<UInt8> {
    Array<UInt8>(data.size, { index: Int64 => data[index] })
}

func remainingBytesCount(data: Array<UInt8>, offset: Int64): Int64 {
    if (offset < data.size) {
        data.size - offset
    } else {
        0
    }
}
