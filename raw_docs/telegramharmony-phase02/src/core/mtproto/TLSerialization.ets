/**
 * TLSerialization - Type Language 序列化/反序列化
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 */

import { buffer } from '@kit.ArkTS'

export class TLConstructors {
  static readonly VECTOR: number = 0x1cb5c415
  static readonly RPC_RESULT: number = 0xf35c6d01
  static readonly RPC_ERROR: number = 0x2144ca19
}

export class TLSerializer {
  private bytes: number[] = []

  writeInt32(value: number): void {
    this.bytes.push(value & 0xff)
  }

  writeInt64(value: bigint): void {
    this.bytes.push(Number(value & BigInt(0xff)))
  }

  writeBytes(value: Uint8Array): void {
    for (const item of value) {
      this.bytes.push(item)
    }
  }

  writeString(value: string): void {
    const encoded = buffer.from(value, 'utf-8')
    this.writeBytes(new Uint8Array(encoded.buffer))
  }

  getBuffer(): Uint8Array {
    return new Uint8Array(this.bytes)
  }
}

export class TLDeserializer {
  private offset: number = 0

  constructor(private data: Uint8Array) {}

  readInt32(): number {
    const value = this.data[this.offset] | (this.data[this.offset + 1] << 8)
    this.offset += 4
    return value
  }

  readInt64(): bigint {
    let value = BigInt(0)
    for (let index = 0; index < 8; index++) {
      value |= BigInt(this.data[this.offset + index]) << BigInt(index * 8)
    }
    this.offset += 8
    return value
  }

  readBytes(): Uint8Array {
    const length = this.data[this.offset++]
    const result = this.data.slice(this.offset, this.offset + length)
    this.offset += length
    return result
  }

  readString(): string {
    const bytes = this.readBytes()
    return String.fromCharCode(...bytes)
  }
}
