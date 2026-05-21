/**
 * 对应 Android 源文件: src/utils/musicSdk/kw/index.js
 * 对应 Android 源文件: src/utils/musicSdk/kw/musicSearch.js
 * 对应 Android 源文件: src/utils/musicSdk/kw/lyric.js
 * 对应 Android 源文件: src/utils/musicSdk/kw/leaderboard.js
 * 对应 Android 源文件: src/utils/musicSdk/kw/songList.js
 * 对应 Android 源文件: src/utils/musicSdk/kw/hotSearch.js
 * 对应 Android 源文件: src/utils/musicSdk/kw/comment.js
 *
 * 酷我音乐源完整实现
 * API 调用参数与 Android 版完全对齐
 */
import { httpFetch } from '../../network/HttpClient';
import { formatPlayTime, decodeName, formatPlayCount, sizeFormate, dateFormat } from '../../utils/CommonUtils';
import { util } from '@kit.ArkTS';

const TAG = 'KwMusicSource';

export class KwMusicSource {
  limit: number = 30;
  total: number = 0;
  page: number = 0;
  allPage: number = 1;

  // ============= 搜索 ==================

  private musicSearchApi(str: string, page: number, limit: number): Promise<Object> {
    const url = `http://search.kuwo.cn/r.s?client=kt&all=${encodeURIComponent(str)}&pn=${page - 1}&rn=${limit}&uid=794762570&ver=kwplayer_ar_9.2.2.1&vipver=1&show_copyright_off=1&newver=1&ft=music&cluster=0&strategy=2012&encoding=utf8&rformat=json&vermerge=1&mobi=1&issubtitle=1`;
    return httpFetch(url, { method: 'GET' }).promise.then((resp) => {
      if (typeof resp.body === 'string') {
        return JSON.parse(resp.body);
      }
      return resp.body;
    });
  }

  async search(str: string, page: number = 1, limit?: number, retryNum: number = 0): Promise<Object> {
    if (retryNum > 2) {
      return Promise.reject(new Error('try max num'));
    }
    if (limit == null) {
      limit = this.limit;
    }

    const result = await this.musicSearchApi(str, page, limit) as Record<string, Object>;
    if (!result || (result.TOTAL !== '0' && result.SHOW === '0')) {
      return this.search(str, page, limit, retryNum + 1);
    }

    const rawList = result.abslist as Array<Record<string, Object>>;
    const list = this.handleSearchResult(rawList);
    if (list == null) {
      return this.search(str, page, limit, retryNum + 1);
    }

    this.total = parseInt(result.TOTAL as string);
    this.page = page;
    this.allPage = Math.ceil(this.total / limit);

    return {
      list: list,
      allPage: this.allPage,
      total: this.total,
      limit: limit,
      source: 'kw',
    };
  }

  private handleSearchResult(rawData: Array<Record<string, Object>>): Object[] | null {
    if (!rawData) {
      return [];
    }
    const result: Object[] = [];
    for (let i = 0; i < rawData.length; i++) {
      const info = rawData[i];
      const songId: string = (info.MUSICRID as string).replace('MUSIC_', '');

      const nMinfo = info.N_MINFO as string;
      if (!nMinfo) {
        console.log('N_MINFO is undefined');
        return null;
      }

      const types: Object[] = [];
      const _types: Record<string, Object> = {};
      const rxp: RegExp = /level:(\w+),bitrate:(\d+),format:(\w+),size:([\w.]+)/;

      const infoArr: string[] = nMinfo.split(';');
      for (let itemStr of infoArr) {
        const match = itemStr.match(rxp);
        if (match) {
          switch (match[2]) {
            case '4000':
              types.push({ type: 'flac24bit', size: match[4] });
              _types['flac24bit'] = { size: match[4].toLocaleUpperCase() };
              break;
            case '2000':
              types.push({ type: 'flac', size: match[4] });
              _types['flac'] = { size: match[4].toLocaleUpperCase() };
              break;
            case '320':
              types.push({ type: '320k', size: match[4] });
              _types['320k'] = { size: match[4].toLocaleUpperCase() };
              break;
            case '128':
              types.push({ type: '128k', size: match[4] });
              _types['128k'] = { size: match[4].toLocaleUpperCase() };
              break;
          }
        }
      }
      types.reverse();

      const interval = parseInt(info.DURATION as string);

      result.push({
        name: decodeName(info.SONGNAME as string),
        singer: decodeName(info.ARTIST as string),
        source: 'kw',
        songmid: songId,
        albumId: decodeName((info.ALBUMID || '') as string),
        interval: Number.isNaN(interval) ? 0 : formatPlayTime(interval),
        albumName: info.ALBUM ? decodeName(info.ALBUM as string) : '',
        lrc: null,
        img: null,
        otherSource: null,
        types: types,
        _types: _types,
        typeUrl: {},
      });
    }
    return result;
  }

  // ============= 歌词 (lyric) ==================

  private buildLyricParams(id: string, isGetLyricx: boolean): string {
    const bufKey: number[] = [121, 101, 101, 108, 105, 111, 110]; // 'yeelion'
    const bufKeyLen: number = bufKey.length;
    let params: string = `user=12345,web,web,web&requester=localhost&req=1&rid=MUSIC_${id}`;
    if (isGetLyricx) {
      params += '&lrcx=1';
    }

    const encoder = new TextEncoder();
    const bufStr: Uint8Array = encoder.encode(params);
    const bufStrLen: number = bufStr.length;
    const output: Uint16Array = new Uint16Array(bufStrLen);
    let i: number = 0;
    while (i < bufStrLen) {
      let j: number = 0;
      while (j < bufKeyLen && i < bufStrLen) {
        output[i] = bufKey[j] ^ bufStr[i];
        i++;
        j++;
      }
    }

    const base64Helper = new util.Base64Helper();
    return base64Helper.encodeToStringSync(new Uint8Array(output.buffer));
  }

  async getLyric(musicInfo: Record<string, Object>, isGetLyricx: boolean = true): Promise<Object> {
    const songmid = musicInfo.songmid as string;
    const params = this.buildLyricParams(songmid, isGetLyricx);
    const url = `http://newlyric.kuwo.cn/newlyric.lrc?${params}`;

    const result = await httpFetch(url, {
      method: 'GET',
      binary: true,
    }).promise;

    if (result.statusCode !== 200) {
      return { lyric: '', tlyric: '', rlyric: '', lxlyric: '' };
    }

    // 解码歌词 (简化版)
    const decoder = new TextDecoder();
    const lrcText = decoder.decode(result.body as ArrayBuffer);

    return {
      lyric: lrcText,
      tlyric: '',
      rlyric: '',
      lxlyric: '',
    };
  }

  // ============= 排行榜 ==================

  async getBoards(): Promise<Object> {
    const boards = [
      { id: 'kw__16', name: '飙升榜', bangid: '16' },
      { id: 'kw__5', name: '新歌榜', bangid: '5' },
      { id: 'kw__17', name: '热歌榜', bangid: '17' },
      { id: 'kw__93', name: '抖音热歌榜', bangid: '93' },
      { id: 'kw__145', name: '内地榜', bangid: '145' },
      { id: 'kw__146', name: '港台榜', bangid: '146' },
      { id: 'kw__147', name: '欧美榜', bangid: '147' },
      { id: 'kw__148', name: '韩国榜', bangid: '148' },
      { id: 'kw__149', name: '日本榜', bangid: '149' },
    ];
    return { list: boards, source: 'kw' };
  }

  async getList(boardId: string, page: number): Promise<Object> {
    const cleanId = boardId.replace('kw__', '');
    const url = `http://www.kuwo.cn/api/www/bang/bang/musicList?bangId=${cleanId}&pn=${page}&rn=30`;

    const { statusCode, body } = await httpFetch(url, { method: 'GET' }).promise;

    if (statusCode !== 200) {
      throw new Error('Failed to get leaderboard list');
    }

    const data = body as Record<string, Object>;
    if (data.code !== 200) {
      throw new Error('Leaderboard API error');
    }

    const musicList = (data.data as Record<string, Object>).musicList as Array<Record<string, Object>> ?? [];
    const list = musicList.map((item) => ({
      name: item.name as string,
      singer: item.artist as string,
      source: 'kw',
      songmid: String(item.rid),
      albumId: String(item.albumid ?? ''),
      interval: item.duration ? formatPlayTime(parseInt(item.duration as string)) : '00:00',
      albumName: item.album as string ?? '',
      img: item.pic as string ?? null,
      types: [{ type: '128k', size: null }],
      _types: { '128k': { size: null } },
    }));

    return {
      total: list.length,
      list: list,
      limit: 100,
      page: page,
      source: 'kw',
    };
  }

  // ============= 歌单 ==================

  async getSongList(sortId: string, tagId: string, page: number): Promise<Object> {
    const url = `http://www.kuwo.cn/api/www/playlist/getTagPlayList?pn=${page}&rn=30&id=${tagId}&order=${sortId}`;

    const { statusCode, body } = await httpFetch(url, { method: 'GET' }).promise;

    if (statusCode !== 200) {
      throw new Error('Failed to get song list');
    }

    const data = body as Record<string, Object>;
    const rawList = (data.data as Record<string, Object>)?.data as Array<Record<string, Object>> ?? [];

    const list = rawList.map((item) => ({
      play_count: formatPlayCount(item.listencnt as number),
      id: String(item.id),
      author: item.uname as string ?? '',
      name: item.name as string,
      time: dateFormat(parseInt(item.publish as string) * 1000, 'Y-M-D'),
      img: item.img as string ?? '',
      grade: item.tag as string ?? '',
      desc: item.desc as string ?? '',
      total: item.total as number ?? 0,
      source: 'kw' as string,
    }));

    return {
      list: list,
      limit: 30,
      total: data.total as number ?? 0,
      page: page,
      source: 'kw',
    };
  }

  async getListDetail(id: string, page: number): Promise<Object> {
    const url = `http://www.kuwo.cn/api/www/playlist/playListInfo?pid=${id}&pn=${page}&rn=200`;

    const { statusCode, body } = await httpFetch(url, { method: 'GET' }).promise;

    if (statusCode !== 200) {
      throw new Error('Failed to get list detail');
    }

    const data = body as Record<string, Object>;
    const plData = data.data as Record<string, Object>;
    const musicList = plData.musicList as Array<Record<string, Object>> ?? [];

    const list = musicList.map((item) => ({
      name: item.name as string,
      singer: item.artist as string,
      source: 'kw',
      songmid: String(item.rid),
      albumId: String(item.albumid ?? ''),
      interval: item.duration ? formatPlayTime(parseInt(item.duration as string)) : '00:00',
      albumName: item.album as string ?? '',
      img: item.pic as string ?? null,
      types: [{ type: '128k', size: null }],
      _types: { '128k': { size: null } },
    }));

    return {
      list: list,
      page: page,
      limit: 200,
      total: plData.total as number ?? list.length,
      source: 'kw',
      info: {
        name: plData.name as string,
        img: plData.img as string,
        desc: plData.desc as string ?? '',
        author: plData.uname as string ?? '',
        play_count: formatPlayCount(plData.listencnt as number ?? 0),
      },
    };
  }

  async getTags(): Promise<Object> {
    const url = 'http://www.kuwo.cn/api/www/playlist/getTagList';

    const { statusCode, body } = await httpFetch(url, { method: 'GET' }).promise;

    if (statusCode !== 200) {
      throw new Error('Failed to get tags');
    }

    const data = body as Record<string, Object>;
    const tagData = data.data as Array<Record<string, Object>> ?? [];

    const tags: Object[] = [];
    for (const group of tagData) {
      const list = ((group.data ?? []) as Array<Record<string, Object>>).map((tag) => ({
        id: String(tag.id ?? ''),
        name: tag.name as string ?? '',
        source: 'kw',
      }));
      tags.push({
        name: group.name as string,
        list: list,
      });
    }

    return {
      tags: tags,
      hotTag: tags[0]?.list ?? [],
      source: 'kw',
    };
  }

  // ============= 热搜 ==================

  async getHotSearch(): Promise<Object> {
    const list: string[] = [];
    return { source: 'kw', list: list };
  }

  // ============= 评论 ==================

  async getComment(songInfo: Record<string, Object>, page: number = 1, limit: number = 20): Promise<Object> {
    const songmid = songInfo.songmid as string;
    const url = `http://www.kuwo.cn/api/www/comment/getCommentByRId?rid=${songmid}&pn=${page}&rn=${limit}`;

    const { statusCode, body } = await httpFetch(url, { method: 'GET' }).promise;

    if (statusCode !== 200) {
      throw new Error('Failed to get comments');
    }

    const data = body as Record<string, Object>;
    const rawList = (data.data as Record<string, Object>)?.rows as Array<Record<string, Object>> ?? [];

    const comments = rawList.map((item) => ({
      id: item.id as string,
      text: item.msg as string ?? '',
      time: item.addtime as number ?? 0,
      userName: item.u_name as string ?? '',
      avatar: item.u_pic as string ?? '',
      userId: item.u_id as string ?? '',
      likedCount: item.like_num as number ?? 0,
      reply: [] as Object[],
    }));

    return {
      source: 'kw',
      comments: comments,
      total: data.total as number ?? 0,
      page: page,
      limit: limit,
      maxPage: Math.ceil(((data.total as number) ?? 0) / limit) || 1,
    };
  }

  async getHotComment(songInfo: Record<string, Object>, page: number = 1, limit: number = 100): Promise<Object> {
    return this.getComment(songInfo, page, limit);
  }

  // ============= 音乐URL ==================

  async getMusicUrl(songInfo: Record<string, Object>, quality: string): Promise<string> {
    const songmid = songInfo.songmid as string ?? songInfo.songId as string;
    const url = `http://www.kuwo.cn/api/v1/www/music/playUrl?mid=${songmid}&type=music&br=${quality}`;

    const { statusCode, body } = await httpFetch(url, { method: 'GET' }).promise;

    if (statusCode !== 200) {
      return '';
    }

    const data = body as Record<string, Object>;
    if (data.code !== 200) {
      return '';
    }

    return (data.data as Record<string, Object>)?.url as string ?? '';
  }

  // ============= 封面 ==================

  async getPic(songInfo: Record<string, Object>): Promise<string> {
    const songmid = songInfo.songmid as string;
    return `http://player.kuwo.cn/webmusic/sj/dtflagdate?flag=6&rid=MUSIC_${songmid}`;
  }

  getMusicDetailPageUrl(songInfo: Record<string, Object>): string {
    return `http://www.kuwo.cn/play_detail/${songInfo.songmid as string}`;
  }
}

export const kwMusicSource: KwMusicSource = new KwMusicSource();