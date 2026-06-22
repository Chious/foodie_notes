import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { OpenFoodFactsService } from './open-food-facts.service.js';
import { FoodCacheService } from '../food-cache/food-cache.service.js';

const mockCache = {
  get: vi.fn().mockResolvedValue(null),
  set: vi.fn().mockResolvedValue(undefined),
};

const mockConfig = {
  get: vi.fn((key: string, def?: string) => {
    const map: Record<string, string> = {
      OFF_BASE_URL: 'https://mock.off.org',
      OFF_USER_AGENT: 'Test/1.0',
    };
    return map[key] ?? def;
  }),
};

const validProduct = {
  code: '123',
  product_name: 'Chocolate',
  nutriments: {
    'energy-kcal_100g': 500,
    proteins_100g: 5,
    fat_100g: 30,
    carbohydrates_100g: 60,
  },
};

describe('OpenFoodFactsService', () => {
  let service: OpenFoodFactsService;
  let fetchSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(async () => {
    vi.clearAllMocks();
    fetchSpy = vi.spyOn(globalThis, 'fetch');
    const module = await Test.createTestingModule({
      providers: [
        OpenFoodFactsService,
        { provide: ConfigService, useValue: mockConfig },
        { provide: FoodCacheService, useValue: mockCache },
      ],
    }).compile();
    service = module.get(OpenFoodFactsService);
  });

  afterEach(() => {
    fetchSpy.mockRestore();
  });

  describe('findByBarcode()', () => {
    it('快取命中時直接回傳，不呼叫 API', async () => {
      const cached = { id: 'off-123', name: 'Cached' };
      mockCache.get.mockResolvedValueOnce(cached);

      const result = await service.findByBarcode('123');
      expect(result).toEqual(cached);
      expect(fetchSpy).not.toHaveBeenCalled();
    });

    it('API 成功時回傳結果並寫入快取', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ status: 1, product: validProduct }),
      } as Response);

      const result = await service.findByBarcode('123');
      expect(result).not.toBeNull();
      expect(result!.id).toBe('off-123');
      expect(mockCache.set).toHaveBeenCalledWith(
        'barcode:off:123',
        'off',
        expect.objectContaining({ id: 'off-123' }),
      );
    });

    it('API 回傳非 OK 狀態時回傳 null', async () => {
      fetchSpy.mockResolvedValueOnce({ ok: false } as Response);
      expect(await service.findByBarcode('123')).toBeNull();
    });

    it('API 回傳 status≠1 時回傳 null', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ status: 0 }),
      } as Response);
      expect(await service.findByBarcode('123')).toBeNull();
    });

    it('API 回傳無 product 時回傳 null', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ status: 1 }),
      } as Response);
      expect(await service.findByBarcode('123')).toBeNull();
    });

    it('網路錯誤時回傳 null 並記錄警告', async () => {
      fetchSpy.mockRejectedValueOnce(new Error('Network error'));
      expect(await service.findByBarcode('123')).toBeNull();
    });
  });

  describe('search()', () => {
    it('快取命中時直接回傳', async () => {
      const cached = [{ id: 'off-1', name: 'Cached' }];
      mockCache.get.mockResolvedValueOnce(cached);

      const result = await service.search('chocolate');
      expect(result).toEqual(cached);
      expect(fetchSpy).not.toHaveBeenCalled();
    });

    it('API 成功時回傳結果並寫入快取', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ products: [validProduct] }),
      } as Response);

      const result = await service.search('chocolate');
      expect(result).toHaveLength(1);
      expect(mockCache.set).toHaveBeenCalled();
    });

    it('過濾無名稱的產品', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          products: [validProduct, { code: '999' }],
        }),
      } as Response);

      const result = await service.search('test');
      expect(result).toHaveLength(1);
    });

    it('空結果不寫入快取', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ products: [] }),
      } as Response);

      await service.search('nothing');
      expect(mockCache.set).not.toHaveBeenCalled();
    });

    it('API 錯誤時回傳空陣列', async () => {
      fetchSpy.mockRejectedValueOnce(new Error('timeout'));
      expect(await service.search('test')).toEqual([]);
    });
  });
});
