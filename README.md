# 食誌 Foodie Notes

AI 驅動的飲食記錄 App，專為台灣使用者設計。透過拍照自動辨識食物、條碼掃描、手動搜尋等方式，輕鬆追蹤每日營養攝取與身體數據。

## 專案結構

```
foodie_notes/
├── frontend/    # Flutter 跨平台 App（Android 為主要目標平台）
├── backend/     # NestJS API 伺服器
└── .github/     # CI/CD workflows
```

## 技術架構

| 層級 | 技術                                  |
| ---- | ------------------------------------- |
| 前端 | Flutter + Dart、go_router、Material 3 |
| 後端 | NestJS + TypeScript                   |
| 部署 | （規劃中）                            |

## 核心功能

- AI 食物辨識（拍照自動分析）
- 條碼掃描查詢食品資訊
- 手動搜尋食物資料庫
- 每日營養攝取追蹤（熱量、三大營養素）
- 身體數據管理

## 開發狀態

目前處於 **Phase 1（UI 建構階段）**，前端畫面已完成，資料來源為 mock data，尚未串接後端 API。

## 快速開始

### 前端（Flutter）

```bash
cd frontend
flutter pub get
flutter run              # 連接裝置或模擬器
flutter run -d chrome    # 在瀏覽器執行
flutter analyze          # 靜態分析
flutter test             # 執行測試
```

### 後端（NestJS）

```bash
cd backend
npm install
npm run start:dev        # 開發模式（自動重啟）
npm run build            # 編譯
npm run test             # 執行測試
```

## 文件

架構決策紀錄（ADR）位於 `frontend/docs/ADR/`。
