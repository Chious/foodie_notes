import { tfdaToFoodItem, cellToString, toNumber } from './tfda.utils.js';
import type { TfdaFoodItem } from './interfaces/tfda-food-item.interface.js';

const sampleItem: TfdaFoodItem = {
  sampleCode: 'A0100101',
  category: '穀物類',
  nameZh: '大麥仁',
  description: '樣品狀態:生',
  commonName: '小薏仁,洋薏仁',
  calories: 364.6228,
  protein: 8.5578,
  fat: 1.5935,
  carbs: 77.1418,
  fiber: 8.4591,
  sugar: 0.425,
  sodium: 12.6115,
};

describe('tfdaToFoodItem', () => {
  it('應正確轉換 TfdaFoodItem 為 FoodItemDto', () => {
    const result = tfdaToFoodItem(sampleItem);
    expect(result.name).toBe('大麥仁');
    expect(result.calories).toBe(364.6);
    expect(result.protein).toBe(8.6);
    expect(result.fat).toBe(1.6);
    expect(result.carbs).toBe(77.1);
  });

  it('應將數值四捨五入至小數點第一位', () => {
    const item = { ...sampleItem, calories: 117.456 };
    expect(tfdaToFoodItem(item).calories).toBe(117.5);
  });

  it('id 應加上 "tfda-" 前綴', () => {
    expect(tfdaToFoodItem(sampleItem).id).toBe('tfda-A0100101');
  });

  it('unit 固定為 "100g"，weightG 固定為 100', () => {
    const result = tfdaToFoodItem(sampleItem);
    expect(result.unit).toBe('100g');
    expect(result.weightG).toBe(100);
  });

  it('source 固定為 "tfda"', () => {
    expect(tfdaToFoodItem(sampleItem).source).toBe('tfda');
  });
});

describe('cellToString', () => {
  it('null 或 undefined 回傳空字串', () => {
    expect(cellToString(null)).toBe('');
    expect(cellToString(undefined)).toBe('');
  });

  it('字串值直接回傳', () => {
    expect(cellToString('hello')).toBe('hello');
  });

  it('數值轉為字串', () => {
    expect(cellToString(42)).toBe('42');
  });

  it('布林值轉為字串', () => {
    expect(cellToString(true)).toBe('true');
  });

  it('RichText 物件取 text 屬性', () => {
    expect(cellToString({ text: 'rich' })).toBe('rich');
    expect(cellToString({ text: 123 })).toBe('123');
  });

  it('無法識別的物件回傳空字串', () => {
    expect(cellToString({ foo: 'bar' })).toBe('');
    expect(cellToString([])).toBe('');
  });
});

describe('toNumber', () => {
  it('數值直接回傳', () => {
    expect(toNumber(42.5)).toBe(42.5);
  });

  it('字串數值正確解析', () => {
    expect(toNumber('3.14')).toBe(3.14);
  });

  it('無法解析的值回傳 0', () => {
    expect(toNumber('')).toBe(0);
    expect(toNumber('abc')).toBe(0);
    expect(toNumber(null)).toBe(0);
    expect(toNumber(undefined)).toBe(0);
  });
});
