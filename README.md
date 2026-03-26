# 倒计时 — iOS 事件倒计时应用

一款简洁优雅的 iOS 倒计时应用，支持锁屏实时活动、桌面小组件和智能提醒。

## 功能特性

- **事件管理** — 支持生日、纪念日、考试、旅行、节日、工作等多种分类
- **锁屏实时活动** — 灵动岛 + 锁屏实时倒计时（天/时/分/秒）
- **桌面小组件** — 小/中/大尺寸 + 锁屏矩形小组件
- **智能提醒** — 提前 1-30 天自定义通知提醒
- **事件置顶** — 重要事件始终在最上方
- **数据本地存储** — 所有数据保存在设备本地，无需联网

## 技术栈

- **语言**：Swift 5.9
- **最低版本**：iOS 17.0
- **框架**：SwiftUI, WidgetKit, ActivityKit, UserNotifications
- **状态管理**：@Observable (iOS 17+)
- **数据持久化**：UserDefaults + App Group（应用与小组件共享）
- **项目生成**：XcodeGen (project.yml)

## 项目结构

```
CountdownApp/              # 主应用
├── App/
│   └── CountdownApp.swift     # 应用入口
├── Extensions/
│   └── Theme.swift            # 主题配色
├── Services/
│   ├── EventStore.swift       # 数据存储（CRUD）
│   ├── LiveActivityManager.swift  # 实时活动管理
│   └── NotificationService.swift   # 通知服务
└── Views/
    ├── ContentView.swift      # TabView 主容器
    ├── EventListView.swift    # 事件列表
    ├── EventRowView.swift     # 事件行视图
    ├── AddEditEventView.swift # 添加/编辑表单
    └── SettingsView.swift     # 设置页面

CountdownWidget/            # 小组件扩展
├── CountdownWidgetBundle.swift      # 小组件入口
├── EventTimelineProvider.swift      # 时间线数据源
├── EventWidgetView.swift            # 小组件 UI
└── CountdownLiveActivity.swift      # 实时活动 UI

Shared/                     # 共享代码
├── CountdownEvent.swift          # 事件数据模型
├── CountdownAttributes.swift      # 实时活动属性
└── Color+Hex.swift               # 颜色扩展
```

## 环境要求

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（可选，用于从 project.yml 生成 .xcodeproj）

## 构建步骤

### 使用 XcodeGen 生成项目（推荐）

```bash
# 安装 XcodeGen
brew install xcodegen

# 生成 Xcode 项目
cd countdown-app
xcodegen generate

# 打开项目
open CountdownApp.xcodeproj
```

### 直接使用现有 .xcodeproj

```bash
open CountdownApp.xcodeproj
```

### 配置

1. 在 Xcode 中设置 `DEVELOPMENT_TEAM` 为你的开发者团队 ID
2. 在 Apple Developer 后台创建 App Group `group.com.openclaw.countdown`
3. 确保 Xcode 的 Signing & Capabilities 中正确配置了 App Group

## 上架准备

### 必需截图（App Store Connect）

| 设备 | 尺寸 (px) | 数量 |
|------|-----------|------|
| iPhone 6.7" | 1290 x 2796 | 3-5 张 |

### 建议截图内容

1. 主界面（事件列表 + 分类分区）
2. 添加事件表单（分类选择 + 日历）
3. 锁屏实时活动（灵动岛效果）
4. 桌面小组件（多尺寸展示）
5. 通知提醒效果

### 上架前检查清单

- [ ] 设置 `DEVELOPMENT_TEAM` 团队 ID
- [ ] 在开发者后台创建 App Group `group.com.openclaw.countdown`
- [ ] 准备 App Store 截图（iPhone 6.7" 至少 3 张）
- [ ] 上传隐私政策（PrivacyPolicy.md）
- [ ] 在 App Store Connect 填写应用名称、副标题、关键词、描述
- [ ] Archive 并上传构建版本
- [ ] 通过 TestFlight 测试验证
- [ ] 提交审核

## 许可证

All rights reserved.
