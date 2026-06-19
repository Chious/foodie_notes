class MealItem {
  final String name;
  final int kcal;
  final int grams;

  const MealItem({required this.name, required this.kcal, required this.grams});
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
}
