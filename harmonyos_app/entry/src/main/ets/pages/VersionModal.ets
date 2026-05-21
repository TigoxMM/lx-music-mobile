/**
 * 对应 Android 源文件: src/screens/Modal/VersionModal.tsx
 *
 * 版本更新弹窗
 */
import { router } from '@kit.ArkUI';

@Component
export struct VersionModal {
  @State version: string = '1.8.4';
  @State changelog: string = '暂无更新日志';
  @State hasUpdate: boolean = false;

  aboutToAppear(): void {
    this.checkVersion();
  }

  async checkVersion(): Promise<void> {
    this.hasUpdate = false;
    // TODO: 对接实际更新 API
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('版本更新')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('v' + this.version)
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(20)

      Divider().color('#F0F0F0')

      if (this.hasUpdate) {
        Column() {
          Text('发现新版本!')
            .fontSize(16)
            .fontColor('#07C556')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 16 })

          Text(this.changelog)
            .fontSize(13)
            .fontColor('#666666')
            .maxLines(8)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .padding({ left: 20, right: 20, top: 10 })
            .textAlign(TextAlign.Start)

          Button('立即更新')
            .width('80%')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#07C556')
            .borderRadius(22)
            .margin({ top: 20, bottom: 10 })
            .onClick(() => {
              console.log('start update');
            })

          Text('稍后提醒')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ bottom: 16 })
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          Text('已是最新版本')
            .fontSize(15)
            .fontColor('#999999')
            .margin({ top: 30 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }

      Blank()

      Button('确定')
        .width('80%')
        .height(44)
        .fontSize(15)
        .fontColor('#07C556')
        .backgroundColor('#F5F5F5')
        .borderRadius(22)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}