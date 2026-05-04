package core.mtproto

public func decompress(data: Array<UInt8>): Array<UInt8> {
    if (data.size < Int64(7)) {
        return cloneInflateBytes(data)
    }

    let cmf = byteToInt64(data[Int64(0)])
    let flg = byteToInt64(data[Int64(1)])
    if ((cmf & Int64(0x0f)) != Int64(8)) {
        return cloneInflateBytes(data)
    }
    if ((((cmf << Int64(8)) + flg) % Int64(31)) != Int64(0)) {
        return cloneInflateBytes(data)
    }

    let payloadEnd = data.size - Int64(4)
    var cursor = Int64(2)
    var output: Array<UInt8> = []

    while (cursor < payloadEnd) {
        let blockHeader = byteToInt64(data[cursor])
        cursor += Int64(1)

        let blockType = (blockHeader >> Int64(1)) & Int64(0x03)
        if (blockType != Int64(0)) {
            return cloneInflateBytes(data)
        }
        if (cursor + Int64(4) > payloadEnd) {
            return cloneInflateBytes(data)
        }

        let length = byteToInt64(data[cursor]) + (byteToInt64(data[cursor + Int64(1)]) << Int64(8))
        cursor += Int64(4)
        if (cursor + length > payloadEnd) {
            return cloneInflateBytes(data)
        }

        output = appendInflateRange(output, data, cursor, length)
        cursor += length
        if ((blockHeader & Int64(0x01)) == Int64(1)) {
            return output
        }
    }

    output
}

func byteToInt64(value: UInt8): Int64 {
    Int64(value) & Int64(0xff)
}

func cloneInflateBytes(data: Array<UInt8>): Array<UInt8> {
    Array<UInt8>(data.size, { index: Int64 => data[index] })
}

func appendInflateRange(
    base: Array<UInt8>,
    source: Array<UInt8>,
    start: Int64,
    length: Int64
): Array<UInt8> {
    let total = base.size + length
    Array<UInt8>(total, { index: Int64 =>
        if (index < base.size) {
            base[index]
        } else {
            source[start + index - base.size]
        }
    })
}
