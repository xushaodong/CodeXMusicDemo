interface SongItem {
  id: number
  title: string
  artist: string
  duration: string
}

const LIGHT_THEME = {
  bg: '#FFFFFF',
  text: '#1F2937',
  accent: '#3B82F6',
  card: '#B3FFFFFF',
  border: '#E5E7EB',
  secondaryText: '#6B7280',
  overlay: '#66000000'
}

const DARK_THEME = {
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
  @State isDark: boolean = true
  @State isPlaying: boolean = true
  @State menuOpen: boolean = false
  @State currentTime: number = 57
  @State totalTime: number = 267
  @State volume: number = 70
  @State currentSong: number = 1
  @State vinylAngle: number = 0

  private songs: SongItem[] = [
    { id: 1, title: 'Midnight Dreams', artist: 'Luna Echo', duration: '04:03' },
    { id: 2, title: 'Electric Sunrise', artist: 'Neon Waves', duration: '04:27' },
    { id: 3, title: 'Ocean Breeze', artist: 'Coastal Vibes', duration: '03:54' },
    { id: 4, title: 'Forest Symphony', artist: 'Nature Sounds', duration: '04:49' },
    { id: 5, title: 'Urban Pulse', artist: 'City Lights', duration: '04:16' }
  ]

  private get theme() {
    return this.isDark ? DARK_THEME : LIGHT_THEME
  }

  aboutToAppear(): void {
    this.rotateVinyl()
  }

  private rotateVinyl(): void {
    setInterval(() => {
      if (this.isPlaying) {
        this.vinylAngle = (this.vinylAngle + 3) % 360
      }
    }, 16)
  }

  private formatTime(value: number): string {
    let m: number = Math.floor(value / 60)
    let s: number = value % 60
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }

  private chooseSong(idx: number): void {
    this.currentSong = idx
    this.currentTime = 0
    this.menuOpen = false
    this.vinylAngle = 0
  }

  @Builder
  NavBar(isLandscape: boolean) {
    Row() {
      Text('Music Player')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.text)

      Blank()

      Button(this.isDark ? '☀️' : '🌙')
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .borderRadius(8)
        .onClick(() => this.isDark = !this.isDark)

      if (!isLandscape) {
        Button('☰')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .borderRadius(8)
          .onClick(() => this.menuOpen = true)
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
    .border({ width: { bottom: 1 }, color: this.theme.border })
  }

  @Builder
  Vinyl(size: number) {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(size)
        .height(size)
        .fill(this.isDark ? '#101316' : '#111111')
        .shadow({ radius: 20, color: this.isDark ? '#80000000' : '#30000000', offsetX: 0, offsetY: 8 })

      Circle()
        .width(size * 0.72)
        .height(size * 0.72)
        .stroke(this.isDark ? '#2C2F36' : '#444444', 2)

      Circle()
        .width(size * 0.18)
        .height(size * 0.18)
        .fill('#C0C4CC')

      Circle()
        .width(size * 0.04)
        .height(size * 0.04)
        .fill(this.theme.bg)

      Text('🎵')
        .fontSize(34)
    }
    .rotate({ z: 1, angle: this.vinylAngle })
    .animation({ duration: 100, curve: Curve.Linear })
    .scale({ x: 1, y: 1 })
  }

  @Builder
  ControlsCard() {
    Column({ space: 16 }) {
      Text(this.songs[this.currentSong].title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.text)
      Text(this.songs[this.currentSong].artist)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.theme.secondaryText)

      Column({ space: 8 }) {
        Slider({ value: this.currentTime, min: 0, max: this.totalTime })
          .blockColor(this.theme.accent)
          .trackThickness(4)
          .onChange((v: number) => this.currentTime = Math.floor(v))

        Row() {
          Text(this.formatTime(this.currentTime)).fontSize(12).fontColor(this.theme.secondaryText)
          Blank()
          Text(this.songs[this.currentSong].duration).fontSize(12).fontColor(this.theme.secondaryText)
        }
        .width('100%')
      }

      Row({ space: 24 }) {
        Button('⏮').width(52).height(52).borderRadius(26)
          .backgroundColor(this.theme.card)
          .onClick(() => this.chooseSong(Math.max(0, this.currentSong - 1)))

        Button(this.isPlaying ? '⏸' : '▶')
          .width(60)
          .height(60)
          .borderRadius(30)
          .backgroundColor(this.theme.accent)
          .fontColor('#FFFFFF')
          .onClick(() => this.isPlaying = !this.isPlaying)

        Button('⏭').width(52).height(52).borderRadius(26)
          .backgroundColor(this.theme.card)
          .onClick(() => this.chooseSong(Math.min(this.songs.length - 1, this.currentSong + 1)))
      }

      Row({ space: 12 }) {
        Text('🔊').fontSize(18)
        Slider({ value: this.volume, min: 0, max: 100 })
          .blockColor(this.theme.accent)
          .trackThickness(4)
          .onChange((v: number) => this.volume = Math.floor(v))
          .layoutWeight(1)
        Text(`${this.volume}%`)
          .fontSize(12)
          .fontColor(this.theme.secondaryText)
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor(this.theme.card)
    .borderRadius(16)
    .backdropBlur(18)
    .border({ width: 1, color: this.theme.border })
  }

  @Builder
  Playlist(simple: boolean = false) {
    Column({ space: 8 }) {
      Row() {
        Text('Playlist')
          .fontSize(18)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(this.theme.text)
        Blank()
        if (!simple) {
          Button('✕')
            .backgroundColor(Color.Transparent)
            .onClick(() => this.menuOpen = false)
        }
      }

      List({ space: 8 }) {
        ForEach(this.songs, (song: SongItem, idx: number) => {
          ListItem() {
            Row() {
              Text(`${song.id}`).width(28).fontColor(this.theme.secondaryText)
              if (simple) {
                Text(`${song.title} - ${song.artist}`).layoutWeight(1).fontColor(this.theme.text)
              } else {
                Column({ space: 2 }) {
                  Text(song.title).fontColor(this.theme.text)
                  Text(song.artist).fontSize(12).fontColor(this.theme.secondaryText)
                }
                .layoutWeight(1)
              }
              Text(song.duration).fontSize(12).fontColor(this.theme.secondaryText)
            }
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .backgroundColor(this.currentSong === idx ? '#333B82F6' : this.theme.card)
            .onClick(() => this.chooseSong(idx))
          }
        }, (song: SongItem) => song.id.toString())
      }
      .layoutWeight(1)
    }
    .height('100%')
    .padding(16)
    .backgroundColor(this.theme.card)
    .borderRadius(16)
    .backdropBlur(18)
    .border({ width: 1, color: this.theme.border })
  }

  @Builder
  PortraitLayout() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: 24 }) {
        this.NavBar(false)

        Column({ space: 24 }) {
          this.Vinyl(280)
          this.ControlsCard()
        }
        .padding({ left: 24, right: 24, bottom: 24 })
      }

      if (this.menuOpen) {
        Row() {
          Blank()
            .onClick(() => this.menuOpen = false)
            .backgroundColor(this.theme.overlay)

          Column() {
            this.Playlist(false)
          }
          .width('78%')
          .height('100%')
          .padding(12)
          .backgroundColor(this.theme.overlay)
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  @Builder
  LandscapeLayout() {
    Column({ space: 12 }) {
      this.NavBar(true)

      Row({ space: 24 }) {
        Column() {
          this.Vinyl(320)
        }
        .width('40%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        Column({ space: 16 }) {
          this.ControlsCard()
        }
        .width('60%')
        .height('100%')
      }
      .layoutWeight(1)
      .padding({ left: 24, right: 24 })

      Column() {
        this.Playlist(true)
      }
      .height('40%')
      .padding({ left: 24, right: 24, bottom: 16 })
    }
  }

  build() {
    Column() {
      If(this.getUIContext().windowStage?.getMainWindowSync().getWindowProperties().windowRect.width >
        this.getUIContext().windowStage?.getMainWindowSync().getWindowProperties().windowRect.height, () => {
        this.LandscapeLayout()
      }, () => {
        this.PortraitLayout()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
}
