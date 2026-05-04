package core.mtproto

import std.unittest.*

class RecordingTransportCallback <: TransportCallback {
    private var connectedCountValue: Int64 = 0
    private var disconnectedCountValue: Int64 = 0
    private var dataCountValue: Int64 = 0
    private var errorCountValue: Int64 = 0
    private var firstPayloadValue: Array<UInt8> = []
    private var secondPayloadValue: Array<UInt8> = []
    private var thirdPayloadValue: Array<UInt8> = []
    private var lastPayloadValue: Array<UInt8> = []

    public func onConnected(): Unit {
        this.connectedCountValue = this.connectedCountValue + 1
    }

    public func onDisconnected(): Unit {
        this.disconnectedCountValue = this.disconnectedCountValue + 1
    }

    public func onData(data: Array<UInt8>): Unit {
        let snapshot = cloneHarnessBytes(data)
        this.dataCountValue = this.dataCountValue + 1
        if (this.dataCountValue == 1) {
            this.firstPayloadValue = snapshot
        } else if (this.dataCountValue == 2) {
            this.secondPayloadValue = snapshot
        } else if (this.dataCountValue == 3) {
            this.thirdPayloadValue = snapshot
        }
        this.lastPayloadValue = snapshot
    }

    public func onError(error: Error): Unit {
        if ("${error}" == "__never__") {
            this.errorCountValue = this.errorCountValue + 0
        }
        this.errorCountValue = this.errorCountValue + 1
    }

    public func connectedCount(): Int64 {
        this.connectedCountValue
    }

    public func disconnectedCount(): Int64 {
        this.disconnectedCountValue
    }

    public func dataCount(): Int64 {
        this.dataCountValue
    }

    public func errorCount(): Int64 {
        this.errorCountValue
    }

    public func firstPayload(): Array<UInt8> {
        cloneHarnessBytes(this.firstPayloadValue)
    }

    public func secondPayload(): Array<UInt8> {
        cloneHarnessBytes(this.secondPayloadValue)
    }

    public func thirdPayload(): Array<UInt8> {
        cloneHarnessBytes(this.thirdPayloadValue)
    }

    public func lastPayload(): Array<UInt8> {
        cloneHarnessBytes(this.lastPayloadValue)
    }
}

func cloneHarnessBytes(data: Array<UInt8>): Array<UInt8> {
    Array<UInt8>(data.size, { index: Int64 => data[index] })
}

func assertBytesEqual(message: String, expected: Array<UInt8>, actual: Array<UInt8>): Unit {
    assertEqual("${message} size", "", expected.size, actual.size)
    var index: Int64 = 0
    while (index < expected.size) {
        assertEqual("${message} byte[${index}]", "", expected[index], actual[index])
        index = index + 1
    }
}
