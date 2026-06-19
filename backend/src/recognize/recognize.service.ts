import { Injectable } from '@nestjs/common';
import { RecognizeResponseDto } from './dto/recognize.dto.js';

@Injectable()
export class RecognizeService {
  recognize(): RecognizeResponseDto {
    return {
      mealName: '雞腿便當',
      detectedCount: 3,
      items: [
        {
          id: 'tfda-rice-001',
          name: '白飯',
          calories: 293,
          protein: 5.0,
          carbs: 65.0,
          fat: 0.5,
          quantity: 1,
          unit: '碗',
          weightG: 160,
          confidence: 'high',
          selected: true,
          source: 'tfda',
        },
        {
          id: 'tfda-chicken-001',
          name: '烤雞腿',
          calories: 280,
          protein: 25.3,
          carbs: 2.0,
          fat: 18.5,
          quantity: 1,
          unit: '隻',
          weightG: 150,
          confidence: 'high',
          selected: true,
          source: 'tfda',
        },
        {
          id: 'tfda-veg-001',
          name: '炒青菜',
          calories: 77,
          protein: 2.5,
          carbs: 4.0,
          fat: 5.5,
          quantity: 1,
          unit: '份',
          weightG: 100,
          confidence: 'medium',
          selected: true,
          source: 'tfda',
        },
      ],
      summary: {
        totalCalories: 650,
        totalProtein: 32.8,
        dailyCaloriesPct: 32.5,
        dailyProteinPct: 54.7,
      },
    };
  }
}
