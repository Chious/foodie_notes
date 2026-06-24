import { Injectable, Logger } from '@nestjs/common';
import { z } from 'zod';
import type { Prisma } from '../../generated/prisma/client.js';
import { PrismaService } from '../../prisma/prisma.service.js';

const FoodItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  calories: z.number(),
  protein: z.number(),
  carbs: z.number(),
  fat: z.number(),
  unit: z.string(),
  weightG: z.number(),
  source: z.string(),
});

const CacheDataSchema = z.union([FoodItemSchema, z.array(FoodItemSchema)]);

@Injectable()
export class FoodCacheService {
  private readonly logger = new Logger(FoodCacheService.name);

  constructor(private readonly prisma: PrismaService) {}

  async get<T>(key: string): Promise<T | null> {
    const entry = await this.prisma.client.foodCache.findUnique({
      where: { cacheKey: key },
    });
    if (!entry || entry.expiresAt < new Date()) {
      return null;
    }
    const parsed = CacheDataSchema.safeParse(entry.data);
    if (!parsed.success) {
      this.logger.warn(
        `Invalid cache data for key "${key}": ${parsed.error.message}`,
      );
      return null;
    }
    return parsed.data as T;
  }

  async set(
    key: string,
    source: string,
    data: unknown,
    ttlDays = 30,
  ): Promise<void> {
    const parsed = CacheDataSchema.safeParse(data);
    if (!parsed.success) {
      this.logger.warn(
        `Refusing to cache invalid data for key "${key}": ${parsed.error.message}`,
      );
      return;
    }
    const expiresAt = new Date(Date.now() + ttlDays * 24 * 60 * 60 * 1000);
    const jsonData = parsed.data as unknown as Prisma.InputJsonValue;
    await this.prisma.client.foodCache.upsert({
      where: { cacheKey: key },
      update: { data: jsonData, expiresAt },
      create: { cacheKey: key, source, data: jsonData, expiresAt },
    });
  }

  async invalidateExpired(): Promise<number> {
    const result = await this.prisma.client.foodCache.deleteMany({
      where: { expiresAt: { lt: new Date() } },
    });
    if (result.count > 0) {
      this.logger.log(`Cleaned up ${result.count} expired cache entries`);
    }
    return result.count;
  }
}
