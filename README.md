# Pocket Aero

一款基于 Flutter 的移动端飞行仪表盘应用。它以"玻璃座舱"（glass cockpit）风格，在横屏界面上实时呈现姿态、航向、位置与飞行数据，所有数据均来自设备自身的传感器与 GPS。

> 注意：本项目目前为个人/私有项目（pubspec 中 `publish_to: 'none'`），并非发布到 pub.dev 的库。

## 功能特性

- **姿态仪（Attitude Indicator）**：基于加速度计计算俯仰（pitch）与横滚（roll），以人工地平仪方式绘制天空/地面与俯仰梯。
- **磁罗盘（Magnetic Compass）**：基于磁力计计算航向（heading），支持 N/E/S/W  cardinal 标记与刻度盘。
- **离线底图（Offline Basemap）**：使用 [`flutter_map`](https://pub.dev/packages/flutter_map) 作为渲染层，底图瓦片**飞行前由用户主动选择区域下载到设备本地**，飞行中开启飞行模式（离线）仍可显示。实时显示当前经纬度的导航箭头，并支持位置跟随（点击地图可取消跟随）。
- **实时飞行数据**：显示高度（ALT）、地速（SPD，m/s 转 km/h）、垂直速度（V/S，根据地速与俯仰角估算）、卫星数量（SAT）。
- **传感器融合**：通过低通滤波（low-pass）平滑加速度计/磁力计读数，降低噪声。
- **沉浸式横屏 UI**：强制横屏（landscape）、沉浸式（immersiveSticky）状态栏、深色主题。

## 技术栈

| 类别 | 依赖 | 用途 |
| --- | --- | --- |
| 框架 | Flutter SDK `^3.10.4` | 跨平台 UI |
| 地图 | `flutter_map` `^8.3.1` | 瓦片地图渲染 |
| 地理 | `latlong2` `^0.10.1` | 经纬度坐标模型 |
| 传感器 | `sensors_plus` `^7.1.0` | 加速度计 / 磁力计 / 陀螺仪事件流 |
| 定位 | `geolocator` `^14.0.3` | GPS 位置、速度、高度、权限请求 |
| 权限 | `permission_handler` `^12.0.3` | 运行时权限管理 |
| 存储 | `path_provider` `^2.1.6` | 本地路径（预留） |
| 数学 | `vector_math` `^2.2.0` | 向量/矩阵计算 |
| 图标 | `cupertino_icons` `^1.0.8` | iOS 风格图标 |

开发依赖：`flutter_test`、`flutter_lints ^6.0.0`。

## 项目结构

```
lib/
├── main.dart                      # 应用入口：主题、横屏与沉浸式设置
├── models/
│   └── flight_data.dart           # 飞行数据模型（不可变 FlightData）
├── services/
│   ├── sensor_service.dart        # 已实现：传感器与 GPS 融合，广播 FlightData 流
│   └── map_download_service.dart  # 规划：区域瓦片下载与落盘（飞行前使用）
├── pages/
│   ├── flight_page.dart           # 已实现：主 HUD 布局（上：仪表 / 下：地图+数据）
│   └── map_manager_page.dart      # 规划：区域选择 / 下载 / 管理 UI
└── widgets/
    ├── attitude_indicator.dart    # 已实现：姿态仪（CustomPaint 绘制）
    ├── magnetic_compass.dart      # 已实现：磁罗盘（CustomPaint 绘制）
    └── offline_map.dart           # 已实现：底图与位置标记（规划改用本地 TileProvider）
test/
└── widget_test.dart               # 默认 widget 测试
```

## 环境要求

- Flutter SDK `>=3.10.4`（stable channel）
- Dart SDK（随 Flutter 提供）
- 目标设备需具备加速度计、磁力计与 GPS（手机/平板体验最完整）
- 运行前请先执行 `flutter pub get`

## 安装与运行

```bash
# 1. 获取依赖
flutter pub get

# 2. 检查设备/模拟器
flutter devices

# 3. 运行（建议真机以获得传感器与 GPS 数据）
flutter run
```

构建发布包：

```bash
flutter build apk          # Android
flutter build ios          # iOS（需 macOS + Xcode）
```

## 使用说明

- **权限**：应用通过 `geolocator` 在运行时请求定位权限。首次启动若拒绝定位，地图位置与高度/速度等字段将显示 `---`。
- **横屏**：应用强制横屏，请在横置设备上使用。
- **地图交互**：点击地图任意位置会取消"位置跟随"，右下角定位按钮可重新居中。
- **数据说明**：
  - 俯仰/横滚来自加速度计，航向来自磁力计，均经过低通滤波。
  - 垂直速度（V/S）由地速与俯仰角估算，为近似值。
  - 卫星数量在模拟位置（mock）时置空。

## 架构说明

数据流采用**单向流式架构**：

1. `SensorService` 同时订阅加速度计、磁力计（来自 `sensors_plus`）与 GPS 位置流（来自 `geolocator`）。
2. 传感器读数经低通滤波后写入内部状态；GPS 回调触发 `_emit()`。
3. `_emit()` 将快照封装为不可变 `FlightData`，通过 `StreamController.broadcast()` 广播。
4. `FlightPage` 监听 `dataStream`，通过 `setState` 更新各仪表与地图组件。

该设计将数据采集（Service）与展示（Widget）解耦，便于后续替换为模拟数据源或添加新的数据通道。

## 离线底图（Offline Basemap）

本项目定位为**飞行中离线可用**的应用，地图因此采用"飞行前下载、文档目录持久化、飞行模式只读"的设计，而非在线瓦片。

### 设计原则

- **用户主动下载，而非缓存**：底图瓦片在飞行前、有网络时由用户在地图管理页选择区域下载。它被视为**用户数据文件**，不是系统缓存。
- **持久化存储，不被系统清理**：瓦片落盘到应用**文档目录**（`path_provider` 的 `getApplicationDocumentsDirectory()`），而非临时/缓存目录（`getTemporaryDirectory` / `getCacheDirectory`）。文档目录在存储空间紧张时不会被操作系统自动回收，也不会被"清除缓存"动作删除。
- **飞行中纯离线**：进入飞行（飞行模式）后，地图只读本地瓦片文件，不发起任何网络请求。

### 瓦片文件布局

```
{documents}/pocket_aero_maps/
├── {regionId}/            # 区域标识，如 bounds 哈希或自定义名称
│   ├── region.json        # 元数据：bounds、缩放范围、瓦片数、来源
│   └── {z}/{x}/{y}.png    # 标准 slippy 瓦片
└── {regionId2}/...
```

### 核心组件

| 组件 | 职责 |
| --- | --- |
| `MapDownloadService` | 飞行前按区域包围盒 + 缩放级别逐个下载瓦片并落盘；通过 `Stream` 上报进度，支持取消 |
| `OfflineMap` | 改用读取本地文件的 `TileProvider`；对**未下载到（超范围/超缩放）的瓦片做优雅降级**，不崩溃、不黑屏 |
| `MapManagerPage` | 选择区域（框选或输入经纬度范围）、选择缩放级别、管理已下载区域（保留/删除由用户决定） |

### 瓦片来源

默认使用 [OpenStreetMap](https://www.openstreetmap.org/) 标准 XYZ 瓦片（`{z}/{x}/{y}.png`），下载时通过 `HttpClient` 携带 `User-Agent` 以遵守 OSM 使用规范。后续可替换为航空图数据源（如 OpenAIP、Sectional）而不影响离线架构。

> 状态说明：当前 `lib/widgets/offline_map.dart` 仍使用 OSM **在线** `urlTemplate` 作为占位实现；离线下载服务、本地 `TileProvider` 与地图管理页为规划中的实现，将在后续提交中落地。

## 平台支持

项目已生成 Android、iOS、Linux、macOS、Web、Windows 六个平台配置。其中：

- **Android / iOS**：功能最完整（传感器 + GPS）。
- **桌面 / Web**：`sensors_plus` 与 `geolocator` 在这些平台支持有限，仪表与地图行为可能受限。

> Android 应用包名为 `com.pocketacro.pocket_aero`（见 `lib/widgets/offline_map.dart` 中的 `userAgentPackageName`）。

## 已知限制

- **离线底图尚未落地**：当前 `OfflineMap` 仍使用 OSM 在线 `urlTemplate` 占位，区域下载服务、本地 `TileProvider` 与地图管理页待实现；落地前无网络时地图无法显示。
- 垂直速度、卫星数量为简化估算，非专业航电精度。
- 未接入陀螺仪融合算法（已预留 `_gyroscopeSub` 字段，尚未使用）。

## 许可证

本项目未包含许可证文件，当前为私有/未授权状态。如需分发或协作，请先补充许可证声明。
