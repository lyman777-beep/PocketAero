# Pocket Aero

一款基于 Flutter 的移动端飞行仪表盘应用。它以"玻璃座舱"（glass cockpit）风格，在横屏界面上实时呈现姿态、航向、位置与飞行数据，所有数据均来自设备自身的传感器与 GPS。

> 注意：本项目目前为个人/私有项目（pubspec 中 `publish_to: 'none'`），并非发布到 pub.dev 的库。

## 功能特性

- **姿态仪（Attitude Indicator）**：基于加速度计计算俯仰（pitch）与横滚（roll），以人工地平仪方式绘制天空/地面与俯仰梯。
- **磁罗盘（Magnetic Compass）**：基于磁力计计算航向（heading），支持 N/E/S/W  cardinal 标记与刻度盘。
- **离线地图**：使用 [`flutter_map`](https://pub.dev/packages/flutter_map) 渲染。海岸线/陆地通过 Natural Earth 50m GeoJSON 以 PolygonLayer 绘制；地形阴影通过预渲染的 MBTiles 瓦片叠加 TileLayer；机场/跑道通过 OurAirports CSV 数据以 MarkerLayer/PolylineLayer 展示。全部离线运行，飞行中不依赖网络。
- **实时飞行数据**：显示高度（ALT）、地速（SPD，m/s 转 km/h）、垂直速度（V/S，根据地速与俯仰角估算）、卫星数量（SAT）。
- **传感器融合**：通过低通滤波（low-pass）平滑加速度计/磁力计读数，降低噪声。
- **沉浸式横屏 UI**：强制横屏（landscape）、沉浸式（immersiveSticky）状态栏、深色主题。

## 技术栈

| 类别 | 依赖 | 用途 |
| --- | --- | --- |
| 框架 | Flutter SDK `^3.10.4` | 跨平台 UI |
| 地图 | `flutter_map` `^8.3.1` | 地图渲染引擎 |
| 地理 | `latlong2` `^0.10.1` | 经纬度坐标模型 |
| CSV 解析 | `csv` | 机场/跑道数据加载 |
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
│   ├── airport_data_service.dart  # 规划：OurAirports CSV 加载与查询
│   └── elevation_service.dart     # 规划：SRTM DEM 海拔查询
├── pages/
│   └── flight_page.dart           # 已实现：主 HUD 布局（上：仪表 / 下：地图+数据）
└── widgets/
    ├── attitude_indicator.dart    # 已实现：姿态仪（CustomPaint 绘制）
    ├── magnetic_compass.dart      # 已实现：磁罗盘（CustomPaint 绘制）
    └── offline_map.dart           # 已实现：底图与飞行图层（GeoJSON + TileLayer + Marker）
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
- **地图交互**：点击地图任意位置会取消"位置跟随"，右下角定位按钮可重新居中。拖动地图时海岸线自动切换为简化版本，松手后恢复精细版本。
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

## 离线地图

本项目定位为**飞行中纯离线**应用，地图全部数据预先打包到用户设备，飞行中不依赖任何网络请求。

### 数据来源与体系

```
MAP_resources/
├── Natural Earth/               # 海岸线、湖泊、陆地（矢量）
├── HYP_50M_SR.tif               # 地形阴影（栅格，167 MB）
├── SRTM30_1km/                  # 全球 DEM 1km 分辨率（海拔查询）
└── OurAirports/                 # 机场、跑道、频率、导航台（CSV）
```

### 数据预处理管线

在 PC 端通过 GDAL 等工具一次性完成：

```
Natural Earth .shp
  → ogr2ogr -simplify 0.001 → GeoJSON
  → assets/data/*.geojson  （PolygonLayer 海陆底图）

HYP_50M_SR.tif
  → gdal2tiles.py → XYZ PNG tiles
  → MBTiles（Terrain tile provider）

SRTM30 .dem
  → gdal_merge.py → 单张 GeoTIFF
  → 降采样 → 内存网格（运行时 O(1) 海拔查询）

OurAirports .csv
  → 运行时 CSV 解析 → 内存/ SQLite
  → MarkerLayer（机场）+ PolylineLayer（跑道）
```

### 图层渲染结构

| 图层 | 类型 | 精度选择 | 说明 |
| --- | --- | --- | --- |
| 海陆底图 | `PolygonLayer` + `PolylineLayer` | 低缩放用 110m，主力 50m | 拖拽时自动降级为 110m，松手恢复 50m |
| 地形阴影 | `TileLayer`（MBTiles Provider） | zoom 0-12 | 已预渲染的灰度 hillshade |
| 机场标记 | `MarkerLayer` | 全部机场 | ICAO/名称/频率可点选 |
| 跑道 | `PolylineLayer` | 有坐标的跑道 | 方向线 |
| 海拔查询 | 内存 DEM 网格 | 1km | 实时显示离地高度 AGL |
| 导航台 | `MarkerLayer` | VOR/NDB | 下拉可查询

## 平台支持

项目已生成 Android、iOS、Linux、macOS、Web、Windows 六个平台配置。其中：

- **Android / iOS**：功能最完整（传感器 + GPS）。
- **桌面 / Web**：`sensors_plus` 与 `geolocator` 在这些平台支持有限，仪表与地图行为可能受限。

> Android 应用包名为 `com.pocketacro.pocket_aero`（见 `lib/widgets/offline_map.dart` 中的 `userAgentPackageName`）。

## 已知限制

- **离线地图待实现**：当前 `OfflineMap` 仍使用 OSM 在线 `urlTemplate` 占位，GeoJSON 海陆底图、MBTiles 地形阴影、CSV 机场数据等组件均为待实现状态。
- 垂直速度、卫星数量为简化估算，非专业航电精度。
- 未接入陀螺仪融合算法（已预留 `_gyroscopeSub` 字段，尚未使用）。
- 预处理管线（ogr2ogr、gdal2tiles）需在 PC 端手动执行，尚未集成到构建流程。

## 许可证

本项目未包含许可证文件，当前为私有/未授权状态。如需分发或协作，请先补充许可证声明。
