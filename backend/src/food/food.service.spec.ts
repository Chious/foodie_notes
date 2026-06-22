import { Test } from '@nestjs/testing';
import { FoodService } from './food.service.js';
import { TfdaService } from '../tfda/tfda.service.js';
import { OpenFoodFactsService } from '../open-food-facts/open-food-facts.service.js';
import { FatSecretService } from '../fat-secret/fat-secret.service.js';

const mockTfda = { search: vi.fn() };
const mockOff = { search: vi.fn(), findByBarcode: vi.fn() };
const mockFs = { search: vi.fn(), findByBarcode: vi.fn() };

const tfdaItem = {
  id: 'tfda-A001',
  name: '雞胸肉',
  calories: 117,
  protein: 24,
  carbs: 0,
  fat: 1.9,
  unit: '100g',
  weightG: 100,
  source: 'tfda',
};

const offItem = {
  id: 'off-123',
  name: 'Chocolate',
  calories: 500,
  protein: 5,
  carbs: 60,
  fat: 30,
  unit: '100g',
  weightG: 100,
  source: 'off',
};

const fsItem = { ...offItem, id: 'fs-456', source: 'fatsecret' };

describe('FoodService', () => {
  let service: FoodService;

  beforeEach(async () => {
    vi.clearAllMocks();
    const module = await Test.createTestingModule({
      providers: [
        FoodService,
        { provide: TfdaService, useValue: mockTfda },
        { provide: OpenFoodFactsService, useValue: mockOff },
        { provide: FatSecretService, useValue: mockFs },
      ],
    }).compile();
    service = module.get(FoodService);
  });

  describe('search()', () => {
    it('中文查詢只回傳 TFDA 結果，不查詢 OFF', async () => {
      mockTfda.search.mockReturnValue({ items: [tfdaItem], total: 1 });

      const result = await service.search('雞胸肉');
      expect(result.items).toHaveLength(1);
      expect(result.items[0].source).toBe('tfda');
      expect(mockOff.search).not.toHaveBeenCalled();
    });

    it('英文查詢 TFDA 無結果時用 OFF 補充', async () => {
      mockTfda.search.mockReturnValue({ items: [], total: 0 });
      mockOff.search.mockResolvedValue([offItem]);

      const result = await service.search('chocolate');
      expect(result.items).toHaveLength(1);
      expect(result.items[0].source).toBe('off');
    });

    it('OFF 補充失敗時仍回傳 TFDA 結果', async () => {
      mockTfda.search.mockReturnValue({ items: [], total: 0 });
      mockOff.search.mockRejectedValue(new Error('Network error'));

      const result = await service.search('chocolate');
      expect(result.items).toHaveLength(0);
    });

    it('正確傳遞 query 參數給 TFDA', async () => {
      mockTfda.search.mockReturnValue({ items: [], total: 0 });
      mockOff.search.mockResolvedValue([]);

      await service.search('test');
      expect(mockTfda.search).toHaveBeenCalledWith('test');
    });
  });

  describe('findByBarcode()', () => {
    it('OFF 找到時直接回傳，source 為 "off"', async () => {
      mockOff.findByBarcode.mockResolvedValue(offItem);

      const result = await service.findByBarcode('123');
      expect(result.found).toBe(true);
      expect(result.source).toBe('off');
      expect(mockFs.findByBarcode).not.toHaveBeenCalled();
    });

    it('OFF 沒找到時查詢 FatSecret', async () => {
      mockOff.findByBarcode.mockResolvedValue(null);
      mockFs.findByBarcode.mockResolvedValue(fsItem);

      const result = await service.findByBarcode('123');
      expect(result.found).toBe(true);
      expect(result.source).toBe('fatsecret');
    });

    it('FatSecret 找到時回傳，source 為 "fatsecret"', async () => {
      mockOff.findByBarcode.mockResolvedValue(null);
      mockFs.findByBarcode.mockResolvedValue(fsItem);

      const result = await service.findByBarcode('123');
      expect(result.item?.id).toBe('fs-456');
    });

    it('兩者皆未找到時回傳 found: false', async () => {
      mockOff.findByBarcode.mockResolvedValue(null);
      mockFs.findByBarcode.mockResolvedValue(null);

      const result = await service.findByBarcode('123');
      expect(result).toEqual({ found: false, item: null, source: null });
    });
  });
});
