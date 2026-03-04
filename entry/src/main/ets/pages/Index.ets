/**
 * 音乐项接口定义
 */
interface SongItem {
  id: number
  title: string
  artist: string
  duration: string
}

/**
 * 主题配置接口
 */
interface ThemeConfig {
  bg: string
  text: string
  accent: string
  card: string
  border: string
  secondaryText: string
  overlay: string
}

// 定义亮色主题常量
const LIGHT_THEME: ThemeConfig = {
  bg: '#FFFFFF',
  text: '#1F2937',
  accent: '#3B82F6',
  card: '#B3FFFFFF',
  border: '#E5E7EB',
  secondaryText: '#6B7280',
  overlay: '#66000000'
}

// 定义暗色主题常量
const DARK_THEME: ThemeConfig = {
  bg: '#0F1419',
  text: '#E5E7EB',
  accent: '#3B82F6',
  card: '#B31E1E28',
  border: '#1AFFFFFF',
  secondaryText: '#9CA3AF',
  overlay: '#80000000'
}

@Entry
@Component
struct Index {
  // 状态变量
  @State isDark: boolean = false
  @State isPlaying: boolean = true
  @State menuOpen: boolean = false
  @State currentTime: number = 57
  @State totalTime: number = 267
  @State volume: number = 70
  @State currentSongIdx: number = 0 // 使用索引管理
  @State vinylAngle: number = 0

  private timerId: number = -1

  private songs: SongItem[] = [
    { id: 1, title: 'Midnight Dreams', artist: 'Luna Echo', duration: '04:03' },
    { id: 2, title: 'Electric Sunrise', artist: 'Neon Waves', duration: '04:27' },
    { id: 3, title: 'Ocean Breeze', artist: 'Coastal Vibes', duration: '03:54' },
    { id: 4, title: 'Forest Symphony', artist: 'Nature Sounds', duration: '04:49' },
    { id: 5, title: 'Urban Pulse', artist: 'City Lights', duration: '04:16' }
  ]

  // 计算属性：获取当前主题，增加兜底逻辑防止 undefined
  private getTheme(): ThemeConfig {
    return this.isDark ? DARK_THEME : LIGHT_THEME
  }

  aboutToAppear(): void {
    this.startVinylAnimation()
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
    }
  }

  private startVinylAnimation(): void {
    this.timerId = setInterval(() => {
      if (this.isPlaying) {
        this.vinylAngle = (this.vinylAngle + 2) % 360
      }
    }, 20)
  }

  private formatTime(value: number): string {
    let m: number = Math.floor(value / 60)
    let s: number = value % 60
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }

  private chooseSong(idx: number): void {
    this.currentSongIdx = idx
    this.currentTime = 0
    this.menuOpen = false
    this.vinylAngle = 0
  }

  @Builder
  NavBar(isLandscape: boolean) {
    Row() {
      Text('Music Player')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTheme().text)

      Blank()

      Button(this.isDark ? '☀️' : '🌙')
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.isDark = !this.isDark)

      if (!isLandscape) {
        Button('☰')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.menuOpen = true)
          .margin({ left: 12 })
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: this.getTheme().border })
  }

  @Builder
  Vinyl(size: number) {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(size)
        .height(size)
        .fill(this.isDark ? '#101316' : '#111111')
        .shadow({ radius: 30, color: '#33000000', offsetY: 10 })

      Circle()
        .width(size * 0.7)
        .height(size * 0.7)
        .stroke(this.isDark ? '#2C2F36' : '#444444')
        .strokeWidth(1)

      Circle()
        .width(size * 0.2)
        .height(size * 0.2)
        .fill('#C0C4CC')

      Text('🎵')
        .fontSize(size * 0.1)
    }
    .rotate({ z: 1, angle: this.vinylAngle })
  }

  @Builder
  ControlsCard() {
    Column({ space: 16 }) {
      Text(this.songs[this.currentSongIdx].title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTheme().text)

      Text(this.songs[this.currentSongIdx].artist)
        .fontSize(16)
        .fontColor(this.getTheme().secondaryText)

      Column({ space: 4 }) {
        Slider({ value: this.currentTime, min: 0, max: this.totalTime })
          .selectedColor(this.getTheme().accent)
          .trackColor(this.getTheme().border)
          .onChange((v: number) => this.currentTime = Math.floor(v))

        Row() {
          Text(this.formatTime(this.currentTime)).fontSize(12).fontColor(this.getTheme().secondaryText)
          Blank()
          Text(this.songs[this.currentSongIdx].duration).fontSize(12).fontColor(this.getTheme().secondaryText)
        }.width('100%')
      }

      Row({ space: 30 }) {
        Text('⏮').fontSize(24).fontColor(this.getTheme().text)
          .onClick(() => this.chooseSong(Math.max(0, this.currentSongIdx - 1)))

        Stack() {
          Circle().width(64).height(64).fill(this.getTheme().accent)
          Text(this.isPlaying ? '⏸' : '▶').fontSize(28).fontColor('#FFFFFF')
        }.onClick(() => this.isPlaying = !this.isPlaying)

        Text('⏭').fontSize(24).fontColor(this.getTheme().text)
          .onClick(() => this.chooseSong(Math.min(this.songs.length - 1, this.currentSongIdx + 1)))
      }

      Row({ space: 12 }) {
        Text('🔊').fontSize(16).fontColor(this.getTheme().secondaryText)
        Slider({ value: this.volume, min: 0, max: 100 })
          .layoutWeight(1)
          .selectedColor(this.getTheme().accent)
        Text(`${this.volume}%`).fontSize(12).fontColor(this.getTheme().secondaryText)
      }.width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor(this.getTheme().card)
    .borderRadius(24)
    .border({ width: 1, color: this.getTheme().border })
  }

  @Builder
  PlaylistView() {
    Column() {
      Row() {
        Text('播放列表').fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.getTheme().text)
        Blank()
        Text('关闭').fontColor(this.getTheme().accent).onClick(() => this.menuOpen = false)
      }.width('100%').padding(20)

      List() {
        ForEach(this.songs, (item: SongItem, index: number) => {
          ListItem() {
            Row({ space: 12 }) {
              Text(`${index + 1}`).fontColor(this.getTheme().secondaryText).width(20)
              Column() {
                Text(item.title).fontColor(this.getTheme().text).fontSize(16)
                Text(item.artist).fontColor(this.getTheme().secondaryText).fontSize(12)
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Text(item.duration).fontColor(this.getTheme().secondaryText).fontSize(12)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.currentSongIdx === index ? '#1A3B82F6' : Color.Transparent)
            .onClick(() => this.chooseSong(index))
          }
        })
      }.layoutWeight(1)
    }
    .width('80%')
    .height('100%')
    .backgroundColor(this.getTheme().bg)
    .shadow({ radius: 50, color: '#40000000' })
  }

  build() {
    Stack() {
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getTheme().bg)

      // 主内容
      Column() {
        this.NavBar(false)

        Scroll() {
          Column({ space: 30 }) {
            this.Vinyl(260)
            this.ControlsCard()
          }
          .padding(24)
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      // 抽屉菜单遮罩
      if (this.menuOpen) {
        Row() {
          Rect()
            .width('20%')
            .height('100%')
            .fill(this.getTheme().overlay)
            .onClick(() => this.menuOpen = false)

          this.PlaylistView()
        }
        .width('100%')
        .height('100%')
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.move(TransitionEdge.END),
          TransitionEffect.move(TransitionEdge.END)
        ))
      }
    }
    .width('100%')
    .height('100%')
  }
}
