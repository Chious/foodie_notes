# Food Data Pipeline — Implementation Tickets

**關聯 ADR**: [ADR-004: 台灣飲食資料管線](../../../docs/ADR/ADR-004-taiwan-food-data-pipeline.md)
**建立日期**: 2026-06-23

---

## 總覽

| ID | 標題 | 依賴 | 優先級 | 狀態 |
|----|------|------|--------|------|
| FDP-01 | Crawler 專案初始化 | — | P0 | TODO |
| FDP-02 | 定義 CrawledFoodItem Schema + SiteConfig | — | P0 | TODO |
| FDP-03 | 實作 LLM Extractor Agent | FDP-02 | P0 | TODO |
| FDP-04 | 實作 Normalizer | FDP-02 | P0 | TODO |
| FDP-05 | 實作 Validator + 抽樣報告 | FDP-02 | P0 | TODO |
| FDP-06 | 實作通用爬蟲執行器 | FDP-01~05 | P1 | TODO |
| FDP-07 | 第一個站台端到端測試 | FDP-06 | P1 | TODO |
| FDP-08 | Prisma 新增 FoodItem model | — | P1 | TODO |
| FDP-09 | 實作 NDJSON import script | FDP-08, FDP-02 | P1 | TODO |
| FDP-10 | 實作 CrawledModule | FDP-08 | P2 | TODO |
| FDP-11 | FoodService — search() 整合爬蟲 DB | FDP-10 | P2 | TODO |
| FDP-12 | FoodService — findByBarcode() 整合爬蟲 DB | FDP-10 | P2 | TODO |
| FDP-13 | RecognizeService fallback 鏈更新 | FDP-10 | P3 | TODO |
| FDP-14 | Apify Actor 雲端部署設定 | FDP-06 | P3 | TODO |

---

## P0: Crawler 基礎建設

### FDP-01: Crawler 專案初始化

**描述**：將 `crawler/` 從 boilerplate 重構為正式專案結構。

**工作項目**：
- 切換為 TypeScript + ESM（`"type": "module"`）
- 新增 `tsconfig.json`
- 建立目錄結構：`src/agent/`、`src/utils/`、`src/sites/`
- 更新 `package.json` scripts（`crawl:site`、`crawl:all`）
- 設定 `.gitignore`（`output/`、`node_modules/`）
- 新增 LLM API 相關依賴

**驗收條件**：
- [x] `npm run build` 編譯成功
- [x] 專案結構符合 ADR-004 規劃

**相關檔案**：
- `crawler/package.json`
- `crawler/tsconfig.json`
- `crawler/src/run.ts`

---

### FDP-02: 定義 CrawledFoodItem Schema + SiteConfig

**描述**：定義 crawler 的統一輸出型別和站台設定介面。

**工作項目**：
- 定義 `CrawledFoodItem` interface（含 confidence、extractionMethod）
- 定義 `SiteConfig` interface
- 建立站台設定檔（初始可為空陣列）

**驗收條件**：
- [x] TypeScript 型別可被 agent、utils、sites 模組引用
- [x] Schema 與 ADR-004 規格一致

**相關檔案**：
- `crawler/src/types.ts`
- `crawler/src/sites/config.ts`

---

### FDP-03: 實作 LLM Extractor Agent

**描述**：建立 LLM Agent，負責分析頁面 HTML/截圖並提取結構化營養資料。

**工作項目**：
- 設計 structured prompt（輸入：HTML/截圖，輸出：CrawledFoodItem）
- 支援文字表格、圖片 OCR（Vision API）、混合格式
- 回傳 confidence 和 extractionMethod
- 處理中英文混合、不同單位的判斷
- Provider 抽象（同 ADR-003 的多模型支援）

**驗收條件**：
- [x] 給定一個包含營養表格的 HTML，能正確提取 CrawledFoodItem
- [x] 給定營養標示圖片，能透過 Vision API 提取數據
- [x] 缺失營養資訊時回傳 confidence: 'low'

**相關檔案**：
- `crawler/src/agent/extractor.ts`
- `crawler/src/agent/prompts.ts`

---

### FDP-04: 實作 Normalizer

**描述**：將 Agent 提取的原始數據標準化為 per-100g 單位。

**工作項目**：
- per-serving → per-100g 轉換：`valuePer100g = valuePerServing × (100 / servingWeightG)`
- 處理無 servingWeightG 的情況（標記 confidence: 'low'）
- 欄位名稱標準化

**驗收條件**：
- [x] 已知 servingWeightG 時，per-100g 換算正確
- [x] 未知 servingWeightG 時，保留原始值並降低 confidence

**相關檔案**：
- `crawler/src/utils/normalize.ts`

---

### FDP-05: 實作 Validator + 抽樣報告

**描述**：自動規則檢查 + 人工抽樣報告產生。

**工作項目**：
- 卡路里合理範圍（0-900 kcal/100g）
- 三大營養素交叉驗證（`|P×4 + C×4 + F×9 - Cal| / Cal < 0.2`）
- 必填欄位檢查
- 非負值檢查
- 低 confidence 自動標記
- 產生抽樣報告（隨機 10 筆 + 所有異常筆），輸出至 `output/{site-id}-review.md`

**驗收條件**：
- [x] 卡路里 1000 的品項被標記異常
- [x] P×4+C×4+F×9 偏差 >20% 被標記
- [x] 抽樣報告包含品項名稱、營養數據、來源 URL

**相關檔案**：
- `crawler/src/utils/validator.ts`
- `crawler/src/utils/output.ts`

---

## P1: 端到端流程

### FDP-06: 實作通用爬蟲執行器

**描述**：讀取 SiteConfig，驅動 Crawlee 導航頁面，搭配 Agent 提取，經過 Normalizer 和 Validator 輸出 NDJSON。

**工作項目**：
- 根據 `crawlerType` 選用 CheerioCrawler 或 PuppeteerCrawler
- 整合 Extractor → Normalizer → Validator → Output 流程
- CLI 介面：`npm run crawl -- --site=<site-id>`
- 支援 `maxPages` 限制
- 錯誤處理與日誌

**驗收條件**：
- [x] 指定一個 SiteConfig，能完成爬取並輸出 NDJSON + 抽樣報告
- [x] CLI 可正常執行

**依賴**：FDP-01, FDP-02, FDP-03, FDP-04, FDP-05

**相關檔案**：
- `crawler/src/sites/runner.ts`
- `crawler/src/run.ts`

---

### FDP-07: 第一個站台端到端測試

**描述**：選定一個連鎖餐廳或電商站台，驗證完整流程。

**工作項目**：
- 加入站台設定（startUrls、crawlerType、extractionHints）
- 執行爬取
- 檢查 NDJSON 輸出
- 審核抽樣報告，與官網比對準確度
- 修正 prompt 或驗證規則（若需要）

**驗收條件**：
- [x] 產出可用的 NDJSON 資料
- [x] 抽樣報告與官網數據吻合（容許 ±5% 誤差）
- [x] 無 validator 無法解釋的異常

**依賴**：FDP-06

---

### FDP-08: Prisma 新增 FoodItem model

**描述**：在 backend 新增 `FoodItem` model 用於儲存爬蟲資料。

**工作項目**：
- 新增 `FoodItem` model 至 `prisma/schema.prisma`（欄位見 ADR-004）
- 執行 `prisma migrate dev` 建立 `food_item` 表
- 確認 index 正確（name, barcode, brand, source）
- 確認 unique constraint（source + sourceId）

**驗收條件**：
- [x] Migration 成功執行
- [x] `food_item` 表結構與 ADR-004 規格一致

**相關檔案**：
- `backend/prisma/schema.prisma`

---

### FDP-09: 實作 NDJSON import script

**描述**：Backend CLI script，讀取 crawler 輸出的 NDJSON 檔案並 upsert 至 `food_item` 表。

**工作項目**：
- 逐行讀取 NDJSON
- 驗證每筆資料符合 CrawledFoodItem schema
- Upsert（依 source + sourceId）至 PostgreSQL
- 輸出匯入統計（新增/更新/跳過筆數）

**驗收條件**：
- [x] `npm run import:crawled -- --file=<path>` 正常執行
- [x] 重複執行為 upsert，不產生重複資料
- [x] 匯入後 `SELECT count(*) FROM food_item` 數量正確

**依賴**：FDP-08, FDP-02

**相關檔案**：
- `backend/src/scripts/import-crawled.ts`
- `backend/src/food/sources/crawled/crawled-import.service.ts`

---

## P2: Backend 整合

### FDP-10: 實作 CrawledModule

**描述**：新增 NestJS module，提供爬蟲資料的搜尋與條碼查詢。

**工作項目**：
- `CrawledService.search(query, limit)` — PostgreSQL ILIKE on name
- `CrawledService.findByBarcode(barcode)` — exact match on barcode
- `CrawledService.findByBrand(brand, limit)` — 品牌篩選
- 回傳 `FoodItemDto`（source: 'crawled'）

**驗收條件**：
- [x] 搜尋中文品項名稱能命中爬蟲資料
- [x] 條碼查詢能命中有 barcode 的爬蟲資料

**依賴**：FDP-08

**相關檔案**：
- `backend/src/food/sources/crawled/crawled.module.ts`
- `backend/src/food/sources/crawled/crawled.service.ts`

---

### FDP-11: FoodService — search() 整合爬蟲 DB

**描述**：修改 FoodService.search()，加入爬蟲 DB 並行查詢，移除 FatSecret。

**工作項目**：
- 注入 `CrawledService`
- TFDA + 爬蟲 DB 並行查詢（`Promise.all`）
- 合併去重（名稱相似度比對）
- 非中文查詢時 OFF 補充
- 從 search 流程中移除 FatSecret

**驗收條件**：
- [x] `GET /api/food/search?q=大麥克` 回傳爬蟲資料（source: 'crawled'）
- [x] `GET /api/food/search?q=雞胸肉` 仍回傳 TFDA 資料（無回歸）
- [x] FatSecret 不再出現在 search 結果中

**依賴**：FDP-10

**相關檔案**：
- `backend/src/food/food.service.ts`
- `backend/src/food/food.module.ts`

---

### FDP-12: FoodService — findByBarcode() 整合爬蟲 DB

**描述**：修改 FoodService.findByBarcode()，優先查詢爬蟲 DB。

**工作項目**：
- 查詢順序：爬蟲 DB → OFF → FatSecret
- 爬蟲 DB 命中時直接回傳，不查外部 API

**驗收條件**：
- [x] 已匯入的電商商品條碼能直接命中
- [x] 未匯入的條碼仍能 fallback 到 OFF → FatSecret

**依賴**：FDP-10

**相關檔案**：
- `backend/src/food/food.service.ts`

---

## P3: 延伸

### FDP-13: RecognizeService fallback 鏈更新

**描述**：在 AI 辨識的 nutrition grounding fallback 鏈中加入爬蟲 DB。

**工作項目**：
- 更新 fallback 順序：TFDA → 爬蟲 DB → OFF → FatSecret → LLM estimate
- 當 RecognizeService 從 mock 切換到實際實作時一併處理

**驗收條件**：
- [x] 辨識「夏威夷比薩」時能從爬蟲 DB 取得營養數據（若已匯入）

**依賴**：FDP-10

**相關檔案**：
- `backend/src/food/recognize/recognize.service.ts`

---

### FDP-14: Apify Actor 雲端部署設定

**描述**：設定 Apify Actor 配置，讓需要 headless browser 的爬蟲可在雲端執行。

**工作項目**：
- 新增 `.actor/` 配置目錄
- 設定 `actor.json` manifest
- Dockerfile 或 Apify runtime 配置
- 測試雲端執行

**驗收條件**：
- [x] `apify run` 能在 Apify 平台成功執行爬蟲
- [x] 輸出與本地執行一致

**依賴**：FDP-06

**相關檔案**：
- `crawler/.actor/actor.json`
