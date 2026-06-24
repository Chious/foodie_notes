# LLM Vision API — 串接參考

- **用途**：食物照片辨識（回傳食物名稱、估算份量、信心度）
- **支援 Provider**：Google Gemini / OpenAI GPT / Anthropic Claude / Hugging Face（開源 VLM）
- **關聯 ADR**：[ADR-003](../../docs/ADR/ADR-003-ai-food-recognition-pipeline.md)

## 概述

LLM Vision API 負責「看」— 接收使用者拍攝的食物照片，辨識其中的食物品項。**LLM 僅辨識食物名稱與估算份量，不提供營養數據**（營養數據由 TFDA/OFF/FatSecret 提供）。

後端支援多個 LLM Provider，透過統一介面抽象，可在執行時切換。

## Provider 比較

| Provider | 套件名稱 | 推薦模型 | Input 成本/1M tokens | Output 成本/1M tokens | 結構化輸出 | 建議用途 |
|----------|---------|---------|---------------------|----------------------|-----------|---------|
| Google | `@google/generative-ai` | Gemini 2.5 Flash | ~$0.15-0.50 | ~$0.60-2.00 | `responseMimeType` | **預設首選**：最便宜 |
| OpenAI | `openai` | GPT-4o-mini | ~$0.15 | ~$0.60 | 原生 `json_schema` | 備選：JSON 輸出最穩定 |
| Anthropic | `@anthropic-ai/sdk` | Claude Haiku 4.5 | ~$1.00 | ~$5.00 | prompt 引導 | 替代：推理能力強 |
| Hugging Face | `@huggingface/inference` | Qwen2.5-VL-7B-Instruct | 依方案而異 | 依方案而異 | prompt 引導 | 開源自架：長期成本最低 |

> **成本提醒**：一張食物照片約 250-1000 tokens（依解析度），加上 prompt 和回應約 500-2000 tokens 總計。使用最便宜的 provider（Gemini Flash 或 GPT-4o-mini），每次辨識成本約 $0.001-0.005。

## 安裝套件

```bash
# 依需求安裝（至少一個）
npm install @google/generative-ai    # Gemini
npm install openai                   # OpenAI
npm install @anthropic-ai/sdk        # Anthropic Claude
npm install @huggingface/inference   # Hugging Face
```

## 環境變數

```bash
# .env — 至少設定一組 API Key
GEMINI_API_KEY=your_gemini_api_key
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key

# Provider 選擇（gemini | openai | anthropic | huggingface）
LLM_VISION_PROVIDER=gemini

# Hugging Face API Token（使用 HF 時必填）
HF_API_TOKEN=your_huggingface_api_token

# 可選：覆寫預設模型
LLM_VISION_MODEL=gemini-2.5-flash
```

## 共用 Prompt 設計

所有 Provider 使用相同的 system prompt，要求回傳繁體中文食物名稱與結構化 JSON：

```typescript
const FOOD_RECOGNITION_PROMPT = `你是一個專業的食物辨識助手。分析這張食物照片，辨識所有可見的食物品項。

規則：
1. 食物名稱使用繁體中文（台灣用語）
2. 估算每個品項的重量（克）
3. 為每個品項評估辨識信心度（high / medium / low）
4. 如果看起來是一個完整餐點，推測整餐名稱
5. 不要提供營養數據，只辨識名稱和份量

回傳以下 JSON 格式：
{
  "meal_name": "整餐名稱（如：雞排便當）",
  "items": [
    {
      "name": "食物名稱",
      "weight_g": 估算重量（數字）,
      "quantity": 數量（數字）,
      "unit": "單位（份/碗/杯/片等）",
      "confidence": "high/medium/low"
    }
  ]
}`;
```

### LLM 回應的 Zod 驗證 Schema

```typescript
import { z } from 'zod';

const LlmFoodItemSchema = z.object({
  name: z.string(),
  weight_g: z.number().positive(),
  quantity: z.number().positive().default(1),
  unit: z.string().default('份'),
  confidence: z.enum(['high', 'medium', 'low']),
});

const LlmRecognitionSchema = z.object({
  meal_name: z.string(),
  items: z.array(LlmFoodItemSchema).min(1),
});

type LlmRecognitionResult = z.infer<typeof LlmRecognitionSchema>;
```

## Provider 串接

### 1. Google Gemini（預設首選）

**官方文件**：
- API 總覽：https://ai.google.dev/gemini-api/docs
- 圖片理解：https://ai.google.dev/gemini-api/docs/image-understanding
- 定價：https://ai.google.dev/gemini-api/docs/pricing

```typescript
import { GoogleGenerativeAI } from '@google/generative-ai';

async function recognizeWithGemini(
  imageBuffer: Buffer,
  mimeType: string,
): Promise<LlmRecognitionResult> {
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
  const model = genAI.getGenerativeModel({
    model: 'gemini-2.5-flash',
    generationConfig: {
      responseMimeType: 'application/json',
    },
  });

  const result = await model.generateContent([
    FOOD_RECOGNITION_PROMPT,
    {
      inlineData: {
        data: imageBuffer.toString('base64'),
        mimeType, // 'image/jpeg' 或 'image/png'
      },
    },
  ]);

  const text = result.response.text();
  const parsed = JSON.parse(text);
  return LlmRecognitionSchema.parse(parsed);
}
```

**Gemini 特色**：
- `responseMimeType: 'application/json'` 強制回傳合法 JSON
- 支援 `responseSchema` 進一步約束 JSON 結構
- 圖片 token 計算：依解析度自動調整（約 250-500 tokens/張）

### 2. OpenAI GPT（備選）

**官方文件**：
- Vision 指南：https://developers.openai.com/api/docs/guides/images-vision
- 結構化輸出：https://developers.openai.com/api/docs/guides/structured-outputs
- 定價：https://developers.openai.com/api/docs/pricing

```typescript
import OpenAI from 'openai';

async function recognizeWithOpenAI(
  imageBuffer: Buffer,
  mimeType: string,
): Promise<LlmRecognitionResult> {
  const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY! });

  const base64Image = imageBuffer.toString('base64');
  const dataUri = `data:${mimeType};base64,${base64Image}`;

  const response = await client.chat.completions.create({
    model: 'gpt-4o-mini',
    response_format: {
      type: 'json_schema',
      json_schema: {
        name: 'FoodRecognition',
        strict: true,
        schema: {
          type: 'object',
          properties: {
            meal_name: { type: 'string' },
            items: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  weight_g: { type: 'number' },
                  quantity: { type: 'number' },
                  unit: { type: 'string' },
                  confidence: {
                    type: 'string',
                    enum: ['high', 'medium', 'low'],
                  },
                },
                required: ['name', 'weight_g', 'quantity', 'unit', 'confidence'],
                additionalProperties: false,
              },
            },
          },
          required: ['meal_name', 'items'],
          additionalProperties: false,
        },
      },
    },
    messages: [
      {
        role: 'user',
        content: [
          { type: 'image_url', image_url: { url: dataUri } },
          { type: 'text', text: FOOD_RECOGNITION_PROMPT },
        ],
      },
    ],
  });

  const text = response.choices[0].message.content!;
  return LlmRecognitionSchema.parse(JSON.parse(text));
}
```

**OpenAI 特色**：
- `response_format.json_schema` 搭配 `strict: true` 保證回傳符合 schema 的 JSON
- 圖片以 data URI 格式傳送（`data:image/jpeg;base64,...`）
- 也支援 URL 方式傳送圖片

### 3. Anthropic Claude（替代方案）

**官方文件**：
- Vision 文件：https://docs.anthropic.com/en/docs/build-with-claude/vision
- 定價：https://docs.anthropic.com/en/docs/about-claude/pricing

```typescript
import Anthropic from '@anthropic-ai/sdk';

async function recognizeWithClaude(
  imageBuffer: Buffer,
  mimeType: string,
): Promise<LlmRecognitionResult> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY! });

  const response = await anthropic.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 1024,
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            source: {
              type: 'base64',
              media_type: mimeType as 'image/jpeg' | 'image/png' | 'image/gif' | 'image/webp',
              data: imageBuffer.toString('base64'),
            },
          },
          {
            type: 'text',
            text: FOOD_RECOGNITION_PROMPT + '\n\n請只回傳 JSON，不要包含其他文字。',
          },
        ],
      },
    ],
  });

  const textBlock = response.content.find((b) => b.type === 'text');
  if (!textBlock || textBlock.type !== 'text') {
    throw new Error('Claude 未回傳文字內容');
  }

  const jsonStr = textBlock.text.replace(/```json\n?|\n?```/g, '').trim();
  return LlmRecognitionSchema.parse(JSON.parse(jsonStr));
}
```

**Claude 特色**：
- 圖片使用 `image` content block（非 URL）
- `media_type` 必須明確指定
- 無原生 JSON schema 強制，需透過 prompt 引導 + 後處理清理 markdown code block
- 支援 `image/jpeg`, `image/png`, `image/gif`, `image/webp`

### 4. Hugging Face 開源 VLM（自架 / Inference API）

**官方文件**：
- Inference API：https://huggingface.co/docs/api-inference
- Qwen2.5-VL-7B-Instruct：https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct
- Qwen2.5-VL-72B-Instruct：https://huggingface.co/Qwen/Qwen2.5-VL-72B-Instruct

```typescript
import { HfInference } from '@huggingface/inference';

async function recognizeWithHuggingFace(
  imageBuffer: Buffer,
  mimeType: string,
): Promise<LlmRecognitionResult> {
  const hf = new HfInference(process.env.HF_API_TOKEN!);

  const response = await hf.chatCompletion({
    model: 'Qwen/Qwen2.5-VL-7B-Instruct',
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image_url',
            image_url: {
              url: `data:${mimeType};base64,${imageBuffer.toString('base64')}`,
            },
          },
          {
            type: 'text',
            text: FOOD_RECOGNITION_PROMPT + '\n\n請只回傳 JSON，不要包含其他文字。',
          },
        ],
      },
    ],
    max_tokens: 1024,
  });

  const text = response.choices[0].message.content!;
  const jsonStr = text.replace(/```json\n?|\n?```/g, '').trim();
  return LlmRecognitionSchema.parse(JSON.parse(jsonStr));
}
```

**Hugging Face 特色**：
- 可透過 Inference API 免自架使用，也可自架於 GPU 伺服器
- 無原生 JSON schema 強制，需透過 prompt 引導 + 後處理清理 markdown code block
- 模型開源免授權費，長期大量使用成本最低
- 推薦模型比較：

| 模型 | 參數量 | 適用場景 |
|------|--------|---------|
| Qwen2.5-VL-3B-Instruct | 3B | 輕量部署、Edge 裝置 |
| Qwen2.5-VL-7B-Instruct | 7B | **推薦**：精度與成本平衡 |
| Qwen2.5-VL-72B-Instruct | 72B | 最高精度，需大量 GPU |
| InternVL 3 | 多種 | 原生多模態預訓練，視覺理解能力強 |
| LLaVA 系列 | 7B-13B | 經典開源 VLM，社群資源豐富 |

> **注意**：開源 VLM 的食物辨識精度可能略低於商業模型（GPT-4o / Gemini），建議先以測試集評估後再正式採用。

#### 專門食物分類模型（補充）

Hugging Face 上也有針對食物分類 fine-tuned 的輕量模型，僅做分類（回傳食物類別），**無法**估算份量或回傳結構化 JSON，適合作為前置篩選或輔助：

| 模型 | 基礎架構 | 說明 |
|------|---------|------|
| [Kaludi/food-category-classification-v2.0](https://huggingface.co/Kaludi/food-category-classification-v2.0) | ViT | 多分類食物類別 |
| [BinhQuocNguyen/food-recognition-vit](https://huggingface.co/BinhQuocNguyen/food-recognition-vit) | ViT-Base | 10 類食物辨識 |
| [Shresthadev403/food-image-classification](https://huggingface.co/Shresthadev403/food-image-classification) | ViT | Food-101 資料集 |

相關資料集：[Codatta/MM-Food-100K](https://huggingface.co/datasets/Codatta/MM-Food-100K) — 10 萬張食物圖片，涵蓋辨識、分類、營養分析。

## NestJS 整合架構

### Provider 介面

```typescript
interface LlmVisionProvider {
  recognize(imageBuffer: Buffer, mimeType: string): Promise<LlmRecognitionResult>;
}
```

### Factory 模式選擇 Provider

```typescript
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class LlmVisionFactory {
  constructor(
    private config: ConfigService,
    private gemini: GeminiVisionService,
    private openai: OpenAIVisionService,
    private anthropic: AnthropicVisionService,
    private huggingface: HuggingFaceVisionService,
  ) {}

  getProvider(override?: string): LlmVisionProvider {
    const provider = override ?? this.config.get('LLM_VISION_PROVIDER', 'gemini');

    switch (provider) {
      case 'gemini': return this.gemini;
      case 'openai': return this.openai;
      case 'anthropic': return this.anthropic;
      case 'huggingface': return this.huggingface;
      default: return this.gemini;
    }
  }
}
```

### RecognizeService 整合

```typescript
import { RecognizeResponseDto, RecognizedItemDto } from './dto/recognize.dto.js';

@Injectable()
export class RecognizeService {
  constructor(
    private llmFactory: LlmVisionFactory,
    private tfdaService: TfdaService,
  ) {}

  async recognize(
    imageBuffer: Buffer,
    mimeType: string,
    provider?: string,
  ): Promise<RecognizeResponseDto> {
    const llm = this.llmFactory.getProvider(provider);
    const result = await llm.recognize(imageBuffer, mimeType);

    // LLM 辨識結果 → 對應 TFDA 營養數據
    const items: RecognizedItemDto[] = result.items.map((item) => {
      const tfdaMatch = this.tfdaService.fuzzyMatch(item.name);

      if (tfdaMatch) {
        const scale = item.weight_g / 100;
        return {
          id: tfdaMatch.item.id,
          name: item.name,
          calories: Math.round(tfdaMatch.item.caloriesPer100g * scale),
          protein: Math.round(tfdaMatch.item.proteinPer100g * scale * 10) / 10,
          carbs: Math.round(tfdaMatch.item.carbsPer100g * scale * 10) / 10,
          fat: Math.round(tfdaMatch.item.fatPer100g * scale * 10) / 10,
          quantity: item.quantity,
          unit: item.unit,
          weightG: item.weight_g,
          confidence: this.resolveConfidence(item.confidence, tfdaMatch.score),
          selected: item.confidence === 'high' && tfdaMatch.score >= 0.9,
          source: 'tfda',
        };
      }

      // TFDA 無匹配 → 標記為 LLM 估算
      return {
        id: `llm-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
        name: item.name,
        calories: 0, protein: 0, carbs: 0, fat: 0,
        quantity: item.quantity,
        unit: item.unit,
        weightG: item.weight_g,
        confidence: 'low',
        selected: false,
        source: 'user', // 需要使用者確認
      };
    });

    const selectedItems = items.filter((i) => i.selected);

    return {
      mealName: result.meal_name,
      detectedCount: items.length,
      items,
      summary: {
        totalCalories: selectedItems.reduce((sum, i) => sum + i.calories, 0),
        totalProtein: selectedItems.reduce((sum, i) => sum + i.protein, 0),
        dailyCaloriesPct: 0, // 需依使用者設定計算
        dailyProteinPct: 0,
      },
    };
  }

  private resolveConfidence(
    llmConfidence: string,
    matchScore: number,
  ): string {
    if (llmConfidence === 'high' && matchScore >= 0.9) return 'high';
    if (llmConfidence === 'high' && matchScore >= 0.7) return 'medium';
    return 'low';
  }
}
```

## 錯誤處理與重試

### Timeout 設定

```typescript
// 每個 LLM 呼叫設定 15 秒 timeout
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 15_000);

try {
  // ... API 呼叫 ...
} finally {
  clearTimeout(timeoutId);
}
```

### Fallback Chain

```typescript
async recognizeWithFallback(
  imageBuffer: Buffer,
  mimeType: string,
): Promise<LlmRecognitionResult> {
  const providers = ['gemini', 'openai', 'anthropic', 'huggingface'];

  for (const providerName of providers) {
    try {
      const provider = this.llmFactory.getProvider(providerName);
      return await provider.recognize(imageBuffer, mimeType);
    } catch (error) {
      this.logger.warn(`${providerName} 辨識失敗: ${error.message}`);
      continue;
    }
  }

  throw new Error('所有 LLM Provider 皆辨識失敗');
}
```

### 常見錯誤

| 錯誤 | Provider | 處理方式 |
|------|----------|---------|
| 429 Too Many Requests | 全部 | 指數退避重試（最多 2 次） |
| 400 Invalid Image | 全部 | 檢查圖片格式與大小，回傳錯誤訊息 |
| Safety Block | Gemini | 圖片被安全過濾，回傳提示使用者重拍 |
| 500 Server Error | 全部 | 切換至下一個 provider |
| JSON Parse Error | Claude | 清除 markdown code block 後重新解析 |
| Zod Validation Error | 全部 | log 原始回應，嘗試部分解析或重新呼叫 |

## 成本估算

以每次辨識一張 1024px JPEG 食物照片為基準：

| Provider | 模型 | 每次成本估算 | 100 次/天 月費 | 1000 次/天 月費 |
|----------|------|-------------|--------------|----------------|
| Google | Gemini 2.5 Flash | ~$0.001-0.003 | ~$3-9 | ~$30-90 |
| OpenAI | GPT-4o-mini | ~$0.001-0.003 | ~$3-9 | ~$30-90 |
| OpenAI | GPT-4o | ~$0.01-0.02 | ~$30-60 | ~$300-600 |
| Anthropic | Claude Haiku 4.5 | ~$0.003-0.008 | ~$9-24 | ~$90-240 |
| Anthropic | Claude Sonnet 4.6 | ~$0.01-0.03 | ~$30-90 | ~$300-900 |
| HF Inference API | Qwen2.5-VL-7B | 依用量計費 | 依用量 | 依用量 |
| 自架 GPU | Qwen2.5-VL-7B | GPU 固定成本 | ~$50-150（含 GPU 租用） | ~$50-150（含 GPU 租用） |

> 建議 MVP 階段使用 Gemini Flash 或 GPT-4o-mini，在準確度可接受的前提下成本最低。自架開源模型適合日請求量 > 1000 次的場景，長期成本優勢明顯。

## 圖片預處理建議

Client 端上傳前應壓縮圖片（依 ADR-003）：

| 參數 | 建議值 | 說明 |
|------|--------|------|
| 最大邊長 | 1024px | 平衡辨識品質與 token 成本 |
| 格式 | JPEG | 比 PNG 小很多 |
| 品質 | 80 | JPEG quality |
| 目標大小 | 200-400KB | 兼顧上傳速度與辨識準確度 |

Server 端收到圖片後，可額外檢查：

```typescript
function validateImage(buffer: Buffer, mimeType: string): void {
  const maxSize = 5 * 1024 * 1024; // 5MB
  if (buffer.length > maxSize) {
    throw new BadRequestException('圖片大小超過 5MB 限制');
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
  if (!allowedTypes.includes(mimeType)) {
    throw new BadRequestException('不支援的圖片格式');
  }
}
```

## 參考資源

### 商業 Provider 官方文件

- Google Gemini API：https://ai.google.dev/gemini-api/docs
- OpenAI Vision：https://developers.openai.com/api/docs/guides/images-vision
- Anthropic Claude Vision：https://docs.anthropic.com/en/docs/build-with-claude/vision

### Hugging Face 開源模型

- [Qwen2.5-VL-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct) — 推薦的開源 VLM，支援結構化輸出
- [Qwen2.5-VL-72B-Instruct](https://huggingface.co/Qwen/Qwen2.5-VL-72B-Instruct) — 最高精度版本
- [Kaludi/food-category-classification-v2.0](https://huggingface.co/Kaludi/food-category-classification-v2.0) — 食物分類模型
- [BinhQuocNguyen/food-recognition-vit](https://huggingface.co/BinhQuocNguyen/food-recognition-vit) — ViT 食物辨識
- [Shresthadev403/food-image-classification](https://huggingface.co/Shresthadev403/food-image-classification) — Food-101 分類

### 資料集

- [Codatta/MM-Food-100K](https://huggingface.co/datasets/Codatta/MM-Food-100K) — 10 萬張食物圖片資料集
- [Hugging Face Image Classification Models](https://huggingface.co/models?pipeline_tag=image-classification) — 所有圖片分類模型索引
