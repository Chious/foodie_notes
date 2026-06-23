import { ApiProperty } from '@nestjs/swagger';

export class FoodDbVersionDto {
  @ApiProperty({ description: '資料庫版本', example: '1.0.0' })
  version: string;

  @ApiProperty({ description: '更新日期', example: '2026-06-19T00:00:00.000Z' })
  updatedAt: string;

  @ApiProperty({ description: '檔案大小 (bytes)', example: 2048000 })
  sizeBytes: number;

  @ApiProperty({ description: '收錄食物數量', example: 1500 })
  recordCount: number;
}

export class FoodDbDownloadDto {
  @ApiProperty({ description: '下載狀態', example: 'stub' })
  status: string;

  @ApiProperty({
    description: '說明',
    example: '實際實作時將回傳 SQLite 檔案串流',
  })
  message: string;
}
