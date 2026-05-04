/**
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 */

import { TCPTransport } from './MTProtoTransport'

export interface AuthKeyResult {
  authKey: Uint8Array
  authKeyId: Uint8Array
  serverSalt: Uint8Array
  timeOffset: number
}

export class AuthKeyCreator {
  constructor(private transport: TCPTransport) {}

  async createAuthKey(): Promise<AuthKeyResult> {
    await this.transport.send(new Uint8Array([1, 2, 3]))
    return {
      authKey: new Uint8Array([1]),
      authKeyId: new Uint8Array([2]),
      serverSalt: new Uint8Array([3]),
      timeOffset: 0
    }
  }
}
