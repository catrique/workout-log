class WorkoutHistory {
  final String historyId;
  final String workoutId;
  final String workoutName;
  final DateTime dateTime;
  final List<HistoryExerciseSet> sets;

  const WorkoutHistory({
    required this.historyId,
    required this.workoutId,
    required this.workoutName,
    required this.dateTime,
    required this.sets,
  });
}

class HistoryExerciseSet {
  final String exerciseName;
  final int setNumber;
  final String weightUsed;

  const HistoryExerciseSet({
    required this.exerciseName,
    required this.setNumber,
    required this.weightUsed,
  });
}