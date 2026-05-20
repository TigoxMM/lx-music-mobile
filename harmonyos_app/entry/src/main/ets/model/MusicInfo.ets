/**
 * 对应 Android 源文件: src/types/music.d.ts
 *
 * 音乐相关类型定义
 */

export interface MusicQualityType {
  type: Quality
  size: string | null
}

export interface MusicQualityTypeKg extends MusicQualityType {
  hash: string
}

export type Quality = '128k' | '320k' | 'flac' | 'flac24bit' | 'ape' | 'wav'

export type OnlineSource = 'kw' | 'wy' | 'kg' | 'tx' | 'mg'

export type Source = OnlineSource | 'local'

export interface MusicInfoMetaBase {
  songId: string | number
  albumName: string
  picUrl?: string | null
  toggleMusicInfo?: MusicInfoOnline | null
}

export interface MusicInfoMetaOnline extends MusicInfoMetaBase {
  qualitys: MusicQualityType[]
  _qualitys: Record<string, { size: string | null; hash?: string }>
  albumId?: string | number
}

export interface MusicInfoMetaLocal extends MusicInfoMetaBase {
  filePath: string
  ext: string
}

export interface MusicInfoBase {
  id: string
  name: string
  singer: string
  source: string
  interval: string | null
}

export interface MusicInfoOnline extends MusicInfoBase {
  meta: MusicInfoMetaOnline & { hash?: string; strMediaMid?: string; copyrightId?: string }
}

export interface MusicInfoLocal extends MusicInfoBase {
  source: 'local'
  meta: MusicInfoMetaLocal
}

export type MusicInfo = MusicInfoOnline | MusicInfoLocal

export interface LyricInfo {
  lyric: string
  tlyric?: string | null
  rlyric?: string | null
  lxlyric?: string | null
}

export interface MusicUrlInfo {
  id: string
  url: string
}

export interface SearchResult {
  list: MusicInfoOnline[]
  allPage: number
  limit: number
  total: number
  source: string
}