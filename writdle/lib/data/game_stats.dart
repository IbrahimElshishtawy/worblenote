class UserStats {
  // 🎮 إحصائيات الألعاب
  static int totalGames = 0;
  static int winsFirstTry = 0;
  static int winsSecondTry = 0;
  static int winsThirdTry = 0;
  static int winsFourthTry = 0;
  static int losses = 0;

  // ✅ إحصائيات المهام
  static int completedTasks = 0;
  static List<String> completedTaskTitles = [];

  // 🔁 تحديث البيانات
  static void updateStats({
    required int total,
    required int first,
    required int second,
    required int third,
    required int fourth,
    required int loss,
    required int completed,
    required List<String> titles,
  }) {
    totalGames = total;
    winsFirstTry = first;
    winsSecondTry = second;
    winsThirdTry = third;
    winsFourthTry = fourth;
    losses = loss;

    completedTasks = completed;
    completedTaskTitles = titles;
  }

  // 🧹 إعادة تعيين الإحصائيات
  static void reset() {
    totalGames = 0;
    winsFirstTry = 0;
    winsSecondTry = 0;
    winsThirdTry = 0;
    winsFourthTry = 0;
    losses = 0;
    completedTasks = 0;
    completedTaskTitles = [];
  }

  // 🔢 إجمالي عدد مرات الفوز
  static int get totalWins =>
      winsFirstTry + winsSecondTry + winsThirdTry + winsFourthTry;

  // 📈 نسبة الفوز
  static double get winRate => totalGames == 0 ? 0 : totalWins / totalGames;
}
