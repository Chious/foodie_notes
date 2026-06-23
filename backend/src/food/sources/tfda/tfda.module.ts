import { Module } from '@nestjs/common';
import { TfdaService } from './tfda.service.js';

@Module({
  providers: [TfdaService],
  exports: [TfdaService],
})
export class TfdaModule {}
