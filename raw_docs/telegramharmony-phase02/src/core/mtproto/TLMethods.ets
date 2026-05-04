/**
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 */

export abstract class InputPeer {}

export class InputPeerEmpty extends InputPeer {}

export class InputPeerUser extends InputPeer {
  userId: bigint = BigInt(0)
  accessHash: bigint = BigInt(0)
}

export class InputPeerChat extends InputPeer {
  chatId: number = 0
}

export class InputPeerChannel extends InputPeer {
  channelId: bigint = BigInt(0)
  accessHash: bigint = BigInt(0)
}

export class InputReplyToMessage {
  replyToMsgId: number = 0
}

export class MessagesSendMessage {
  peer: InputPeer = new InputPeerEmpty()
  message: string = ''
  randomId: bigint = BigInt(0)

  toBytes(): Uint8Array {
    return new Uint8Array([0x28, 0x0d, 0x09, 0x6f])
  }
}

export class MessagesGetHistory {
  peer: InputPeer = new InputPeerEmpty()
  limit: number = 20

  toBytes(): Uint8Array {
    return new Uint8Array([0, 1, 2, 3])
  }
}

export class InitConnection {
  query: Uint8Array = new Uint8Array(0)
  toBytes(): Uint8Array {
    return this.query
  }
}

export class InvokeWithLayer {
  query: Uint8Array = new Uint8Array(0)
  toBytes(): Uint8Array {
    return this.query
  }
}

export class HelpGetConfig {
  toBytes(): Uint8Array {
    return new Uint8Array([9, 9, 9])
  }
}
