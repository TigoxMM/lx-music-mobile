/**
 * 对应 Android 源文件: src/screens/Comment/index.tsx
 * 对应 Android 源文件: src/screens/comment/comment.js
 *
 * 评论页面
 */
import { AppViewModel } from '../viewmodel/AppViewModel';
import { kwMusicSource } from '../service/KwMusicSource';
import { router } from '@kit.ArkUI';

@Component
export struct CommentPage {
  @Prop viewModel: AppViewModel;
  @State hotComments: Object[] = [];
  @State comments: Object[] = [];
  @State total: number = 0;
  @State isLoading: boolean = false;
  @State page: number = 1;
  @State activeTab: number = 0; // 0=热门, 1=最新

  aboutToAppear(): void {
    this.loadComments();
  }

  async loadComments(): Promise<void> {
    this.isLoading = true;

    const songInfo: Record<string, Object> = {
      songmid: 'default',
    };

    try {
      const hotResult = await kwMusicSource.getHotComment(songInfo, 1, 100) as Record<string, Object>;
      this.hotComments = hotResult.comments as Object[] ?? [];

      const result = await kwMusicSource.getComment(songInfo, 1, 20) as Record<string, Object>;
      this.comments = result.comments as Object[] ?? [];
      this.total = result.total as number ?? 0;
      this.page = 1;
    } catch (err) {
      console.error('load comments error: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async loadMore(): Promise<void> {
    this.isLoading = true;
    const nextPage = this.page + 1;

    const songInfo: Record<string, Object> = {
      songmid: 'default',
    };

    try {
      const result = await kwMusicSource.getComment(songInfo, nextPage, 20) as Record<string, Object>;
      this.comments = this.comments.concat(result.comments as Object[] ?? []);
      this.page = nextPage;
    } catch (err) {
      console.error('load more comments error: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('评论')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ left: 10 })

        Image($r('sys.media.ohos_ic_public_more'))
          .width(24)
          .height(24)
          .fillColor('#333333')
      }
      .width('100%')
      .height(50)
      .padding({ left: 14, right: 14 })

      Divider().color('#F0F0F0')

      // Tab切换
      Row() {
        Text('热门')
          .fontSize(15)
          .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.activeTab === 0 ? '#333333' : '#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
          .onClick(() => {
            this.activeTab = 0;
          })

        Text('最新')
          .fontSize(15)
          .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.activeTab === 1 ? '#333333' : '#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
          .onClick(() => {
            this.activeTab = 1;
          })
      }
      .width('100%')

      Divider().color('#F0F0F0')

      if (this.isLoading && this.comments.length === 0) {
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
      } else if (
        (this.activeTab === 0 && this.hotComments.length === 0) ||
        (this.activeTab === 1 && this.comments.length === 0)
      ) {
        Column() {
          Text('暂无评论')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 0 }) {
          if (this.activeTab === 0) {
            ForEach(this.hotComments, (item: Record<string, Object>, index: number) => {
              ListItem() {
                this.commentItem(item, index);
              }
            })
          } else {
            ForEach(this.comments, (item: Record<string, Object>, index: number) => {
              ListItem() {
                this.commentItem(item, index);
              }
            })

            if (this.comments.length < this.total) {
              ListItem() {
                Row() {
                  Text('加载更多')
                    .fontSize(13)
                    .fontColor('#07C556')
                }
                .width('100%')
                .height(44)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.loadMore();
                })
              }
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .divider({
          strokeWidth: 0.5,
          color: '#F5F5F5',
          startMargin: 14,
          endMargin: 14,
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  commentItem(item: Record<string, Object>, index: number): void {
    Row() {
      Image(item.avatar as string ?? '')
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('#F0F0F0')
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.app_icon'))

      Column() {
        Row() {
          Text(item.userName as string ?? '匿名用户')
            .fontSize(13)
            .fontColor('#666666')

          Blank()

          Text(`${item.likedCount ?? 0}赞`)
            .fontSize(11)
            .fontColor('#CCCCCC')

          Image($r('sys.media.ohos_ic_public_thumb_up'))
            .width(14)
            .height(14)
            .fillColor('#CCCCCC')
            .margin({ left: 4 })
        }
        .width('100%')

        Text(item.text as string ?? '')
          .fontSize(13)
          .fontColor('#333333')
          .maxLines(5)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 6 })
          .width('100%')

        // 发布时间
        if (item.time) {
          Text(new Date((item.time as number) * 1000).toLocaleDateString())
            .fontSize(10)
            .fontColor('#CCCCCC')
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .alignItems(VerticalAlign.Top)
  }
}