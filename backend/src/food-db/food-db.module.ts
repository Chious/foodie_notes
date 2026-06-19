import { Module } from '@nestjs/common';
import { FoodDbController } from './food-db.controller.js';
import { FoodDbService } from './food-db.service.js';

@Module({
  controllers: [FoodDbController],
  providers: [FoodDbService],
})
export class FoodDbModule {}
