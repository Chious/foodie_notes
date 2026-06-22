# FatSecret Platform API — 串接參考

- **API 類型**：REST API（需 OAuth 2.0 認證）
- **Base URL**：`https://platform.fatsecret.com/rest/server.api`
- **官方文件**：https://platform.fatsecret.com/docs/guides
- **開發者註冊**：https://platform.fatsecret.com/
- **關聯 ADR**：[ADR-003](../../frontend/docs/ADR/ADR-003-ai-food-recognition-pipeline.md)

## 概述

FatSecret 是商業食品資料庫，提供全球食品營養數據。在食誌 App 中，FatSecret 作為**第三優先來源**：

1. **條碼掃描 fallback**（OFF 查無結果時使用）
2. **國際品牌食品搜尋**（補充 TFDA 和 OFF 的不足）

**資料來源標記**：`source: 'fatsecret'`

> **重要**：FatSecret 免費方案有每日 5,000 次呼叫限制，必須搭配快取使用（依 ADR-003 `food_cache` 設計，快取 30 天）。

## 註冊與取得憑證

1. 前往 https://platform.fatsecret.com/ 註冊開發者帳號
2. 建立新應用程式（Application）
3. 取得 `Client ID` 和 `Client Secret`
4. 選擇方案：
   - **Basic**（免費）：5,000 calls/day
   - **Premier Free**（免費，需申請）：unlimited calls，限新創/非營利/學生

## 環境變數

```bash
# .env
FATSECRET_CLIENT_ID=your_client_id
FATSECRET_CLIENT_SECRET=your_client_secret
FATSECRET_TOKEN_URL=https://oauth.fatsecret.com/connect/token
FATSECRET_API_URL=https://platform.fatsecret.com/rest/server.api
```

## 安裝套件

建議使用 Node.js 內建 `fetch`（自行管理 OAuth token）：

```bash
# 不需額外安裝
# 如需社群 SDK：
# npm install fatsecret-api
```

## OAuth 2.0 認證

FatSecret 使用 **Client Credentials Grant** 取得 access token。

### Token 請求

```
POST https://oauth.fatsecret.com/connect/token
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

grant_type=client_credentials&scope=basic
```

### Token 回應

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6...",
  "expires_in": 86400,
  "token_type": "Bearer",
  "scope": "basic"
}
```

> Token 有效期通常為 24 小時（86400 秒），需在過期前自動更新。

## API 端點

所有 API 呼叫使用 **POST** 方法，以 `method` 參數指定操作：

```
POST https://platform.fatsecret.com/rest/server.api
Content-Type: application/x-www-form-urlencoded
Authorization: Bearer {access_token}

method={method_name}&format=json&{parameters}
```

### 1. 食物搜尋 — `foods.search`

**請求參數**：

| 參數 | 必填 | 說明 |
|------|------|------|
| `method` | 是 | `foods.search` |
| `search_expression` | 是 | 搜尋關鍵字 |
| `format` | 是 | `json` |
| `max_results` | 否 | 每頁數量（預設 20，最大 50） |
| `page_number` | 否 | 頁碼（從 0 開始） |
| `region` | 否 | 地區代碼（如 `TW`） |
| `language` | 否 | 語言代碼（如 `zh`） |

**回應範例**：

```json
{
  "foods": {
    "food": [
      {
        "food_id": "36421",
        "food_name": "Mushrooms",
        "food_type": "Generic",
        "food_description": "Per 100g - Calories: 22kcal | Fat: 0.34g | Carbs: 3.28g | Protein: 3.09g",
        "food_url": "https://www.fatsecret.com/calories-nutrition/usda/mushrooms"
      },
      {
        "food_id": "62145",
        "food_name": "Chicken Breast",
        "food_type": "Generic",
        "food_description": "Per 100g - Calories: 165kcal | Fat: 3.57g | Carbs: 0.00g | Protein: 31.02g",
        "food_url": "https://www.fatsecret.com/calories-nutrition/usda/chicken-breast"
      }
    ],
    "max_results": "20",
    "page_number": "0",
    "total_results": "1129"
  }
}
```

**關鍵欄位**：

| 欄位 | 說明 |
|------|------|
| `food_id` | 食物唯一 ID，用於查詢詳情 |
| `food_name` | 食物名稱（主要為英文） |
| `food_type` | `Generic`（通用）或 `Brand`（品牌） |
| `food_description` | 營養摘要字串，需正則解析 |

**解析 `food_description`**：

```typescript
function parseFoodDescription(desc: string): {
  calories: number;
  fat: number;
  carbs: number;
  protein: number;
} {
  const caloriesMatch = desc.match(/Calories:\s*([\d.]+)kcal/);
  const fatMatch = desc.match(/Fat:\s*([\d.]+)g/);
  const carbsMatch = desc.match(/Carbs:\s*([\d.]+)g/);
  const proteinMatch = desc.match(/Protein:\s*([\d.]+)g/);

  return {
    calories: caloriesMatch ? parseFloat(caloriesMatch[1]) : 0,
    fat: fatMatch ? parseFloat(fatMatch[1]) : 0,
    carbs: carbsMatch ? parseFloat(carbsMatch[1]) : 0,
    protein: proteinMatch ? parseFloat(proteinMatch[1]) : 0,
  };
}
```

> **注意**：`food_description` 格式可能因地區/語言而異。搜尋中文時（`region=TW&language=zh`），描述可能為中文格式。

### 2. 食物詳情 — `food.get.v4`

**請求參數**：

| 參數 | 必填 | 說明 |
|------|------|------|
| `method` | 是 | `food.get.v4` |
| `food_id` | 是 | 食物 ID |
| `format` | 是 | `json` |

**回應範例**：

```json
{
  "food": {
    "food_id": "36421",
    "food_name": "Mushrooms",
    "food_type": "Generic",
    "servings": {
      "serving": [
        {
          "serving_id": "34083",
          "serving_description": "100 g",
          "metric_serving_amount": "100.000",
          "metric_serving_unit": "g",
          "calories": "22",
          "protein": "3.090",
          "carbohydrate": "3.280",
          "fat": "0.340",
          "saturated_fat": "0.050",
          "sodium": "5",
          "fiber": "1.000",
          "sugar": "1.980"
        },
        {
          "serving_id": "34084",
          "serving_description": "1 cup, pieces or slices",
          "metric_serving_amount": "70.000",
          "metric_serving_unit": "g",
          "calories": "15",
          "protein": "2.160",
          "carbohydrate": "2.300",
          "fat": "0.240"
        }
      ]
    }
  }
}
```

**關鍵欄位**（serving 層級）：

| 欄位 | 說明 | 對應 `FoodItemDto` |
|------|------|--------------------|
| `calories` | 該份量熱量 | `calories`（使用 100g 的 serving） |
| `protein` | 蛋白質 (g) | `protein` |
| `carbohydrate` | 碳水化合物 (g) | `carbs` |
| `fat` | 脂肪 (g) | `fat` |
| `metric_serving_amount` | 份量克數 | `weightG` |
| `serving_description` | 份量描述 | `unit` |

> 優先選取 `metric_serving_amount = 100` 的 serving，確保與 TFDA/OFF 的 per-100g 基準一致。

### 3. 條碼查詢 — `food.find_id_for_barcode`

**兩步驟流程**：先以條碼取得 `food_id`，再查詢食物詳情。

**Step 1：條碼 → food_id**

```
POST /rest/server.api
method=food.find_id_for_barcode&barcode={barcode}&format=json
```

**回應**：

```json
{
  "food_id": {
    "value": "62145"
  }
}
```

若查無結果，`food_id.value` 為 `"0"`。

**Step 2：food_id → 食物詳情**

使用上述 `food.get.v4` 端點查詢完整營養資訊。

## 速率限制

| 方案 | 每日上限 | 每秒建議 |
|------|---------|---------|
| Basic（免費） | 5,000 calls/day | 最多 2 req/sec |
| Premier Free | unlimited | 最多 5 req/sec |
| Premier | unlimited | 依合約 |

**管理策略**：
- 所有查詢結果存入 `food_cache`（快取 30 天）
- 監控每日用量，在 80% 時 log 警告
- 優先使用 TFDA 和 OFF，FatSecret 僅作為 fallback

## TypeScript 程式碼範例

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FoodItemDto } from '../food/dto/food-search.dto.js';
import { BarcodeResponseDto } from '../food/dto/food-barcode.dto.js';

@Injectable()
export class FatSecretService {
  private readonly logger = new Logger(FatSecretService.name);
  private readonly clientId: string;
  private readonly clientSecret: string;
  private readonly tokenUrl: string;
  private readonly apiUrl: string;

  private accessToken: string | null = null;
  private tokenExpiresAt = 0;

  constructor(private config: ConfigService) {
    this.clientId = this.config.getOrThrow('FATSECRET_CLIENT_ID');
    this.clientSecret = this.config.getOrThrow('FATSECRET_CLIENT_SECRET');
    this.tokenUrl = this.config.get(
      'FATSECRET_TOKEN_URL',
      'https://oauth.fatsecret.com/connect/token',
    );
    this.apiUrl = this.config.get(
      'FATSECRET_API_URL',
      'https://platform.fatsecret.com/rest/server.api',
    );
  }

  // --- OAuth 2.0 Token 管理 ---

  private async getAccessToken(): Promise<string> {
    if (this.accessToken && Date.now() < this.tokenExpiresAt) {
      return this.accessToken;
    }

    const credentials = Buffer.from(
      `${this.clientId}:${this.clientSecret}`,
    ).toString('base64');

    const response = await fetch(this.tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Authorization: `Basic ${credentials}`,
      },
      body: 'grant_type=client_credentials&scope=basic',
    });

    if (!response.ok) {
      throw new Error(`FatSecret token error: ${response.status}`);
    }

    const data = await response.json();
    this.accessToken = data.access_token;
    // 提前 5 分鐘更新 token
    this.tokenExpiresAt = Date.now() + (data.expires_in - 300) * 1000;

    return this.accessToken!;
  }

  private async apiCall(params: Record<string, string>): Promise<unknown> {
    const token = await this.getAccessToken();
    const body = new URLSearchParams({ ...params, format: 'json' });

    const response = await fetch(this.apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Authorization: `Bearer ${token}`,
      },
      body: body.toString(),
      signal: AbortSignal.timeout(10_000),
    });

    if (!response.ok) {
      throw new Error(`FatSecret API error: ${response.status}`);
    }

    return response.json();
  }

  // --- 食物搜尋 ---

  async search(query: string, page = 0, limit = 20): Promise<FoodItemDto[]> {
    const data = (await this.apiCall({
      method: 'foods.search',
      search_expression: query,
      max_results: String(limit),
      page_number: String(page),
    })) as { foods?: { food?: FsSearchFood | FsSearchFood[] } };

    const foods = data.foods?.food;
    if (!foods) return [];

    const foodArray = Array.isArray(foods) ? foods : [foods];
    return foodArray.map((f) => this.searchResultToFoodItem(f));
  }

  // --- 條碼查詢 ---

  async findByBarcode(barcode: string): Promise<BarcodeResponseDto> {
    const idData = (await this.apiCall({
      method: 'food.find_id_for_barcode',
      barcode,
    })) as { food_id?: { value: string } };

    const foodId = idData.food_id?.value;
    if (!foodId || foodId === '0') {
      return { found: false, item: null, source: null };
    }

    const detailData = (await this.apiCall({
      method: 'food.get.v4',
      food_id: foodId,
    })) as { food?: FsDetailFood };

    if (!detailData.food) {
      return { found: false, item: null, source: null };
    }

    return {
      found: true,
      item: this.detailToFoodItem(detailData.food),
      source: 'fatsecret',
    };
  }

  // --- 資料對應 ---

  private searchResultToFoodItem(food: FsSearchFood): FoodItemDto {
    const parsed = parseFoodDescription(food.food_description ?? '');
    return {
      id: `fs-${food.food_id}`,
      name: food.food_name,
      calories: parsed.calories,
      protein: parsed.protein,
      carbs: parsed.carbs,
      fat: parsed.fat,
      unit: '100g',
      weightG: 100,
      source: 'fatsecret',
    };
  }

  private detailToFoodItem(food: FsDetailFood): FoodItemDto {
    const servings = food.servings?.serving;
    if (!servings) {
      return {
        id: `fs-${food.food_id}`,
        name: food.food_name,
        calories: 0, protein: 0, carbs: 0, fat: 0,
        unit: '100g', weightG: 100, source: 'fatsecret',
      };
    }

    const servingArray = Array.isArray(servings) ? servings : [servings];
    // 優先選取 100g 的 serving
    const serving =
      servingArray.find((s) => parseFloat(s.metric_serving_amount) === 100) ??
      servingArray[0];

    return {
      id: `fs-${food.food_id}`,
      name: food.food_name,
      calories: parseFloat(serving.calories) || 0,
      protein: parseFloat(serving.protein) || 0,
      carbs: parseFloat(serving.carbohydrate) || 0,
      fat: parseFloat(serving.fat) || 0,
      unit: serving.serving_description ?? '100g',
      weightG: parseFloat(serving.metric_serving_amount) || 100,
      source: 'fatsecret',
    };
  }
}

// --- 輔助型別 ---

interface FsSearchFood {
  food_id: string;
  food_name: string;
  food_type: string;
  food_description?: string;
}

interface FsDetailFood {
  food_id: string;
  food_name: string;
  servings?: {
    serving?: FsServing | FsServing[];
  };
}

interface FsServing {
  serving_id: string;
  serving_description: string;
  metric_serving_amount: string;
  metric_serving_unit: string;
  calories: string;
  protein: string;
  carbohydrate: string;
  fat: string;
}

function parseFoodDescription(desc: string) {
  const cal = desc.match(/Calories:\s*([\d.]+)kcal/);
  const fat = desc.match(/Fat:\s*([\d.]+)g/);
  const carbs = desc.match(/Carbs:\s*([\d.]+)g/);
  const protein = desc.match(/Protein:\s*([\d.]+)g/);
  return {
    calories: cal ? parseFloat(cal[1]) : 0,
    fat: fat ? parseFloat(fat[1]) : 0,
    carbs: carbs ? parseFloat(carbs[1]) : 0,
    protein: protein ? parseFloat(protein[1]) : 0,
  };
}
```

## 錯誤處理

| 錯誤碼 | 說明 | 處理方式 |
|--------|------|---------|
| HTTP 401 | Token 過期或無效 | 清除 token 快取，重新取得 |
| HTTP 429 | 超出速率限制 | 等待後重試，或回傳 fallback |
| API error `2` | 缺少必要參數 | 檢查請求參數 |
| API error `7` | 無效的 food_id | 回傳查無結果 |
| API error `107` | 缺少 method 參數 | 檢查請求格式 |
| `food_id.value = "0"` | 條碼查無結果 | 回傳 `found: false` |
| 搜尋無結果 | `foods` 欄位不存在 | 回傳空陣列 |
| 單一結果 | `foods.food` 為物件非陣列 | 包裝為陣列處理 |

> **特別注意**：當搜尋結果只有 1 筆時，`foods.food` 會是物件而非陣列。程式碼中需處理這個邊界情況（見上方 `Array.isArray` 檢查）。
