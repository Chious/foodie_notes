import { ApiProperty } from '@nestjs/swagger';

export class RecognizedItemDto {
  @ApiProperty({ example: 'tfda-rice-001' })
  id: string;

  @ApiProperty({ example: '白飯' })
  name: string;

  @ApiProperty({ description: '熱量 (kcal)', example: 293 })
  calories: number;

  @ApiProperty({ description: '蛋白質 (g)', example: 5.0 })
  protein: number;

  @ApiProperty({ description: '碳水化合物 (g)', example: 65.0 })
  carbs: number;

  @ApiProperty({ description: '脂肪 (g)', example: 0.5 })
  fat: number;

  @ApiProperty({ description: '份量', example: 1 })
  quantity: number;

  @ApiProperty({ description: '單位', example: '碗' })
  unit: string;

  @ApiProperty({ description: '重量 (g)', example: 160 })
  weightG: number;

  @ApiProperty({
    description: '辨識信心度',
    enum: ['high', 'medium', 'low'],
    example: 'high',
  })
  confidence: string;

  @ApiProperty({ description: '是否預設選取', example: true })
  selected: boolean;

  @ApiProperty({
    description: '資料來源',
    enum: ['tfda', 'off', 'fatsecret', 'user'],
    example: 'tfda',
  })
  source: string;
}

export class RecognizeSummaryDto {
  @ApiProperty({ example: 650 })
  totalCalories: number;

  @ApiProperty({ example: 35.2 })
  totalProtein: number;

  @ApiProperty({ description: '佔每日熱量目標百分比', example: 32.5 })
  dailyCaloriesPct: number;

  @ApiProperty({ description: '佔每日蛋白質目標百分比', example: 58.7 })
  dailyProteinPct: number;
}

export class RecognizeResponseDto {
  @ApiProperty({ description: '餐點名稱', example: '雞腿便當' })
  mealName: string;

  @ApiProperty({ description: '偵測到的食物數量', example: 3 })
  detectedCount: number;

  @ApiProperty({ type: [RecognizedItemDto] })
  items: RecognizedItemDto[];

  @ApiProperty({ type: RecognizeSummaryDto })
  summary: RecognizeSummaryDto;
}
