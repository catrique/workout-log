import 'package:sqflite/sqflite.dart';
import 'package:meu_treino/core/database/database_helper.dart';
import 'package:meu_treino/features/workout/domain/workout_repository.dart';
import 'package:meu_treino/features/workout/domain/workout.dart';
import 'package:meu_treino/features/history/domain/workout_history.dart';
import 'package:meu_treino/features/workout/domain/exercise.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

String _normalizeExerciseName(String name) {
    String text = name.trim().toLowerCase();
    
    var comAcento = 'àáâãäåçèéêëìíîïñòóâõöùúûüýÿ';
    var semAcento = 'aaaaaaceeeeiiiinooooouuuuyy';
    for (int i = 0; i < comAcento.length; i++) {
      text = text.replaceAll(comAcento[i], semAcento[i]);
    }
    
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text;
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        'workouts',
        workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final exercise in workout.exercises) {
        await txn.insert(
          'exercises',
          exercise.toMap(workout.id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<Workout>> getActiveWorkouts() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> workoutMaps = await db.query(
      'workouts',
      where: 'is_archived = ?',
      whereArgs: [0],
    );

    final List<Workout> workouts = [];

    for (final workoutMap in workoutMaps) {
      final workoutId = workoutMap['id'] as String;

      final List<Map<String, dynamic>> exerciseMaps = await db.query(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );

      final exercises = exerciseMaps
          .map((e) => WorkoutExercise.fromMap(e))
          .toList();

      workouts.add(Workout.fromMap(workoutMap, exercises));
    }

    return workouts;
  }

  @override
  Future<void> archiveWorkout(String id) async {
    final db = await _dbHelper.database;

    await db.update(
      'workouts',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> saveWorkoutHistory({
    required String historyId,
    required String workoutId,
    required String workoutName,
    required DateTime dateTime,
    required Map<String, String> weights,
    required List<WorkoutExercise> exercises,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.insert('workout_history', {
        'history_id': historyId,
        'workout_id': workoutId,
        'workout_name': workoutName,
        'date_time': dateTime.toIso8601String(),
      });

      for (final exercise in exercises) {
        for (int setIndex = 0; setIndex < exercise.setsTarget; setIndex++) {
          final setNumber = setIndex + 1;
          final setKey = '${exercise.exerciseId}_$setNumber';
          final weight = weights[setKey] ?? '';

          await txn.insert('exercise_history_sets', {
            'history_id': historyId,
            'exercise_name': exercise.name,
            'set_number': setNumber,
            'weight_used': weight.isEmpty ? '0' : weight,
          });
        }
      }
    });
  }

  @override
  Future<List<WorkoutHistory>> getWorkoutHistory() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> historyMaps = await db.query(
      'workout_history',
      orderBy: 'date_time DESC',
    );

    final List<WorkoutHistory> historyList = [];

    for (final historyMap in historyMaps) {
      final historyId = historyMap['history_id'] as String;

      final List<Map<String, dynamic>> setMaps = await db.query(
        'exercise_history_sets',
        where: 'history_id = ?',
        whereArgs: [historyId],
      );

      final sets = setMaps.map((s) {
        return HistoryExerciseSet(
          exerciseName: s['exercise_name'] as String,
          setNumber: s['set_number'] as int,
          weightUsed: s['weight_used'] as String,
        );
      }).toList();

      historyList.add(
        WorkoutHistory(
          historyId: historyId,
          workoutId: historyMap['workout_id'] as String,
          workoutName: historyMap['workout_name'] as String,
          dateTime: DateTime.parse(historyMap['date_time'] as String),
          sets: sets,
        ),
      );
    }

    return historyList;
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseProgress(
    String exerciseName,
  ) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
      SELECT h.date_time, s.weight_used, s.set_number
      FROM exercise_history_sets s
      INNER JOIN workout_history h ON s.history_id = h.history_id
      WHERE s.exercise_name = ?
      ORDER BY h.date_time ASC
    ''',
      [exerciseName],
    );
  }

  @override
  Future<List<String>> getUniqueTrainedExercises() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT exercise_name FROM exercise_history_sets
      WHERE weight_used != '0' AND weight_used != ''
    ''');

    return maps.map((m) => m['exercise_name'] as String).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseTopProgress(
    String exerciseName,
  ) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
      SELECT 
        DATE(h.date_time) as training_date, 
        MAX(CAST(s.weight_used AS INTEGER)) as max_weight
      FROM exercise_history_sets s
      INNER JOIN workout_history h ON s.history_id = h.history_id
      WHERE s.exercise_name = ? AND s.weight_used != '0' AND s.weight_used != ''
      GROUP BY DATE(h.date_time)
      ORDER BY h.date_time DESC
      LIMIT 3
    ''',
      [exerciseName],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseFullProgressGraph(
    String exerciseName,
  ) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
      SELECT 
        DATE(h.date_time) as training_date, 
        MAX(CAST(s.weight_used AS INTEGER)) as max_weight
      FROM exercise_history_sets s
      INNER JOIN workout_history h ON s.history_id = h.history_id
      WHERE s.exercise_name = ? AND s.weight_used != '0' AND s.weight_used != ''
      GROUP BY DATE(h.date_time)
      ORDER BY h.date_time ASC
    ''',
      [exerciseName],
    );
  }

  @override
  Future<List<String>> getExercisesByWorkout(String workoutId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT s.exercise_name 
      FROM exercise_history_sets s
      INNER JOIN workout_history h ON s.history_id = h.history_id
      WHERE h.workout_id = ? AND s.weight_used != '0' AND s.weight_used != ''
    ''',
      [workoutId],
    );

    return maps.map((m) => m['exercise_name'] as String).toList();
  }

  Future<List<String>> getTrainedDates() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT DATE(date_time) as trained_date FROM workout_history'
    );
    return maps.map((m) => m['trained_date'] as String).toList();
  }

  @override
  Future<List<Exercise>> getExercises() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_catalog',
      orderBy: 'name ASC',
    );
    return maps.map((e) => Exercise.fromMap(e)).toList();
  }

  @override
  Future<int> insertExercise(Exercise exercise) async {
    final db = await _dbHelper.database;
    
    final normalizedName = _normalizeExerciseName(exercise.name);
    
    if (normalizedName.isEmpty) return -1;

    final List<Map<String, dynamic>> existing = await db.query(
      'exercise_catalog',
      where: 'LOWER(name) = ?', 
      whereArgs: [normalizedName],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return await db.insert(
      'exercise_catalog',
      {'name': exercise.name.trim()},
    );
  }
}
