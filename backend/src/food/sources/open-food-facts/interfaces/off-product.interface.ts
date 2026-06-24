export interface OffNutriments {
  'energy-kcal_100g'?: number;
  proteins_100g?: number;
  fat_100g?: number;
  carbohydrates_100g?: number;
  fiber_100g?: number;
  sugars_100g?: number;
  sodium_100g?: number;
}

export interface OffProduct {
  code?: string;
  product_name?: string;
  product_name_zh?: string;
  brands?: string;
  quantity?: string;
  nutriments?: OffNutriments;
}

export interface OffProductResponse {
  status: number;
  product?: OffProduct;
}

export interface OffSearchResponse {
  count: number;
  page: number;
  page_size: number;
  products: OffProduct[];
}
