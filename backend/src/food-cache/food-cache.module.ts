import { Global, Module } from '@nestjs/common';
import { FoodCacheService } from './food-cache.service.js';

@Global()
@Module({
  providers: [FoodCacheService],
  exports: [FoodCacheService],
})
export class FoodCacheModule {}
