import {
  ensureArray,
  parseFoodDescription,
  fsSearchToFoodItem,
  fsServingToFoodItem,
} from './fat-secret.utils.js';
import type { FsSearchFood, FsServing } from './interfaces/fat-secret.interface.js';

describe('ensureArray', () => {
  it('undefined 回傳空陣列', () => {
    expect(ensureArray(undefined)).toEqual([]);
  });

  it('null 回傳空陣列', () => {
    expect(ensureArray(null as unknown as undefined)).toEqual([]);
  });

  it('單一值包裝為陣列', () => {
    expect(ensureArray('item')).toEqual(['item']);
  });

  it('陣列原樣回傳', () => {
    expect(ensureArray(['a', 'b'])).toEqual(['a', 'b']);
  });
});

describe('parseFoodDescription', () => {
  it('正確解析 FatSecret 標準描述格式', () => {
    const desc =
      'Per 100g - Calories: 165kcal | Fat: 3.6g | Carbs: 0.0g | Protein: 31.0g';
    const result = parseFoodDescription(desc);
    expect(result.calories).toBe(165);
    expect(result.fat).toBe(3.6);
    expect(result.carbs).toBe(0);
    expect(result.protein).toBe(31);
  });

  it('無法解析的字串回傳全零', () => {
    const result = parseFoodDescription('No nutritional data');
    expect(result).toEqual({ calories: 0, fat: 0, carbs: 0, protein: 0 });
  });
});

describe('fsSearchToFoodItem', () => {
  const food: FsSearchFood = {
    food_id: '12345',
    food_name: 'Chicken Breast',
    food_description:
      'Per 100g - Calories: 165kcal | Fat: 3.6g | Carbs: 0.0g | Protein: 31.0g',
    brand_name: 'Generic',
    food_type: 'Generic',
    food_url: 'https://example.com',
  };

  it('有品牌名稱時正確附加', () => {
    const result = fsSearchToFoodItem(food);
    expect(result.name).toBe('Chicken Breast (Generic)');
  });

  it('無品牌名稱時不附加', () => {
    const result = fsSearchToFoodItem({ ...food, brand_name: undefined });
    expect(result.name).toBe('Chicken Breast');
  });

  it('id 加上 "fs-" 前綴', () => {
    expect(fsSearchToFoodItem(food).id).toBe('fs-12345');
  });
});

describe('fsServingToFoodItem', () => {
  const serving: FsServing = {
    serving_id: '1',
    serving_description: '100 g',
    metric_serving_amount: '100',
    metric_serving_unit: 'g',
    calories: '165',
    protein: '31.0',
    fat: '3.6',
    carbohydrate: '0.0',
  };

  it('使用 metric_serving_amount 作為 weightG', () => {
    const result = fsServingToFoodItem('Chicken', '123', serving);
    expect(result.weightG).toBe(100);
  });

  it('缺少 metric_serving_amount 時預設 100', () => {
    const s = { ...serving, metric_serving_amount: undefined };
    const result = fsServingToFoodItem('Chicken', '123', s);
    expect(result.weightG).toBe(100);
  });

  it('字串數值正確解析', () => {
    const result = fsServingToFoodItem('Chicken', '123', serving);
    expect(result.calories).toBe(165);
    expect(result.protein).toBe(31);
    expect(result.fat).toBe(3.6);
    expect(result.carbs).toBe(0);
  });
});
