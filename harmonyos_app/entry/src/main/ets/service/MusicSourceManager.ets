/**
 * 对应 Android 源文件: src/utils/musicSdk/index.js
 * 对应 Android 源文件: src/utils/musicSdk/api-source.js
 *
 * 音乐源管理器 - 统一调度所有音乐源 API
 */
import { kwMusicSource } from './KwMusicSource';
import { wyMusicSource } from './WyMusicSource';
import { kgMusicSource } from './KgMusicSource';
import { txMusicSource } from './TxMusicSource';
import { mgMusicSource } from './MgMusicSource';
import { bdMusicSource } from './BdMusicSource';
import { MusicSource } from './MusicSourceAPI';

interface MusicSourceAPI {
  search: (str: string, page: number, limit?: number) => Promise<Object>;
  getBoards?: () => Promise<Object>;
  getList?: (boardId: string, page: number) => Promise<Object>;
  getSongList?: (sortId: string, tagId: string, page: number) => Promise<Object>;
  getListDetail?: (id: string, page: number) => Promise<Object>;
  getTags?: () => Promise<Object>;
  getLyric?: (musicInfo: Record<string, Object>, isGetLyricx?: boolean) => Promise<Object>;
  getHotSearch?: () => Promise<Object>;
  getComment?: (songInfo: Record<string, Object>, page: number, limit: number) => Promise<Object>;
  getHotComment?: (songInfo: Record<string, Object>, page: number, limit: number) => Promise<Object>;
  getMusicUrl?: (songInfo: Record<string, Object>, quality: string) => Promise<string>;
  getPic?: (songInfo: Record<string, Object>) => Promise<string>;
  getMusicDetailPageUrl?: (songInfo: Record<string, Object>) => string;
}

const sourceMap: Record<string, MusicSourceAPI> = {
  [MusicSource.WY]: wyMusicSource as unknown as MusicSourceAPI,
  [MusicSource.KG]: kgMusicSource as unknown as MusicSourceAPI,
  [MusicSource.KW]: kwMusicSource as unknown as MusicSourceAPI,
  [MusicSource.TX]: txMusicSource as unknown as MusicSourceAPI,
  [MusicSource.MG]: mgMusicSource as unknown as MusicSourceAPI,
  [MusicSource.BD]: bdMusicSource as unknown as MusicSourceAPI,
};

function getSource(sourceName: string): MusicSourceAPI | null {
  if (sourceMap[sourceName]) {
    return sourceMap[sourceName];
  }
  return sourceMap[MusicSource.KW];
}

export async function searchMusic(
  sourceName: string,
  str: string,
  page: number,
  limit?: number
): Promise<Object> {
  const source = getSource(sourceName);
  return source!.search(str, page, limit);
}

export async function getLyric(
  sourceName: string,
  musicInfo: Record<string, Object>,
  isGetLyricx?: boolean
): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getLyric) {
    return source!.getLyric(musicInfo, isGetLyricx);
  }
  return { lyric: '', tlyric: null, rlyric: null, lxlyric: null };
}

export async function getLeaderboardBoards(sourceName: string): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getBoards) {
    return source!.getBoards();
  }
  return { list: [], source: sourceName };
}

export async function getLeaderboardList(
  sourceName: string,
  boardId: string,
  page: number
): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getList) {
    return source!.getList(boardId, page);
  }
  return { list: [], total: 0, limit: 0, page: 1, source: sourceName };
}

export async function getSongListTags(sourceName: string): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getTags) {
    return source!.getTags();
  }
  return { tags: [], hotTag: [], source: sourceName };
}

export async function getSongListData(
  sourceName: string,
  sortId: string,
  tagId: string,
  page: number
): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getSongList) {
    return source!.getSongList(sortId, tagId, page);
  }
  return { list: [], limit: 30, total: 0, page: 1, source: sourceName };
}

export async function getSongListDetail(
  sourceName: string,
  id: string,
  page: number
): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getListDetail) {
    return source!.getListDetail(id, page);
  }
  return { list: [], page: 1, limit: 0, total: 0, source: sourceName, info: {} };
}

export async function getMusicUrl(
  sourceName: string,
  musicInfo: Record<string, Object>,
  quality: string
): Promise<string> {
  const source = getSource(sourceName);
  if (source!.getMusicUrl) {
    return source!.getMusicUrl(musicInfo, quality);
  }
  return '';
}

export async function getComments(
  sourceName: string,
  songInfo: Record<string, Object>,
  page: number,
  limit: number
): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getComment) {
    return source!.getComment(songInfo, page, limit);
  }
  return { source: sourceName, comments: [], total: 0, page, limit, maxPage: 1 };
}

export async function getHotComments(
  sourceName: string,
  songInfo: Record<string, Object>,
  page: number,
  limit: number
): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getHotComment) {
    return source!.getHotComment(songInfo, page, limit);
  }
  return { source: sourceName, comments: [], total: 0, page, limit, maxPage: 1 };
}

export async function getHotSearchList(sourceName: string): Promise<Object> {
  const source = getSource(sourceName);
  if (source!.getHotSearch) {
    return source!.getHotSearch();
  }
  return { source: sourceName, list: [] };
}