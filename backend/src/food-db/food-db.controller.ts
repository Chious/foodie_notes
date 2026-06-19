import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { FoodDbService } from './food-db.service.js';
import { FoodDbVersionDto, FoodDbDownloadDto } from './dto/food-db.dto.js';

@ApiTags('Food DB')
@Controller('food-db')
export class FoodDbController {
  constructor(private readonly foodDbService: FoodDbService) {}

  @Get('version')
  @ApiOperation({ summary: '精簡資料庫版本檢查' })
  @ApiResponse({ status: 200, type: FoodDbVersionDto })
  getVersion(): FoodDbVersionDto {
    return this.foodDbService.getVersion();
  }

  @Get('download')
  @ApiOperation({ summary: '下載精簡資料庫' })
  @ApiResponse({ status: 200, type: FoodDbDownloadDto })
  getDownload(): FoodDbDownloadDto {
    return this.foodDbService.getDownload();
  }
}
