/**
 * 对应 Android 源文件: src/screens/Modal/PactModal.tsx
 *
 * 用户协议弹窗
 */
import { router } from '@kit.ArkUI';

@Component
export struct PactModal {
  @State isAgree: boolean = false;

  build() {
    Column() {
      Text('用户协议')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 20 })

      Scroll() {
        Column() {
          Text('欢迎使用落雪音乐！\n\n' +
            '本软件为开源免费软件，仅供学习交流使用。\n\n' +
            '使用本软件即表示您同意以下条款：\n\n' +
            '1. 本软件不提供任何音频资源的存储服务，所有音频资源均来自公共网络。\n' +
            '2. 本软件仅提供音频资源的搜索和播放功能，不鼓励下载和分发受版权保护的内容。\n' +
            '3. 用户应自行承担使用本软件过程中可能存在的法律风险。\n' +
            '4. 软件开发者不对用户使用本软件的任何行为负责。\n\n' +
            '如您不同意以上条款，请立即停止使用本软件。')
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(22)
            .width('100%')
            .padding({ left: 20, right: 20, top: 10 })
            .textAlign(TextAlign.Start)
        }
      }
      .width('90%')
      .layoutWeight(1)
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      .margin({ top: 10 })

      Button('同意并继续')
        .width('80%')
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#07C556')
        .borderRadius(22)
        .margin({ top: 16, bottom: 20 })
        .onClick(() => {
          this.isAgree = true;
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}