import 'package:meta/meta.dart';

@immutable
class Workout {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final bool isArchived;

  const Workout({
    required this.id,
    required this.name,
    required this.exercises,
    this.isArchived = false,
  });

  Workout copyWith({
    String? id,
    String? name,
    List<WorkoutExercise>? exercises,
    bool? isArchived,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

@immutable
class WorkoutExercise {
  final String exerciseId;
  final String name;
  final int setsTarget;
  final int repsTarget;

  const WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.setsTarget,
    required this.repsTarget,
  });
}
