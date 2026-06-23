import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FoodCacheService } from '../../cache/food-cache.service.js';
import type {
  FsTokenResponse,
  FsSearchResponse,
  FsGetFoodResponse,
  FsBarcodeResponse,
} from './interfaces/fat-secret.interface.js';
import {
  ensureArray,
  fsSearchToFoodItem,
  fsServingToFoodItem,
} from './fat-secret.utils.js';
import type { FoodItemDto } from '../../dto/food-search.dto.js';

@Injectable()
export class FatSecretService {
  private readonly logger = new Logger(FatSecretService.name);
  private readonly clientId: string;
  private readonly clientSecret: string;
  private readonly tokenUrl: string;
  private readonly apiUrl: string;
  private readonly enabled: boolean;

  private accessToken: string | null = null;
  private tokenExpiresAt = 0;

  constructor(
    private readonly config: ConfigService,
    private readonly cache: FoodCacheService,
  ) {
    this.clientId = this.config.get('FATSECRET_CLIENT_ID', '');
    this.clientSecret = this.config.get('FATSECRET_CLIENT_SECRET', '');
    this.tokenUrl = this.config.get(
      'FATSECRET_TOKEN_URL',
      'https://oauth.fatsecret.com/connect/token',
    );
    this.apiUrl = this.config.get(
      'FATSECRET_API_URL',
      'https://platform.fatsecret.com/rest/server.api',
    );
    this.enabled = !!(this.clientId && this.clientSecret);
    if (!this.enabled) {
      this.logger.warn(
        'FatSecret credentials not configured — service disabled',
      );
    }
  }

  async search(query: string, page = 0, limit = 20): Promise<FoodItemDto[]> {
    if (!this.enabled) return [];

    const cacheKey = `search:fatsecret:${query}`;
    const cached = await this.cache.get<FoodItemDto[]>(cacheKey);
    if (cached) return cached;

    try {
      const params = new URLSearchParams({
        method: 'foods.search',
        search_expression: query,
        page_number: String(page),
        max_results: String(limit),
        format: 'json',
      });

      const data = await this.apiCall<FsSearchResponse>(params);
      if (!data?.foods?.food) return [];

      const foods = ensureArray(data.foods.food);
      const items = foods.map(fsSearchToFoodItem);

      if (items.length > 0) {
        await this.cache.set(cacheKey, 'fatsecret', items);
      }
      return items;
    } catch (err) {
      this.logger.warn(`FatSecret search failed for "${query}": ${err}`);
      return [];
    }
  }

  async findByBarcode(barcode: string): Promise<FoodItemDto | null> {
    if (!this.enabled) return null;

    const cacheKey = `barcode:fatsecret:${barcode}`;
    const cached = await this.cache.get<FoodItemDto>(cacheKey);
    if (cached) return cached;

    try {
      const barcodeParams = new URLSearchParams({
        method: 'food.find_id_for_barcode',
        barcode,
        format: 'json',
      });
      const barcodeData = await this.apiCall<FsBarcodeResponse>(barcodeParams);
      const foodId = barcodeData?.food_id?.value;
      if (!foodId) return null;

      const foodParams = new URLSearchParams({
        method: 'food.get.v4',
        food_id: foodId,
        format: 'json',
      });
      const foodData = await this.apiCall<FsGetFoodResponse>(foodParams);
      if (!foodData?.food) return null;

      const servings = ensureArray(foodData.food.servings?.serving);
      const per100g = servings.find(
        (s) =>
          s.metric_serving_amount === '100' && s.metric_serving_unit === 'g',
      );
      const serving = per100g ?? servings[0];
      if (!serving) return null;

      const item = fsServingToFoodItem(
        foodData.food.food_name,
        foodData.food.food_id,
        serving,
        foodData.food.brand_name,
      );

      await this.cache.set(cacheKey, 'fatsecret', item);
      return item;
    } catch (err) {
      this.logger.warn(
        `FatSecret barcode lookup failed for ${barcode}: ${err}`,
      );
      return null;
    }
  }

  private async apiCall<T>(
    params: URLSearchParams,
    retry = true,
  ): Promise<T | null> {
    const token = await this.getAccessToken();
    if (!token) return null;

    const res = await fetch(`${this.apiUrl}?${params}`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      signal: AbortSignal.timeout(10_000),
    });

    if (res.status === 401 && retry) {
      this.accessToken = null;
      this.tokenExpiresAt = 0;
      return this.apiCall<T>(params, false);
    }

    if (!res.ok) return null;
    return (await res.json()) as T;
  }

  private async getAccessToken(): Promise<string | null> {
    if (this.accessToken && Date.now() < this.tokenExpiresAt - 60_000) {
      return this.accessToken;
    }

    try {
      const res = await fetch(this.tokenUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          grant_type: 'client_credentials',
          client_id: this.clientId,
          client_secret: this.clientSecret,
          scope: 'basic',
        }),
        signal: AbortSignal.timeout(10_000),
      });

      if (!res.ok) {
        this.logger.warn(`FatSecret token request failed: ${res.status}`);
        return null;
      }

      const data = (await res.json()) as FsTokenResponse;
      this.accessToken = data.access_token;
      this.tokenExpiresAt = Date.now() + data.expires_in * 1000;
      return this.accessToken;
    } catch (err) {
      this.logger.warn(`FatSecret token request failed: ${err}`);
      return null;
    }
  }
}
