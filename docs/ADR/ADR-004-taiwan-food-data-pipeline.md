# ADR-004: 台灣飲食資料管線

- **狀態**: Proposed
- **日期**: 2026-06-23
- **關聯**: [ADR-002](ADR-002-client-server-architecture.md), [ADR-003](ADR-003-ai-food-recognition-pipeline.md)

## Context

食誌 App 的目標受眾是台灣外食族與偶爾自炊的上班族，但現有第三方食物資料庫對台灣食品的覆蓋嚴重不足：

- **FatSecret**：台灣品牌食品（如 Tyrall 高蛋白粉、達美樂比薩）幾乎找不到對應資料
- **Open Food Facts**：以歐美包裝食品為主，台灣本土商品覆蓋有限
- **TFDA 食品營養成分資料庫**：僅涵蓋原型食材（雞肉、白米等），不包含連鎖餐廳菜單或加工食品
- **MyFitnessPal API**：經調查為使用者數據 API（飲食日記、體重紀錄），不提供食品搜尋功能，需 Partner 資格
- **Codatta MM-Food-100K**：10 萬筆食物照片的營養資料由 GPT-4o / Qwen 看圖估算，論文自承亞洲料理誤差率高達 76%，不可靠

台灣法規要求連鎖餐廳公開營養資訊，這些資料散佈在各品牌官網上。電商平台（PCHome、PXGO 等）的食品頁面也包含營養標示，但格式多樣（文字表格、圖片、甚至缺失），且不同平台的頁面結構各異，難以用固定腳本涵蓋所有情境。

## Decision

### 資料分層策略

依食物類型分層取得資料，各層使用最適合的來源與取得方式：

| 食物類型 | 資料來源 | 取得方式 | 範例 |
|----------|----------|----------|------|
| 原型食材 | TFDA 食品營養成分資料庫 | 直接匯入（已完成，見 [ADR-002](ADR-002-client-server-architecture.md)） | 雞胸肉、白米、花椰菜 |
| 連鎖餐廳 | 各品牌官網 | Agent-driven 爬蟲 | 達美樂、麥當勞、Subway |
| 包裝食品 | 電商平台 / OFF | Agent-driven 爬蟲 + OFF API | 樂事、蛋白粉、超商食品 |
| 台灣本土料理 | TFDA 份量代換表 | 初始匯入 + 使用者眾包 | 肉粽、滷肉飯、蚵仔煎 |

### FatSecret 角色調整

FatSecret 從全功能資料來源降級為**僅條碼查詢 fallback**，不再參與名稱搜尋。原因：台灣食品覆蓋率不足，名稱搜尋結果品質太低。現有 OAuth 實作與 barcode fallback 邏輯保留，待自建資料庫成熟後再評估是否完全移除。

### 爬蟲架構：Agent-Driven Extraction

核心理念：**不為每個網站寫固定的 CSS selector parser**，而是讓 LLM Agent 動態分析頁面內容並提取營養資料。

#### 為什麼不用固定腳本

| 面向 | 固定腳本 | Agent-driven |
|------|---------|--------------|
| 新站台上線 | 需寫新 parser + 測試 | 提供 URL + 設定，Agent 自行分析 |
| HTML 改版 | parser 壞掉，需人工修復 | Agent 自適應新結構 |
| 營養標示格式 | 只能處理預設格式 | 文字 / 圖片 / 混合都能處理 |
| 維護成本 | 隨站台數量線性增長 | 主要維護 prompt 和 schema |
| 準確度 | 高（若 selector 正確） | 需驗證流程把關，但彈性高 |

以 PCHome 為例：食品分類下有大量商品頁面，部分營養標示以文字呈現、部分以圖片呈現、部分完全缺失。若改以 PXGO 或其他電商為來源，頁面結構又完全不同。Agent-driven 架構讓同一個提取流程適用於所有情境。

#### Pipeline 流程

```
┌─────────────────────────────────────────────────────────┐
│                   Crawler Pipeline                       │
│                                                         │
│  1. Navigator (Crawlee)                                 │
│     └─ 依 SiteConfig 發現並遍歷目標網站的食品頁面          │
│     └─ CheerioCrawler（靜態頁面）                         │
│     └─ PuppeteerCrawler（SPA / 動態載入頁面）             │
│                                                         │
│  2. Extractor (LLM Agent)                               │
│     └─ 接收頁面 HTML 或截圖                               │
│     └─ 動態判斷營養資訊格式（文字表格 / 圖片 / 缺失）       │
│     └─ 圖片格式透過 Vision API 進行 OCR 提取              │
│     └─ 提取結構化營養數據，對應到 CrawledFoodItem schema   │
│     └─ 處理中英文混合、不同單位的轉換判斷                   │
│                                                         │
│  3. Normalizer                                          │
│     └─ per-serving → per-100g 單位換算                   │
│     └─ 欄位標準化為 CrawledFoodItem schema               │
│                                                         │
│  4. Validator                                           │
│     └─ 自動規則檢查（見驗證策略）                          │
│     └─ 異常標記 → 人工抽樣報告                            │
│                                                         │
│  5. Output                                              │
│     └─ NDJSON 檔案，每來源一個                            │
│     └─ 抽樣報告（隨機 N 筆 + 所有異常筆）                  │
└─────────────────────────────────────────────────────────┘
```

#### LLM 在爬蟲中的角色

- 分析頁面 HTML 結構，辨識營養資訊所在位置
- 判斷營養資訊格式：結構化文字、HTML 表格、圖片中的營養標示
- 對圖片格式的營養標示進行 OCR 提取（透過 Vision API）
- 將多樣化的原始數據對應到統一的 CrawledFoodItem schema
- 處理中英文混合、不同單位（每份 / per serving / 每 100g）的轉換判斷
- 回傳提取信心度（high / medium / low），供驗證流程參考

#### 技術選型

| 元件 | 選擇 | 說明 |
|------|------|------|
| 爬蟲框架 | Crawlee（Apify 生態系） | 頁面導航、排程、request queue 管理 |
| 靜態頁面 | CheerioCrawler | 連鎖餐廳營養表格等不需 JS 執行的頁面 |
| 動態頁面 | PuppeteerCrawler | PCHome 等 SPA / 需 JS 渲染的頁面 |
| 雲端部署 | Apify Actor | 適用需 headless browser 的場景 |
| 頁面分析 | LLM API | 同 [ADR-003](ADR-003-ai-food-recognition-pipeline.md) 的 provider 抽象 |
| 輸出格式 | NDJSON | 每來源一個檔案，便於增量處理與除錯 |

### Crawler 專案結構

```
crawler/
  src/
    types.ts              # CrawledFoodItem 統一輸出 schema
    agent/
      extractor.ts        # LLM Agent：分析頁面、提取營養資料
      prompts.ts          # 提取用 structured prompt
    utils/
      normalize.ts        # per-serving → per-100g 轉換
      validator.ts        # 自動規則檢查 + 異常標記
      output.ts           # NDJSON 輸出 + 抽樣報告產生
    sites/
      config.ts           # 站台設定（URL、爬取策略、crawler 類型）
      runner.ts           # 通用爬蟲執行器（讀取 config，搭配 Agent 提取）
    run.ts                # CLI 進入點
  output/                 # NDJSON 輸出 + 驗證報告（.gitignore）
```

### 站台設定

不同站台不寫獨立 parser，而是用設定描述。通用執行器讀取設定並搭配 Agent 完成提取：

```typescript
interface SiteConfig {
  id: string;              // "dominos-tw"
  name: string;            // "達美樂台灣"
  startUrls: string[];     // 入口 URL
  crawlerType: 'cheerio' | 'puppeteer';
  maxPages?: number;
  extractionHints?: string; // 給 Agent 的額外提示
}
```

### 統一輸出 Schema

所有爬蟲共用的輸出格式，也是 crawler → backend 的資料合約：

```typescript
interface CrawledFoodItem {
  sourceId: string;        // 來源內唯一 ID，如 "dominos-hawaiian-pizza-large-1slice"
  source: string;          // SiteConfig.id，如 "dominos-tw"
  brand: string;           // 品牌中文名，如 "達美樂"
  name: string;            // 食品名稱，如 "夏威夷比薩（大，每片）"
  nameEn?: string;         // 英文名稱（選填）
  category?: string;       // 分類，如 "pizza"、"burger"
  barcode?: string;        // EAN-13 條碼（僅包裝食品）

  // 所有營養數據以 per 100g 為單位
  caloriesPer100g: number;
  proteinPer100g: number;
  carbsPer100g: number;
  fatPer100g: number;
  fiberPer100g?: number;
  sugarPer100g?: number;
  sodiumPer100g?: number;

  // 原始份量資訊（供顯示用）
  servingSize?: string;    // "1片"、"1個"、"1份"
  servingWeightG?: number; // 每份克數

  // 提取品質
  confidence: 'high' | 'medium' | 'low';
  extractionMethod: 'text' | 'image' | 'table';

  // 中繼資料
  sourceUrl: string;       // 資料來源頁面 URL
  crawledAt: string;       // ISO 8601 時間戳
}
```

### 資料標準化

- 所有營養數據以 **per 100g** 為單位儲存，方便任意份量換算
- 原始份量資訊（servingSize、servingWeightG）保留供 UI 顯示
- per-serving → per-100g 轉換公式：`valuePer100g = valuePerServing × (100 / servingWeightG)`
- 若無法取得 servingWeightG（份量克數未標示），該品項標記為 `confidence: 'low'` 並加入人工覆核清單

### 驗證策略：自動規則 + 人工抽樣

#### 自動規則（每筆資料通過 validator）

| 規則 | 條件 | 處理 |
|------|------|------|
| 卡路里合理範圍 | 0 ≤ caloriesPer100g ≤ 900 | 超出範圍 → 標記異常 |
| 三大營養素交叉驗證 | `\|P×4 + C×4 + F×9 - Cal\| / Cal < 0.2` | 偏差 >20% → 標記異常 |
| 必填欄位檢查 | name, brand, caloriesPer100g, proteinPer100g, carbsPer100g, fatPer100g | 缺失 → 跳過該筆 |
| 非負值 | 所有 per-100g 欄位 ≥ 0 | 負值 → 標記異常 |
| 低信心度 | confidence = 'low' | 自動加入人工覆核清單 |

#### 人工抽樣報告

每次爬取後自動產生抽樣報告，輸出至 `output/{site-id}-review.md`：

- 隨機抽取 10 筆正常資料 + 所有 validator 標記異常的筆數
- 報告格式：品項名稱、營養數據、來源 URL，便於與官網比對
- 用於驗收爬蟲品質，發現系統性提取錯誤

### Backend 資料流

```
站台設定 → Crawlee 導航頁面 → LLM Agent 提取 → 標準化 → 驗證
  → NDJSON 檔案 → backend import script 驗證 + upsert → PostgreSQL food_item 表
```

Crawler 輸出 NDJSON 檔案，由 backend 的 import script 讀取並匯入資料庫。兩端解耦：crawler 不需要連接資料庫，可在本地或 Apify 雲端執行。

### Backend 新增 Prisma Model

新增 `FoodItem` model，與現有 `FoodCache` 分開：

```prisma
model FoodItem {
  id                String   @id @default(cuid())
  sourceId          String
  source            String
  brand             String?
  name              String
  nameEn            String?
  category          String?
  barcode           String?

  caloriesPer100g   Float
  proteinPer100g    Float
  carbsPer100g      Float
  fatPer100g        Float
  fiberPer100g      Float?
  sugarPer100g      Float?
  sodiumPer100g     Float?

  servingSize       String?
  servingWeightG    Float?

  confidence        String?
  extractionMethod  String?
  sourceUrl         String?
  rawData           Json?

  crawledAt         DateTime
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  @@unique([source, sourceId])
  @@index([name])
  @@index([barcode])
  @@index([brand])
  @@index([source])
  @@map("food_item")
}
```

**為什麼不復用 `FoodCache`**：
- `FoodCache` 是快取（有 TTL、JSON blob），爬蟲資料是自建權威資料（無過期、結構化欄位）
- `FoodItem` 需要 ILIKE 搜尋 name、barcode index、brand 篩選，JSON blob 不支援
- `@@unique([source, sourceId])` 確保冪等 upsert

### FoodService 整合設計

修改 `backend/src/food/food.service.ts` 的查詢邏輯：

**名稱搜尋（search）**：
```
TFDA fuzzy search + 爬蟲 DB ILIKE search（並行）
  → 合併去重
  → 若為非中文查詢且結果不足 → OFF 補充
```

**條碼查詢（findByBarcode）**：
```
爬蟲 DB barcode 查詢 → OFF → FatSecret fallback
```

FatSecret 從 `search()` 中完全移除，僅保留 `findByBarcode()` 的最後 fallback。

## Consequences

### 優點

- **台灣食品覆蓋率大幅提升**：連鎖餐廳、電商包裝食品、本土料理皆可涵蓋
- **減少對外部 API 的依賴**：自建資料庫為主，外部 API 為補充
- **Agent-driven 彈性高**：新增站台只需加設定，不需寫新 parser
- **格式自適應**：文字 / 圖片 / 混合格式的營養標示皆可處理
- **資料標準化**：以 per 100g 為單位，份量換算一致
- **可驗證**：自動規則 + 人工抽樣確保資料品質

### 缺點

- **LLM 提取有成本**：每頁面一次 API call，大量爬取時需控制成本
- **Agent 準確度需驗證**：不如固定 selector 精確，必須搭配驗證流程
- **初始建置投入**：框架、Agent prompt、驗證流程需要時間開發
- **定期重爬**：連鎖餐廳菜單季節性更新，需建立重爬機制

### 待決定事項

- [ ] 爬蟲排程策略（手動觸發 / cron / Apify 排程）
- [ ] Agent 使用哪個 LLM provider（Gemini Flash CP 值最高，或其他）
- [ ] 圖片營養標示的 Vision OCR 精度是否足夠
- [ ] 爬蟲執行監控與異常告警機制
- [ ] 初期目標站台清單（連鎖餐廳 + 電商平台）
- [ ] 爬蟲成本預算（per-page LLM call 費用估算）
