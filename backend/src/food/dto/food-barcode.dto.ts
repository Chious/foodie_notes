import { ApiProperty } from '@nestjs/swagger';
import { FoodItemDto } from './food-search.dto.js';

export class BarcodeResponseDto {
  @ApiProperty({ example: true })
  found: boolean;

  @ApiProperty({ type: FoodItemDto, nullable: true })
  item: FoodItemDto | null;

  @ApiProperty({
    description: '資料來源',
    enum: ['off', 'fatsecret'],
    example: 'off',
    nullable: true,
  })
  source: string | null;
}
