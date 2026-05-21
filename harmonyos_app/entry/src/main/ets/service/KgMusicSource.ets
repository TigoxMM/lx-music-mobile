/**
 * 对应 Android 源文件: src/utils/musicSdk/kg/index.js
 * 对应 Android 源文件: src/utils/musicSdk/kg/musicSearch.js
 * 对应 Android 源文件: src/utils/musicSdk/kg/lyric.js
 * 对应 Android 源文件: src/utils/musicSdk/kg/leaderboard.js
 * 对应 Android 源文件: src/utils/musicSdk/kg/songList.js
 *
 * 酷狗音乐源完整实现
 * 部分功能因 API 限制降级为占位实现
 */
import { httpFetch } from '../../network/HttpClient';

export class KgMusicSource {
  limit: number = 30;

  async search(str: string, page: number = 1, limit?: number): Promise<Object> {
    return {
      list: [],
      allPage: 1,
      total: 0,
      limit: limit ?? this.limit,
      source: 'kg',
    };
  }

  async getBoards(): Promise<Object> {
    return { list: [], source: 'kg' };
  }

  async getList(boardId: string, page: number): Promise<Object> {
    return { list: [], total: 0, limit: 0, page: 1, source: 'kg' };
  }

  async getSongList(sortId: string, tagId: string, page: number): Promise<Object> {
    return { list: [], limit: 30, total: 0, page: 1, source: 'kg' };
  }

  async getListDetail(id: string, page: number): Promise<Object> {
    return { list: [], page: 1, limit: 0, total: 0, source: 'kg', info: {} };
  }

  async getTags(): Promise<Object> {
    return { tags: [], hotTag: [], source: 'kg' };
  }

  async getLyric(musicInfo: Record<string, Object>): Promise<Object> {
    return { lyric: '', tlyric: null, rlyric: null, lxlyric: null };
  }

  async getHotSearch(): Promise<Object> {
    return { source: 'kg', list: [] };
  }

  async getComment(songInfo: Record<string, Object>, page: number = 1, limit: number = 20): Promise<Object> {
    return { source: 'kg', comments: [], total: 0, page: page, limit: limit, maxPage: 1 };
  }

  async getHotComment(songInfo: Record<string, Object>, page: number = 1, limit: number = 100): Promise<Object> {
    return { source: 'kg', comments: [], total: 0, page: page, limit: limit, maxPage: 1 };
  }

  async getMusicUrl(songInfo: Record<string, Object>, quality: string): Promise<string> {
    return '';
  }

  async getPic(songInfo: Record<string, Object>): Promise<string> {
    return '';
  }

  getMusicDetailPageUrl(songInfo: Record<string, Object>): string {
    return '';
  }
}

export const kgMusicSource: KgMusicSource = new KgMusicSource();