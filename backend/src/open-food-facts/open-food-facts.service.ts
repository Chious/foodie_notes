import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FoodCacheService } from '../food-cache/food-cache.service.js';
import type {
  OffProductResponse,
  OffSearchResponse,
} from './interfaces/off-product.interface.js';
import { offToFoodItem } from './off.utils.js';
import type { FoodItemDto } from '../food/dto/food-search.dto.js';

@Injectable()
export class OpenFoodFactsService {
  private readonly logger = new Logger(OpenFoodFactsService.name);
  private readonly baseUrl: string;
  private readonly userAgent: string;

  constructor(
    private readonly config: ConfigService,
    private readonly cache: FoodCacheService,
  ) {
    this.baseUrl = this.config.get(
      'OFF_BASE_URL',
      'https://world.openfoodfacts.org',
    );
    this.userAgent = this.config.get('OFF_USER_AGENT', 'FoodieNotes/1.0');
  }

  async findByBarcode(barcode: string): Promise<FoodItemDto | null> {
    const cacheKey = `barcode:off:${barcode}`;
    const cached = await this.cache.get<FoodItemDto>(cacheKey);
    if (cached) return cached;

    try {
      const url = `${this.baseUrl}/api/v2/product/${encodeURIComponent(barcode)}.json`;
      const res = await fetch(url, {
        headers: { 'User-Agent': this.userAgent },
        signal: AbortSignal.timeout(10_000),
      });
      if (!res.ok) return null;

      const data = (await res.json()) as OffProductResponse;
      if (data.status !== 1 || !data.product) return null;

      const item = offToFoodItem(data.product);
      await this.cache.set(cacheKey, 'off', item);
      return item;
    } catch (err) {
      this.logger.warn(`OFF barcode lookup failed for ${barcode}: ${err}`);
      return null;
    }
  }

  async search(query: string, page = 1, limit = 20): Promise<FoodItemDto[]> {
    const cacheKey = `search:off:${query}`;
    const cached = await this.cache.get<FoodItemDto[]>(cacheKey);
    if (cached) return cached;

    try {
      const params = new URLSearchParams({
        search_terms: query,
        page: String(page),
        page_size: String(limit),
        json: '1',
        fields: 'code,product_name,product_name_zh,brands,quantity,nutriments',
      });
      const url = `${this.baseUrl}/cgi/search.pl?${params}`;
      const res = await fetch(url, {
        headers: { 'User-Agent': this.userAgent },
        signal: AbortSignal.timeout(10_000),
      });
      if (!res.ok) return [];

      const data = (await res.json()) as OffSearchResponse;
      const items = (data.products ?? [])
        .filter((p) => p.product_name || p.product_name_zh)
        .map(offToFoodItem);

      if (items.length > 0) {
        await this.cache.set(cacheKey, 'off', items);
      }
      return items;
    } catch (err) {
      this.logger.warn(`OFF search failed for "${query}": ${err}`);
      return [];
    }
  }
}
