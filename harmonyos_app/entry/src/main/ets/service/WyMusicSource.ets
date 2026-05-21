/**
 * 对应 Android 源文件: src/utils/musicSdk/wy/index.js
 * 对应 Android 源文件: src/utils/musicSdk/wy/musicSearch.js
 * 对应 Android 源文件: src/utils/musicSdk/wy/lyric.js
 * 对应 Android 源文件: src/utils/musicSdk/wy/leaderboard.js
 * 对应 Android 源文件: src/utils/musicSdk/wy/songList.js
 * 对应 Android 源文件: src/utils/musicSdk/wy/hotSearch.js
 * 对应 Android 源文件: src/utils/musicSdk/wy/comment.js
 *
 * 网易云音乐源完整实现
 * API 调用参数与 Android 版完全对齐
 */
import { httpFetch, HttpFetchResult } from '../../network/HttpClient';

const TAG = 'WyMusicSource';

export class WyMusicSource {
  limit: number = 30;
  total: number = 0;
  page: number = 0;
  allPage: number = 1;

  // ============= 搜索 ==================

  async search(str: string, page: number = 1, limit?: number, retryNum: number = 0): Promise<Object> {
    if (retryNum > 2) {
      return Promise.reject(new Error('try max num'));
    }
    if (limit == null) {
      limit = this.limit;
    }

    const url = `http://music.163.com/api/search/pc?offset=${(page - 1) * limit}&limit=${limit}&type=1&s=${encodeURIComponent(str)}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const respData = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const data = respData as Record<string, Object>;

      if (!data || data.code !== 200) {
        return this.search(str, page, limit, retryNum + 1);
      }

      const result = data.result as Record<string, Object>;
      const rawList = result.songs as Array<Record<string, Object>> ?? [];

      const list = rawList.map((item) => {
        const interval = item.duration as number;
        const album = item.al as Record<string, Object> ?? {};
        const artists = item.ar as Array<Record<string, Object>> ?? [];
        const singerName = artists.map((a) => a.name as string).join('、');

        return {
          name: item.name as string,
          singer: singerName,
          source: 'wy',
          songId: String(item.id),
          albumId: String(album.id ?? ''),
          interval: interval ? `${Math.floor(interval / 60000)}:${String(Math.floor((interval % 60000) / 1000)).padStart(2, '0')}` : '00:00',
          albumName: album.name as string ?? '',
          img: (album.picUrl as string) ?? null,
          types: [{ type: '128k', size: null }],
          _types: { '128k': { size: null } },
        };
      });

      this.total = result.songCount as number ?? 0;
      this.page = page;
      this.allPage = Math.ceil(this.total / limit);

      return {
        list: list,
        allPage: this.allPage,
        total: this.total,
        limit: limit,
        source: 'wy',
      };
    });
  }

  // ============= 歌词 ==================

  async getLyric(musicInfo: Record<string, Object>, isGetLyricx: boolean = false): Promise<Object> {
    const songId = musicInfo.songId as string;
    const url = `https://music.163.com/api/song/lyric?id=${songId}&lv=1&kv=1&tv=-1`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      const lrc = res.lrc as Record<string, Object> ?? {};
      const tlyric = res.tlyric as Record<string, Object> ?? {};

      return {
        lyric: lrc.lyric as string ?? '',
        tlyric: tlyric.lyric as string ?? null,
        rlyric: null,
        lxlyric: null,
      };
    });
  }

  // ============= 排行榜 ==================

  async getBoards(): Promise<Object> {
    const boards = [
      { id: 'wy__19723756', name: '飙升榜', bangid: '19723756' },
      { id: 'wy__3779629', name: '新歌榜', bangid: '3779629' },
      { id: 'wy__3778678', name: '热歌榜', bangid: '3778678' },
      { id: 'wy__2884035', name: '原创榜', bangid: '2884035' },
      { id: 'wy__2250011882', name: '抖音排行榜', bangid: '2250011882' },
      { id: 'wy__71384707', name: '云音乐韩语榜', bangid: '71384707' },
      { id: 'wy__1978921795', name: '云音乐说唱榜', bangid: '1978921795' },
      { id: 'wy__1899724', name: '云音乐电音榜', bangid: '1899724' },
    ];
    return { list: boards, source: 'wy' };
  }

  async getList(boardId: string, page: number): Promise<Object> {
    const cleanId = boardId.replace('wy__', '');
    const url = `https://music.163.com/api/playlist/detail?id=${cleanId}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 200) {
        throw new Error('Leaderboard API error');
      }

      const playlist = res.playlist as Record<string, Object> ?? {};
      const tracks = playlist.tracks as Array<Record<string, Object>> ?? [];

      const list = tracks.map((item) => {
        const album = item.al as Record<string, Object> ?? {};
        const artists = item.ar as Array<Record<string, Object>> ?? [];
        const singerName = artists.map((a) => a.name as string).join('、');
        const interval = item.dt as number ?? 0;

        return {
          name: item.name as string,
          singer: singerName,
          source: 'wy',
          songId: String(item.id),
          albumId: String(album.id ?? ''),
          interval: interval ? `${Math.floor(interval / 60000)}:${String(Math.floor((interval % 60000) / 1000)).padStart(2, '0')}` : '00:00',
          albumName: album.name as string ?? '',
          img: (album.picUrl as string) ?? null,
          types: [{ type: '128k', size: null }],
          _types: { '128k': { size: null } },
        };
      });

      return {
        total: playlist.trackCount as number ?? 0,
        list: list,
        limit: list.length,
        page: 1,
        source: 'wy',
        info: {
          name: playlist.name as string,
          img: playlist.coverImgUrl as string ?? null,
          desc: playlist.description as string ?? '',
          play_count: this.formatPlayCount(playlist.playCount as number ?? 0),
        },
      };
    });
  }

  // ============= 歌单 ==================

  async getSongList(sortId: string, tagId: string, page: number): Promise<Object> {
    const cat = tagId || '全部';
    const order = sortId === 'new' ? 'new' : 'hot';
    const url = `https://music.163.com/api/playlist/list?cat=${encodeURIComponent(cat)}&order=${order}&offset=${(page - 1) * 30}&limit=30&total=true`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 200) {
        throw new Error('SongList API error');
      }

      const rawList = res.playlists as Array<Record<string, Object>> ?? [];
      const list = rawList.map((item) => ({
        play_count: this.formatPlayCount(item.playCount as number ?? 0),
        id: String(item.id),
        author: (item.creator as Record<string, Object>)?.nickname as string ?? '',
        name: item.name as string,
        time: new Date(item.createTime as number).toLocaleDateString(),
        img: item.coverImgUrl as string ?? '',
        grade: (item.tags as string[])?.join('·') ?? '',
        desc: item.description as string ?? '',
        total: item.trackCount as number ?? 0,
        source: 'wy',
      }));

      return {
        list: list,
        limit: 30,
        total: res.total as number ?? 0,
        page: page,
        source: 'wy',
      };
    });
  }

  async getListDetail(id: string, page: number): Promise<Object> {
    const url = `https://music.163.com/api/playlist/detail?id=${id}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 200) {
        throw new Error('List detail API error');
      }

      const playlist = res.playlist as Record<string, Object> ?? {};
      const tracks = playlist.tracks as Array<Record<string, Object>> ?? [];

      const list = tracks.map((item) => {
        const album = item.al as Record<string, Object> ?? {};
        const artists = item.ar as Array<Record<string, Object>> ?? [];
        const singerName = artists.map((a) => a.name as string).join('、');

        return {
          name: item.name as string,
          singer: singerName,
          source: 'wy',
          songId: String(item.id),
          interval: null,
          albumName: album.name as string ?? '',
          img: (album.picUrl as string) ?? null,
          types: [{ type: '128k', size: null }],
          _types: { '128k': { size: null } },
        };
      });

      return {
        list: list,
        page: 1,
        limit: list.length,
        total: playlist.trackCount as number ?? list.length,
        source: 'wy',
        info: {
          name: playlist.name as string,
          img: playlist.coverImgUrl as string,
          desc: playlist.description as string ?? '',
          author: (playlist.creator as Record<string, Object>)?.nickname as string ?? '',
          play_count: this.formatPlayCount(playlist.playCount as number ?? 0),
        },
      };
    });
  }

  async getTags(): Promise<Object> {
    const url = 'https://music.163.com/api/playlist/catalogue';

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      const categories = res.categories as Record<string, string> ?? {};
      const sub = res.sub as Array<Record<string, Object>> ?? [];

      const tagCategories: Object[] = [];
      const tagMap: Record<string, Array<{ id: string; name: string; source: string }>> = {};

      for (const tagItem of sub) {
        const catId = String(tagItem.category);
        const catName = categories[catId] ?? '其他';

        if (!tagMap[catName]) {
          tagMap[catName] = [];
        }
        tagMap[catName].push({
          id: tagItem.name as string,
          name: tagItem.name as string,
          source: 'wy',
        });
      }

      for (const catName of Object.keys(tagMap)) {
        tagCategories.push({
          name: catName,
          list: tagMap[catName],
        });
      }

      const hotTags = (res.all as Record<string, Object>)?.hot as Array<Record<string, Object>> ?? [];

      return {
        tags: tagCategories,
        hotTag: hotTags.map((t) => ({ id: t.name as string, name: t.name as string, source: 'wy' })),
        source: 'wy',
      };
    });
  }

  // ============= 热搜 ==================

  async getHotSearch(): Promise<Object> {
    const url = 'https://music.163.com/api/search/hot';

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      const hotKeys = res.result as Record<string, Object> ?? {};
      const rawList = hotKeys.hots as Array<Record<string, Object>> ?? [];
      const list = rawList.map((item) => item.first as string);

      return { source: 'wy', list: list };
    });
  }

  // ============= 评论 ==================

  async getComment(songInfo: Record<string, Object>, page: number = 1, limit: number = 20): Promise<Object> {
    const songId = songInfo.songId as string;
    const offset = (page - 1) * limit;
    const url = `https://music.163.com/api/v1/resource/comments/R_SO_4_${songId}?limit=${limit}&offset=${offset}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 200) {
        throw new Error('Comment API error');
      }

      const rawList = res.comments as Array<Record<string, Object>> ?? [];
      const comments = rawList.map((item) => {
        const user = item.user as Record<string, Object> ?? {};
        return {
          id: String(item.commentId ?? ''),
          text: item.content as string ?? '',
          time: Math.floor((item.time as number ?? 0) / 1000),
          userName: user.nickname as string ?? '匿名用户',
          avatar: user.avatarUrl as string ?? '',
          userId: String(user.userId ?? ''),
          likedCount: item.likedCount as number ?? 0,
          reply: [] as Object[],
        };
      });

      return {
        source: 'wy',
        comments: comments,
        total: res.total as number ?? 0,
        page: page,
        limit: limit,
        maxPage: Math.ceil(((res.total as number) ?? 0) / limit) || 1,
      };
    });
  }

  async getHotComment(songInfo: Record<string, Object>, page: number = 1, limit: number = 100): Promise<Object> {
    const songId = songInfo.songId as string;
    const offset = (page - 1) * limit;
    const url = `https://music.163.com/api/v1/resource/comment/R_SO_4_${songId}?limit=${limit}&offset=${offset}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 200) {
        throw new Error('Hot comment API error');
      }

      const rawList = res.comments as Array<Record<string, Object>> ?? [];
      const comments = rawList.map((item) => {
        const user = item.user as Record<string, Object> ?? {};
        return {
          id: String(item.commentId ?? ''),
          text: item.content as string ?? '',
          time: Math.floor((item.time as number ?? 0) / 1000),
          userName: user.nickname as string ?? '匿名用户',
          avatar: user.avatarUrl as string ?? '',
          userId: String(user.userId ?? ''),
          likedCount: item.likedCount as number ?? 0,
          reply: [] as Object[],
        };
      });

      return {
        source: 'wy',
        comments: comments,
        total: res.total as number ?? 0,
        page: page,
        limit: limit,
        maxPage: Math.ceil(((res.total as number) ?? 0) / limit) || 1,
      };
    });
  }

  // ============= 音乐URL ==================

  async getMusicUrl(songInfo: Record<string, Object>, quality: string): Promise<string> {
    const songId = songInfo.songId as string;
    const url = `https://music.163.com/api/song/enhance/player/url?id=${songId}&ids=[${songId}]&br=${quality === '128k' ? 128000 : quality === '320k' ? 320000 : quality === 'flac' ? 999000 : 128000}`;

    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      const data = typeof resp.body === 'string' ? JSON.parse(resp.body) : resp.body;
      const res = data as Record<string, Object>;

      if (res.code !== 200) {
        return '';
      }

      const songs = res.data as Array<Record<string, Object>> ?? [];
      if (songs.length > 0 && songs[0].url) {
        return songs[0].url as string;
      }
      return '';
    });
  }

  // ============= 封面 ==================

  async getPic(songInfo: Record<string, Object>): Promise<string> {
    const songId = songInfo.songId as string;
    return `https://music.163.com/api/song/detail?ids=[${songId}]`;
  }

  getMusicDetailPageUrl(songInfo: Record<string, Object>): string {
    return `https://music.163.com/song?id=${songInfo.songId as string}`;
  }

  private formatPlayCount(count: number): string {
    if (count >= 100000000) {
      return `${(count / 100000000).toFixed(1)}亿`;
    }
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    }
    return String(count);
  }
}

export const wyMusicSource: WyMusicSource = new WyMusicSource();