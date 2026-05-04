/**
 * RealMessageService - 真实消息服务
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 * Simplified for repo-scale dry-run indexing only.
 */

import { Signal, ValueSignal, SignalPipe } from '@ohos/signalkit'
import {
  Message,
  PeerId
} from '@ohos/models'
import { IMessageService, SendMessageParams, GetHistoryParams } from '@ohos/services'
import { getMTProtoClient } from '../core/mtproto/MTProtoClient'
import {
  MessagesSendMessage,
  MessagesGetHistory,
  InputPeer,
  InputPeerEmpty,
  InputPeerUser,
  InputPeerChat,
  InputPeerChannel
} from '../core/mtproto/TLMethods'
import { TLSerializer, TLDeserializer } from '../core/mtproto/TLSerialization'
import { TLUser, TLChannel } from '../core/mtproto/TLDialogs'

export class RealMessageService implements IMessageService {
  private userAccessHashes: Map<string, bigint> = new Map()
  private channelAccessHashes: Map<string, bigint> = new Map()
  private messageSignals: Map<string, SignalPipe<Message[]>> = new Map()
  private messageCache: Map<string, Message[]> = new Map()
  private localMessageIdCounter = -1

  constructor() {
    console.info('[RealMessageService] Service initialized')
  }

  cacheUsers(users: TLUser[]): void {
    for (const user of users) {
      if (user.accessHash !== undefined) {
        this.userAccessHashes.set(user.id.toString(), user.accessHash)
      }
    }
  }

  cacheChannels(channels: TLChannel[]): void {
    for (const channel of channels) {
      if (channel.accessHash !== undefined) {
        this.channelAccessHashes.set(channel.id.toString(), channel.accessHash)
      }
    }
  }

  private createInputPeer(peerId: PeerId): InputPeer {
    if (peerId.namespace === 0) {
      const peer = new InputPeerUser()
      peer.userId = BigInt(peerId.id)
      peer.accessHash = this.userAccessHashes.get(`${peerId.id}`) ?? BigInt(0)
      return peer
    }
    if (peerId.namespace === 1) {
      const peer = new InputPeerChat()
      peer.chatId = peerId.id
      return peer
    }
    if (peerId.namespace === 2) {
      const peer = new InputPeerChannel()
      peer.channelId = BigInt(peerId.id)
      peer.accessHash = this.channelAccessHashes.get(`${peerId.id}`) ?? BigInt(0)
      return peer
    }
    return new InputPeerEmpty()
  }

  getMessages(peerId: PeerId, limit: number): Signal<Message[]> {
    const key = `${peerId.namespace}_${peerId.id}`
    if (!this.messageSignals.has(key)) {
      const signal = new ValueSignal<Message[]>(this.messageCache.get(key) ?? [])
      this.messageSignals.set(key, signal)
      this.fetchMessages({ peerId, limit }).catch((error: Error) => {
        console.error('[RealMessageService] fetchMessages failed', error)
      })
    }
    return this.messageSignals.get(key)!
  }

  async fetchMessages(params: GetHistoryParams): Promise<Message[]> {
    const client = getMTProtoClient()
    const request = new MessagesGetHistory()
    request.peer = this.createInputPeer(params.peerId)
    request.limit = params.limit
    const response = await client.sendRequest(request.toBytes())
    const deserializer = new TLDeserializer(response)
    const messages: Message[] = []
    const vectorId = deserializer.readInt32()
    if (vectorId !== 0x1cb5c415) {
      return messages
    }
    const count = deserializer.readInt32()
    for (let index = 0; index < count; index++) {
      const parsed = this.parseMessageContent(deserializer, params.peerId, vectorId)
      if (parsed) {
        messages.push(parsed)
      }
    }
    const cacheKey = `${params.peerId.namespace}_${params.peerId.id}`
    this.messageCache.set(cacheKey, messages)
    this.messageSignals.get(cacheKey)?.set(messages)
    return messages
  }

  async sendMessage(params: SendMessageParams): Promise<Message> {
    const client = getMTProtoClient()
    const request = new MessagesSendMessage()
    request.peer = this.createInputPeer(params.peerId)
    request.message = params.text
    request.randomId = BigInt(Date.now())
    const response = await client.sendRequest(request.toBytes())
    const deserializer = new TLDeserializer(response)
    const constructor = deserializer.readInt32()
    const message = this.parseMessageContent(deserializer, params.peerId, constructor)
    if (!message) {
      throw new Error('failed to parse message response')
    }
    const key = `${params.peerId.namespace}_${params.peerId.id}`
    const existing = this.messageCache.get(key) ?? []
    this.messageCache.set(key, [...existing, message])
    this.messageSignals.get(key)?.set(this.messageCache.get(key)!)
    return message
  }

  private parseMessageContent(deserializer: TLDeserializer, peerId: PeerId, constructor: number): Message | null {
    try {
      const flags = deserializer.readInt32()
      const id = deserializer.readInt32()
      const text = deserializer.readString()
      return {
        id,
        text,
        peerId,
        flags,
        stableVersion: this.localMessageIdCounter--
      } as Message
    } catch (error) {
      console.error('[RealMessageService] parseMessageContent failed', constructor, error)
      return null
    }
  }
}
