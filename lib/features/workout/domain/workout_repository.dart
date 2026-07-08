import 'workout.dart';
import 'exercise.dart';
import 'package:meu_treino/features/history/domain/workout_history.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getActiveWorkouts();
  Future<void> saveWorkout(Workout workout);
  Future<void> archiveWorkout(String id);
  Future<List<WorkoutHistory>> getWorkoutHistory();
  Future<List<Map<String, dynamic>>> getExerciseProgress(String exerciseName);
  Future<List<String>> getUniqueTrainedExercises();
  Future<List<Map<String, dynamic>>> getExerciseTopProgress(String exerciseName,);
  Future<List<Map<String, dynamic>>> getExerciseFullProgressGraph(String exerciseName,);
  Future<List<String>> getExercisesByWorkout(String workoutId);
  Future<List<String>> getTrainedDates();
  Future<List<Exercise>> getExercises();
  Future<int> insertExercise(Exercise exercise);

  Future<void> saveWorkoutHistory({
    required String historyId,
    required String workoutId,
    required String workoutName,
    required DateTime dateTime,
    required Map<String, String> weights,
    required List<WorkoutExercise> exercises,
  });
}
