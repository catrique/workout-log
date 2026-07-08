import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_treino/features/workout/domain/workout.dart';
import 'package:meu_treino/features/workout/data/workout_repository_impl.dart';

class WorkoutExecutePage extends StatefulWidget {
  final Workout workout;

  const WorkoutExecutePage({super.key, required this.workout});

  @override
  State<WorkoutExecutePage> createState() => _WorkoutExecutePageState();
}

class _WorkoutExecutePageState extends State<WorkoutExecutePage> {
  final Map<String, String> _weights = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Executando: ${widget.workout.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.workout.exercises.length,
                itemBuilder: (context, exerciseIndex) {
                  final exercise = widget.workout.exercises[exerciseIndex];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    clipBehavior: Clip.antiAlias, 
                    child: ExpansionTile(
                      shape: const Border(), 
                      collapsedShape: const Border(),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${exercise.setsTarget} séries x ${exercise.repsTarget} reps',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[50],
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.green[700],
                          size: 18,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ),
                          child: Column(
                            children: [
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: exercise.setsTarget,
                                itemBuilder: (context, setIndex) {
                                  final setNumber = setIndex + 1;
                                  final setKey =
                                      '${exercise.exerciseId}_$setNumber';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Série $setNumber',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        SizedBox(
                                          width: 300,
                                          height: 40,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Peso (kg)',
                                              suffixText: 'kg',
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              _weights[setKey] = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final String uniqueHistoryId = DateTime.now()
                      .millisecondsSinceEpoch
                      .toString();

                  await WorkoutRepositoryImpl().saveWorkoutHistory(
                    historyId: uniqueHistoryId,
                    workoutId: widget.workout.id,
                    workoutName: widget.workout.name,
                    dateTime: DateTime.now(),
                    weights: _weights,
                    exercises: widget.workout.exercises,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Treino finalizado! Cargas gravadas com sucesso. 🎉',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Finalizar Treino',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}