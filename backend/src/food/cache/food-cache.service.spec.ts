import { Test } from '@nestjs/testing';
import { FoodCacheService } from './food-cache.service.js';
import { PrismaService } from '../../prisma/prisma.service.js';

const mockPrisma = {
  client: {
    foodCache: {
      findUnique: vi.fn(),
      upsert: vi.fn(),
      deleteMany: vi.fn(),
    },
  },
};

describe('FoodCacheService', () => {
  let service: FoodCacheService;

  beforeEach(async () => {
    vi.clearAllMocks();
    const module = await Test.createTestingModule({
      providers: [
        FoodCacheService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get(FoodCacheService);
  });

  const validItem = {
    id: 'off-123',
    name: 'Test',
    calories: 100,
    protein: 10,
    carbs: 20,
    fat: 5,
    unit: '100g',
    weightG: 100,
    source: 'off',
  };

  describe('get()', () => {
    it('快取不存在時回傳 null', async () => {
      mockPrisma.client.foodCache.findUnique.mockResolvedValue(null);
      expect(await service.get('missing')).toBeNull();
    });

    it('快取已過期時回傳 null', async () => {
      mockPrisma.client.foodCache.findUnique.mockResolvedValue({
        cacheKey: 'key',
        data: validItem,
        expiresAt: new Date(Date.now() - 1000),
      });
      expect(await service.get('key')).toBeNull();
    });

    it('快取有效時回傳解析後的資料', async () => {
      mockPrisma.client.foodCache.findUnique.mockResolvedValue({
        cacheKey: 'key',
        data: validItem,
        expiresAt: new Date(Date.now() + 86400000),
      });
      const result = await service.get('key');
      expect(result).toEqual(validItem);
    });

    it('快取資料格式不符 Zod 驗證時回傳 null 並記錄警告', async () => {
      mockPrisma.client.foodCache.findUnique.mockResolvedValue({
        cacheKey: 'key',
        data: { invalid: true },
        expiresAt: new Date(Date.now() + 86400000),
      });
      expect(await service.get('key')).toBeNull();
    });
  });

  describe('set()', () => {
    it('資料通過 Zod 驗證時執行 upsert', async () => {
      await service.set('key', 'off', validItem);
      expect(mockPrisma.client.foodCache.upsert).toHaveBeenCalledOnce();
    });

    it('資料未通過 Zod 驗證時拒絕寫入', async () => {
      await service.set('key', 'off', { bad: 'data' });
      expect(mockPrisma.client.foodCache.upsert).not.toHaveBeenCalled();
    });

    it('正確計算 expiresAt（預設 30 天）', async () => {
      const before = Date.now();
      await service.set('key', 'off', validItem);
      const call = mockPrisma.client.foodCache.upsert.mock.calls[0][0];
      const expiresAt = call.create.expiresAt.getTime();
      const expected = before + 30 * 24 * 60 * 60 * 1000;
      expect(expiresAt).toBeGreaterThanOrEqual(expected - 1000);
      expect(expiresAt).toBeLessThanOrEqual(expected + 1000);
    });
  });

  describe('invalidateExpired()', () => {
    it('刪除過期項目並回傳數量', async () => {
      mockPrisma.client.foodCache.deleteMany.mockResolvedValue({ count: 5 });
      expect(await service.invalidateExpired()).toBe(5);
    });

    it('無過期項目時回傳 0', async () => {
      mockPrisma.client.foodCache.deleteMany.mockResolvedValue({ count: 0 });
      expect(await service.invalidateExpired()).toBe(0);
    });
  });
});
