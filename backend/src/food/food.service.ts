import { Injectable } from '@nestjs/common';
import { FoodSearchResponseDto } from './dto/food-search.dto.js';
import { BarcodeResponseDto } from './dto/food-barcode.dto.js';

@Injectable()
export class FoodService {
  search(q: string, page = 1, limit = 20): FoodSearchResponseDto {
    return {
      items: [
        {
          id: 'tfda-001',
          name: '雞胸肉',
          calories: 117,
          protein: 24.2,
          carbs: 0,
          fat: 1.9,
          unit: '100g',
          weightG: 100,
          source: 'tfda',
        },
        {
          id: 'tfda-002',
          name: '白飯',
          calories: 183,
          protein: 3.1,
          carbs: 40.6,
          fat: 0.3,
          unit: '一碗 (160g)',
          weightG: 160,
          source: 'tfda',
        },
      ].filter((item) => item.name.includes(q) || !q),
      total: 2,
      page,
      limit,
    };
  }

  findByBarcode(code: string): BarcodeResponseDto {
    return {
      found: true,
      item: {
        id: `off-${code}`,
        name: '義美小泡芙 (巧克力)',
        calories: 533,
        protein: 7.2,
        carbs: 60.1,
        fat: 29.5,
        unit: '一包 (57g)',
        weightG: 57,
        source: 'off',
      },
      source: 'off',
    };
  }
}
