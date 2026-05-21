/**
 * 对应 Android 源文件: src/screens/Modal/SyncModeModal.tsx
 *
 * 同步模式选择弹窗
 */

@Component
export struct SyncModeModal {
  @State selectedMode: string = 'server';

  build() {
    Column() {
      Text('同步模式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 20 })

      Divider().color('#F0F0F0')
        .margin({ top: 12 })

      Column() {
        this.modeOption(
          'server',
          '服务端模式',
          '作为同步服务端，其他设备可连接到此设备进行同步',
          $r('sys.media.ohos_ic_public_server')
        );

        this.modeOption(
          'client',
          '客户端模式',
          '作为同步客户端，连接到其他设备的同步服务',
          $r('sys.media.ohos_ic_public_client')
        );

        this.modeOption(
          'both',
          '双模式',
          '同时作为服务端和客户端',
          $r('sys.media.ohos_ic_public_network')
        );
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12 })
      .layoutWeight(1)

      Button('确定')
        .width('80%')
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#07C556')
        .borderRadius(22)
        .margin({ bottom: 20 })
        .onClick(() => {
          console.log('sync mode selected: ' + this.selectedMode);
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  modeOption(mode: string, title: string, desc: string, icon: Resource): void {
    Row() {
      Image(icon)
        .width(32)
        .height(32)
        .fillColor(this.selectedMode === mode ? '#07C556' : '#999999')

      Column() {
        Text(title)
          .fontSize(15)
          .fontColor(this.selectedMode === mode ? '#07C556' : '#333333')
          .fontWeight(this.selectedMode === mode ? FontWeight.Medium : FontWeight.Normal)

        Text(desc)
          .fontSize(11)
          .fontColor('#999999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      if (this.selectedMode === mode) {
        Image($r('sys.media.ohos_ic_public_ok'))
          .width(20)
          .height(20)
          .fillColor('#07C556')
      }
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .onClick(() => {
      this.selectedMode = mode;
    })
  }
}