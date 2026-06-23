import { Module } from '@nestjs/common';
import { FoodController } from './food.controller.js';
import { FoodService } from './food.service.js';
import { TfdaModule } from './sources/tfda/tfda.module.js';
import { OpenFoodFactsModule } from './sources/open-food-facts/open-food-facts.module.js';
import { FatSecretModule } from './sources/fat-secret/fat-secret.module.js';
import { FoodDbModule } from './db/food-db.module.js';
import { RecognizeModule } from './recognize/recognize.module.js';

@Module({
  imports: [
    TfdaModule,
    OpenFoodFactsModule,
    FatSecretModule,
    FoodDbModule,
    RecognizeModule,
  ],
  controllers: [FoodController],
  providers: [FoodService],
  exports: [FoodService],
})
export class FoodModule {}
