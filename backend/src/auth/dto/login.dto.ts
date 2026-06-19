import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  email: string;

  @ApiProperty({ example: 'password123' })
  password: string;
}

class LoginUserDto {
  @ApiProperty({ example: 'cm1a2b3c4d5e6f7g8h9i0' })
  id: string;

  @ApiProperty({ example: 'user@example.com' })
  email: string;

  @ApiProperty({ example: 'Test User' })
  name: string;
}

export class LoginResponseDto {
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  token: string;

  @ApiProperty({ example: '2026-07-19T00:00:00.000Z' })
  expiresAt: string;

  @ApiProperty({ type: LoginUserDto })
  user: LoginUserDto;
}
