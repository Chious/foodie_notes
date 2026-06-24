import type {
  FsSearchFood,
  FsServing,
} from './interfaces/fat-secret.interface.js';
import type { FoodItemDto } from '../../dto/food-search.dto.js';

export function ensureArray<T>(value: T | T[] | undefined): T[] {
  if (value === undefined || value === null) return [];
  return Array.isArray(value) ? value : [value];
}

export function parseFoodDescription(desc: string): {
  calories: number;
  fat: number;
  carbs: number;
  protein: number;
} {
  const cal = desc.match(/Calories:\s*([\d.]+)/i);
  const fat = desc.match(/Fat:\s*([\d.]+)g/i);
  const carbs = desc.match(/Carbs:\s*([\d.]+)g/i);
  const protein = desc.match(/Protein:\s*([\d.]+)g/i);

  return {
    calories: cal ? parseFloat(cal[1]) : 0,
    fat: fat ? parseFloat(fat[1]) : 0,
    carbs: carbs ? parseFloat(carbs[1]) : 0,
    protein: protein ? parseFloat(protein[1]) : 0,
  };
}

export function fsSearchToFoodItem(food: FsSearchFood): FoodItemDto {
  const parsed = parseFoodDescription(food.food_description);
  const brand = food.brand_name ? ` (${food.brand_name})` : '';

  return {
    id: `fs-${food.food_id}`,
    name: `${food.food_name}${brand}`,
    calories: parsed.calories,
    protein: parsed.protein,
    carbs: parsed.carbs,
    fat: parsed.fat,
    unit: '100g',
    weightG: 100,
    source: 'fatsecret',
  };
}

export function fsServingToFoodItem(
  foodName: string,
  foodId: string,
  serving: FsServing,
  brandName?: string,
): FoodItemDto {
  const brand = brandName ? ` (${brandName})` : '';
  const weight = serving.metric_serving_amount
    ? parseFloat(serving.metric_serving_amount)
    : 100;

  return {
    id: `fs-${foodId}`,
    name: `${foodName}${brand}`,
    calories: parseFloat(serving.calories ?? '0'),
    protein: parseFloat(serving.protein ?? '0'),
    carbs: parseFloat(serving.carbohydrate ?? '0'),
    fat: parseFloat(serving.fat ?? '0'),
    unit: serving.serving_description || '100g',
    weightG: weight,
    source: 'fatsecret',
  };
}
