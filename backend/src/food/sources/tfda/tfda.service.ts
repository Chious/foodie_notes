import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import path from 'node:path';
import type { TfdaFoodItem } from './interfaces/tfda-food-item.interface.js';
import { tfdaToFoodItem, cellToString, toNumber } from './tfda.utils.js';
import { FOOD_SYNONYMS } from './data/synonyms.js';
import type { FoodItemDto } from '../../dto/food-search.dto.js';

const EXCEL_FILE = '食品營養成分資料庫2025版UPDATE1.xlsx';

const HEADER_MAP: Record<string, keyof TfdaFoodItem> = {
  整合編號: 'sampleCode',
  食品分類: 'category',
  樣品名稱: 'nameZh',
  內容物描述: 'description',
  俗名: 'commonName',
  '熱量(kcal)': 'calories',
  '粗蛋白(g)': 'protein',
  '粗脂肪(g)': 'fat',
  '總碳水化合物(g)': 'carbs',
  '膳食纖維(g)': 'fiber',
  '糖質總量(g)': 'sugar',
  '鈉(mg)': 'sodium',
};

@Injectable()
export class TfdaService implements OnModuleInit {
  private readonly logger = new Logger(TfdaService.name);
  private foods: TfdaFoodItem[] = [];
  private reverseIndex = new Map<string, string[]>();

  async onModuleInit() {
    await this.loadDatabase();
    this.buildReverseIndex();
  }

  private async loadDatabase() {
    const filePath = path.join(process.cwd(), 'assets', EXCEL_FILE);
    const ExcelJS = await import('exceljs');
    const workbook = new ExcelJS.default.Workbook();
    await workbook.xlsx.readFile(filePath);

    const worksheet = workbook.worksheets[0];
    if (!worksheet) throw new Error('TFDA Excel 檔案沒有工作表');

    const headerRow = worksheet.getRow(2);
    const colMap = new Map<string, number>();
    headerRow.eachCell((cell, colNumber) => {
      const header = cellToString(cell.value).trim();
      if (HEADER_MAP[header]) {
        colMap.set(HEADER_MAP[header], colNumber);
      }
    });

    worksheet.eachRow((row, rowNumber) => {
      if (rowNumber <= 2) return;

      const sampleCode = cellToString(
        row.getCell(colMap.get('sampleCode')!).value,
      ).trim();
      if (!sampleCode) return;

      this.foods.push({
        sampleCode,
        category: cellToString(row.getCell(colMap.get('category')!).value),
        nameZh: cellToString(row.getCell(colMap.get('nameZh')!).value),
        description: cellToString(
          row.getCell(colMap.get('description')!).value,
        ),
        commonName: cellToString(row.getCell(colMap.get('commonName')!).value),
        calories: toNumber(row.getCell(colMap.get('calories')!).value),
        protein: toNumber(row.getCell(colMap.get('protein')!).value),
        fat: toNumber(row.getCell(colMap.get('fat')!).value),
        carbs: toNumber(row.getCell(colMap.get('carbs')!).value),
        fiber: toNumber(row.getCell(colMap.get('fiber')!).value),
        sugar: toNumber(row.getCell(colMap.get('sugar')!).value),
        sodium: toNumber(row.getCell(colMap.get('sodium')!).value),
      });
    });

    this.logger.log(`TFDA 資料庫載入完成：${this.foods.length} 筆`);
  }

  private buildReverseIndex() {
    for (const [canonical, aliases] of Object.entries(FOOD_SYNONYMS)) {
      for (const alias of aliases) {
        if (!this.reverseIndex.has(alias)) {
          this.reverseIndex.set(alias, []);
        }
        this.reverseIndex.get(alias)!.push(canonical);
      }
      if (!this.reverseIndex.has(canonical)) {
        this.reverseIndex.set(canonical, []);
      }
      this.reverseIndex.get(canonical)!.push(...aliases);
    }
  }

  fuzzySearch(query: string, limit = 20): FoodItemDto[] {
    const q = query.trim();
    if (!q) return [];

    const searchTerms = [q, ...(this.reverseIndex.get(q) ?? [])];
    const scored: { food: TfdaFoodItem; score: number }[] = [];

    for (const food of this.foods) {
      const score = this.scoreMatch(food, q, searchTerms);
      if (score > 0) {
        scored.push({ food, score });
      }
    }

    scored.sort((a, b) => b.score - a.score);

    return scored.slice(0, limit).map(({ food }) => tfdaToFoodItem(food));
  }

  findBestMatch(term: string): FoodItemDto | null {
    const searchTerms = [term, ...(this.reverseIndex.get(term) ?? [])];
    let bestFood: TfdaFoodItem | null = null;
    let bestScore = 0;

    for (const food of this.foods) {
      const score = this.scoreMatch(food, term, searchTerms);
      if (score > bestScore) {
        bestScore = score;
        bestFood = food;
      }
    }

    return bestFood ? tfdaToFoodItem(bestFood) : null;
  }

  private scoreMatch(
    food: TfdaFoodItem,
    originalTerm: string,
    searchTerms: string[],
  ): number {
    const targets = [food.nameZh];
    if (food.commonName) {
      for (const alias of food.commonName.split(',')) {
        const trimmed = alias.trim();
        if (trimmed) targets.push(trimmed);
      }
    }

    let best = 0;

    for (const target of targets) {
      if (!target) continue;
      if (target === originalTerm) return 1000;
      if (target.includes(originalTerm)) {
        const score = 500 + (1 / target.length) * 100;
        if (score > best) best = score;
      }
    }

    for (let i = 1; i < searchTerms.length; i++) {
      const synonym = searchTerms[i];
      for (const target of targets) {
        if (!target) continue;
        if (target === synonym) {
          const score = 400;
          if (score > best) best = score;
        } else if (target.includes(synonym)) {
          const score = 300 + (1 / target.length) * 100;
          if (score > best) best = score;
        }
      }
    }

    return best;
  }

  findByCode(sampleCode: string): FoodItemDto | null {
    const food = this.foods.find((f) => f.sampleCode === sampleCode);
    return food ? tfdaToFoodItem(food) : null;
  }

  getCategories(): string[] {
    return [...new Set(this.foods.map((f) => f.category))];
  }

  getItemCount(): number {
    return this.foods.length;
  }
}
