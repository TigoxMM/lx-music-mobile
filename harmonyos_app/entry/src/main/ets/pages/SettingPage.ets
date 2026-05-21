/**
 * 对应 Android 源文件: src/screens/Home/Views/Setting/index.tsx
 * 对应 Android 源文件: src/store/setting/state.ts
 *
 * 设置页
 */
import { AppViewModel } from '../../viewmodel/AppViewModel';
import { AppSetting } from '../../model/AppSetting';
import { saveData, getData } from '../../database/PreferencesStore';
import { storageDataPrefix } from '../../constants/Constant';
import { getDefaultSetting } from '../../constants/DefaultSetting';

@Component
export struct SettingPage {
  @Prop viewModel: AppViewModel;

  build() {
    Column() {
      Scroll() {
        Column() {
          // ========== 常规设置 ==========
          this.sectionHeader('常规设置');

          this.settingItem('播放与下载', '常见的设置项', () => {
            console.log('navigate to play setting');
          });

          this.settingItem('主题与外观', '深色模式、主题色等', () => {
            console.log('navigate to theme setting');
          });

          this.settingItem('语言', this.getLangName(), () => {
            console.log('change language');
          });

          this.toggleItem(
            '自动更换主题',
            '是否自动跟随日出日落切换主题',
            this.viewModel.setting['common.isAutoTheme'],
            (value: boolean) => {
              this.updateCommonSetting('isAutoTheme', value);
            }
          );

          // ========== 播放设置 ==========
          this.sectionHeader('播放设置');

          this.toggleItem(
            '显示歌词翻译',
            '在歌词下方显示翻译',
            this.viewModel.setting['player.isShowLyricTranslation'],
            (value: boolean) => {
              this.updatePlayerSetting('isShowLyricTranslation', value);
            }
          );

          this.toggleItem(
            '显示罗马音',
            '在歌词下方显示罗马音',
            this.viewModel.setting['player.isShowLyricRoma'],
            (value: boolean) => {
              this.updatePlayerSetting('isShowLyricRoma', value);
            }
          );

          this.toggleItem(
            '简繁转换',
            '将歌词转换为简体中文',
            this.viewModel.setting['player.isS2t'],
            (value: boolean) => {
              this.updatePlayerSetting('isS2t', value);
            }
          );

          this.settingItem(
            '默认播放音质',
            this.viewModel.setting['player.playQuality'],
            () => {
              console.log('change quality');
            }
          );

          // ========== 桌面歌词 ==========
          this.sectionHeader('桌面歌词');

          this.toggleItem(
            '启用桌面歌词',
            '在桌面显示歌词悬浮窗',
            this.viewModel.setting['desktopLyric.enable'],
            (value: boolean) => {
              this.updateSetting('desktopLyric.enable', value);
            }
          );

          this.toggleItem(
            '锁定桌面歌词',
            '锁定后无法拖动歌词窗口',
            this.viewModel.setting['desktopLyric.isLock'],
            (value: boolean) => {
              this.updateSetting('desktopLyric.isLock', value);
            }
          );

          this.toggleItem(
            '单行歌词',
            '仅显示一行歌词',
            this.viewModel.setting['desktopLyric.isSingleLine'],
            (value: boolean) => {
              this.updateSetting('desktopLyric.isSingleLine', value);
            }
          );

          // ========== 数据设置 ==========
          this.sectionHeader('数据设置');

          this.toggleItem(
            '列表同步',
            '通过局域网同步列表数据',
            this.viewModel.setting['sync.enable'],
            (value: boolean) => {
              this.updateSetting('sync.enable', value);
            }
          );

          this.settingItem('导入列表', '从文件导入播放列表', () => {
            console.log('import list');
          });

          this.settingItem('导出列表', '将播放列表导出为文件', () => {
            console.log('export list');
          });

          // ========== 关于 ==========
          this.sectionHeader('关于');

          Row() {
            Text('落雪音乐')
              .fontSize(15)
              .fontColor('#333333')

            Blank()

            Text('v1.8.4')
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')
          .height(50)
          .padding({ left: 14, right: 14 })

          Row() {
            Text('检查更新')
              .fontSize(15)
              .fontColor('#333333')

            Blank()

            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(16)
              .height(16)
              .fillColor('#CCCCCC')
          }
          .width('100%')
          .height(50)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            console.log('check update');
          })

          // ========== 重置 ==========
          this.sectionHeader('');

          Text('恢复默认设置')
            .fontSize(15)
            .fontColor('#FF5252')
            .width('100%')
            .height(50)
            .padding({ left: 14, right: 14 })
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.resetSettings();
            })

          Blank()
            .height(40)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  sectionHeader(title: string): void {
    if (title) {
      Text(title)
        .fontSize(12)
        .fontColor('#999999')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: 14, top: 20, bottom: 6 })
        .backgroundColor('#F8F8F8')
    }
  }

  @Builder
  settingItem(title: string, desc: string, onClick: () => void): void {
    Row() {
      Column() {
        Text(title)
          .fontSize(15)
          .fontColor('#333333')
        if (desc) {
          Text(desc)
            .fontSize(11)
            .fontColor('#CCCCCC')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .minHeight(50)
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
    .onClick(onClick)
  }

  @Builder
  toggleItem(title: string, desc: string, value: boolean, onChange: (value: boolean) => void): void {
    Row() {
      Column() {
        Text(title)
          .fontSize(15)
          .fontColor('#333333')
        if (desc) {
          Text(desc)
            .fontSize(11)
            .fontColor('#CCCCCC')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor('#07C556')
        .onChange((isOn: boolean) => {
          onChange(isOn);
        })
    }
    .width('100%')
    .minHeight(50)
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
  }

  private getLangName(): string {
    const langId = this.viewModel.setting['common.langId'];
    if (langId === 'cns') return '简体中文';
    if (langId === 'cnt') return '繁體中文';
    return '跟随系统';
  }

  private async updateSetting(key: keyof AppSetting, value: Object): Promise<void> {
    const newSetting = { ...this.viewModel.setting };
    (newSetting as Record<string, Object>)[key] = value;
    this.viewModel.setting = newSetting;
    await saveData(storageDataPrefix.setting, newSetting);
  }

  private async updateCommonSetting(subKey: string, value: Object): Promise<void> {
    const fullKey = `common.${subKey}`;
    await this.updateSetting(fullKey as keyof AppSetting, value);
  }

  private async updatePlayerSetting(subKey: string, value: Object): Promise<void> {
    const fullKey = `player.${subKey}`;
    await this.updateSetting(fullKey as keyof AppSetting, value);
  }

  private async resetSettings(): Promise<void> {
    const defaultSetting = getDefaultSetting();
    defaultSetting['common.isAgreePact'] = this.viewModel.setting['common.isAgreePact'];
    this.viewModel.setting = defaultSetting;
    await saveData(storageDataPrefix.setting, defaultSetting);
  }
}