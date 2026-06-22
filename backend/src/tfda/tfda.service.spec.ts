import { Test } from '@nestjs/testing';
import { TfdaService } from './tfda.service.js';

const mockRows = [
  {
    sampleCode: 'A001',
    category: '肉類',
    nameZh: '雞胸肉',
    commonName: '去皮清肉,雞胸',
    description: '',
    calories: 117,
    protein: 24,
    fat: 1.9,
    carbs: 0,
    fiber: 0,
    sugar: 0,
    sodium: 50,
  },
  {
    sampleCode: 'A002',
    category: '肉類',
    nameZh: '雞腿',
    commonName: '棒棒腿',
    description: '',
    calories: 200,
    protein: 18,
    fat: 13,
    carbs: 0,
    fiber: 0,
    sugar: 0,
    sodium: 80,
  },
  {
    sampleCode: 'B001',
    category: '穀類',
    nameZh: '白飯',
    commonName: '白米飯,米飯',
    description: '',
    calories: 183,
    protein: 3.1,
    fat: 0.3,
    carbs: 40.6,
    fiber: 0.4,
    sugar: 0,
    sodium: 2,
  },
  {
    sampleCode: 'C001',
    category: '蔬菜類',
    nameZh: '花椰菜',
    commonName: '',
    description: '',
    calories: 23,
    protein: 2.5,
    fat: 0.2,
    carbs: 3.8,
    fiber: 2,
    sugar: 1.5,
    sodium: 15,
  },
];

const headerNames = [
  '整合編號',
  '食品分類',
  '樣品名稱',
  '內容物描述',
  '俗名',
  '',
  '熱量(kcal)',
  '', '',
  '粗蛋白(g)',
  '粗脂肪(g)',
  '', '',
  '總碳水化合物(g)',
  '膳食纖維(g)',
  '糖質總量(g)',
  '', '', '', '', '', '',
  '鈉(mg)',
];

function buildMockWorksheet() {
  const colIndexByHeader = new Map<string, number>();
  headerNames.forEach((h, i) => {
    if (h) colIndexByHeader.set(h, i + 1);
  });

  const fieldToHeader: Record<string, string> = {
    sampleCode: '整合編號',
    category: '食品分類',
    nameZh: '樣品名稱',
    description: '內容物描述',
    commonName: '俗名',
    calories: '熱量(kcal)',
    protein: '粗蛋白(g)',
    fat: '粗脂肪(g)',
    carbs: '總碳水化合物(g)',
    fiber: '膳食纖維(g)',
    sugar: '糖質總量(g)',
    sodium: '鈉(mg)',
  };

  return {
    getRow: (rowNum: number) => {
      if (rowNum === 2) {
        return {
          eachCell: (cb: (cell: { value: string }, col: number) => void) => {
            headerNames.forEach((h, i) => {
              if (h) cb({ value: h }, i + 1);
            });
          },
        };
      }
      return { getCell: () => ({ value: null }) };
    },
    eachRow: (cb: (row: any, rowNum: number) => void) => {
      cb({ getCell: () => ({ value: null }) }, 1);
      cb({ eachCell: () => {}, getCell: () => ({ value: null }) }, 2);
      mockRows.forEach((data, i) => {
        const cells = new Map<number, unknown>();
        for (const [field, header] of Object.entries(fieldToHeader)) {
          const col = colIndexByHeader.get(header);
          if (col) cells.set(col, data[field as keyof typeof data]);
        }
        cb(
          { getCell: (col: number) => ({ value: cells.get(col) ?? null }) },
          i + 3,
        );
      });
    },
  };
}

vi.mock('exceljs', () => ({
  default: {
    Workbook: class MockWorkbook {
      xlsx = { readFile: vi.fn().mockResolvedValue(undefined) };
      worksheets = [buildMockWorksheet()];
    },
  },
}));

describe('TfdaService', () => {
  let service: TfdaService;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      providers: [TfdaService],
    }).compile();
    service = module.get(TfdaService);
    await service.onModuleInit();
  });

  describe('search()', () => {
    it('空白查詢回傳空結果', () => {
      expect(service.search('')).toEqual({ items: [], total: 0 });
    });

    it('精確匹配 nameZh 回傳最佳結果', () => {
      const result = service.search('白飯');
      expect(result.items).toHaveLength(1);
      expect(result.items[0].name).toBe('白飯');
    });

    it('透過同義詞展開匹配（去皮清肉 → 雞胸肉）', () => {
      const result = service.search('去皮清肉');
      expect(result.items[0].name).toBe('雞胸肉');
    });

    it('子字串匹配回傳最相關的結果', () => {
      const result = service.search('雞');
      expect(result.items).toHaveLength(1);
      expect(['雞胸肉', '雞腿']).toContain(result.items[0].name);
    });

    it('查無結果回傳空陣列', () => {
      const result = service.search('不存在的食物');
      expect(result.items).toEqual([]);
      expect(result.total).toBe(0);
    });

    it('逗號分隔支援多食材查詢', () => {
      const result = service.search('白飯,花椰菜');
      expect(result.items).toHaveLength(2);
      expect(result.items[0].name).toBe('白飯');
      expect(result.items[1].name).toBe('花椰菜');
    });

    it('多食材查詢中無匹配的項目被過濾', () => {
      const result = service.search('白飯,不存在的食物,花椰菜');
      expect(result.items).toHaveLength(2);
      expect(result.total).toBe(2);
    });

    it('逗號分隔的 commonName 各別匹配', () => {
      const result = service.search('白米飯');
      expect(result.items[0].name).toBe('白飯');
    });
  });

  describe('findBestMatch()', () => {
    it('精確匹配 nameZh 優先', () => {
      const result = service.findBestMatch('雞胸肉');
      expect(result).not.toBeNull();
      expect(result!.name).toBe('雞胸肉');
    });

    it('不存在的食物回傳 null', () => {
      expect(service.findBestMatch('不存在')).toBeNull();
    });
  });

  describe('findByCode()', () => {
    it('存在的編號回傳 FoodItemDto', () => {
      const result = service.findByCode('A001');
      expect(result).not.toBeNull();
      expect(result!.name).toBe('雞胸肉');
    });

    it('不存在的編號回傳 null', () => {
      expect(service.findByCode('Z999')).toBeNull();
    });
  });

  describe('getCategories()', () => {
    it('回傳不重複的分類清單', () => {
      const cats = service.getCategories();
      expect(cats).toContain('肉類');
      expect(cats).toContain('穀類');
      expect(cats).toContain('蔬菜類');
      expect(new Set(cats).size).toBe(cats.length);
    });
  });

  describe('getItemCount()', () => {
    it('回傳載入的食物總數', () => {
      expect(service.getItemCount()).toBe(4);
    });
  });
});
