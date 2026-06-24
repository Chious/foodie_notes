# Implementation Plan: TFDA + Open Food Facts + FatSecret Services

## Context

The backend currently has stub/mock implementations for all food-related endpoints (`/api/food/search`, `/api/food/barcode/:code`, `/api/food-db/version`). The actual data sources — TFDA Excel database, Open Food Facts API, and FatSecret API — need real implementations so the app can serve nutrition data to the Flutter client and integrate with LLM food recognition in the future.

The TFDA Excel file already exists at `backend/assets/食品營養成分資料庫2025版UPDATE1.xlsx`. All DTOs (`FoodItemDto`, `BarcodeResponseDto`, `FoodDbVersionDto`) are already defined with Swagger decorators.

## Approach

Create three new NestJS service modules, then rewire the existing `FoodService` and `FoodDbService` to orchestrate them. Add a `FoodCache` table in PostgreSQL via Prisma to cache third-party API results.

---

## Phase 0: Dependencies & Config

1. **Install packages**: `npm install @nestjs/config exceljs`
2. **Add `ConfigModule.forRoot({ isGlobal: true })` to `src/app.module.ts`** — centralizes env var access for OFF and FatSecret services
3. **Update `.env`** with new variables:
   ```
   OFF_BASE_URL=https://world.openfoodfacts.org
   OFF_USER_AGENT=FoodieNotes/1.0
   FATSECRET_CLIENT_ID=
   FATSECRET_CLIENT_SECRET=
   ```

## Phase 1: TfdaModule (local Excel data source)

New files under `src/tfda/`:

| File | Purpose |
|------|---------|
| `tfda.module.ts` | Module that exports `TfdaService` |
| `tfda.service.ts` | `OnModuleInit` — parses Excel into memory, exposes `search()`, `findByCode()`, `getCategories()`, `getItemCount()` |
| `tfda.utils.ts` | `tfdaToFoodItem()` conversion to `FoodItemDto` |
| `interfaces/tfda-food-item.interface.ts` | `TfdaFoodItem` interface |
| `data/synonyms.ts` | `FOOD_SYNONYMS` map for fuzzy matching |

### Key decisions

- Use `process.cwd()` + `'assets/...'` for Excel path (works in both dev & production)
- Parse by **header name** (not column index) for resilience — verified actual columns:
  - Col 1: `整合編號`, Col 2: `食品分類`, Col 3: `樣品名稱`, Col 4: `內容物描述`, Col 5: `俗名`
  - Col 7: `熱量(kcal)`, Col 10: `粗蛋白(g)`, Col 11: `粗脂肪(g)`, Col 14: `總碳水化合物(g)`
  - Col 15: `膳食纖維(g)`, Col 16: `糖質總量(g)`, Col 23: `鈉(mg)` (**doc said col 18, actually 23**)
- 2503 data rows, all in Traditional Chinese — Chinese queries match directly via substring on `樣品名稱` and `俗名`
- Example: "雞胸肉" matches `去皮清肉(土雞)` via alias `去皮雞胸肉`, `去皮清肉(肉雞)` via alias `去皮雞胸肉`
- Search: exact match → synonym expansion → substring match
- ~2500 items in memory (~2-5 MB), negligible
- OFF/FatSecret are English-primary — they supplement for packaged foods, not generic Chinese food names

### Search strategy by query language

| Query type | Primary source | Supplementary |
|------------|---------------|---------------|
| Chinese food name (雞胸肉, 白飯) | **TFDA** — direct substring match | OFF/FatSecret mostly irrelevant |
| Packaged brand (義美小泡芙) | TFDA (if exists) | **OFF** (if has Chinese label) |
| Barcode (4710088411150) | N/A | **OFF first** → FatSecret fallback |
| English food name (chicken) | TFDA (no match) | OFF/FatSecret may return results |

## Phase 2: OpenFoodFactsModule (REST API)

New files under `src/open-food-facts/`:

| File | Purpose |
|------|---------|
| `open-food-facts.module.ts` | Module that exports `OpenFoodFactsService` |
| `open-food-facts.service.ts` | `findByBarcode()`, `search()` using native `fetch` |
| `off.utils.ts` | `offToFoodItem()` conversion |
| `interfaces/off-product.interface.ts` | Response type interfaces |

### Key decisions

- No auth needed, just `User-Agent` header
- 10s timeout via `AbortSignal.timeout(10_000)`
- Returns `null` on failure — caller handles fallback
- Checks `FoodCacheService` before calling external API

## Phase 3: FatSecretModule (OAuth 2.0 REST API)

New files under `src/fat-secret/`:

| File | Purpose |
|------|---------|
| `fat-secret.module.ts` | Module that exports `FatSecretService` |
| `fat-secret.service.ts` | OAuth token management + `search()`, `findByBarcode()` |
| `fat-secret.utils.ts` | `parseFoodDescription()` regex, `ensureArray()` helper, `fatSecretToFoodItem()` |
| `interfaces/fat-secret.interface.ts` | API response type interfaces |

### Key decisions

- **Graceful degradation**: if `FATSECRET_CLIENT_ID`/`SECRET` are empty, service logs a warning and all methods return `null`/`[]`
- Token cached in memory, refreshed 60s before expiry
- Handle single-result-vs-array edge case with `ensureArray()`
- Checks `FoodCacheService` before calling external API

## Phase 4: Food Cache (Prisma + PostgreSQL)

Cache third-party API results so repeated queries (e.g. multiple users searching "白飯") hit the database instead of OFF/FatSecret.

### Prisma schema addition (`prisma/schema.prisma`)

```prisma
model FoodCache {
  id        String   @id @default(cuid())
  cacheKey  String   @unique    // "search:{source}:{query}" or "barcode:{source}:{code}"
  source    String              // "off" | "fatsecret"
  data      Json               // serialized FoodItemDto[] or FoodItemDto
  expiresAt DateTime           // cache TTL (30 days from creation)
  createdAt DateTime @default(now())

  @@index([cacheKey])
  @@map("food_cache")
}
```

### New files under `src/food-cache/`

| File | Purpose |
|------|---------|
| `food-cache.module.ts` | Global module exporting `FoodCacheService` |
| `food-cache.service.ts` | `get(key)`, `set(key, data, ttlDays=30)`, `invalidateExpired()` |

### Cache key design

| Operation | Cache key format | Example |
|-----------|-----------------|---------|
| OFF search | `search:off:{query}` | `search:off:chocolate` |
| OFF barcode | `barcode:off:{code}` | `barcode:off:4710088411150` |
| FatSecret search | `search:fatsecret:{query}` | `search:fatsecret:chicken` |
| FatSecret barcode | `barcode:fatsecret:{code}` | `barcode:fatsecret:4710088411150` |

- TTL: 30 days (per ADR-003)
- `get()` returns `null` if expired or missing
- `set()` upserts (create or update) the cache entry
- TFDA is not cached (already in-memory)

### Cache flow

```
User query → TFDA (in-memory, always) 
           → Check food_cache for OFF/FatSecret results
             → Cache HIT → return cached data
             → Cache MISS → call external API → store in cache → return
```

## Phase 5: Rewire FoodService (orchestration)

Modify existing files:

| File | Change |
|------|--------|
| `src/food/food.module.ts` | Add `imports: [TfdaModule, OpenFoodFactsModule, FatSecretModule, FoodCacheModule]` |
| `src/food/food.service.ts` | Replace mock with real orchestration — inject 3 services + cache |
| `src/food/food.controller.ts` | Make methods `async` |

Search orchestration: TFDA first (local, fast), then check cache for OFF results, only call OFF API on cache miss.

Barcode orchestration: check cache → OFF API → FatSecret API, cache hits on success.

## Phase 6: Rewire FoodDbService

| File | Change |
|------|--------|
| `src/food-db/food-db.module.ts` | Add `imports: [TfdaModule]` |
| `src/food-db/food-db.service.ts` | Inject `TfdaService`, return real `recordCount` and version `2025-UPDATE1` |

## File Summary

**New files (15)**: 4 per data source module + 1 synonyms data file + 2 for food-cache module

**Modified files (6)**: `app.module.ts`, `food.module.ts`, `food.service.ts`, `food.controller.ts`, `food-db/food-db.module.ts`, `food-db/food-db.service.ts`

**Schema**: `prisma/schema.prisma` — add `FoodCache` model + migration

**Config**: `.env`, `package.json`

## Verification

1. `npm run build` — must compile without errors
2. `npx prisma migrate dev` — creates `food_cache` table
3. `npm run start:dev` — server starts, logs `TFDA 資料庫載入完成：~2500 筆`
4. `GET /api/food/search?q=雞胸肉` — returns real TFDA results with `source: 'tfda'`
5. `GET /api/food/search?q=chocolate` — may include OFF results
6. Repeat step 5 — second call should hit cache (no external API call, visible in logs)
7. `GET /api/food/barcode/4710088411150` — returns OFF result (or `found: false` if not in OFF)
8. `GET /api/food-db/version` — returns `recordCount` matching actual parsed count
9. Swagger UI at `/api/docs` — all endpoints documented
