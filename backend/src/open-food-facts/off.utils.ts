import type { OffProduct } from './interfaces/off-product.interface.js';
import type { FoodItemDto } from '../food/dto/food-search.dto.js';

export function offToFoodItem(product: OffProduct): FoodItemDto {
  const n = product.nutriments ?? {};
  const name = product.product_name_zh || product.product_name || 'Unknown';
  const brand = product.brands ? ` (${product.brands})` : '';

  return {
    id: `off-${product.code ?? 'unknown'}`,
    name: `${name}${brand}`,
    calories: round(n['energy-kcal_100g'] ?? 0),
    protein: round(n.proteins_100g ?? 0),
    carbs: round(n.carbohydrates_100g ?? 0),
    fat: round(n.fat_100g ?? 0),
    unit: product.quantity || '100g',
    weightG: 100,
    source: 'off',
  };
}

function round(value: number): number {
  return Math.round(value * 10) / 10;
}
