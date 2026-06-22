import { Module } from '@nestjs/common';
import { FoodDbController } from './food-db.controller.js';
import { FoodDbService } from './food-db.service.js';
import { TfdaModule } from '../tfda/tfda.module.js';

@Module({
  imports: [TfdaModule],
  controllers: [FoodDbController],
  providers: [FoodDbService],
})
export class FoodDbModule {}
