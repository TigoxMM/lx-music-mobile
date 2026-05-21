/**
 * 对应 Android 源文件: src/screens/components/PlayerBar.tsx
 *
 * 底部迷你播放控制栏
 */
import { playerService } from '../service/PlayerService';
import { AppViewModel } from '../viewmodel/AppViewModel';

@Component
export struct PlayerBar {
  @Link isPlay: boolean;
  @Link musicName: string;
  @Link musicSinger: string;
  @Link playProgress: number;
  @Link nowPlayTimeStr: string;

  build() {
    Column() {
      Row() {
        // 封面区域
        Stack() {
          Image($r('app.media.app_icon'))
            .width(44)
            .height(44)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)
        }
        .width(44)
        .height(44)
        .borderRadius(6)
        .backgroundColor('#F0F0F0')

        // 歌曲信息
        Column() {
          Text(this.musicName || '落雪音乐')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(this.musicSinger || '点击播放')
            .fontSize(11)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 2 })
        }
        .margin({ left: 10 })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 播放/暂停按钮
        Button() {
          Image(
            this.isPlay ?
              $r('sys.media.ohos_ic_media_pause') :
              $r('sys.media.ohos_ic_media_play')
          )
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.isPlay) {
            playerService.pause();
          } else {
            playerService.play();
          }
          this.isPlay = !this.isPlay;
        })

        // 下一首
        Button() {
          Image($r('sys.media.ohos_ic_media_next'))
            .width(20)
            .height(20)
            .fillColor('#999999')
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .margin({ left: 4 })
        .onClick(() => {
          playerService.playNext();
        })
      }
      .width('100%')
      .padding({ left: 14, right: 10, top: 6, bottom: 6 })
      .alignItems(VerticalAlign.Center)

      // 进度条
      Progress({
        value: Math.round(this.playProgress * 100),
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(2)
        .color('#07C556')
        .backgroundColor('#EEEEEE')
    }
    .width('100%')
    .backgroundColor('#FAFAFA')
  }
}