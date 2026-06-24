import { offToFoodItem } from './off.utils.js';
import type { OffProduct } from './interfaces/off-product.interface.js';

const fullProduct: OffProduct = {
  code: '4710088411150',
  product_name: 'Puff Snack',
  product_name_zh: '義美小泡芙',
  brands: '義美',
  quantity: '57g',
  nutriments: {
    'energy-kcal_100g': 533.4,
    proteins_100g: 7.2,
    fat_100g: 29.5,
    carbohydrates_100g: 60.1,
  },
};

describe('offToFoodItem', () => {
  it('完整產品資料應正確轉換', () => {
    const result = offToFoodItem(fullProduct);
    expect(result.id).toBe('off-4710088411150');
    expect(result.name).toBe('義美小泡芙 (義美)');
    expect(result.calories).toBe(533.4);
    expect(result.protein).toBe(7.2);
    expect(result.carbs).toBe(60.1);
    expect(result.fat).toBe(29.5);
    expect(result.unit).toBe('57g');
    expect(result.source).toBe('off');
  });

  it('缺少 nutriments 時數值預設為 0', () => {
    const result = offToFoodItem({ code: '123', product_name: 'Test' });
    expect(result.calories).toBe(0);
    expect(result.protein).toBe(0);
    expect(result.carbs).toBe(0);
    expect(result.fat).toBe(0);
  });

  it('優先使用中文名稱 product_name_zh', () => {
    const result = offToFoodItem(fullProduct);
    expect(result.name).toContain('義美小泡芙');
  });

  it('無中文名稱時使用 product_name', () => {
    const result = offToFoodItem({ ...fullProduct, product_name_zh: undefined });
    expect(result.name).toContain('Puff Snack');
  });

  it('兩者皆無時使用 "Unknown"', () => {
    const result = offToFoodItem({ code: '123' });
    expect(result.name).toContain('Unknown');
  });

  it('有品牌時附加括號格式', () => {
    const result = offToFoodItem(fullProduct);
    expect(result.name).toMatch(/\(義美\)$/);
  });

  it('無品牌時不附加括號', () => {
    const result = offToFoodItem({ ...fullProduct, brands: undefined });
    expect(result.name).toBe('義美小泡芙');
  });

  it('缺少 code 時 id 為 "off-unknown"', () => {
    const result = offToFoodItem({ product_name: 'Test' });
    expect(result.id).toBe('off-unknown');
  });
});
