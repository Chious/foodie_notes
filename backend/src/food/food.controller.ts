import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';
import { FoodService } from './food.service.js';
import { FoodSearchResponseDto } from './dto/food-search.dto.js';
import { BarcodeResponseDto } from './dto/food-barcode.dto.js';

@ApiTags('Food')
@Controller('food')
export class FoodController {
  constructor(private readonly foodService: FoodService) {}

  @Get('search')
  @ApiOperation({ summary: '食物名稱搜尋（整合 TFDA + OFF）' })
  @ApiQuery({ name: 'q', description: '搜尋關鍵字', example: '雞胸肉' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  @ApiResponse({ status: 200, type: FoodSearchResponseDto })
  search(
    @Query('q') q: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ): FoodSearchResponseDto {
    return this.foodService.search(q, page, limit);
  }

  @Get('barcode/:code')
  @ApiOperation({ summary: '條碼查詢（整合 OFF + FatSecret）' })
  @ApiResponse({ status: 200, type: BarcodeResponseDto })
  findByBarcode(@Param('code') code: string): BarcodeResponseDto {
    return this.foodService.findByBarcode(code);
  }
}
