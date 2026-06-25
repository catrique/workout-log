import 'workout.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getActiveWorkout();
  Future<void> saveWorkout(Workout workout);
  Future<void> archiveWorkout(String id);
}
