import { window } from '@kit.ArkUI';

interface SettingItem {
  id: string;
  title: string;
  desc: string;
  type: 'toggle' | 'select' | 'slider';
}

@Entry
@Component
struct WearablePerformanceDashboard {
  // --- Reusable item data ---
  private settingsItems: SettingItem[] = [
    { id: 'opt_enable', title: 'Enable/Disable', desc: 'Toggle interactivity', type: 'toggle' },
    { id: 'opt_visibility', title: 'Visibility', desc: 'Show/Hide/None', type: 'select' },
    { id: 'opt_zorder', title: 'Z-order', desc: 'Layer stacking', type: 'slider' },
    { id: 'opt_overlay', title: 'Overlay', desc: 'Float on top', type: 'toggle' },
    { id: 'opt_rounding_comp', title: 'Comp Rounding', desc: 'Sub-pixel fix', type: 'toggle' },
    { id: 'opt_rounding_page', title: 'Page Rounding', desc: 'Global snap', type: 'toggle' },
    { id: 'opt_reuse_options', title: 'Reuse Cache', desc: 'List recycling', type: 'slider' }
  ];

  // Recyclable list data
  private recyclableItems: string[] = [
    'Performance Monitor', 'Battery Saver', 'Frame Optimizer',
    'Memory Cleaner', 'Render Cache', 'UI Accelerator'
  ];

  // Demo state variables
  @State enableDemoActive: boolean = true;
  @State visibilityState: Visibility = Visibility.Visible;
  @State zIndexFront: number = 0;
  @State overlayVisible: boolean = false;
  @State componentRoundingEnabled: boolean = false;
  @State pageRoundingEnabled: boolean = false;
  @State reuseCacheSize: number = 10;
  @State listItemActiveId: string = 'opt_enable';
  // Performance metrics
  @State frameTimeMs: number = 0;
  @State renderTimeMs: number = 0;
  @State memoryDeltaKB: number = 0;
  private lastMemUsage: number = 0;
  private frameInterval: number = 0;
  private lastTimestamp: number = 0;

  aboutToAppear() {
    this.startPerformanceMonitoring();
    if (this.pageRoundingEnabled) {
      this.applyPageRounding(true);
    }
  }

  aboutToDisappear() {
    if (this.frameInterval) {
      clearInterval(this.frameInterval);
    }
  }

  startPerformanceMonitoring() {
    this.lastTimestamp = Date.now();
    this.frameInterval = setInterval(() => {
      const now = Date.now();
      this.lastTimestamp = now;

      const simulatedFrameTime = 12 + (now % 7);
      this.frameTimeMs = simulatedFrameTime;
      this.renderTimeMs = simulatedFrameTime * 0.6;

      const newMem = 42000 + (this.reuseCacheSize * 80);
      this.memoryDeltaKB = newMem - this.lastMemUsage;
      this.lastMemUsage = newMem;
    }, 1000);
  }

  applyPageRounding(enable: boolean) {
    if (enable) {
      console.info('Page-level pixel rounding ENABLED');
      window.getLastWindow(this.getUIContext().getHostContext()!, (err: Error, win: window.Window) => {
        if (!err && win) {
          win.setWindowLayoutFullScreen(true);
        }
      });
    } else {
      console.info('Page-level pixel rounding DISABLED');
    }
  }

  @Builder
  RoundedContentExample() {
    Text(`← Rounding ON →`)
      .fontSize(10)
      .padding({ top: 6, bottom: 6, left: 12, right: 12 })
      .backgroundColor('#1B5E20')
      .borderRadius(16)
      .margin({ top: 4 })
  }

  @Builder
  SettingItemRow(item: SettingItem) {
    Row() {
      Column() {
        Text(item.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
        Text(item.desc)
          .fontSize(9)
          .fontColor('#9E9E9E')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })

      Blank()

      if (item.type === 'toggle') {
        Toggle({ type: ToggleType.Switch, isOn: this.getToggleValue(item.id) })
          .width(36)
          .height(20)
          .onChange((isOn: boolean) => this.handleToggle(item.id, isOn))
      } else if (item.type === 'select') {
        Select([{ value: 'Show' }, { value: 'Hide' }, { value: 'None' }])
          .selected(this.getVisibilityIndex())
          .onSelect((index: number) => this.handleVisibilityChange(index))
          .width(80)
          .height(32)
          .backgroundColor('#424242')
          .fontColor('#FFFFFF')
      } else if (item.type === 'slider') {
        Slider({
          value: this.getSliderValue(item.id),
          min: 0,
          max: 20,
          step: 1
        })
          .width(100)
          .blockColor('#FF9800')
          .trackColor('#424242')
          .selectedColor('#FF9800')
          .onChange((value: number) => this.handleSlider(item.id, value))
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 12, right: 12 })
    .borderRadius(12)
    .backgroundColor(this.getItemBackgroundColor(item.id))
    .margin({ bottom: 6 })
  }

  getToggleValue(id: string): boolean {
    if (id === 'opt_enable') {return this.enableDemoActive;}
    if (id === 'opt_overlay') {return this.overlayVisible;}
    if (id === 'opt_rounding_comp') {return this.componentRoundingEnabled;}
    if (id === 'opt_rounding_page') {return this.pageRoundingEnabled;}
    return false;
  }

  getSliderValue(id: string): number {
    if (id === 'opt_zorder') {return this.zIndexFront;}
    if (id === 'opt_reuse_options') {return this.reuseCacheSize;}
    return 0;
  }

  getVisibilityIndex(): number {
    if (this.visibilityState === Visibility.Visible) {return 0;}
    if (this.visibilityState === Visibility.Hidden) {return 1;}
    return 2;
  }

  handleToggle(id: string, val: boolean) {
    if (id === 'opt_enable') {this.enableDemoActive = val;}
    if (id === 'opt_overlay') {this.overlayVisible = val;}
    if (id === 'opt_rounding_comp') {this.componentRoundingEnabled = val;}
    if (id === 'opt_rounding_page') {
      this.pageRoundingEnabled = val;
      this.applyPageRounding(val);
    }
    this.listItemActiveId = id;
  }

  handleVisibilityChange(idx: number) {
    if (idx === 0) {this.visibilityState = Visibility.Visible;}
    else if (idx === 1){ this.visibilityState = Visibility.Hidden;}
    else {this.visibilityState = Visibility.None;}
    this.listItemActiveId = 'opt_visibility';
  }

  handleSlider(id: string, val: number) {
    if (id === 'opt_zorder') {this.zIndexFront = val;}
    if (id === 'opt_reuse_options'){ this.reuseCacheSize = val;}
    this.listItemActiveId = id;
  }

  getItemBackgroundColor(id: string): ResourceColor {
    if (this.listItemActiveId === id) {return '#2C3E50';}
    if (id === 'opt_enable' && !this.enableDemoActive) {return '#2A2A2A';}
    return '#1E1E1E';
  }

  getVisibilityStateName(): string {
    if (this.visibilityState === Visibility.Visible) {return 'Show';}
    if (this.visibilityState === Visibility.Hidden) {return 'Hide';}
    return 'None';
  }

  getPerformanceColor(): ResourceColor {
    if (this.frameTimeMs < 16.6) {return '#4CAF50';}
    if (this.frameTimeMs < 25) {return '#FF9800';}
    return '#F44336';
  }

  build() {
    Stack() {
      // Dark background
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#121212')

      // Main content
      Column() {
        // Header with performance metrics
        Column() {
          Text('⚡ PERF OPTIMIZER')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
            .letterSpacing(1)
            .margin({ bottom: 6 })

          Row() {
            Column() {
              Text(`${this.frameTimeMs.toFixed(0)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getPerformanceColor())
              Text('ms/frame')
                .fontSize(8)
                .fontColor('#757575')
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`${this.renderTimeMs.toFixed(0)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#00BCD4')
              Text('render')
                .fontSize(8)
                .fontColor('#757575')
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`${this.memoryDeltaKB > 0 ? '+' : ''}${this.memoryDeltaKB.toFixed(0)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.memoryDeltaKB > 0 ? '#F44336' : '#4CAF50')
              Text('KB Δ')
                .fontSize(8)
                .fontColor('#757575')
            }
            .width('34%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 4, bottom: 4 })
        }
        .width('100%')
        .padding({ top: 12, bottom: 8 })
        .backgroundColor('#1E1E1E')
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })

        // Scrollable content
        Scroll() {
          Column({ space: 8 }) {
            // --- 1. ENABLE/DISABLE CONTROL ---
            Column() {
              Text('1. Enable/Disable')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF9800')
                .margin({ bottom: 6 })

              Row() {
                if (this.enableDemoActive) {
                  Row() {
                    Text('✅ ACTIVE')
                      .fontSize(11)
                      .fontColor('#4CAF50')
                  }
                  .height(36)
                  .padding({ left: 16, right: 16 })
                  .backgroundColor('#1B5E20')
                  .borderRadius(18)
                  .onClick(() => console.info(`Active`))
                } else {
                  Row() {
                    Text('⛔ DISABLED')
                      .fontSize(11)
                      .fontColor('#9E9E9E')
                  }
                  .height(36)
                  .padding({ left: 16, right: 16 })
                  .backgroundColor('#2A2A2A')
                  .borderRadius(18)
                  .enabled(false)
                }
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1E1E1E')
            .borderRadius(16)

            // --- 2. VISIBILITY CONTROL ---
            Column() {
              Text('2. Visibility')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF9800')
                .margin({ bottom: 6 })

              Column() {
                Text(this.getVisibilityStateName() === `Show` ? `👁️ SHOW` :
                  this.getVisibilityStateName() === `Hide` ? `🙈 HIDE` : `🚫 NONE`)
                  .fontSize(11)
                  .fontColor('#FFFFFF')
                  .padding(8)
              }
              .visibility(this.visibilityState)
              .backgroundColor('#2C3E50')
              .borderRadius(12)
              .width('100%')
              .height(this.visibilityState === Visibility.None ? 0 : 40)
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1E1E1E')
            .borderRadius(16)

            // --- 3. Z-ORDER & 4. OVERLAY ---
            Column() {
              Text('3+4. Z-order + Overlay')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF9800')
                .margin({ bottom: 6 })

              Stack() {
                Column() {
                  Text('BACK')
                    .fontSize(10)
                    .fontColor('#FFF')
                }
                .width(100)
                .height(60)
                .backgroundColor('#C62828')
                .borderRadius(12)
                .zIndex(this.zIndexFront === 0 ? 2 : 1)

                Column() {
                  Text('FRONT')
                    .fontSize(10)
                    .fontColor('#FFF')
                }
                .width(100)
                .height(60)
                .backgroundColor('#2E7D32')
                .borderRadius(12)
                .zIndex(this.zIndexFront === 1 ? 2 : 1)

                if (this.overlayVisible) {
                  Column() {
                    Text('★')
                      .fontSize(16)
                  }
                  .width(32)
                  .height(32)
                  .backgroundColor('#FF9800')
                  .borderRadius(16)
                  .zIndex(3)
                  .position({ x: '70%', y: -8 })
                }
              }
              .width('100%')
              .height(70)
              .margin({ top: 4 })

              Text(this.zIndexFront === 1 ? 'FRONT on top' : 'BACK on top')
                .fontSize(9)
                .fontColor('#9E9E9E')
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1E1E1E')
            .borderRadius(16)

            // --- 5+6. REUSE ID & OPTIONS - FIXED: Shows all 6 items ---
            Column() {
              Text('5+6. Reuse ID + Cache')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF9800')
                .margin({ bottom: 6 })

              Text(`Cache size: ${this.reuseCacheSize} items | 6 items total`)
                .fontSize(9)
                .fontColor('#00BCD4')
                .margin({ bottom: 8 })

              // Recyclable List - showing ALL items
              List({ space: 6 }) {
                ForEach(this.recyclableItems, (item: string) => {
                  ListItem() {
                    Row() {
                      Text('♻️')
                        .fontSize(14)
                      Text(item)
                        .fontSize(11)
                        .fontColor('#FFFFFF')
                        .margin({ left: 10 })
                      Text(`${this.recyclableItems.indexOf(item) + 1}/6`)
                        .fontSize(9)
                        .fontColor('#9E9E9E')
                        .margin({ left: 'auto' })
                    }
                    .width('100%')
                    .height(40)
                    .padding({ left: 14, right: 14 })
                    .backgroundColor('#2C3E50')
                    .borderRadius(12)
                  }
                  .reuseId(`reusable_item_${this.recyclableItems.indexOf(item) % 2}`) // 5. REUSE ID
                }, (item: string) => item)
              }
              .width('100%')
              .height(280) // Enough height to show 6 items (6 * 46px)
              .margin({ top: 4 })
              .backgroundColor('transparent')
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1E1E1E')
            .borderRadius(16)

            // --- 7+8. PIXEL ROUNDING ---
            Column() {
              Text('7+8. Pixel Rounding')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF9800')
                .margin({ bottom: 6 })

              Row() {
                Text(this.componentRoundingEnabled ? '✓ COMP ON' : '✗ COMP OFF')
                  .fontSize(9)
                  .fontColor(this.componentRoundingEnabled ? '#4CAF50' : '#F44336')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#2A2A2A')
                  .borderRadius(12)

                Blank()

                Text(this.pageRoundingEnabled ? '✓ PAGE ON' : '✗ PAGE OFF')
                  .fontSize(9)
                  .fontColor(this.pageRoundingEnabled ? '#4CAF50' : '#F44336')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#2A2A2A')
                  .borderRadius(12)
              }
              .width('100%')

              if (this.componentRoundingEnabled) {
                this.RoundedContentExample()
              }
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1E1E1E')
            .borderRadius(16)

            // --- 9. ITEMSTATE Controls ---
            Column() {
              Text('9. ItemState Controls')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF9800')
                .margin({ bottom: 6 })

              ForEach(this.settingsItems, (item: SettingItem) => {
                this.SettingItemRow(item)
              }, (item: SettingItem) => item.id)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#1E1E1E')
            .borderRadius(16)
          }
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 60 })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
  }
}