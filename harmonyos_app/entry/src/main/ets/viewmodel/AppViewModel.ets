/**
 * 对应 Android 源文件: src/store/index.ts
 * 对应 Android 源文件: src/store/player/state.ts
 * 对应 Android 源文件: src/store/list/state.ts
 * 对应 Android 源文件: src/store/setting/state.ts
 * 对应 Android 源文件: src/store/leaderboard/state.ts
 *
 * 全局应用状态 ViewModel - AppStorage 绑定
 */
import { AppSetting } from '../model/AppSetting';
import { MusicInfo, MusicInfoOnline, SearchResult } from '../model/MusicInfo';
import { PlayMusicInfo, TogglePlayMethod } from '../model/PlayerInfo';
import { UserListInfo, MyAllList, ListUpdateInfo } from '../model/ListInfo';
import { getDefaultSetting } from '../constants/DefaultSetting';
import { NAV_MENUS, NavIdType } from '../constants/Constant';
import { playerService } from './PlayerService';

@ObservedV2
export class AppViewModel {
  // ============= 导航状态 =============
  @Trace currentNavId: NavIdType = 'nav_search';

  // ============= 设置状态 =============
  @Trace setting: AppSetting = getDefaultSetting();

  // ============= 播放器状态 =============
  @Trace isPlay: boolean = false;
  @Trace playMusicInfo: PlayMusicInfo | null = null;
  @Trace togglePlayMethod: TogglePlayMethod = 'listLoop';

  // ============= 当前歌曲信息 =============
  @Trace currentMusicName: string = '';
  @Trace currentMusicSinger: string = '';
  @Trace currentMusicPic: string = '';
  @Trace playProgress: number = 0;
  @Trace nowPlayTimeStr: string = '00:00';
  @Trace maxPlayTimeStr: string = '00:00';

  // ============= 列表状态 =============
  @Trace userList: UserListInfo[] = [];
  @Trace activeListId: string = 'default';

  // ============= 搜索状态 =============
  @Trace searchText: string = '';
  @Trace searchList: MusicInfoOnline[] = [];
  @Trace searchTotal: number = 0;
  @Trace searchPage: number = 1;
  @Trace searchAllPage: number = 1;
  @Trace isSearching: boolean = false;
  @Trace searchHistory: string[] = [];
  @Trace searchSource: string = 'kw';
  @Trace searchTempSource: string = 'kw';

  // ============= 歌单状态 =============
  @Trace songListSortId: string = 'new';
  @Trace songListTagId: string = '';
  @Trace songListTagName: string = '';
  @Trace songListData: Object[] = [];
  @Trace songListTotal: number = 0;
  @Trace songListPage: number = 1;
  @Trace songListTags: Object[] = [];
  @Trace isLoadingSongList: boolean = false;

  // ============= 排行榜状态 =============
  @Trace leaderboardSource: string = 'kw';
  @Trace leaderboardBoardId: string = 'kw__16';
  @Trace leaderboardList: Object[] = [];
  @Trace leaderboardTotal: number = 0;
  @Trace leaderboardPage: number = 1;
  @Trace isLoadingLeaderboard: boolean = false;

  // ============= 播放详情状态 =============
  @Trace playDetailLrc: string = '';
  @Trace playDetailTlrc: string = '';
  @Trace playDetailName: string = '';
  @Trace playDetailSinger: string = '';
  @Trace playDetailAlbum: string = '';

  // ============= 评论状态 =============
  @Trace commentList: Object[] = [];
  @Trace hotCommentList: Object[] = [];
  @Trace commentTotal: number = 0;
  @Trace commentPage: number = 1;
  @Trace isLoadingComment: boolean = false;

  // ============= 歌单详情状态 =============
  @Trace songlistDetailList: MusicInfoOnline[] = [];
  @Trace songlistDetailTotal: number = 0;
  @Trace songlistDetailPage: number = 1;
  @Trace songlistDetailInfo: Record<string, Object> = {};
  @Trace isLoadingSonglistDetail: boolean = false;

  // ============= 方法 =============

  switchNav(id: NavIdType): void {
    this.currentNavId = id;
  }

  updateSetting(setting: AppSetting): void {
    this.setting = setting;
  }

  updateSearchResult(result: SearchResult): void {
    this.searchList = result.list;
    this.searchTotal = result.total;
    this.searchAllPage = result.allPage;
  }

  appendSearchResult(result: SearchResult): void {
    this.searchList = this.searchList.concat(result.list);
    this.searchTotal = result.total;
    this.searchAllPage = result.allPage;
  }

  updateSongListData(data: Object[], total: number, page: number): void {
    if (page === 1) {
      this.songListData = data;
    } else {
      this.songListData = this.songListData.concat(data);
    }
    this.songListTotal = total;
    this.songListPage = page;
  }

  updateLeaderboardData(data: Object[], total: number, page: number): void {
    if (page === 1) {
      this.leaderboardList = data;
    } else {
      this.leaderboardList = this.leaderboardList.concat(data);
    }
    this.leaderboardTotal = total;
    this.leaderboardPage = page;
  }

  updateCommentData(comments: Object[], total: number, page: number): void {
    if (page === 1) {
      this.commentList = comments;
    } else {
      this.commentList = this.commentList.concat(comments);
    }
    this.commentTotal = total;
    this.commentPage = page;
  }

  updateSonglistDetailData(list: MusicInfoOnline[], total: number, page: number): void {
    if (page === 1) {
      this.songlistDetailList = list;
    } else {
      this.songlistDetailList = this.songlistDetailList.concat(list);
    }
    this.songlistDetailTotal = total;
    this.songlistDetailPage = page;
  }

  updatePlayerStatus(): void {
    this.isPlay = playerService.isPlay;
    this.playMusicInfo = playerService.playMusicInfo;
    this.togglePlayMethod = playerService.togglePlayMethod;
    this.playProgress = playerService.progress.progress;
    this.nowPlayTimeStr = playerService.progress.nowPlayTimeStr;
    this.maxPlayTimeStr = playerService.progress.maxPlayTimeStr;

    if (playerService.musicInfo) {
      this.currentMusicName = playerService.musicInfo.name;
      this.currentMusicSinger = playerService.musicInfo.singer;
    }
  }

  setPlayProgress(progress: number): void {
    this.playProgress = progress;
  }
}