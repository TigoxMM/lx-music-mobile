/**
 * 对应 Android 源文件: src/screens/Home/Views/Leaderboard/index.tsx
 * 对应 Android 源文件: src/screens/leaderboard/index.js
 *
 * 排行榜页
 */
import { AppViewModel } from '../../viewmodel/AppViewModel';
import { kwMusicSource } from '../../service/KwMusicSource';
import { MusicInfoOnline } from '../../model/MusicInfo';
import { playerService } from '../../service/PlayerService';

@Component
export struct LeaderboardPage {
  @Prop viewModel: AppViewModel;
  @State boards: Object[] = [];

  aboutToAppear(): void {
    this.loadBoards();
  }

  async loadBoards(): Promise<void> {
    try {
      const result = await kwMusicSource.getBoards() as Record<string, Object>;
      this.boards = result.list as Object[] ?? [];
    } catch (err) {
      console.error('loadBoards error: ' + JSON.stringify(err));
    }
  }

  async loadBoardList(boardId: string): Promise<void> {
    this.viewModel.leaderboardBoardId = boardId;
    this.viewModel.isLoadingLeaderboard = true;

    try {
      const result = await kwMusicSource.getList(boardId, 1) as Record<string, Object>;
      this.viewModel.updateLeaderboardData(
        result.list as Object[],
        result.total as number,
        1
      );
    } catch (err) {
      console.error('loadBoardList error: ' + JSON.stringify(err));
    } finally {
      this.viewModel.isLoadingLeaderboard = false;
    }
  }

  async loadMoreBoardList(): Promise<void> {
    this.viewModel.isLoadingLeaderboard = true;
    const nextPage = this.viewModel.leaderboardPage + 1;

    try {
      const result = await kwMusicSource.getList(
        this.viewModel.leaderboardBoardId,
        nextPage
      ) as Record<string, Object>;

      this.viewModel.updateLeaderboardData(
        this.viewModel.leaderboardList.concat(result.list as Object[]),
        result.total as number,
        nextPage
      );
    } catch (err) {
      console.error('loadMoreBoardList error: ' + JSON.stringify(err));
    } finally {
      this.viewModel.isLoadingLeaderboard = false;
    }
  }

  playMusic(item: Record<string, Object>): void {
    const music: MusicInfoOnline = {
      id: item.source as string + '_' + item.songmid as string,
      name: item.name as string,
      singer: item.singer as string,
      source: item.source as string,
      interval: item.interval as string,
      meta: {
        songId: item.songmid as string,
        albumName: item.albumName as string ?? '',
        picUrl: item.img as string ?? null,
        qualitys: [{ type: '128k', size: null }],
        _qualitys: { '128k': { size: null } },
      },
    };

    playerService.playMusic({
      musicInfo: music,
      listId: this.viewModel.leaderboardBoardId,
      isTempPlay: false,
    });
    this.viewModel.updatePlayerStatus();
  }

  build() {
    Column() {
      // 排行榜切换
      if (this.boards.length > 0) {
        Scroll() {
          Row() {
            ForEach(this.boards, (board: Record<string, Object>) => {
              Text(board.name as string)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.viewModel.leaderboardBoardId === (board.id as string) ? '#07C556' : '#666666')
                .border({
                  width: this.viewModel.leaderboardBoardId === (board.id as string) ? 1.5 : 0,
                  color: '#07C556',
                })
                .borderRadius(16)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ right: 10 })
                .backgroundColor(
                  this.viewModel.leaderboardBoardId === (board.id as string) ? 'rgba(7,197,86,0.08)' : '#F5F5F5'
                )
                .onClick(() => {
                  this.loadBoardList(board.id as string);
                })
            })
          }
          .padding({ left: 14, right: 14 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .padding({ top: 14, bottom: 10 })
      }

      // 排行榜列表
      if (this.viewModel.isLoadingLeaderboard && this.viewModel.leaderboardList.length === 0) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.viewModel.leaderboardList.length === 0) {
        Column() {
          Text('暂无数据')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.viewModel.leaderboardList, (item: Record<string, Object>, index: number) => {
            ListItem() {
              Row() {
                Text(`${index + 1}`)
                  .fontSize(14)
                  .fontColor(index < 3 ? '#07C556' : '#999999')
                  .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Normal)
                  .width(32)
                  .textAlign(TextAlign.Center)

                Image(item.img as string || '')
                  .width(40)
                  .height(40)
                  .borderRadius(4)
                  .backgroundColor('#F0F0F0')
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.app_icon'))

                Column() {
                  Text(item.name as string)
                    .fontSize(14)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(`${item.singer as string} - ${item.albumName as string}`)
                    .fontSize(11)
                    .fontColor('#999999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 10 })

                Text(item.interval as string ?? '')
                  .fontSize(12)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .height(56)
              .padding({ left: 14, right: 14 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.playMusic(item);
              })
            }
          }, (item: Record<string, Object>) => item.songmid as string)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({
          strokeWidth: 0.5,
          color: '#F0F0F0',
          startMargin: 14,
          endMargin: 14,
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}