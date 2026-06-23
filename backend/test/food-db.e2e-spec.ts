import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';
import { PrismaService } from '../src/prisma/prisma.service.js';
import { FoodCacheService } from '../src/food/cache/food-cache.service.js';

const mockPrisma = {
  client: { foodCache: { findUnique: vi.fn(), upsert: vi.fn(), deleteMany: vi.fn() } },
  onModuleInit: vi.fn(),
  onModuleDestroy: vi.fn(),
};

const mockCache = {
  get: vi.fn().mockResolvedValue(null),
  set: vi.fn().mockResolvedValue(undefined),
};

describe('FoodDbController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: false,
    } as Response);

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(mockPrisma)
      .overrideProvider(FoodCacheService)
      .useValue(mockCache)
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api', { exclude: ['/'] });
    await app.init();
  });

  afterAll(async () => {
    vi.restoreAllMocks();
    await app.close();
  });

  it('GET /api/food/db/version 回傳正確版本與筆數', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/food/db/version')
      .expect(200);

    expect(res.body.version).toBe('2025-UPDATE1');
    expect(res.body.recordCount).toBeGreaterThan(0);
    expect(res.body.sizeBytes).toBeGreaterThan(0);
  });

  it('GET /api/food/db/download 回傳 stub 狀態', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/food/db/download')
      .expect(200);

    expect(res.body.status).toBe('stub');
  });
});
