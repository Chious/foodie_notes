import { Module } from '@nestjs/common';
import { FoodController } from './food.controller.js';
import { FoodService } from './food.service.js';
import { TfdaModule } from '../tfda/tfda.module.js';
import { OpenFoodFactsModule } from '../open-food-facts/open-food-facts.module.js';
import { FatSecretModule } from '../fat-secret/fat-secret.module.js';

@Module({
  imports: [TfdaModule, OpenFoodFactsModule, FatSecretModule],
  controllers: [FoodController],
  providers: [FoodService],
})
export class FoodModule {}
