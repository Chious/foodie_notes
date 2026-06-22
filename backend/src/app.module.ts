import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { FoodModule } from './food/food.module.js';
import { RecognizeModule } from './recognize/recognize.module.js';
import { FoodDbModule } from './food-db/food-db.module.js';
import { FoodCacheModule } from './food-cache/food-cache.module.js';
import { TfdaModule } from './tfda/tfda.module.js';
import { OpenFoodFactsModule } from './open-food-facts/open-food-facts.module.js';
import { FatSecretModule } from './fat-secret/fat-secret.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    FoodCacheModule,
    TfdaModule,
    OpenFoodFactsModule,
    FatSecretModule,
    AuthModule,
    FoodModule,
    RecognizeModule,
    FoodDbModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
