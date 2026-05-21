/**
 * 对应 Android 源文件: src/screens/Home/Views/Mylist/index.tsx
 *
 * 我的列表页 - 包含试听列表、我的收藏和用户自定义列表
 */
import { AppViewModel } from '../../viewmodel/AppViewModel';
import { UserListInfo } from '../../model/ListInfo';
import { playerService } from '../../service/PlayerService';
import { MusicInfo, MusicInfoOnline } from '../../model/MusicInfo';
import { getListMusics } from '../../database/DataStore';

@Component
export struct MyListPage {
  @Prop viewModel: AppViewModel;

  build() {
    Column() {
      // 固定列表项
      Column() {
        Row() {
          Image($r('sys.media.ohos_ic_public_music'))
            .width(24)
            .height(24)
            .fillColor('#07C556')
            .margin({ right: 12 })

          Column() {
            Text('试听列表')
              .fontSize(15)
              .fontColor('#333333')
            Text('未保存到任何列表的试听歌曲')
              .fontSize(11)
              .fontColor('#CCCCCC')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(16)
            .height(16)
            .fillColor('#CCCCCC')
        }
        .width('100%')
        .height(60)
        .padding({ left: 14, right: 14 })
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.viewModel.activeListId = 'default';
        })

        Divider().color('#F5F5F5').width('100%')

        Row() {
          Image($r('sys.media.ohos_ic_public_favor_filled'))
            .width(24)
            .height(24)
            .fillColor('#FF5252')
            .margin({ right: 12 })

          Column() {
            Text('我的收藏')
              .fontSize(15)
              .fontColor('#333333')
            Text('收藏的歌曲')
              .fontSize(11)
              .fontColor('#CCCCCC')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(16)
            .height(16)
            .fillColor('#CCCCCC')
        }
        .width('100%')
        .height(60)
        .padding({ left: 14, right: 14 })
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.viewModel.activeListId = 'love';
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .margin({ top: 14, left: 14, right: 14 })

      // 分隔标题
      Row() {
        Text('我的列表')
          .fontSize(13)
          .fontColor('#999999')
          .fontWeight(FontWeight.Medium)

        Blank()

        Text('新建')
          .fontSize(13)
          .fontColor('#07C556')
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 16, bottom: 8 })

      // 用户自定义列表
      if (this.viewModel.userList.length === 0) {
        Column() {
          Text('暂无列表')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 40 })
          Text('点击右上角"新建"创建一个列表')
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ top: 6 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.viewModel.userList, (item: UserListInfo) => {
            ListItem() {
              Row() {
                Text(item.name)
                  .fontSize(15)
                  .fontColor(this.viewModel.activeListId === item.id ? '#07C556' : '#333333')
                  .fontWeight(this.viewModel.activeListId === item.id ? FontWeight.Medium : FontWeight.Normal)
                  .maxLines(1)
                  .layoutWeight(1)

                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .height(16)
                  .fillColor('#CCCCCC')
              }
              .width('100%')
              .height(50)
              .padding({ left: 14, right: 14 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.viewModel.activeListId = item.id;
              })
            }
          }, (item: UserListInfo) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }
}