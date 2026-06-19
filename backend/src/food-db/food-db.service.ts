import { Injectable } from '@nestjs/common';
import { FoodDbVersionDto, FoodDbDownloadDto } from './dto/food-db.dto.js';

@Injectable()
export class FoodDbService {
  getVersion(): FoodDbVersionDto {
    return {
      version: '1.0.0',
      updatedAt: '2026-06-19T00:00:00.000Z',
      sizeBytes: 2048000,
      recordCount: 1500,
    };
  }

  getDownload(): FoodDbDownloadDto {
    return {
      status: 'stub',
      message: '實際實作時將回傳 SQLite 檔案串流',
    };
  }
}
