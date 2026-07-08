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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_archived': isArchived ? 1 : 0, 
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, List<WorkoutExercise> exercises) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      isArchived: (map['is_archived'] as int) == 1,
      exercises: exercises,
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

  Map<String, dynamic> toMap(String workoutId) {
    return {
      'exercise_id': exerciseId,
      'workout_id': workoutId,
      'name': name,
      'sets_target': setsTarget,
      'reps_target': repsTarget,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exercise_id'] as String,
      name: map['name'] as String,
      setsTarget: map['sets_target'] as int,
      repsTarget: map['reps_target'] as int,
    );
  }
}