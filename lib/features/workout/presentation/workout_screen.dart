import 'package:flutter/material.dart';
import 'package:meu_treino/core/theme/app_colors.dart';
import 'package:meu_treino/features/workout/data/workout_repository_impl.dart';
import 'package:meu_treino/features/workout/domain/workout.dart';
import 'package:meu_treino/features/workout/presentation/widgets/workout_calendar.dart';
import 'package:meu_treino/features/workout/presentation/workout_create_screen.dart';
import 'package:meu_treino/features/workout/presentation/exercises_manage_screen.dart';

import 'workout_execute_screen.dart';

class WorkoutPage extends StatefulWidget {
  final Function(String)? onGoToHistory; 

  const WorkoutPage({super.key, this.onGoToHistory});

  @override
  State<WorkoutPage> createState() => _WorkoutpageState();
}

class _WorkoutpageState extends State<WorkoutPage> {
  Future<List<Workout>> _loadWorkouts() {
    return WorkoutRepositoryImpl().getActiveWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),

              WorkoutCalendar(onGoToHistory: widget.onGoToHistory,),
              const SizedBox(height: 35),

              const Text(
                'Meus Treinos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: FutureBuilder<List<Workout>>(
                  future: _loadWorkouts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erro ao carregar os treinos.'),
                      );
                    }

                    final workouts = snapshot.data ?? [];

                    if (workouts.isEmpty) {
                      return _buildWorkoutListPlaceholder();
                    }

                    return ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[50],
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(
                              workout.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${workout.exercises.length} exercícios adicionados',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WorkoutExecutePage(workout: workout),
                                ),
                              ).then((_) {
                                setState(() {});
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkoutCreatePage(),
              ),
            );
            setState(() {});
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

 Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: const Text(
            'C',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Text(
          'IronProgress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.fitness_center, color: AppColors.textPrimary),
          tooltip: 'Catálogo de Exercícios',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExercisesManageScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutListPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text('Nenhum treino ativo criado ainda.')),
    );
  }
}
