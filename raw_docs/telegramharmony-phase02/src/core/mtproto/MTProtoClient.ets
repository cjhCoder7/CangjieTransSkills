/**
 * MTProtoClient - MTProto 协议客户端
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 */

import { MTProtoConfig, SessionInfo, SessionManager, AuthKeyState } from './MTProtoConfig'
import { ByteUtils, EncryptedMessage } from './CryptoUtils'
import { TLDeserializer, TLSerializer } from './TLSerialization'
import { TransportCallback, TransportManager } from './MTProtoTransport'
import { InitConnection, InvokeWithLayer, HelpGetConfig } from './TLMethods'
import { AuthKeyCreator } from './AuthKeyCreator'
import { decompress } from './Inflate'

class RPCCallback {
  resolve: (result: Uint8Array) => void
  reject: (error: Error) => void
  timeoutId: number

  constructor(resolve: (result: Uint8Array) => void, reject: (error: Error) => void, timeoutId: number) {
    this.resolve = resolve
    this.reject = reject
    this.timeoutId = timeoutId
  }
}

export class MTProtoClient implements TransportCallback {
  private transportManager: TransportManager
  private session: SessionInfo
  private pendingRPCs: Map<string, RPCCallback> = new Map()
  private updateCallback: ((update: Uint8Array) => void) | null = null
  private connectionInitialized: boolean = false

  constructor() {
    this.transportManager = new TransportManager()
    this.session = SessionManager.getSession(MTProtoConfig.USE_TEST_DC ? 2 : 1)
  }

  setUpdateCallback(callback: (update: Uint8Array) => void): void {
    this.updateCallback = callback
  }

  async initialize(forceNewAuthKey: boolean = false): Promise<void> {
    const transport = this.transportManager.getTransport()
    transport.setCallback(this)
    if (forceNewAuthKey) {
      this.session.authKey = null
      this.session.authKeyState = AuthKeyState.None
    }
    await transport.connect()
    if (!this.session.authKey) {
      await this.createAuthKey()
    }
  }

  private async createAuthKey(): Promise<void> {
    const transport = this.transportManager.getTransport()
    const creator = new AuthKeyCreator(transport)
    const result = await creator.createAuthKey()
    this.session.authKey = result.authKey
    this.session.authKeyId = result.authKeyId
    this.session.serverSalt = result.serverSalt
    this.session.authKeyState = AuthKeyState.Created
    SessionManager.saveSession(this.session)
  }

  async sendRequest(data: Uint8Array): Promise<Uint8Array> {
    if (!this.connectionInitialized) {
      await this.initConnection()
    }

    return new Promise<Uint8Array>((resolve, reject) => {
      const key = `${Date.now()}`
      this.pendingRPCs.set(key, new RPCCallback(resolve, reject, 0))
      this.transportManager.getTransport().send(data).catch(reject)
    })
  }

  private async initConnection(): Promise<void> {
    const getConfig = new HelpGetConfig()
    const initConn = new InitConnection()
    initConn.query = getConfig.toBytes()
    const invokeWithLayer = new InvokeWithLayer()
    invokeWithLayer.query = initConn.toBytes()
    const payload = invokeWithLayer.toBytes()
    await this.transportManager.getTransport().send(payload)
    this.connectionInitialized = true
  }

  onConnected(): void {}
  onDisconnected(): void {}

  onData(data: Uint8Array): void {
    const maybeCompressed = decompress(data)
    const deserializer = new TLDeserializer(maybeCompressed)
    if (this.updateCallback) {
      this.updateCallback(maybeCompressed)
    }
    const rpc = this.pendingRPCs.values().next().value
    if (rpc) {
      rpc.resolve(deserializer.readBytes())
    }
  }

  onError(error: Error): void {
    console.error('[MTProtoClient] transport error', error)
  }
}

let clientSingleton: MTProtoClient | null = null
export function getMTProtoClient(): MTProtoClient {
  if (!clientSingleton) {
    clientSingleton = new MTProtoClient()
  }
  return clientSingleton
}
