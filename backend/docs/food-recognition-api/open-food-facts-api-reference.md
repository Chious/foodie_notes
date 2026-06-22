# Open Food Facts API — 串接參考

- **API 類型**：REST API（免費、開源、無需認證）
- **Base URL**：`https://world.openfoodfacts.org`
- **官方文件**：https://openfoodfacts.github.io/openfoodfacts-server/api/
- **API 教學**：https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
- **關聯 ADR**：[ADR-003](../../frontend/docs/ADR/ADR-003-ai-food-recognition-pipeline.md)

## 概述

Open Food Facts（OFF）是全球最大的開源食品資料庫，包含數百萬筆包裝食品資料。在食誌 App 中，OFF 主要用於：

1. **條碼掃描查詢**（優先於 FatSecret，因為免費無限制）
2. **包裝食品名稱搜尋**（作為 TFDA 的補充來源）

**資料來源標記**：`source: 'off'`

## 認證方式

**無需認證**。OFF 是完全開放的 API，不需要 API key。

唯一要求是設定有意義的 **User-Agent** header：

```
User-Agent: FoodieNotes/1.0.0 (contact@foodienotes.app)
```

> OFF 會封鎖未設定 User-Agent 或使用通用 User-Agent 的請求。

## 環境變數

```bash
# .env
OFF_BASE_URL=https://world.openfoodfacts.org   # 預設值
OFF_USER_AGENT=FoodieNotes/1.0.0               # 識別用
```

## 安裝套件

建議使用 Node.js 內建 `fetch`（無需額外套件）：

```bash
# 不需額外安裝
# 如需使用官方 SDK：
# npm install @openfoodfacts/openfoodfacts-nodejs
```

## API 端點

### 1. 條碼查詢

```
GET /api/v2/product/{barcode}?fields={fields}
```

**用途**：以 EAN-13 條碼查詢包裝食品。

**請求範例**：

```
GET https://world.openfoodfacts.org/api/v2/product/4710088412345?fields=product_name,product_name_zh,brands,nutriments,serving_size,serving_quantity,image_url,categories_tags
```

**回應範例**（成功）：

```json
{
  "code": "4710088412345",
  "status": 1,
  "status_verbose": "product found",
  "product": {
    "product_name": "Mini Puff - Chocolate",
    "product_name_zh": "小泡芙巧克力口味",
    "brands": "義美",
    "image_url": "https://images.openfoodfacts.org/...",
    "serving_size": "57g",
    "serving_quantity": 57,
    "categories_tags": ["en:snacks", "en:biscuits"],
    "nutriments": {
      "energy-kcal_100g": 520,
      "proteins_100g": 7.5,
      "carbohydrates_100g": 60.2,
      "fat_100g": 28.1,
      "saturated-fat_100g": 15.2,
      "sugars_100g": 25.0,
      "sodium_100g": 0.18,
      "fiber_100g": 1.5
    }
  }
}
```

**回應範例**（未找到）：

```json
{
  "code": "0000000000000",
  "status": 0,
  "status_verbose": "product not found"
}
```

**關鍵回應欄位**：

| 欄位路徑 | 說明 | 對應 `FoodItemDto` |
|----------|------|--------------------|
| `product.product_name` | 商品名稱（可能為英文） | `name`（優先使用 `product_name_zh`） |
| `product.product_name_zh` | 中文商品名稱（可能不存在） | `name`（優先） |
| `product.nutriments.energy-kcal_100g` | 每 100g 熱量 | `calories` |
| `product.nutriments.proteins_100g` | 每 100g 蛋白質 | `protein` |
| `product.nutriments.carbohydrates_100g` | 每 100g 碳水化合物 | `carbs` |
| `product.nutriments.fat_100g` | 每 100g 脂肪 | `fat` |
| `product.serving_size` | 份量描述（如 "57g"） | 可用於 `unit` |
| `product.serving_quantity` | 份量克數 | `weightG` |

### 2. 食物搜尋

```
GET /cgi/search.pl?search_terms={query}&search_simple=1&action=process&json=1&page={page}&page_size={limit}&fields={fields}
```

**用途**：以關鍵字搜尋食品。

**請求範例**：

```
GET https://world.openfoodfacts.org/cgi/search.pl?search_terms=義美&search_simple=1&action=process&json=1&page=1&page_size=20&fields=code,product_name,product_name_zh,brands,nutriments
```

**回應範例**：

```json
{
  "count": 150,
  "page": 1,
  "page_count": 8,
  "page_size": 20,
  "products": [
    {
      "code": "4710088412345",
      "product_name": "Mini Puff",
      "product_name_zh": "小泡芙",
      "brands": "義美",
      "nutriments": {
        "energy-kcal_100g": 520,
        "proteins_100g": 7.5,
        "carbohydrates_100g": 60.2,
        "fat_100g": 28.1
      }
    }
  ]
}
```

> **注意**：中文搜尋品質有限。OFF 以全球品牌為主，台灣在地食物（如滷肉飯、蚵仔煎）通常查不到。中文搜尋主要適用於有中文標籤的包裝食品。

## 速率限制

| 操作 | 限制 |
|------|------|
| 條碼查詢（GET product） | ~15 req/min/IP |
| 搜尋（GET search） | ~10 req/min/IP |
| 超過限制 | IP 會被暫時封鎖 |

建議：
- 條碼查詢結果在 `food_cache` 表中快取（依 ADR-003 設計，快取 30 天）
- 避免短時間內大量搜尋

## TypeScript 程式碼範例

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FoodItemDto } from '../food/dto/food-search.dto.js';
import { BarcodeResponseDto } from '../food/dto/food-barcode.dto.js';

interface OffNutriments {
  'energy-kcal_100g'?: number;
  proteins_100g?: number;
  carbohydrates_100g?: number;
  fat_100g?: number;
}

interface OffProduct {
  code: string;
  product_name?: string;
  product_name_zh?: string;
  brands?: string;
  nutriments?: OffNutriments;
  serving_size?: string;
  serving_quantity?: number;
}

interface OffProductResponse {
  status: number;
  product?: OffProduct;
}

interface OffSearchResponse {
  count: number;
  page: number;
  page_size: number;
  products: OffProduct[];
}

@Injectable()
export class OpenFoodFactsService {
  private readonly logger = new Logger(OpenFoodFactsService.name);
  private readonly baseUrl: string;
  private readonly userAgent: string;

  constructor(private config: ConfigService) {
    this.baseUrl = this.config.get('OFF_BASE_URL', 'https://world.openfoodfacts.org');
    this.userAgent = this.config.get('OFF_USER_AGENT', 'FoodieNotes/1.0.0');
  }

  async findByBarcode(barcode: string): Promise<BarcodeResponseDto> {
    const fields = 'product_name,product_name_zh,brands,nutriments,serving_size,serving_quantity';
    const url = `${this.baseUrl}/api/v2/product/${barcode}?fields=${fields}`;

    const response = await fetch(url, {
      headers: { 'User-Agent': this.userAgent },
      signal: AbortSignal.timeout(10_000),
    });

    const data: OffProductResponse = await response.json();

    if (data.status !== 1 || !data.product) {
      return { found: false, item: null, source: null };
    }

    return {
      found: true,
      item: this.mapToFoodItem(data.product),
      source: 'off',
    };
  }

  async search(query: string, page = 1, limit = 20): Promise<FoodItemDto[]> {
    const params = new URLSearchParams({
      search_terms: query,
      search_simple: '1',
      action: 'process',
      json: '1',
      page: String(page),
      page_size: String(limit),
      fields: 'code,product_name,product_name_zh,brands,nutriments,serving_size,serving_quantity',
    });

    const url = `${this.baseUrl}/cgi/search.pl?${params}`;

    const response = await fetch(url, {
      headers: { 'User-Agent': this.userAgent },
      signal: AbortSignal.timeout(10_000),
    });

    const data: OffSearchResponse = await response.json();
    return data.products
      .filter((p) => p.nutriments?.['energy-kcal_100g'] !== undefined)
      .map((p) => this.mapToFoodItem(p));
  }

  private mapToFoodItem(product: OffProduct): FoodItemDto {
    const n = product.nutriments ?? {};
    return {
      id: `off-${product.code}`,
      name: product.product_name_zh || product.product_name || '未知商品',
      calories: n['energy-kcal_100g'] ?? 0,
      protein: n.proteins_100g ?? 0,
      carbs: n.carbohydrates_100g ?? 0,
      fat: n.fat_100g ?? 0,
      unit: '100g',
      weightG: product.serving_quantity ?? 100,
      source: 'off',
    };
  }
}
```

## 錯誤處理

| 情境 | 處理方式 |
|------|---------|
| 網路逾時 | 設定 10 秒 timeout，逾時回傳 `found: false` |
| HTTP 404 | 條碼不存在，回傳 `found: false` |
| `status: 0` | 產品未找到，回傳 `found: false` |
| 營養素欄位缺失 | 該欄位回傳 `0`，在搜尋結果中可過濾掉缺失過多的項目 |
| JSON 解析錯誤 | catch 後 log 錯誤，回傳空結果 |
| IP 被暫時封鎖（429） | 等待後重試，或切換至 FatSecret |

## 資料品質備註

- 許多台灣商品存在於 OFF 但營養資料可能不完整
- 商品名稱可能為英文、中文或混合語言
- 營養數值預設為每 100g，使用 `serving_size` 可轉換為每份
- 部分資料為使用者貢獻，可能不精確
- 建議搭配 TFDA 使用：OFF 適合包裝食品，TFDA 適合原型食物
