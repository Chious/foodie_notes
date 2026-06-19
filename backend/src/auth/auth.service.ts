import { Injectable } from '@nestjs/common';
import { LoginResponseDto } from './dto/login.dto.js';

@Injectable()
export class AuthService {
  login(): LoginResponseDto {
    return {
      token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.stub-token',
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      user: {
        id: 'cm1a2b3c4d5e6f7g8h9i0',
        email: 'user@example.com',
        name: 'Test User',
      },
    };
  }
}
