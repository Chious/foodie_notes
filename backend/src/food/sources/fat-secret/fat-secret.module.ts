import { Module } from '@nestjs/common';
import { FatSecretService } from './fat-secret.service.js';

@Module({
  providers: [FatSecretService],
  exports: [FatSecretService],
})
export class FatSecretModule {}
