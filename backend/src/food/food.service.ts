import { Injectable, Logger } from '@nestjs/common';
import { TfdaService } from '../tfda/tfda.service.js';
import { OpenFoodFactsService } from '../open-food-facts/open-food-facts.service.js';
import { FatSecretService } from '../fat-secret/fat-secret.service.js';
import type { FoodSearchResponseDto } from './dto/food-search.dto.js';
import type { BarcodeResponseDto } from './dto/food-barcode.dto.js';

const CJK_REGEX = /[一-鿿]/;

@Injectable()
export class FoodService {
  private readonly logger = new Logger(FoodService.name);

  constructor(
    private readonly tfda: TfdaService,
    private readonly off: OpenFoodFactsService,
    private readonly fatSecret: FatSecretService,
  ) {}

  async search(
    q: string,
    page = 1,
    limit = 20,
  ): Promise<FoodSearchResponseDto> {
    const tfdaResult = this.tfda.search(q);
    const items = [...tfdaResult.items];

    const isChinese = CJK_REGEX.test(q);
    if (!isChinese && items.length < limit) {
      try {
        const offItems = await this.off.search(q, 1, limit - items.length);
        items.push(...offItems);
      } catch (err) {
        this.logger.warn(`OFF search supplement failed: ${err}`);
      }
    }

    return {
      items,
      total: items.length,
      page,
      limit,
    };
  }

  async findByBarcode(code: string): Promise<BarcodeResponseDto> {
    const offItem = await this.off.findByBarcode(code);
    if (offItem) {
      return { found: true, item: offItem, source: 'off' };
    }

    const fsItem = await this.fatSecret.findByBarcode(code);
    if (fsItem) {
      return { found: true, item: fsItem, source: 'fatsecret' };
    }

    return { found: false, item: null, source: null };
  }
}
