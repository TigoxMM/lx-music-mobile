/**
 * 对应 Android 源文件: src/screens/SonglistDetail/index.tsx
 * 对应 Android 源文件: src/screens/songlistDetail/songlistDetail.js
 *
 * 歌单详情页
 */
import { AppViewModel } from '../viewmodel/AppViewModel';
import { kwMusicSource } from '../service/KwMusicSource';
import { MusicInfoOnline } from '../model/MusicInfo';
import { playerService } from '../service/PlayerService';
import { router } from '@kit.ArkUI';

@Component
export struct SonglistDetailPage {
  @Prop viewModel: AppViewModel;
  @State listInfo: Record<string, Object> = {};
  @State songList: MusicInfoOnline[] = [];
  @State total: number = 0;
  @State isLoading: boolean = false;
  @State page: number = 1;

  aboutToAppear(): void {
    this.loadDetail();
  }

  async loadDetail(): Promise<void> {
    this.isLoading = true;

    // 从 viewModel 中获取当前歌单ID
    const songListId = this.viewModel.songListData.length > 0 ?
      (this.viewModel.songListData[0] as Record<string, Object>).id as string :
      '';

    if (!songListId) {
      this.isLoading = false;
      return;
    }

    try {
      const result = await kwMusicSource.getListDetail(songListId, 1) as Record<string, Object>;
      this.listInfo = result.info as Record<string, Object> ?? {};
      this.songList = result.list as MusicInfoOnline[];
      this.total = result.total as number ?? 0;
      this.page = 1;
    } catch (err) {
      console.error('load songlist detail error: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async loadMore(): Promise<void> {
    this.isLoading = true;
    const nextPage = this.page + 1;

    try {
      const songListId = (this.viewModel.songListData[0] as Record<string, Object>).id as string;
      const result = await kwMusicSource.getListDetail(songListId, nextPage) as Record<string, Object>;
      this.songList = this.songList.concat(result.list as MusicInfoOnline[]);
      this.page = nextPage;
    } catch (err) {
      console.error('load more error: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  playAll(): void {
    if (this.songList.length > 0) {
      playerService.playMusic({
        musicInfo: this.songList[0],
        listId: 'default',
        isTempPlay: false,
      });
    }
  }

  playMusic(music: MusicInfoOnline): void {
    playerService.playMusic({
      musicInfo: music,
      listId: 'default',
      isTempPlay: false,
    });
  }

  build() {
    Column() {
      // 顶部返回栏
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text(this.listInfo['name'] as string ?? '歌单详情')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)
          .layoutWeight(1)
          .margin({ left: 10 })

        Image($r('sys.media.ohos_ic_public_more'))
          .width(24)
          .height(24)
          .fillColor('#333333')
      }
      .width('100%')
      .height(50)
      .padding({ left: 14, right: 14 })

      Scroll() {
        Column() {
          // 歌单信息头部
          Row() {
            Image(this.listInfo['img'] as string ?? '')
              .width(100)
              .height(100)
              .borderRadius(8)
              .backgroundColor('#F0F0F0')
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.app_icon'))

            Column() {
              Text(this.listInfo['name'] as string ?? '')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`${this.listInfo['author'] as string ?? ''} · ${this.total}首`)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 6 })

              if (this.listInfo['play_count']) {
                Text(`${this.listInfo['play_count'] as string} 次播放`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 2 })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 14 })
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 14 })

          // 播放全部按钮
          Button('播放全部')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#07C556')
            .borderRadius(20)
            .margin({ left: 14, right: 14, top: 16, bottom: 8 })
            .onClick(() => {
              this.playAll();
            })

          // 歌曲列表
          if (this.isLoading && this.songList.length === 0) {
            Column() {
              LoadingProgress()
                .width(36)
                .height(36)
                .margin({ top: 60 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            ForEach(this.songList, (item: MusicInfoOnline, index: number) => {
              Row() {
                Text(`${index + 1}`)
                  .fontSize(14)
                  .fontColor(index < 3 ? '#07C556' : '#999999')
                  .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Normal)
                  .width(32)
                  .textAlign(TextAlign.Center)

                Column() {
                  Text(item.name)
                    .fontSize(14)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(`${item.singer} - ${item.interval ?? ''}`)
                    .fontSize(11)
                    .fontColor('#999999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 8 })

                Image($r('sys.media.ohos_ic_public_more'))
                  .width(18)
                  .height(18)
                  .fillColor('#CCCCCC')
                  .margin({ left: 4 })
              }
              .width('100%')
              .height(52)
              .padding({ left: 14, right: 14 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.playMusic(item);
              })
            }, (item: MusicInfoOnline) => item.id)

            if (this.songList.length < this.total) {
              Row() {
                Text('加载更多')
                  .fontSize(13)
                  .fontColor('#07C556')
              }
              .width('100%')
              .height(40)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.loadMore();
              })
            }
          }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}