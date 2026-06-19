import { Module } from '@nestjs/common';
import { RecognizeController } from './recognize.controller.js';
import { RecognizeService } from './recognize.service.js';

@Module({
  controllers: [RecognizeController],
  providers: [RecognizeService],
})
export class RecognizeModule {}
