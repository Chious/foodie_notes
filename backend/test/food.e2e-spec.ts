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

describe('FoodController (e2e)', () => {
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

  it('GET /api/food/search?q=雞胸肉 回傳 TFDA 來源的搜尋結果', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/food/search')
      .query({ q: '雞胸肉' })
      .expect(200);

    expect(res.body.items).toBeInstanceOf(Array);
    expect(res.body.items.length).toBeGreaterThan(0);
    expect(res.body.items[0].source).toBe('tfda');
    expect(res.body.total).toBeGreaterThan(0);
  });

  it('GET /api/food/search?q= 回傳空結果', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/food/search')
      .query({ q: '' })
      .expect(200);

    expect(res.body.items).toEqual([]);
  });

  it('GET /api/food/barcode/invalid 回傳 found: false', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/food/barcode/invalid')
      .expect(200);

    expect(res.body.found).toBe(false);
    expect(res.body.item).toBeNull();
    expect(res.body.source).toBeNull();
  });
});
