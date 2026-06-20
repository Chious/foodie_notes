import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { FoodModule } from './food/food.module.js';
import { RecognizeModule } from './recognize/recognize.module.js';
import { FoodDbModule } from './food-db/food-db.module.js';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    FoodModule,
    RecognizeModule,
    FoodDbModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
