import { Injectable } from '@nestjs/common';
import { TfdaService } from '../tfda/tfda.service.js';
import { FoodDbVersionDto, FoodDbDownloadDto } from './dto/food-db.dto.js';

@Injectable()
export class FoodDbService {
  constructor(private readonly tfda: TfdaService) {}

  getVersion(): FoodDbVersionDto {
    return {
      version: '2025-UPDATE1',
      updatedAt: '2025-01-01T00:00:00.000Z',
      sizeBytes: 2037712,
      recordCount: this.tfda.getItemCount(),
    };
  }

  getDownload(): FoodDbDownloadDto {
    return {
      status: 'stub',
      message: '實際實作時將回傳 SQLite 檔案串流',
    };
  }
}
