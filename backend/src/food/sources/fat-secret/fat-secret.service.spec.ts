import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { FatSecretService } from './fat-secret.service.js';
import { FoodCacheService } from '../../cache/food-cache.service.js';

const mockCache = {
  get: vi.fn().mockResolvedValue(null),
  set: vi.fn().mockResolvedValue(undefined),
};

function createMockConfig(enabled: boolean) {
  return {
    get: vi.fn((key: string, def?: string) => {
      const map: Record<string, string> = {
        FATSECRET_CLIENT_ID: enabled ? 'test-id' : '',
        FATSECRET_CLIENT_SECRET: enabled ? 'test-secret' : '',
        FATSECRET_TOKEN_URL: 'https://mock.fs.com/token',
        FATSECRET_API_URL: 'https://mock.fs.com/api',
      };
      return map[key] ?? def;
    }),
  };
}

const tokenResponse = {
  access_token: 'mock-token',
  token_type: 'Bearer',
  expires_in: 86400,
};

const searchResponse = {
  foods: {
    food: [
      {
        food_id: '1',
        food_name: 'Chicken',
        food_description:
          'Per 100g - Calories: 165kcal | Fat: 3.6g | Carbs: 0.0g | Protein: 31.0g',
        food_type: 'Generic',
        food_url: '',
      },
    ],
  },
};

describe('FatSecretService', () => {
  let fetchSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    vi.clearAllMocks();
    fetchSpy = vi.spyOn(globalThis, 'fetch');
  });

  afterEach(() => {
    fetchSpy.mockRestore();
  });

  async function createService(enabled = true) {
    const module = await Test.createTestingModule({
      providers: [
        FatSecretService,
        { provide: ConfigService, useValue: createMockConfig(enabled) },
        { provide: FoodCacheService, useValue: mockCache },
      ],
    }).compile();
    return module.get(FatSecretService);
  }

  describe('停用模式', () => {
    it('未設定 credentials 時 search 回傳空陣列', async () => {
      const service = await createService(false);
      expect(await service.search('test')).toEqual([]);
      expect(fetchSpy).not.toHaveBeenCalled();
    });

    it('未設定 credentials 時 findByBarcode 回傳 null', async () => {
      const service = await createService(false);
      expect(await service.findByBarcode('123')).toBeNull();
      expect(fetchSpy).not.toHaveBeenCalled();
    });
  });

  describe('search()', () => {
    it('取得 OAuth token 後呼叫搜尋 API', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => searchResponse,
        } as Response);

      const result = await service.search('chicken');
      expect(result).toHaveLength(1);
      expect(result[0].name).toBe('Chicken');
      expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('單一結果透過 ensureArray 正確處理', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            foods: { food: searchResponse.foods.food[0] },
          }),
        } as Response);

      const result = await service.search('chicken');
      expect(result).toHaveLength(1);
    });

    it('非空結果寫入快取', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => searchResponse,
        } as Response);

      await service.search('chicken');
      expect(mockCache.set).toHaveBeenCalledWith(
        'search:fatsecret:chicken',
        'fatsecret',
        expect.any(Array),
      );
    });

    it('錯誤時回傳空陣列', async () => {
      const service = await createService();
      fetchSpy.mockRejectedValueOnce(new Error('fail'));

      expect(await service.search('test')).toEqual([]);
    });
  });

  describe('findByBarcode()', () => {
    it('透過條碼查詢 food_id，再取得食物詳情（兩步驟）', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ food_id: { value: '99' } }),
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            food: {
              food_id: '99',
              food_name: 'Snack',
              servings: {
                serving: {
                  serving_id: '1',
                  serving_description: '100 g',
                  metric_serving_amount: '100',
                  metric_serving_unit: 'g',
                  calories: '200',
                  protein: '5',
                  fat: '10',
                  carbohydrate: '25',
                },
              },
            },
          }),
        } as Response);

      const result = await service.findByBarcode('123');
      expect(result).not.toBeNull();
      expect(result!.name).toBe('Snack');
    });

    it('條碼查無 food_id 時回傳 null', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({}),
        } as Response);

      expect(await service.findByBarcode('123')).toBeNull();
    });

    it('食物無份量資料時回傳 null', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ food_id: { value: '99' } }),
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            food: { food_id: '99', food_name: 'Snack', servings: {} },
          }),
        } as Response);

      expect(await service.findByBarcode('123')).toBeNull();
    });
  });

  describe('OAuth token 管理', () => {
    it('在有效期內重複使用快取的 token', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ foods: {} }),
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ foods: {} }),
        } as Response);

      await service.search('a');
      await service.search('b');
      const tokenCalls = fetchSpy.mock.calls.filter((c) =>
        String(c[0]).includes('token'),
      );
      expect(tokenCalls).toHaveLength(1);
    });

    it('收到 401 時清除 token 並重試一次', async () => {
      const service = await createService();
      fetchSpy
        .mockResolvedValueOnce({
          ok: true,
          json: async () => tokenResponse,
        } as Response)
        .mockResolvedValueOnce({ ok: false, status: 401 } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ ...tokenResponse, access_token: 'new-token' }),
        } as Response)
        .mockResolvedValueOnce({
          ok: true,
          json: async () => searchResponse,
        } as Response);

      const result = await service.search('chicken');
      expect(result).toHaveLength(1);
    });
  });
});
