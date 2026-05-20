/**
 * 对应 Android 源文件: src/screens/index.ts
 *
 * 应用主入口页面，负责整体布局框架:
 * - 底部导航栏 (对应 BottomNavigation)
 * - 主页视图容器 (Home Screen)
 * - 播放控制栏 (PlayerBar)
 * - 横竖屏适配
 */

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Stack() {
      }
      .layoutWeight(1)
      .width('100%')

      Tabs({ index: this.currentIndex }) {
        TabContent() {
          Text('搜索')
        }
        .tabBar('搜索')

        TabContent() {
          Text('歌单')
        }
        .tabBar('歌单')

        TabContent() {
          Text('排行榜')
        }
        .tabBar('排行榜')

        TabContent() {
          Text('收藏')
        }
        .tabBar('收藏')

        TabContent() {
          Text('设置')
        }
        .tabBar('设置')
      }
      .barHeight(56)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
  }
}