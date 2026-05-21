/**
 * 对应 Android 源文件: src/screens/Home/Views/SongList/index.tsx
 * 对应 Android 源文件: src/screens/songlist/songlist.js
 *
 * 歌单页
 */
import { AppViewModel } from '../../viewmodel/AppViewModel';
import { kwMusicSource } from '../../service/KwMusicSource';

@Component
export struct SongListPage {
  @Prop viewModel: AppViewModel;
  @State tagName: string = '全部';
  @State showTagList: boolean = false;
  @State sortId: string = 'new';

  aboutToAppear(): void {
    this.loadTags();
    this.loadSongList();
  }

  async loadTags(): Promise<void> {
    try {
      const result = await kwMusicSource.getTags() as Record<string, Object>;
      this.viewModel.songListTags = result.tags as Object[] ?? [];
      const hotTag = (result.hotTag as Object[]) ?? [];
      if (hotTag.length > 0) {
        const tag = hotTag[0] as Record<string, Object>;
        this.viewModel.songListTagId = tag.id as string;
        this.viewModel.songListTagName = tag.name as string;
        this.tagName = tag.name as string;
      }
    } catch (err) {
      console.error('loadTags error: ' + JSON.stringify(err));
    }
  }

  async loadSongList(): Promise<void> {
    if (!this.viewModel.songListTagId) {
      return;
    }

    this.viewModel.isLoadingSongList = true;

    try {
      const result = await kwMusicSource.getSongList(
        this.viewModel.songListSortId,
        this.viewModel.songListTagId,
        1
      ) as Record<string, Object>;

      this.viewModel.updateSongListData(
        result.list as Object[],
        result.total as number,
        1
      );
    } catch (err) {
      console.error('loadSongList error: ' + JSON.stringify(err));
    } finally {
      this.viewModel.isLoadingSongList = false;
    }
  }

  async loadMoreSongList(): Promise<void> {
    this.viewModel.isLoadingSongList = true;
    const nextPage = this.viewModel.songListPage + 1;

    try {
      const result = await kwMusicSource.getSongList(
        this.viewModel.songListSortId,
        this.viewModel.songListTagId,
        nextPage
      ) as Record<string, Object>;

      this.viewModel.updateSongListData(
        this.viewModel.songListData.concat(result.list as Object[]),
        result.total as number,
        nextPage
      );
    } catch (err) {
      console.error('loadMoreSongList error: ' + JSON.stringify(err));
    } finally {
      this.viewModel.isLoadingSongList = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Row() {
          Text(this.tagName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(14)
            .height(14)
            .fillColor('#999999')
            .margin({ left: 4 })
        }
        .onClick(() => {
          this.showTagList = !this.showTagList;
        })

        Blank()

        Row() {
          Text(this.sortId === 'new' ? '最新' : '最热')
            .fontSize(13)
            .fontColor('#999999')

          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(12)
            .height(12)
            .fillColor('#999999')
            .margin({ left: 2 })
        }
        .onClick(() => {
          this.sortId = this.sortId === 'new' ? 'hot' : 'new';
          this.viewModel.songListSortId = this.sortId;
          this.loadSongList();
        })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 14, bottom: 6 })

      // 标签选择器
      if (this.showTagList) {
        Column() {
          ForEach(this.viewModel.songListTags, (group: Record<string, Object>) => {
            Column() {
              Text(group.name as string)
                .fontSize(12)
                .fontColor('#07C556')
                .fontWeight(FontWeight.Medium)
                .padding({ left: 14, top: 8, bottom: 4 })

              Row() {
                ForEach(group.list as Object[], (tag: Record<string, Object>) => {
                  Text(tag.name as string)
                    .fontSize(12)
                    .fontColor(this.viewModel.songListTagId === (tag.id as string) ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.viewModel.songListTagId === (tag.id as string) ? '#07C556' : '#F5F5F5')
                    .borderRadius(12)
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .margin({ right: 8, bottom: 6 })
                    .onClick(() => {
                      this.viewModel.songListTagId = tag.id as string;
                      this.viewModel.songListTagName = tag.name as string;
                      this.tagName = tag.name as string;
                      this.showTagList = false;
                      this.loadSongList();
                    })
                })
              }
              .padding({ left: 14 })
              .flexWrap(FlexWrap.Wrap)
            }
          })
        }
        .width('100%')
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .padding({ bottom: 10 })
      }

      // 歌单列表
      if (this.viewModel.isLoadingSongList && this.viewModel.songListData.length === 0) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .margin({ top: 80 })
          Text('加载中...')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.viewModel.songListData.length === 0) {
        Column() {
          Text('暂无歌单')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Grid() {
          ForEach(this.viewModel.songListData, (item: Record<string, Object>) => {
            GridItem() {
              Column() {
                Stack() {
                  Image(item.img as string || '')
                    .width('100%')
                    .aspectRatio(1)
                    .borderRadius({ topLeft: 8, topRight: 8 })
                    .backgroundColor('#F0F0F0')
                    .objectFit(ImageFit.Cover)
                    .alt($r('app.media.app_icon'))

                  // 播放量
                  if (item.play_count) {
                    Text(item.play_count as string)
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .backgroundColor('rgba(0,0,0,0.5)')
                      .borderRadius(4)
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .position({ right: 4, top: 4 })
                  }
                }
                .width('100%')

                Column() {
                  Text(item.name as string)
                    .fontSize(13)
                    .fontColor('#333333')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Text(`${item.total ?? 0}首`)
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .padding({ left: 6, right: 6, top: 6, bottom: 8 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .shadow({
                radius: 4,
                color: 'rgba(0,0,0,0.06)',
                offsetX: 0,
                offsetY: 2,
              })
              .onClick(() => {
                // TODO: navigate to SonglistDetail
                console.log('navigate to songlist detail: ' + item.id);
              })
            }
          }, (item: Record<string, Object>) => item.id as string)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .padding({ left: 14, right: 14 })
        .layoutWeight(1)
        .onReachEnd(() => {
          if (!this.viewModel.isLoadingSongList) {
            this.loadMoreSongList();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}