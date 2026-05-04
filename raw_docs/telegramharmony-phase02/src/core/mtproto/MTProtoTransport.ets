/**
 * MTProtoTransport - TCP 传输层
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 */

import { socket } from '@kit.NetworkKit'
import { MTProtoConfig } from './MTProtoConfig'

export enum TransportState {
  Disconnected = 0,
  Connecting = 1,
  Connected = 2,
  Error = 3
}

export interface TransportCallback {
  onConnected(): void
  onDisconnected(): void
  onData(data: Uint8Array): void
  onError(error: Error): void
}

export class TCPTransport {
  private tcpSocket: socket.TCPSocket | null = null
  private state: TransportState = TransportState.Disconnected
  private callback: TransportCallback | null = null

  setCallback(callback: TransportCallback | null): void {
    this.callback = callback
  }

  async connect(): Promise<void> {
    if (this.state === TransportState.Connected) {
      return
    }

    this.state = TransportState.Connecting
    try {
      this.tcpSocket = socket.constructTCPSocketInstance()
      this.tcpSocket.on('message', (value: socket.SocketMessageInfo): void => {
        this.onReceive(value)
      })
      await this.tcpSocket.connect({ timeout: MTProtoConfig.CONNECTION_TIMEOUT })
      this.state = TransportState.Connected
      this.callback?.onConnected()
    } catch (e) {
      const errorMsg = e instanceof Error ? e.message : JSON.stringify(e)
      this.state = TransportState.Error
      this.callback?.onError(new Error(errorMsg))
      throw new Error(`Connection failed: ${errorMsg}`)
    }
  }

  async disconnect(): Promise<void> {
    await this.tcpSocket?.close()
    this.state = TransportState.Disconnected
  }

  async send(data: Uint8Array): Promise<void> {
    if (!this.tcpSocket || this.state !== TransportState.Connected) {
      throw new Error('Not connected')
    }
    await this.tcpSocket.send({ data: data.buffer })
  }

  private onReceive(message: socket.SocketMessageInfo): void {
    const data = new Uint8Array(message.message as ArrayBuffer)
    this.callback?.onData(data)
  }
}

export class TransportManager {
  getTransport(): TCPTransport {
    return new TCPTransport()
  }
}
