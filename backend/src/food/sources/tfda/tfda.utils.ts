import type { TfdaFoodItem } from './interfaces/tfda-food-item.interface.js';
import type { FoodItemDto } from '../../dto/food-search.dto.js';

export function tfdaToFoodItem(item: TfdaFoodItem): FoodItemDto {
  return {
    id: `tfda-${item.sampleCode}`,
    name: item.nameZh,
    calories: round(item.calories),
    protein: round(item.protein),
    carbs: round(item.carbs),
    fat: round(item.fat),
    unit: '100g',
    weightG: 100,
    source: 'tfda',
  };
}

function round(value: number): number {
  return Math.round(value * 10) / 10;
}

export function cellToString(value: unknown): string {
  if (value == null) return '';
  if (typeof value === 'string') return value;
  if (typeof value === 'number') return String(value);
  if (typeof value === 'boolean') return String(value);
  if (typeof value === 'object' && 'text' in value) {
    const text = (value as Record<string, unknown>).text;
    if (typeof text === 'string') return text;
    if (typeof text === 'number') return String(text);
    return '';
  }
  return '';
}

export function toNumber(value: unknown): number {
  if (typeof value === 'number') return value;
  const s = cellToString(value);
  const parsed = parseFloat(s);
  return isNaN(parsed) ? 0 : parsed;
}
