/**
 * 对应 Android 源文件: src/utils/musicSdk/bd/index.js
 *
 * 百度音乐源
 */
import { httpFetch } from '../../network/HttpClient';

export class BdMusicSource {
  limit: number = 20;

  async search(str: string, page: number = 1, limit?: number): Promise<Object> {
    const newLimit = limit ?? this.limit;
    const url = `http://tingapi.ting.baidu.com/v1/restserver/ting?from=android&version=5.8.1.0&method=baidu.ting.search.merge&format=json&query=${encodeURIComponent(str)}&page_no=${page}&page_size=${newLimit}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      const result = res.result as Record<string, Object> ?? {};
      const rawList = (result.song_info as Record<string, Object>)?.song_list as Array<Record<string, Object>> ?? [];

      const list = rawList.map((item) => ({
        name: item.title as string,
        singer: item.author as string ?? '',
        source: 'bd',
        songId: item.song_id as string ?? '',
        interval: null,
        albumName: item.album_title as string ?? '',
        types: [{ type: '128k', size: null }],
        _types: { '128k': { size: null } },
      }));

      return {
        list: list,
        allPage: Math.ceil((result.song_num as number ?? 0) / newLimit) || 1,
        total: result.song_num as number ?? 0,
        limit: newLimit,
        source: 'bd',
      };
    });
  }
}

export const bdMusicSource: BdMusicSource = new BdMusicSource();