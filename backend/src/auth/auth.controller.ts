import { Body, Controller, Post } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service.js';
import { LoginDto, LoginResponseDto } from './dto/login.dto.js';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @ApiOperation({ summary: '登入驗證，回傳 API Token' })
  @ApiResponse({ status: 200, type: LoginResponseDto })
  login(@Body() loginDto: LoginDto): LoginResponseDto {
    void loginDto;
    return this.authService.login();
  }
}
