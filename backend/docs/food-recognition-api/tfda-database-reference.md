# TFDA 食品營養成分資料庫 — 串接參考

- **資料來源**：衛生福利部食品藥物管理署（TFDA）
- **檔案位置**：`backend/assets/食品營養成分資料庫2025版UPDATE1.xlsx`
- **官方網站**：https://consumer.fda.gov.tw/Food/TFND.aspx?nodeID=178
- **政府開放資料**：https://data.gov.tw/dataset/8543
- **關聯 ADR**：[ADR-003](../../frontend/docs/ADR/ADR-003-ai-food-recognition-pipeline.md)

## 概述

TFDA 食品營養成分資料庫是台灣官方的食物營養數據來源，收錄約 2,000+ 筆台灣常見食物的每 100g 營養成分。在食誌 App 中，TFDA 是 AI 辨識後進行營養數據比對的**最高優先資料來源**。

**角色定位**：LLM 負責「看」（辨識食物名稱），TFDA 負責「算」（提供權威營養數據）。

## 檔案結構

### 基本資訊

| 項目 | 說明 |
|------|------|
| 檔案格式 | Microsoft Excel 2007+（.xlsx） |
| 檔案大小 | ~1.9 MB |
| 工作表名稱 | 台灣食品成分表 |
| 資料列數 | ~2,000+ 筆 |
| 欄位數 | 100+ 欄（含完整微量營養素） |

### 列結構

| 列號 | 內容 |
|------|------|
| Row 1 | 標題說明：「本資料庫所列數值單位均為每100g可食部分之含量」 |
| Row 2 | 欄位標頭（header） |
| Row 3+ | 實際食物資料 |

### 關鍵欄位對應

以下為與 App 功能相關的核心欄位（已從實際檔案確認）：

| 欄位名稱 | 用途 | 對應 `FoodItemDto` 欄位 |
|----------|------|------------------------|
| `整合編號` | 食物唯一識別碼（如 A0100101） | `id`（加上 `tfda-` 前綴） |
| `食品分類` | 食物分類（如「穀物類」） | 額外資訊，用於分類搜尋 |
| `樣品名稱` | 食物中文名稱 | `name` |
| `俗名` | 別名（如「小薏仁, 洋薏仁」） | 用於 fuzzy match 輔助 |
| `內容物描述` | 狀態描述（如「生, 已去殼」） | 額外資訊 |
| `廢棄率(%)` | 不可食部分比例 | 可用於份量校正 |
| `熱量(kcal)` | 每 100g 熱量 | `calories` |
| `修正熱量(kcal)` | 修正後熱量（考慮膳食纖維） | 可作為替代值 |
| `粗蛋白(g)` | 每 100g 蛋白質 | `protein` |
| `粗脂肪(g)` | 每 100g 脂肪 | `fat` |
| `總碳水化合物(g)` | 每 100g 碳水化合物 | `carbs` |
| `膳食纖維(g)` | 每 100g 膳食纖維 | 額外營養素 |
| `糖質總量(g)` | 每 100g 糖 | 額外營養素 |
| `鈉(mg)` | 每 100g 鈉 | 額外營養素 |

### 完整欄位清單（供參考）

除核心欄位外，還包含以下微量營養素欄位：

- **礦物質**：鉀(mg)、鈣(mg)、鎂(mg)、鐵(mg)、鋅(mg)、磷(mg)、銅(mg)、錳(mg)
- **維生素**：A(IU)、D(ug)、E(mg)、K1(ug)、K2(ug)、B1(mg)、B2(mg)、菸鹼素(mg)、B6(mg)、B12(ug)、葉酸(ug)、C(mg)
- **脂肪酸**：飽和脂肪酸(mg)、單元不飽和脂肪酸(mg)、多元不飽和脂肪酸(mg)、反式脂肪(mg)、EPA/DHA 等
- **胺基酸**：天門冬胺酸、酥胺酸、絲胺酸、麩胺酸 等 20 種
- **其他**：膽固醇(mg)、酒精含量(g)

### 18 種食品分類

穀物類、澱粉類、堅果種子類、豆類、蔬菜類、水果類、菇類、藻類、豆製品、肉類、魚貝類、蛋類、乳品類、油脂類、糖類、飲料類、調味料及香辛料類、糕餅點心類

## 安裝套件

使用 `exceljs` 解析 Excel 檔案（支援 streaming、TypeScript 型別完整）：

```bash
npm install exceljs
```

## TypeScript 介面定義

```typescript
interface TfdaFoodItem {
  id: string;            // "tfda-A0100101"
  sampleCode: string;    // "A0100101"（原始整合編號）
  category: string;      // "穀物類"
  nameZh: string;        // "大麥仁"（樣品名稱）
  commonName: string | null;  // "小薏仁,洋薏仁"（俗名）
  description: string | null; // "生,已去殼"（內容物描述）
  caloriesPer100g: number;
  proteinPer100g: number;
  fatPer100g: number;
  carbsPer100g: number;
  fiberPer100g: number | null;
  sugarPer100g: number | null;
  sodiumPer100g: number | null;
}
```

## 解析程式碼範例

### 啟動時載入（NestJS Service）

```typescript
import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import ExcelJS from 'exceljs';
import * as path from 'path';

@Injectable()
export class TfdaService implements OnModuleInit {
  private readonly logger = new Logger(TfdaService.name);
  private foods: TfdaFoodItem[] = [];

  async onModuleInit() {
    await this.loadDatabase();
    this.logger.log(`TFDA 資料庫載入完成：${this.foods.length} 筆`);
  }

  private async loadDatabase() {
    const filePath = path.join(
      process.cwd(),
      'assets',
      '食品營養成分資料庫2025版UPDATE1.xlsx',
    );

    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.readFile(filePath);

    const worksheet = workbook.worksheets[0];
    const foods: TfdaFoodItem[] = [];

    // Row 1 = 標題說明, Row 2 = 欄位標頭, Row 3+ = 資料
    worksheet.eachRow((row, rowNumber) => {
      if (rowNumber <= 2) return;

      const sampleCode = this.cellToString(row.getCell(1));
      if (!sampleCode) return;

      foods.push({
        id: `tfda-${sampleCode}`,
        sampleCode,
        category: this.cellToString(row.getCell(2)),
        nameZh: this.cellToString(row.getCell(3)),
        description: this.cellToString(row.getCell(4)) || null,
        commonName: this.cellToString(row.getCell(5)) || null,
        caloriesPer100g: this.cellToNumber(row.getCell(7)),
        proteinPer100g: this.cellToNumber(row.getCell(10)),
        fatPer100g: this.cellToNumber(row.getCell(11)),
        carbsPer100g: this.cellToNumber(row.getCell(14)),
        fiberPer100g: this.cellToNumber(row.getCell(15)) || null,
        sugarPer100g: this.cellToNumber(row.getCell(16)) || null,
        sodiumPer100g: this.cellToNumber(row.getCell(18)) || null,
      });
    });

    this.foods = foods;
  }

  private cellToString(cell: ExcelJS.Cell): string {
    const value = cell.value;
    if (value === null || value === undefined) return '';
    return String(value).trim();
  }

  private cellToNumber(cell: ExcelJS.Cell): number {
    const value = cell.value;
    if (value === null || value === undefined) return 0;
    const str = String(value).trim();
    const num = parseFloat(str);
    return isNaN(num) ? 0 : num;
  }
}
```

### 搜尋方法

```typescript
search(query: string, category?: string): TfdaFoodItem[] {
  let results = this.foods;

  if (category) {
    results = results.filter((f) => f.category === category);
  }

  if (!query) return results;

  const q = query.trim().toLowerCase();

  return results.filter(
    (f) =>
      f.nameZh.toLowerCase().includes(q) ||
      (f.commonName && f.commonName.toLowerCase().includes(q)),
  );
}

findByCode(sampleCode: string): TfdaFoodItem | null {
  return this.foods.find((f) => f.sampleCode === sampleCode) ?? null;
}

getCategories(): string[] {
  return [...new Set(this.foods.map((f) => f.category))];
}
```

### 對應到 FoodItemDto

```typescript
import { FoodItemDto } from '../food/dto/food-search.dto.js';

function tfdaToFoodItem(item: TfdaFoodItem): FoodItemDto {
  return {
    id: item.id,
    name: item.nameZh,
    calories: item.caloriesPer100g,
    protein: item.proteinPer100g,
    carbs: item.carbsPer100g,
    fat: item.fatPer100g,
    unit: '100g',
    weightG: 100,
    source: 'tfda',
  };
}
```

## Fuzzy Match 策略

LLM 辨識回傳的食物名稱可能與 TFDA 樣品名稱不完全一致，需要模糊比對。

### Phase 1：子字串 + 同義詞對照表

```typescript
// 同義詞對照表（常見台灣食物）
const SYNONYMS: Record<string, string[]> = {
  '白飯': ['白米飯', '米飯'],
  '雞腿': ['棒棒腿', '雞腿肉'],
  '滷肉飯': ['魯肉飯'],
  '蚵仔煎': ['蚵仔煎餅'],
  // ... 持續擴充
};

function fuzzyMatch(
  llmName: string,
  foods: TfdaFoodItem[],
): { item: TfdaFoodItem; score: number } | null {
  const query = llmName.trim();

  // 1. 完全匹配
  const exact = foods.find(
    (f) => f.nameZh === query || f.commonName?.split(',').some((n) => n.trim() === query),
  );
  if (exact) return { item: exact, score: 1.0 };

  // 2. 同義詞匹配
  for (const [canonical, aliases] of Object.entries(SYNONYMS)) {
    if (aliases.includes(query) || canonical === query) {
      const found = foods.find((f) => f.nameZh.includes(canonical));
      if (found) return { item: found, score: 0.9 };
    }
  }

  // 3. 子字串匹配
  const substring = foods.find(
    (f) => f.nameZh.includes(query) || query.includes(f.nameZh),
  );
  if (substring) return { item: substring, score: 0.7 };

  return null;
}
```

### Phase 2（可選）：使用 fuse.js

```bash
npm install fuse.js
```

```typescript
import Fuse from 'fuse.js';

const fuse = new Fuse(foods, {
  keys: [
    { name: 'nameZh', weight: 0.6 },
    { name: 'commonName', weight: 0.3 },
    { name: 'description', weight: 0.1 },
  ],
  threshold: 0.4,
  includeScore: true,
});

const results = fuse.search('雞排');
// results[0].item = TfdaFoodItem, results[0].score = 0~1 (越小越匹配)
```

## 建置腳本（可選）

將 XLSX 預先轉為 JSON，加速應用啟動：

```typescript
// scripts/parse-tfda.ts
import ExcelJS from 'exceljs';
import * as fs from 'fs';
import * as path from 'path';

async function main() {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(
    path.join(process.cwd(), 'assets', '食品營養成分資料庫2025版UPDATE1.xlsx'),
  );

  const worksheet = workbook.worksheets[0];
  const foods: TfdaFoodItem[] = [];

  // ... 解析邏輯同上 ...

  const outputPath = path.join(process.cwd(), 'assets', 'tfda-foods.json');
  fs.writeFileSync(outputPath, JSON.stringify(foods, null, 2), 'utf-8');
  console.log(`已匯出 ${foods.length} 筆至 ${outputPath}`);
}

main();
```

```json
// package.json scripts
{
  "parse-tfda": "tsx scripts/parse-tfda.ts"
}
```

## 邊界情況處理

| 情況 | 處理方式 |
|------|---------|
| 空白儲存格 | 數值欄位回傳 `0`，文字欄位回傳 `null` |
| 數值含尾隨空白（如 `"365 "`） | `parseFloat()` 自動忽略尾隨空白 |
| 值為 `--` 或 `N/A` | `parseFloat()` 回傳 `NaN`，統一轉為 `0` |
| 俗名含多個值（如 `"小薏仁,洋薏仁"`） | 以逗號分割，每個別名都參與比對 |
| 同名食物不同分類 | 搜尋回傳全部匹配，由 Client 端讓使用者選擇 |
| 複合料理（如「滷肉飯」） | TFDA 可能沒有，需 fallback 到 OFF 或 LLM 估算 |

## 資料更新策略

- TFDA 約每年更新一次資料庫
- 更新流程：下載新版 XLSX → 替換 `assets/` 中的檔案 → 重新部署
- 版本資訊嵌入 `FoodDbVersionDto.version`，可從檔名中提取（如 `2025版UPDATE1`）
- `FoodDbVersionDto.recordCount` 應反映實際解析後的筆數
