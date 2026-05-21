/**
 * 对应 Android 源文件: src/screens/Home/Views/Search/index.tsx
 * 对应 Android 源文件: src/screens/search/search.js
 *
 * 搜索页面 - 支持搜索音乐
 */
import { kwMusicSource } from '../../service/KwMusicSource';
import { AppViewModel } from '../../viewmodel/AppViewModel';
import { MusicInfoOnline } from '../../model/MusicInfo';
import { appEventBus } from '../../service/AppEventBus';
import { playerService } from '../../service/PlayerService';

@Component
export struct SearchPage {
  @Prop viewModel: AppViewModel;
  @State searchText: string = '';
  @State showHistory: boolean = true;
  @State isShowHotSearch: boolean = false;
  @State isShowHistorySearch: boolean = true;
  @State hotSearchList: string[] = [];

  aboutToAppear(): void {
    if (this.isShowHotSearch) {
      this.loadHotSearch();
    }
  }

  async loadHotSearch(): Promise<void> {
    try {
      const result = await kwMusicSource.getHotSearch() as Record<string, Object>;
      this.hotSearchList = result.list as string[] ?? [];
    } catch (err) {
      console.error('loadHotSearch error: ' + JSON.stringify(err));
    }
  }

  async doSearch(): Promise<void> {
    if (!this.searchText.trim()) {
      return;
    }

    this.viewModel.searchText = this.searchText;
    this.viewModel.isSearching = true;
    this.showHistory = false;

    try {
      const result = await kwMusicSource.search(this.searchText, 1, 30) as Record<string, Object>;
      this.viewModel.updateSearchResult({
        list: result.list as MusicInfoOnline[],
        allPage: result.allPage as number,
        limit: result.limit as number,
        total: result.total as number,
        source: result.source as string,
      });
      this.viewModel.searchPage = 1;
    } catch (err) {
      console.error('Search error: ' + JSON.stringify(err));
    } finally {
      this.viewModel.isSearching = false;
    }
  }

  async loadMoreSearch(): Promise<void> {
    if (this.viewModel.searchPage >= this.viewModel.searchAllPage) {
      return;
    }

    const nextPage = this.viewModel.searchPage + 1;
    this.viewModel.isSearching = true;

    try {
      const result = await kwMusicSource.search(this.viewModel.searchText, nextPage, 30) as Record<string, Object>;
      this.viewModel.appendSearchResult({
        list: result.list as MusicInfoOnline[],
        allPage: result.allPage as number,
        limit: result.limit as number,
        total: result.total as number,
        source: result.source as string,
      });
      this.viewModel.searchPage = nextPage;
    } catch (err) {
      console.error('Load more error: ' + JSON.stringify(err));
    } finally {
      this.viewModel.isSearching = false;
    }
  }

  playMusic(music: MusicInfoOnline): void {
    playerService.playMusic({
      musicInfo: music,
      listId: 'default',
      isTempPlay: false,
    });
    this.viewModel.updatePlayerStatus();
  }

  build() {
    Column() {
      // 搜索框
      Row() {
        Image($r('sys.media.ohos_ic_public_search'))
          .width(18)
          .height(18)
          .fillColor('#999999')
          .margin({ left: 10, right: 6 })

        TextInput({ text: this.searchText, placeholder: '搜索音乐' })
          .layoutWeight(1)
          .height(36)
          .backgroundColor(Color.Transparent)
          .fontSize(14)
          .onChange((value: string) => {
            this.searchText = value;
            if (!value.trim()) {
              this.showHistory = true;
            }
          })
          .onSubmit(() => {
            this.doSearch();
          })

        Button('搜索')
          .fontSize(13)
          .fontColor('#07C556')
          .backgroundColor(Color.Transparent)
          .margin({ right: 4 })
          .onClick(() => {
            this.doSearch();
          })
      }
      .width('100%')
      .height(44)
      .backgroundColor('#F5F5F5')
      .borderRadius(22)
      .margin({ top: 12, left: 14, right: 14 })

      if (this.showHistory && this.isShowHotSearch && this.hotSearchList.length > 0) {
        Column() {
          // 热搜
          Text('热搜榜')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 14, top: 16, bottom: 8 })

          ForEach(this.hotSearchList, (item: string, index: number) => {
            Row() {
              Text(`${index + 1}`)
                .fontSize(14)
                .fontColor(index < 3 ? '#07C556' : '#999999')
                .width(24)
                .textAlign(TextAlign.Center)

              Text(item)
                .fontSize(14)
                .fontColor('#333333')
                .maxLines(1)
                .layoutWeight(1)

              Image($r('sys.media.ohos_ic_public_play'))
                .width(16)
                .height(16)
                .fillColor('#CCCCCC')
            }
            .width('100%')
            .height(40)
            .padding({ left: 14, right: 14 })
            .onClick(() => {
              this.searchText = item;
              this.doSearch();
            })
          })
        }
        .width('100%')
      }

      // 搜索结果列表
      if (!this.showHistory && this.viewModel.searchList.length > 0) {
        List({ space: 0 }) {
          ForEach(this.viewModel.searchList, (item: MusicInfoOnline, index: number) => {
            ListItem() {
              Row() {
                // 序号
                Text(`${index + 1}`)
                  .fontSize(13)
                  .fontColor('#999999')
                  .width(36)
                  .textAlign(TextAlign.Center)

                // 歌曲信息
                Column() {
                  Text(item.name)
                    .fontSize(15)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(`${item.singer} ${item.interval || ''}`)
                    .fontSize(12)
                    .fontColor('#999999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 6 })

                // 更多按钮
                Image($r('sys.media.ohos_ic_public_more'))
                  .width(20)
                  .height(20)
                  .fillColor('#CCCCCC')
              }
              .width('100%')
              .height(56)
              .padding({ left: 14, right: 14 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.playMusic(item);
              })
            }
          }, (item: MusicInfoOnline) => item.id as string)

          ListItem() {
            Row() {
              if (this.viewModel.isSearching) {
                LoadingProgress()
                  .width(24)
                  .height(24)
              } else if (this.viewModel.searchPage < this.viewModel.searchAllPage) {
                Text('加载更多')
                  .fontSize(13)
                  .fontColor('#07C556')
                  .onClick(() => {
                    this.loadMoreSearch();
                  })
              } else {
                Text(`共 ${this.viewModel.searchTotal} 首`)
                  .fontSize(13)
                  .fontColor('#999999')
              }
            }
            .width('100%')
            .height(44)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .divider({
          strokeWidth: 0.5,
          color: '#F0F0F0',
          startMargin: 14,
          endMargin: 14,
        })
      } else if (!this.showHistory && !this.viewModel.isSearching) {
        Column() {
          Image($r('sys.media.ohos_ic_public_music'))
            .width(64)
            .height(64)
            .fillColor('#DDDDDD')
            .margin({ top: 80 })

          Text(this.viewModel.searchText ? '暂无搜索结果' : '输入关键词搜索')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}