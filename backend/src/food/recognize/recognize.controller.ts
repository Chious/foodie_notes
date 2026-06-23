import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { RecognizeService } from './recognize.service.js';
import { RecognizeResponseDto } from './dto/recognize.dto.js';

@ApiTags('Food / Recognize')
@Controller('food/recognize')
export class RecognizeController {
  constructor(private readonly recognizeService: RecognizeService) {}

  @Post()
  @ApiOperation({ summary: '上傳食物圖片，回傳 AI 辨識結果' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: { type: 'string', format: 'binary' },
      },
    },
  })
  @ApiResponse({ status: 200, type: RecognizeResponseDto })
  @UseInterceptors(FileInterceptor('image'))
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  recognize(@UploadedFile() _file: unknown): RecognizeResponseDto {
    return this.recognizeService.recognize();
  }
}
