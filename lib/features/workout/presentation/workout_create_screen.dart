import 'package:flutter/material.dart';
import 'package:meu_treino/core/theme/app_colors.dart';
import 'package:meu_treino/features/workout/domain/temp_exercise.dart';
import 'widgets/add_exercise_dialog.dart';
import 'package:meu_treino/features/workout/data/workout_repository_impl.dart';
import 'package:meu_treino/features/workout/domain/workout.dart';

class WorkoutCreatePage extends StatefulWidget {
  const WorkoutCreatePage({super.key});

  @override
  State<WorkoutCreatePage> createState() => _WorkoutCreatePageState();
}

class _WorkoutCreatePageState extends State<WorkoutCreatePage> {
  final _nameController = TextEditingController();

  final List<TempExercise> _addedExercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openAddExerciseDialog() async {
    final TempExercise? result = await showDialog<TempExercise>(
      context: context,
      builder: (context) => const AddExerciseDialog(),
    );

    if (result != null) {
      setState(() {
        _addedExercises.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Montar Novo Treino',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final workoutName = _nameController.text.trim();

              if (workoutName.isEmpty || _addedExercises.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Insira um nome e adicione pelo menos um exercício.',
                    ),
                  ),
                );
                return;
              }

              final String uniqueWorkoutId = DateTime.now()
                  .millisecondsSinceEpoch
                  .toString();

              final List<WorkoutExercise> finalExercises = _addedExercises
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final tempEx = entry.value;

                    return WorkoutExercise(
                      exerciseId: '${uniqueWorkoutId}_ex_$index',
                      name: tempEx.name,
                      setsTarget: tempEx.sets,
                      repsTarget: tempEx.reps,
                    );
                  })
                  .toList();

              final newWorkout = Workout(
                id: uniqueWorkoutId,
                name: workoutName,
                exercises: finalExercises,
              );

              await WorkoutRepositoryImpl().saveWorkout(newWorkout);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome do Treino',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ex: Treino A - Superior',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercícios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _openAddExerciseDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _addedExercises.isEmpty
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhum exercício adicionado a este treino.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _addedExercises.length,
                      itemBuilder: (context, index) {
                        final ex = _addedExercises[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[50],
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              ex.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${ex.sets} séries x ${ex.reps} repetições',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _addedExercises.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
