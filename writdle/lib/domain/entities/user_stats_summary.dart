class UserStatsSummary {
  const UserStatsSummary({
    this.totalGames = 0,
    this.winsFirstTry = 0,
    this.winsSecondTry = 0,
    this.winsThirdTry = 0,
    this.winsFourthTry = 0,
    this.losses = 0,
    this.completedTasks = 0,
    this.completedTaskTitles = const [],
  });

  final int totalGames;
  final int winsFirstTry;
  final int winsSecondTry;
  final int winsThirdTry;
  final int winsFourthTry;
  final int losses;
  final int completedTasks;
  final List<String> completedTaskTitles;

  int get totalWins =>
      winsFirstTry + winsSecondTry + winsThirdTry + winsFourthTry;

  double get winRate => totalGames == 0 ? 0 : (totalWins / totalGames) * 100;

  UserStatsSummary copyWith({
    int? totalGames,
    int? winsFirstTry,
    int? winsSecondTry,
    int? winsThirdTry,
    int? winsFourthTry,
    int? losses,
    int? completedTasks,
    List<String>? completedTaskTitles,
  }) {
    return UserStatsSummary(
      totalGames: totalGames ?? this.totalGames,
      winsFirstTry: winsFirstTry ?? this.winsFirstTry,
      winsSecondTry: winsSecondTry ?? this.winsSecondTry,
      winsThirdTry: winsThirdTry ?? this.winsThirdTry,
      winsFourthTry: winsFourthTry ?? this.winsFourthTry,
      losses: losses ?? this.losses,
      completedTasks: completedTasks ?? this.completedTasks,
      completedTaskTitles: completedTaskTitles ?? this.completedTaskTitles,
    );
  }
}
