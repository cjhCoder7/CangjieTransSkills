/**
 * Excerpted from ForestBook/TelegramHarmony@31af11b6
 * Simplified for repo-scale dry-run indexing only.
 */

export enum AuthKeyState {
  None = 0,
  Created = 1
}

export interface SessionInfo {
  dcId: number
  authKey: Uint8Array | null
  authKeyId: Uint8Array | null
  serverSalt: Uint8Array | null
  authKeyState: AuthKeyState
  sessionId?: Uint8Array
  seqNo: number
  generateSessionId(): void
}

export class MTProtoConfig {
  static readonly USE_TEST_DC: boolean = true
  static readonly API_ID: number = 17349
  static readonly CONNECTION_TIMEOUT: number = 10000
}

export class SessionManager {
  static getSession(dcId: number): SessionInfo {
    return {
      dcId,
      authKey: null,
      authKeyId: null,
      serverSalt: null,
      authKeyState: AuthKeyState.None,
      seqNo: 0,
      generateSessionId(): void {}
    }
  }

  static saveSession(_session: SessionInfo): void {}
}
