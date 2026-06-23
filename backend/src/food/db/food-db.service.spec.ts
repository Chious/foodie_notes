import { Test } from '@nestjs/testing';
import { FoodDbService } from './food-db.service.js';
import { TfdaService } from '../sources/tfda/tfda.service.js';

const mockTfda = { getItemCount: vi.fn().mockReturnValue(2213) };

describe('FoodDbService', () => {
  let service: FoodDbService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        FoodDbService,
        { provide: TfdaService, useValue: mockTfda },
      ],
    }).compile();
    service = module.get(FoodDbService);
  });

  describe('getVersion()', () => {
    it('回傳 TFDA 實際筆數作為 recordCount', () => {
      const result = service.getVersion();
      expect(result.recordCount).toBe(2213);
    });

    it('版本字串為 "2025-UPDATE1"', () => {
      expect(service.getVersion().version).toBe('2025-UPDATE1');
    });
  });

  describe('getDownload()', () => {
    it('回傳 stub 狀態', () => {
      const result = service.getDownload();
      expect(result.status).toBe('stub');
    });
  });
});
