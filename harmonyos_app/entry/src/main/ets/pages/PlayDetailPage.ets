/**
 * 对应 Android 源文件: src/screens/PlayDetail/index.tsx
 * 对应 Android 源文件: src/screens/PlayDetail/vertical/Vertical.tsx
 * 对应 Android 源文件: src/screens/PlayDetail/horizontal/Horizontal.tsx
 *
 * 播放详情页
 */
import { AppViewModel } from '../viewmodel/AppViewModel';
import { playerService } from '../service/PlayerService';
import { AppEventBus, appEventBus } from '../service/AppEventBus';
import { MUSIC_TOGGLE_MODE } from '../constants/Constant';
import { router } from '@kit.ArkUI';

@Component
export struct PlayDetailPage {
  @Prop viewModel: AppViewModel;
  @State isPlay: boolean = false;
  @State name: string = '';
  @State singer: string = '';
  @State album: string = '';
  @State nowPlayTimeStr: string = '00:00';
  @State maxPlayTimeStr: string = '00:00';
  @State progress: number = 0;
  @State toggleMode: string = 'listLoop';
  @State isLoved: boolean = false;

  aboutToAppear(): void {
    this.isPlay = playerService.isPlay;
    this.name = playerService.musicInfo.name;
    this.singer = playerService.musicInfo.singer;
    this.album = playerService.musicInfo.album;
    this.nowPlayTimeStr = playerService.progress.nowPlayTimeStr;
    this.maxPlayTimeStr = playerService.progress.maxPlayTimeStr;
    this.progress = playerService.progress.progress;
    this.toggleMode = playerService.togglePlayMethod;

    appEventBus.on(AppEventBus.EVENT_PLAYER_PLAYING, () => {
      this.isPlay = true;
    });
    appEventBus.on(AppEventBus.EVENT_PLAYER_PAUSE, () => {
      this.isPlay = false;
    });
  }

  aboutToDisappear(): void {
    appEventBus.off(AppEventBus.EVENT_PLAYER_PLAYING, () => {});
    appEventBus.off(AppEventBus.EVENT_PLAYER_PAUSE, () => {});
  }

  private togglePlayPause(): void {
    if (this.isPlay) {
      playerService.pause();
    } else {
      playerService.play();
    }
    this.isPlay = !this.isPlay;
  }

  private togglePlayMode(): void {
    const modes: string[] = ['listLoop', 'random', 'list', 'singleLoop', 'none'];
    const currentIndex = modes.indexOf(this.toggleMode);
    const nextIndex = (currentIndex + 1) % modes.length;
    this.toggleMode = modes[nextIndex];
    playerService.togglePlayMethod = this.toggleMode as 'listLoop' | 'random' | 'list' | 'singleLoop' | 'none';
  }

  private getPlayModeIcon(): ResourceStr {
    switch (this.toggleMode) {
      case 'listLoop': return $r('sys.media.ohos_ic_media_loop');
      case 'singleLoop': return $r('sys.media.ohos_ic_media_singleloop');
      case 'random': return $r('sys.media.ohos_ic_media_shuffle');
      default: return $r('sys.media.ohos_ic_media_sequential');
    }
  }

  private onProgressChange(value: number): void {
    this.progress = value / 100;
    if (this.isPlay) {
      playerService.setProgress(value / 100);
    }
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

        Blank()

        Column() {
          Text(this.name || '未知歌曲')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)

          Text(`${this.singer || '未知歌手'} - ${this.album || ''}`)
            .fontSize(12)
            .fontColor('#999999')
            .maxLines(1)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Blank()

        // 评论入口
        Image($r('sys.media.ohos_ic_public_message'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            console.log('navigate to comment');
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 14, right: 14 })

      // 封面区域
      Column() {
        Image(
          this.viewModel.currentMusicPic || $r('app.media.app_icon')
        )
          .width('70%')
          .aspectRatio(1)
          .borderRadius(12)
          .backgroundColor('#F0F0F0')
          .objectFit(ImageFit.Cover)
          .shadow({
            radius: 12,
            color: 'rgba(0,0,0,0.15)',
            offsetX: 0,
            offsetY: 4,
          })
      }
      .width('100%')
      .margin({ top: 30 })
      .justifyContent(FlexAlign.Center)

      // 歌曲信息
      Column() {
        Text(this.name || '未知歌曲')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${this.singer || '未知歌手'} - ${this.album || ''}`)
          .fontSize(13)
          .fontColor('#999999')
          .maxLines(1)
          .margin({ top: 6 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 24 })
      .padding({ left: 30, right: 30 })

      // 进度条
      Column() {
        Slider({
          value: Math.round(this.progress * 100),
          min: 0,
          max: 100,
        })
          .width('100%')
          .blockColor('#07C556')
          .trackColor('#E0E0E0')
          .selectedColor('#07C556')
          .trackThickness(3)
          .selectedBorderRadius(1.5)
          .onChange((value: number) => {
            this.onProgressChange(value);
          })

        Row() {
          Text(this.nowPlayTimeStr)
            .fontSize(11)
            .fontColor('#999999')

          Blank()

          Text(this.maxPlayTimeStr)
            .fontSize(11)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ top: 2 })
      }
      .width('100%')
      .padding({ left: 30, right: 30 })
      .margin({ top: 32 })

      // 控制按钮
      Row() {
        // 播放模式
        Image(this.getPlayModeIcon())
          .width(22)
          .height(22)
          .fillColor('#666666')
          .onClick(() => {
            this.togglePlayMode();
          })

        Blank()

        // 上一首
        Image($r('sys.media.ohos_ic_media_previous'))
          .width(32)
          .height(32)
          .fillColor('#333333')

        // 播放/暂停
        Button() {
          Image(
            this.isPlay ?
              $r('sys.media.ohos_ic_media_pause') :
              $r('sys.media.ohos_ic_media_play')
          )
            .width(36)
            .height(36)
            .fillColor('#FFFFFF')
        }
        .width(60)
        .height(60)
        .borderRadius(30)
        .backgroundColor('#07C556')
        .margin({ left: 20, right: 20 })
        .onClick(() => {
          this.togglePlayPause();
        })

        // 下一首
        Image($r('sys.media.ohos_ic_media_next'))
          .width(32)
          .height(32)
          .fillColor('#333333')

        Blank()

        // 收藏
        Image(
          this.isLoved ?
            $r('sys.media.ohos_ic_public_favor_filled') :
            $r('sys.media.ohos_ic_public_favor')
        )
          .width(22)
          .height(22)
          .fillColor(this.isLoved ? '#FF5252' : '#666666')
          .onClick(() => {
            this.isLoved = !this.isLoved;
          })
      }
      .width('100%')
      .padding({ left: 30, right: 30 })
      .alignItems(VerticalAlign.Center)
      .margin({ top: 24 })

      // 歌词区域
      Column() {
        Text('歌词功能开发中...')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}