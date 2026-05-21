/**
 * 对应 Android 源文件: src/utils/musicSdk/mg/index.js
 *
 * 咪咕音乐源
 */
import { httpFetch } from '../../network/HttpClient';

export class MgMusicSource {
  limit: number = 20;

  async search(str: string, page: number = 1, limit?: number): Promise<Object> {
    const newLimit = limit ?? this.limit;
    const url = `https://m.music.migu.cn/migu/remoting/scr_search_tag?keyword=${encodeURIComponent(str)}&type=2&pgc=${page}&rows=${newLimit}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      const rawList = res.musics as Array<Record<string, Object>> ?? [];

      const list = rawList.map((item) => {
        const singers = item.singerName as string ?? '';
        return {
          name: item.songName as string,
          singer: singers,
          source: 'mg',
          songId: item.copyrightId as string ?? '',
          interval: null,
          albumName: item.albumName as string ?? '',
          types: [{ type: '128k', size: null }],
          _types: { '128k': { size: null } },
        };
      });

      return {
        list: list,
        allPage: Math.ceil(((res.pgt as number) ?? 0) / newLimit) || 1,
        total: res.pgt as number ?? 0,
        limit: newLimit,
        source: 'mg',
      };
    });
  }

  async getBoards(): Promise<Object> {
    const boards = [
      { id: 'mg__1', name: '咪咕新歌榜', bangid: '1' },
      { id: 'mg__2', name: '咪咕热歌榜', bangid: '2' },
    ];
    return { list: boards, source: 'mg' };
  }

  async getList(boardId: string, page: number): Promise<Object> {
    const cleanId = boardId.replace('mg__', '');
    const url = `https://m.music.migu.cn/migu/remoting/cms_top_tag?nid=${cleanId}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;
      const result = (res.data ?? {}) as Record<string, Object>;
      const rawList = result.contentItemList as Array<Record<string, Object>> ?? [];

      const list = rawList.map((item) => {
        const song = item.item as Array<Record<string, Object>> ?? [];
        const songItem = song[0] ?? {};
        return {
          name: songItem.name as string ?? '',
          singer: songItem.singers as string ?? '',
          source: 'mg',
          songId: songItem.id as string ?? '',
          interval: null,
          albumName: songItem.album as string ?? '',
          types: [{ type: '128k', size: null }],
          _types: { '128k': { size: null } },
        };
      });

      return { list, total: list.length, limit: list.length, page: 1, source: 'mg' };
    });
  }
}

export const mgMusicSource: MgMusicSource = new MgMusicSource();