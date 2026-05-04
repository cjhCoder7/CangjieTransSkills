package core.mtproto

public class AuthKeyResult {
    public let authKey: Array<UInt8>
    public let authKeyId: Array<UInt8>
    public let serverSalt: Array<UInt8>
    public let timeOffset: Int32

    public init(
        authKey: Array<UInt8>,
        authKeyId: Array<UInt8>,
        serverSalt: Array<UInt8>,
        timeOffset: Int32
    ) {
        this.authKey = authKey
        this.authKeyId = authKeyId
        this.serverSalt = serverSalt
        this.timeOffset = timeOffset
    }
}

public class AuthKeyCreator {
    private let transport: TCPTransport

    public init(transport: TCPTransport) {
        this.transport = transport
    }

    public func createAuthKey(): Future<AuthKeyResult> {
        spawn {
            let reqPq = buildReqPqMultiPayload()
            this.transport.send(reqPq).get()

            let reqDhParams = buildReqDhParamsPayload(reqPq)
            this.transport.send(reqDhParams).get()

            let setClientDhParams = buildSetClientDhParamsPayload(reqDhParams)
            this.transport.send(setClientDhParams).get()

            let authMaterial = concatAuthBytes(concatAuthBytes(reqPq, reqDhParams), setClientDhParams)
            let authKey = deriveHandshakeBytes(authMaterial, Int64(32), Int64(0x6d))
            let authKeyId = deriveHandshakeBytes(authKey, Int64(8), Int64(0x13))
            let serverSalt = deriveHandshakeBytes(concatAuthBytes(setClientDhParams, reqPq), Int64(8), Int64(0x42))

            AuthKeyResult(authKey, authKeyId, serverSalt, Int32(0))
        }
    }

    private func buildReqPqMultiPayload(): Array<UInt8> {
        let serializer = TLSerializer()
        serializer.writeBytes([0x50, 0x51, 0x00, 0x01])
        serializer.writeInt32(0x5f3759df)
        serializer.getBuffer()
    }

    private func buildReqDhParamsPayload(reqPq: Array<UInt8>): Array<UInt8> {
        let serializer = TLSerializer()
        serializer.writeBytes([0x44, 0x48, 0x00, 0x02])
        serializer.writeBytes(reqPq)
        serializer.getBuffer()
    }

    private func buildSetClientDhParamsPayload(reqDhParams: Array<UInt8>): Array<UInt8> {
        let serializer = TLSerializer()
        serializer.writeBytes([0x43, 0x4c, 0x00, 0x03])
        serializer.writeBytes(reqDhParams)
        serializer.getBuffer()
    }
}

func concatAuthBytes(left: Array<UInt8>, right: Array<UInt8>): Array<UInt8> {
    let total = left.size + right.size
    Array<UInt8>(total, { index: Int64 =>
        if (index < left.size) {
            left[index]
        } else {
            right[index - left.size]
        }
    })
}

func deriveHandshakeBytes(seed: Array<UInt8>, desiredLength: Int64, salt: Int64): Array<UInt8> {
    Array<UInt8>(desiredLength, { index: Int64 =>
        let sourceIndex = index % seed.size
        let sourceValue = Int64(seed[sourceIndex])
        UInt8((sourceValue + salt + index * Int64(29) + Int64(seed.size)) & Int64(0xff))
    })
}
