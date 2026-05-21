/**
 * 对应 Android 源文件: src/utils/musicSdk/tx/index.js
 *
 * QQ音乐源
 */
import { httpFetch } from '../../network/HttpClient';

export class TxMusicSource {
  limit: number = 30;

  async search(str: string, page: number = 1, limit?: number): Promise<Object> {
    const newLimit = limit ?? this.limit;
    const url = `https://c.y.qq.com/soso/fcgi-bin/client_search_cp?format=json&n=${newLimit}&p=${page}&w=${encodeURIComponent(str)}&cr=1`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 0) {
        throw new Error('QQ search API error');
      }

      const songData = res.data as Record<string, Object>;
      const songList = songData.song as Record<string, Object>;
      const rawList = songList.list as Array<Record<string, Object>> ?? [];

      const list = rawList.map((item) => {
        const singers = item.singer as Array<Record<string, Object>> ?? [];
        const singerName = singers.map((s) => s.name as string).join('、');

        return {
          name: item.songname as string,
          singer: singerName,
          source: 'tx',
          songId: `${item.songmid as string}|${item.albummid as string}`,
          interval: null,
          albumName: item.albumname as string ?? '',
          types: [{ type: '128k', size: null }],
          _types: { '128k': { size: null } },
        };
      });

      return {
        list: list,
        allPage: Math.ceil(((songList.cur_num ?? 0) as number) / 30),
        total: songList.cur_num as number ?? 0,
        limit: newLimit,
        source: 'tx',
      };
    });
  }
}

export const txMusicSource: TxMusicSource = new TxMusicSource();