# 食誌 Backend

食誌 App 的後端服務，基於 NestJS + Prisma + PostgreSQL。

## 技術棧

- **Framework**: NestJS 11
- **ORM**: Prisma 7 (with `@prisma/adapter-pg`)
- **Database**: PostgreSQL 16
- **Auth**: better-auth (email + password)
- **API Docs**: Swagger (`/api/docs`)
- **Container**: Docker + Docker Compose

## 快速開始

```bash
# 安裝依賴
npm install

# 啟動 PostgreSQL
docker compose up postgres -d

# 產生 Prisma client + 執行 migration
npx prisma generate --schema=prisma/schema.prisma
npx prisma migrate dev

# 開發模式啟動
npm run start:dev
```

啟動後：
- API: http://localhost:3000
- Swagger UI: http://localhost:3000/api/docs
- Health check: `GET /`

## Docker Compose（完整環境）

```bash
docker compose up --build
```

包含 `backend` (port 3000) 和 `postgres` (port 5432) 兩個服務。

## API 端點

| 端點 | 方法 | 說明 |
|------|------|------|
| `/api/auth/login` | POST | 登入驗證，回傳 API Token |
| `/api/food/search?q=` | GET | 食物名稱搜尋（TFDA + OFF） |
| `/api/food/barcode/:code` | GET | 條碼查詢（OFF + FatSecret） |
| `/api/recognize` | POST | 上傳食物圖片，回傳 AI 辨識結果 |
| `/api/food-db/version` | GET | 精簡資料庫版本檢查 |
| `/api/food-db/download` | GET | 下載精簡資料庫 |

> 目前所有端點回傳 mock data，詳見 Swagger UI。

## 專案結構

```
src/
  main.ts                 # 應用程式入口 + Swagger 設定
  app.module.ts           # 根模組
  prisma/                 # PrismaService（全域共用）
  auth/                   # 認證模組
  food/                   # 食物搜尋 + 條碼查詢
  recognize/              # AI 食物辨識
  food-db/                # 離線精簡資料庫
  lib/auth.ts             # better-auth 設定
prisma/
  schema.prisma           # 資料庫 schema（目前含 auth 相關表）
  migrations/             # Prisma migrations
```

## 常用指令

```bash
npm run build             # 編譯 TypeScript
npm run start:dev         # 開發模式（watch）
npm run start:prod        # 生產模式
npm run lint              # ESLint 檢查
npm run test              # 執行測試
```
