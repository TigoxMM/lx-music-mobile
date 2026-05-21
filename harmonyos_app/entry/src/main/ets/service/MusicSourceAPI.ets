/**
 * 对应 Android 源文件: src/utils/musicSdk/api-source-info.ts
 * 对应 Android 源文件: src/utils/musicSdk/options.js
 * 对应 Android 源文件: src/utils/musicSdk/utils.js
 *
 * 音乐源信息与公共工具
 */

export enum MusicSource {
  WY = 'wy',
  KG = 'kg',
  KW = 'kw',
  TX = 'tx',
  MG = 'mg',
  BD = 'bd',
}

export interface MusicSourceInfo {
  id: string
  name: string
  disabled: boolean
  supportQualitys: string[]
}

const SOURCE_NAMES: Record<string, string> = {
  wy: '网易云音乐',
  kg: '酷狗音乐',
  kw: '酷我音乐',
  tx: 'QQ音乐',
  mg: '咪咕音乐',
  bd: '百度音乐',
};

export function getSourceName(source: string): string {
  return SOURCE_NAMES[source] ?? source;
}

export function getSourceNames(): Record<string, string> {
  return SOURCE_NAMES;
}

export const bHh: string = '48686878';

export function encodeHTML(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

export function decodeHTML(str: string): string {
  return str
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#039;/g, '\'');
}

export interface MusicSourceAPI {
  musicSearch: (str: string, page: number, limit?: number) => Promise<Object>
  songList: {
    getList: (sortId: string, tagId: string, page: number) => Promise<Object>
    getTags: () => Promise<Object>
    getListDetail: (id: string, page: number) => Promise<Object>
  }
  leaderboard: {
    getBoards: () => Promise<Object>
    getList: (boardId: string, page: number) => Promise<Object>
  }
  hotSearch: {
    getList: () => Promise<Object>
  }
  comment: {
    getComment: (songInfo: Object, page: number, limit: number) => Promise<Object>
    getHotComment: (songInfo: Object, page: number, limit: number) => Promise<Object>
  }
  getMusicUrl: (songInfo: Object, quality: string) => Promise<string>
  getLyric: (songInfo: Object) => Promise<Object>
  getPic: (songInfo: Object) => Promise<string>
  getMusicDetailPageUrl: (songInfo: Object) => string
}