-- CreateTable
CREATE TABLE "food_cache" (
    "id" TEXT NOT NULL,
    "cacheKey" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "data" JSONB NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "food_cache_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "food_cache_cacheKey_key" ON "food_cache"("cacheKey");

-- CreateIndex
CREATE INDEX "food_cache_expiresAt_idx" ON "food_cache"("expiresAt");
