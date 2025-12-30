# 言意合一 - 移动端写作应用

一个帮助用户建立持续写作习惯、追踪创作足迹的 Flutter 跨平台应用（Android + iOS）。

## 项目概述

- **项目名称**：言意合一
- **应用定位**：写作活动追踪与记录应用
- **核心功能**：帮助用户建立持续写作习惯，记录创作足迹
- **Flutter版本**：3.10.4+
- **状态管理**：Provider

## 功能需求列表

### 1. 三方登录/登出（微信、抖音）
- [ ] 集成微信 SDK
- [ ] 集成抖音 SDK
- [ ] 实现登录流程
- [ ] 实现登出功能
- [ ] Token 管理和自动刷新

### 2. 用户信息管理
- [x] 头像设置（相册选择/拍照）
- [x] 昵称编辑
- [x] 邮箱编辑
- [x] 个人简介编辑
- [ ] 用户信息同步

### 3. 用户状态管理
- [x] 用户信息存储
- [ ] 认证状态管理
- [ ] Token 有效期管理
- [ ] 全局状态访问

### 4. 文章管理
- [x] 文章列表展示
- [x] 文章详情查看
- [x] 文章置顶功能
- [ ] 文章创建
- [ ] 文章编辑
- [ ] 文章删除
- [ ] 封面图设置
- [ ] 标签管理

### 5. 主题管理
- [x] 日间/夜间模式切换
- [x] 跟随系统主题
- [ ] 字体大小调节
- [ ] 自定义主题色

### 6. 分享功能
- [ ] 生成文字卡片
- [ ] 分享至微信
- [ ] 分享至抖音
- [ ] 生成分享图片

### 7. 会员功能
- [ ] 会员等级系统
- [ ] 订阅流程
- [ ] AI 写作提示（会员专属）
- [ ] 远端存储数据（会员专属）

### 8. 本地存储
- [x] SharedPreferences 存储
- [ ] JSON 文件存储
- [ ] 数据加密
- [ ] 数据迁移机制

### 9. 权限管理
- [ ] 游客模式（不登录可用）
- [ ] 登录权限检查
- [ ] 会员权限检查
- [ ] 功能开关控制

### 10. Mock 服务
- [x] 基础 Mock 数据
- [ ] 完整 API 接口 Mock
- [ ] 网络延迟模拟
- [ ] 错误场景模拟

## 当前项目结构

```
lib/
├── data/
│   ├── models/
│   │   ├── article.dart              # 文章模型
│   │   ├── user_profile.dart         # 用户资料模型
│   │   └── activity_data.dart        # 活动数据模型
│   └── services/
│       └── mock_data_service.dart    # Mock 数据服务
│
├── presentation/
│   └── pages/
│       ├── splash_page.dart          # 启动页
│       ├── home_page.dart            # 主页
│       ├── article_detail_page.dart  # 文章详情
│       ├── user_profile_edit_page.dart # 用户编辑
│       ├── about_page.dart           # 关于页面
│       └── help_and_feedback_page.dart # 帮助反馈
│
├── providers/
│   ├── theme_provider.dart           # 主题管理
│   ├── user_provider.dart            # 用户管理
│   └── activity_provider.dart        # 活动管理
│
├── widgets/
│   ├── article_list.dart             # 文章列表
│   ├── writing_activity_calendar.dart # 活动日历
│   ├── custom_app_bar.dart           # 自定义AppBar
│   ├── menu_content.dart             # 菜单内容
│   ├── expandable_fab.dart           # 可展开FAB
│   ├── draggable_side_sheet.dart     # 可拖动侧边栏
│   └── ...
│
└── main.dart                         # 应用入口
```

## 技术架构

### 状态管理架构

```
┌─────────────────────────────────────────┐
│           MyApp (MaterialApp)            │
├─────────────────────────────────────────┤
│                                          │
│  ┌──────────────┐  ┌──────────────┐     │
│  │AuthProvider  │  │ThemeProvider  │     │
│  │- 用户登录状态 │  │- 主题设置    │     │
│  │- Token管理   │  │- 字体大小    │     │
│  └──────┬───────┘  └──────┬───────┘     │
│         │                 │              │
│  ┌──────▼───────┐  ┌──────▼───────┐     │
│  │UserProvider  │  │MemberProvider│     │
│  │- 用户信息    │  │- 会员状态    │     │
│  │- 个人资料    │  │- 订阅管理    │     │
│  └──────┬───────┘  └──────┬───────┘     │
│         │                 │              │
│  ┌──────▼─────────────────▼───────┐     │
│  │     ArticleProvider            │     │
│  │  - 文章列表                     │     │
│  │  - 增删查改                     │     │
│  │  - 本地存储同步                 │     │
│  └─────────────────────────────────┘     │
│                                          │
└─────────────────────────────────────────┘
```

### 数据层架构

```
┌─────────────────────────────────────────┐
│         Presentation Layer               │
│  (Pages, Widgets, Screens)              │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Provider Layer                  │
│  (State Management, Business Logic)     │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Service Layer                   │
│  ┌──────────────┐  ┌──────────────┐    │
│  │ ApiService   │  │AuthService   │    │
│  │(接口抽象)    │  │(认证服务)    │    │
│  └──────┬───────┘  └──────┬───────┘    │
│         │                 │             │
│  ┌──────▼───────┐  ┌──────▼───────┐    │
│  │MockApiService│  │LocalStorage  │    │
│  │(Mock实现)    │  │Service       │    │
│  └──────────────┘  └──────────────┘    │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Data Layer                      │
│  (Models, Repositories)                 │
└─────────────────────────────────────────┘
```

## 实施计划

### 阶段一：核心基础架构（优先级：高）

#### 1.1 用户认证系统
- [ ] 创建 `AuthProvider` - 统一的认证状态管理
- [ ] 创建 `AuthService` - 认证服务
- [ ] 实现微信登录流程
- [ ] 实现抖音登录流程
- [ ] 实现 Token 管理和自动刷新
- [ ] 创建登录页面（`LoginPage`）

**涉及文件**：
- `lib/providers/auth_provider.dart`（新建）
- `lib/services/auth_service.dart`（新建）
- `lib/presentation/pages/login_page.dart`（新建）

#### 1.2 完善本地存储服务
- [ ] 创建 `LocalStorageService` - 统一的本地存储接口
- [ ] 实现 JSON 文件读写
- [ ] 实现数据加密存储
- [ ] 创建数据迁移机制

**涉及文件**：
- `lib/services/local_storage_service.dart`（新建）
- `lib/utils/storage_helper.dart`（新建）

#### 1.3 完善 Mock 服务
- [ ] 扩展 `MockDataService`
- [ ] 创建 `ApiService` 抽象层
- [ ] 实现网络延迟模拟
- [ ] 添加错误场景模拟

**涉及文件**：
- `lib/data/services/mock_data_service.dart`（扩展）
- `lib/data/services/api_service.dart`（新建）
- `lib/data/services/api_service_interface.dart`（新建）

### 阶段二：文章管理功能（优先级：高）

#### 2.1 文章创建和编辑
- [ ] 创建文章编辑器页面
- [ ] 集成富文本编辑
- [ ] 支持图片上传和插入
- [ ] 支持封面图设置
- [ ] 支持标签管理
- [ ] 实现草稿保存

**涉及文件**：
- `lib/presentation/pages/article_editor_page.dart`（新建）
- `lib/widgets/rich_text_editor.dart`（新建）

#### 2.2 文章删除和管理
- [ ] 实现软删除机制
- [ ] 添加回收站功能
- [ ] 批量操作支持
- [ ] 文章搜索功能

**涉及文件**：
- `lib/providers/article_provider.dart`（新建）
- `lib/widgets/article_actions.dart`（新建）

### 阶段三：会员和权限系统（优先级：中）

#### 3.1 会员系统
- [ ] 创建会员模型
- [ ] 实现订阅流程
- [ ] 会员等级管理
- [ ] 会员特权展示

**涉及文件**：
- `lib/data/models/membership.dart`（新建）
- `lib/providers/membership_provider.dart`（新建）
- `lib/presentation/pages/membership_page.dart`（新建）

#### 3.2 权限管理
- [ ] 创建权限定义
- [ ] 实现权限检查装饰器
- [ ] 创建权限提示组件
- [ ] 实现功能开关控制

**涉及文件**：
- `lib/utils/permissions.dart`（新建）
- `lib/widgets/auth_required_widget.dart`（新建）
- `lib/widgets/member_required_widget.dart`（新建）

### 阶段四：高级功能（优先级：中）

#### 4.1 分享功能
- [ ] 集成 `share_plus` 插件
- [ ] 创建文章卡片生成器
- [ ] 实现文字卡片样式设计
- [ ] 支持生成图片分享
- [ ] 集成微信和抖音SDK

**涉及文件**：
- `lib/services/share_service.dart`（新建）
- `lib/widgets/article_share_card.dart`（新建）

#### 4.2 主题增强
- [ ] 实现字体大小调节
- [ ] 添加更多主题色选项
- [ ] 支持自定义主题

**涉及文件**：
- `lib/providers/theme_provider.dart`（扩展）
- `lib/presentation/pages/theme_settings_page.dart`（新建）

#### 4.3 AI 功能（会员专属）
- [ ] 集成 AI API
- [ ] 实现 AI 写作提示
- [ ] 实现 AI 文章总结
- [ ] 实现 AI 标签推荐

**涉及文件**：
- `lib/services/ai_service.dart`（新建）
- `lib/providers/ai_provider.dart`（新建）

### 阶段五：优化和完善（优先级：低）

#### 5.1 性能优化
- [ ] 图片缓存优化
- [ ] 列表虚拟化
- [ ] 数据懒加载
- [ ] 状态管理优化

#### 5.2 用户体验优化
- [ ] 添加引导页面
- [ ] 完善动画效果
- [ ] 错误提示优化
- [ ] 加载状态优化

#### 5.3 测试和文档
- [ ] 单元测试
- [ ] 集成测试
- [ ] 用户手册
- [ ] API 文档

## 主要依赖

### 已安装
- `provider` - 状态管理
- `shared_preferences` - 本地存储
- `flutter_quill` - 富文本编辑
- `image_picker` - 图片选择
- `fluttertoast` - Toast提示
- `intl` - 国际化

### 待添加

```yaml
# 三方登录
fluwx: ^4.0.0           # 微信SDK
tencent_kit: ^1.0.0     # 腾讯系（抖音等）

# 分享功能
share_plus: ^7.0.0
image_gallery_saver: ^2.0.0

# 网络请求（为后续真实后端准备）
dio: ^5.3.0
retrofit: ^4.0.0

# 本地数据库
sqflite: ^2.3.0
path_provider: ^2.1.0

# 图片处理
cached_network_image: ^3.2.0

# 工具类
uuid: ^4.0.0

# 权限管理
permission_handler: ^11.0.0
```

## 开发原则

1. **Mock优先**：所有功能先用Mock实现，确保UI和交互流程完整
2. **渐进式开发**：每个功能独立开发，可随时切换到真实后端
3. **权限分层**：游客、登录用户、会员三层权限体系
4. **本地优先**：支持完全离线使用
5. **组件复用**：最大化组件复用率

## 运行项目

### 安装依赖
```bash
flutter pub get
```

### 运行项目
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web（暂不支持）
flutter run -d chrome
```

### 构建发布版
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 项目特色

1. **设计风格**：现代简洁，支持深色模式
2. **交互体验**：流畅的动画和微交互
3. **数据可视化**：GitHub风格的写作活动日历
4. **本地优先**：所有数据本地存储，保护隐私
5. **组件化**：高度模块化的组件设计
6. **扩展性**：良好的代码结构，易于功能扩展

## 开源协议

MIT License

---

**最后更新**：2025-12-30
