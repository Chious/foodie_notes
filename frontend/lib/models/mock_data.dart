class MealItem {
  final String name;
  final int kcal;
  final int grams;

  const MealItem({required this.name, required this.kcal, required this.grams});
}

class MealMacro {
  final int protein;
  final int carbs;
  final int fat;

  const MealMacro({
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class StatsMeal {
  final String name;
  final String time;
  final String summary;
  final int kcal;
  final MealMacro macros;

  const StatsMeal({
    required this.name,
    required this.time,
    required this.summary,
    required this.kcal,
    required this.macros,
  });
}

enum DayStatus { past, today, future }

class DayCalorie {
  final String label;
  final int kcal;
  final DayStatus status;

  const DayCalorie({
    required this.label,
    required this.kcal,
    required this.status,
  });
}

class WeeklyStatsData {
  final String dateRange;
  final int calorieGoal;
  final List<DayCalorie> days;
  final String avgMacros;
  final String weightChange;

  const WeeklyStatsData({
    required this.dateRange,
    required this.calorieGoal,
    required this.days,
    required this.avgMacros,
    required this.weightChange,
  });
}

class MonthlyStatsData {
  final String monthLabel;
  final int calorieGoal;
  final List<DayCalorie> days;
  final int targetRate;
  final String weightChange;
  final String mostEaten;

  const MonthlyStatsData({
    required this.monthLabel,
    required this.calorieGoal,
    required this.days,
    required this.targetRate,
    required this.weightChange,
    required this.mostEaten,
  });
}

class DailyStatsData {
  final String dateLabel;
  final int totalCalories;
  final int goalCalories;
  final MacroData macros;
  final List<StatsMeal> meals;
  final String currentTime;

  const DailyStatsData({
    required this.dateLabel,
    required this.totalCalories,
    required this.goalCalories,
    required this.macros,
    required this.meals,
    required this.currentTime,
  });

  int get remaining => goalCalories - totalCalories;
}

class FoodItem {
  final String name;
  final int kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final int defaultServingGrams;

  const FoodItem({
    required this.name,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
  });
}

class RecognizedItem {
  final FoodItem foodItem;
  final double quantity;
  final bool selected;

  const RecognizedItem({
    required this.foodItem,
    required this.quantity,
    this.selected = true,
  });
}

class RecognitionResult {
  final String mealName;
  final List<RecognizedItem> items;

  const RecognitionResult({
    required this.mealName,
    required this.items,
  });
}

class Meal {
  final String name;
  final String time;
  final List<MealItem> items;
  final int totalKcal;

  const Meal({
    required this.name,
    required this.time,
    required this.items,
    required this.totalKcal,
  });

  String get itemsSummary => items.map((i) => '${i.name} ${i.grams}g').join('、');
}

class MacroData {
  final int proteinCurrent;
  final int proteinGoal;
  final int carbsCurrent;
  final int carbsGoal;
  final int fatCurrent;
  final int fatGoal;

  const MacroData({
    required this.proteinCurrent,
    required this.proteinGoal,
    required this.carbsCurrent,
    required this.carbsGoal,
    required this.fatCurrent,
    required this.fatGoal,
  });
}

class DailyData {
  final String dateLabel;
  final String dayLabel;
  final int totalCalories;
  final int goalCalories;
  final MacroData macros;
  final List<Meal> meals;

  const DailyData({
    required this.dateLabel,
    required this.dayLabel,
    required this.totalCalories,
    required this.goalCalories,
    required this.macros,
    required this.meals,
  });

  int get remaining => goalCalories - totalCalories;
}

class BodyData {
  final double height;
  final double currentWeight;
  final double targetWeight;
  final double startWeight;
  final String targetDate;
  final int dailyCalorieGoal;

  const BodyData({
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    required this.startWeight,
    required this.targetDate,
    required this.dailyCalorieGoal,
  });

  double get weightLost => startWeight - currentWeight;
  double get weightRemaining => currentWeight - targetWeight;
  double get progress =>
      (startWeight - currentWeight) / (startWeight - targetWeight);
}

abstract class MockData {
  static const dailyData = DailyData(
    dateLabel: 'JUN 17 · TUE',
    dayLabel: '今天',
    totalCalories: 1240,
    goalCalories: 2000,
    macros: MacroData(
      proteinCurrent: 58,
      proteinGoal: 100,
      carbsCurrent: 138,
      carbsGoal: 250,
      fatCurrent: 41,
      fatGoal: 65,
    ),
    meals: [
      Meal(
        name: '午餐',
        time: '12:30',
        items: [
          MealItem(name: '白飯', kcal: 65, grams: 50),
          MealItem(name: '雞排', kcal: 250, grams: 100),
          MealItem(name: '炒青菜', kcal: 45, grams: 50),
        ],
        totalKcal: 360,
      ),
      Meal(
        name: '早餐',
        time: '08:10',
        items: [
          MealItem(name: '燕麥粥', kcal: 280, grams: 200),
          MealItem(name: '美式咖啡', kcal: 140, grams: 350),
        ],
        totalKcal: 420,
      ),
    ],
  );

  static const bodyData = BodyData(
    height: 178,
    currentWeight: 72.5,
    targetWeight: 68.0,
    startWeight: 80.0,
    targetDate: '2026/9/30',
    dailyCalorieGoal: 2000,
  );

  static const recentFoods = ['雞排便當', '珍珠奶茶', '滷肉飯'];

  static const _chickenCutletBoneless = FoodItem(
    name: '雞排（去骨）',
    kcalPer100g: 250,
    proteinPer100g: 20,
    carbsPer100g: 10,
    fatPer100g: 15,
    defaultServingGrams: 100,
  );

  static const allFoodItems = <FoodItem>[
    _chickenCutletBoneless,
    FoodItem(
      name: '雞排（帶骨）',
      kcalPer100g: 272,
      proteinPer100g: 18,
      carbsPer100g: 11,
      fatPer100g: 17,
      defaultServingGrams: 120,
    ),
    FoodItem(
      name: '鹹酥雞',
      kcalPer100g: 295,
      proteinPer100g: 19,
      carbsPer100g: 14,
      fatPer100g: 19,
      defaultServingGrams: 100,
    ),
    FoodItem(
      name: '雞胸肉（水煮）',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 4,
      defaultServingGrams: 100,
    ),
    FoodItem(
      name: '白飯',
      kcalPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
      defaultServingGrams: 150,
    ),
    FoodItem(
      name: '炒青菜',
      kcalPer100g: 90,
      proteinPer100g: 4,
      carbsPer100g: 8,
      fatPer100g: 4,
      defaultServingGrams: 100,
    ),
    FoodItem(
      name: '滷肉飯',
      kcalPer100g: 190,
      proteinPer100g: 8,
      carbsPer100g: 25,
      fatPer100g: 7,
      defaultServingGrams: 200,
    ),
    FoodItem(
      name: '珍珠奶茶',
      kcalPer100g: 70,
      proteinPer100g: 0.5,
      carbsPer100g: 16,
      fatPer100g: 1,
      defaultServingGrams: 500,
    ),
    FoodItem(
      name: '燕麥粥',
      kcalPer100g: 68,
      proteinPer100g: 2.5,
      carbsPer100g: 12,
      fatPer100g: 1.5,
      defaultServingGrams: 250,
    ),
  ];

  static const recognitionResult = RecognitionResult(
    mealName: '雞排便當',
    items: [
      RecognizedItem(
        foodItem: FoodItem(
          name: '白飯',
          kcalPer100g: 130,
          proteinPer100g: 2.7,
          carbsPer100g: 28,
          fatPer100g: 0.3,
          defaultServingGrams: 50,
        ),
        quantity: 1,
      ),
      RecognizedItem(
        foodItem: _chickenCutletBoneless,
        quantity: 1,
      ),
      RecognizedItem(
        foodItem: FoodItem(
          name: '炒青菜',
          kcalPer100g: 90,
          proteinPer100g: 4,
          carbsPer100g: 8,
          fatPer100g: 4,
          defaultServingGrams: 50,
        ),
        quantity: 1,
        selected: false,
      ),
    ],
  );

  static const dailyStatsData = DailyStatsData(
    dateLabel: '6月17日 週二',
    totalCalories: 1240,
    goalCalories: 2000,
    macros: MacroData(
      proteinCurrent: 58,
      proteinGoal: 100,
      carbsCurrent: 138,
      carbsGoal: 250,
      fatCurrent: 41,
      fatGoal: 65,
    ),
    meals: [
      StatsMeal(
        name: '早餐',
        time: '08:10',
        summary: '燕麥粥、咖啡',
        kcal: 420,
        macros: MealMacro(protein: 23, carbs: 27, fat: 18),
      ),
      StatsMeal(
        name: '午餐',
        time: '12:30',
        summary: '白飯、雞排、炒青菜',
        kcal: 360,
        macros: MealMacro(protein: 23, carbs: 27, fat: 18),
      ),
    ],
    currentTime: '15:00',
  );

  static const weeklyStatsData = WeeklyStatsData(
    dateRange: '6/15 – 6/21',
    calorieGoal: 2000,
    days: [
      DayCalorie(label: '一', kcal: 1240, status: DayStatus.past),
      DayCalorie(label: '二', kcal: 1420, status: DayStatus.past),
      DayCalorie(label: '三', kcal: 1580, status: DayStatus.past),
      DayCalorie(label: '四', kcal: 1360, status: DayStatus.past),
      DayCalorie(label: '五', kcal: 1720, status: DayStatus.past),
      DayCalorie(label: '六', kcal: 1240, status: DayStatus.today),
      DayCalorie(label: '日', kcal: 0, status: DayStatus.future),
    ],
    avgMacros: 'P72 · C198 · F58',
    weightChange: '−0.6 kg',
  );

  static const monthlyStatsData = MonthlyStatsData(
    monthLabel: '2026 年 6 月',
    calorieGoal: 2000,
    days: [
      DayCalorie(label: '1', kcal: 1160, status: DayStatus.past),
      DayCalorie(label: '2', kcal: 1440, status: DayStatus.past),
      DayCalorie(label: '3', kcal: 1620, status: DayStatus.past),
      DayCalorie(label: '4', kcal: 1320, status: DayStatus.past),
      DayCalorie(label: '5', kcal: 1800, status: DayStatus.past),
      DayCalorie(label: '6', kcal: 960, status: DayStatus.past),
      DayCalorie(label: '7', kcal: 1540, status: DayStatus.past),
      DayCalorie(label: '8', kcal: 1240, status: DayStatus.past),
      DayCalorie(label: '9', kcal: 1680, status: DayStatus.past),
      DayCalorie(label: '10', kcal: 1400, status: DayStatus.past),
      DayCalorie(label: '11', kcal: 1100, status: DayStatus.past),
      DayCalorie(label: '12', kcal: 1760, status: DayStatus.past),
      DayCalorie(label: '13', kcal: 1900, status: DayStatus.past),
      DayCalorie(label: '14', kcal: 1200, status: DayStatus.past),
      DayCalorie(label: '15', kcal: 1480, status: DayStatus.past),
      DayCalorie(label: '16', kcal: 1640, status: DayStatus.past),
      DayCalorie(label: '17', kcal: 1000, status: DayStatus.past),
      DayCalorie(label: '18', kcal: 1560, status: DayStatus.past),
      DayCalorie(label: '19', kcal: 1280, status: DayStatus.past),
      DayCalorie(label: '20', kcal: 1720, status: DayStatus.past),
      DayCalorie(label: '21', kcal: 1440, status: DayStatus.past),
      DayCalorie(label: '22', kcal: 1080, status: DayStatus.today),
      DayCalorie(label: '23', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '24', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '25', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '26', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '27', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '28', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '29', kcal: 0, status: DayStatus.future),
      DayCalorie(label: '30', kcal: 0, status: DayStatus.future),
    ],
    targetRate: 73,
    weightChange: '−2.1',
    mostEaten: '雞排便當',
  );
}
