/**
 * 对应 Android 源文件: src/types/player.d.ts
 *
 * 播放器相关类型定义
 */

import { MusicInfo, LyricInfo } from './MusicInfo';

export interface PlayMusicInfo {
  musicInfo: MusicInfo
  listId: string
  isTempPlay: boolean
}

export interface PlayerMusicInfo {
  id: string | null
  pic: string | null | undefined
  lrc: string | null
  tlrc: string | null
  rlrc: string | null
  lxlrc: string | null
  rawlrc: string | null
  name: string
  singer: string
  album: string
}

export interface PlayerLyricInfo extends LyricInfo {
  rawlrcInfo: LyricInfo
}

export interface PlayInfo {
  playIndex: number
  playerListId: string | null
  playerPlayIndex: number
}

export interface SavedPlayInfo {
  time: number
  maxTime: number
  listId: string
  index: number
}

export interface PlayerProgress {
  nowPlayTime: number
  maxPlayTime: number
  progress: number
  nowPlayTimeStr: string
  maxPlayTimeStr: string
}

export type TogglePlayMethod = 'listLoop' | 'random' | 'list' | 'singleLoop' | 'none'

export const TOGGLE_PLAY_METHOD_LIST: TogglePlayMethod[] = [
  'listLoop', 'random', 'list', 'singleLoop', 'none'
]