/**
 * 对应 Android 源文件: src/screens/index.ts
 * 对应 Android 源文件: src/screens/Home/index.tsx
 *
 * 应用主入口页面 - 包含底部 Tab 导航和 PlayerBar
 */
import { AppViewModel } from '../viewmodel/AppViewModel';
import { PlayerBar } from '../components/PlayerBar';
import { SearchPage } from './SearchPage';
import { SongListPage } from './SongListPage';
import { LeaderboardPage } from './LeaderboardPage';
import { MyListPage } from './MyListPage';
import { SettingPage } from './SettingPage';
import { NavIdType } from '../constants/Constant';
import { playerService } from '../service/PlayerService';

@Entry
@Component
struct Index {
  @State viewModel: AppViewModel = new AppViewModel();
  @State currentTabIndex: number = 0;
  @State isPlay: boolean = false;
  @State musicName: string = '落雪音乐';
  @State musicSinger: string = '点击播放';
  @State playProgress: number = 0;
  @State nowPlayTimeStr: string = '00:00';
  @State showPlayerBar: boolean = true;

  private tabTitles: NavIdType[] = ['nav_search', 'nav_songlist', 'nav_top', 'nav_love', 'nav_setting'];

  aboutToAppear(): void {
    playerService.init();
  }

  build() {
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(0)

      // 主内容区
      Tabs({ index: this.currentTabIndex }) {
        TabContent() {
          SearchPage({ viewModel: this.viewModel })
        }
        .tabBar(this.getTabBar('nav_search', '搜索', 0))

        TabContent() {
          SongListPage({ viewModel: this.viewModel })
        }
        .tabBar(this.getTabBar('nav_songlist', '歌单', 1))

        TabContent() {
          LeaderboardPage({ viewModel: this.viewModel })
        }
        .tabBar(this.getTabBar('nav_top', '排行榜', 2))

        TabContent() {
          MyListPage({ viewModel: this.viewModel })
        }
        .tabBar(this.getTabBar('nav_love', '我的', 3))

        TabContent() {
          SettingPage({ viewModel: this.viewModel })
        }
        .tabBar(this.getTabBar('nav_setting', '设置', 4))
      }
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index;
        this.viewModel.switchNav(this.tabTitles[index]);
      })

      // 播放控制栏
      if (this.showPlayerBar) {
        PlayerBar({
          isPlay: this.isPlay,
          musicName: this.musicName,
          musicSinger: this.musicSinger,
          playProgress: this.playProgress,
          nowPlayTimeStr: this.nowPlayTimeStr,
        })
          .onClick(() => {
            // 跳转播放详情页
            console.log('navigate to play detail');
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  getTabBar(id: NavIdType, title: string, index: number): void {
    Column() {
      Text(title)
        .fontSize(11)
        .fontColor(this.currentTabIndex === index ? '#07C556' : '#999999')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ top: 2 })
  }
}