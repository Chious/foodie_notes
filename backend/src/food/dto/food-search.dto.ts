import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class FoodSearchQueryDto {
  @ApiProperty({ description: '搜尋關鍵字', example: '雞胸肉' })
  q: string;

  @ApiPropertyOptional({ description: '頁碼', example: 1, default: 1 })
  page?: number;

  @ApiPropertyOptional({ description: '每頁數量', example: 20, default: 20 })
  limit?: number;
}

export class FoodItemDto {
  @ApiProperty({ example: 'tfda-001' })
  id: string;

  @ApiProperty({ example: '雞胸肉' })
  name: string;

  @ApiProperty({ description: '每 100g 熱量 (kcal)', example: 117 })
  calories: number;

  @ApiProperty({ description: '蛋白質 (g)', example: 24.2 })
  protein: number;

  @ApiProperty({ description: '碳水化合物 (g)', example: 0 })
  carbs: number;

  @ApiProperty({ description: '脂肪 (g)', example: 1.9 })
  fat: number;

  @ApiProperty({ description: '預設份量單位', example: '100g' })
  unit: string;

  @ApiProperty({ description: '每份重量 (g)', example: 100 })
  weightG: number;

  @ApiProperty({
    description: '資料來源',
    enum: ['tfda', 'off', 'fatsecret', 'user'],
    example: 'tfda',
  })
  source: string;
}

export class FoodSearchResponseDto {
  @ApiProperty({ type: [FoodItemDto] })
  items: FoodItemDto[];

  @ApiProperty({ example: 2 })
  total: number;

  @ApiProperty({ example: 1 })
  page: number;

  @ApiProperty({ example: 20 })
  limit: number;
}
