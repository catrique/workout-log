import 'package:flutter/material.dart';
import 'package:meu_treino/features/workout/presentation/widgets/workout_calendar.dart';
import 'package:meu_treino/features/workout/presentation/workout_create_screen.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutpageState();
}

class _WorkoutpageState extends State<WorkoutPage> {
  void _showWorkoutSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inicial qual treino?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('Treino A - Peito e triceps'),
                  subtitle: const Text('4 exercícios'),
                  onTap: () => _startWorkout(context, 'Treino A'),
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('Treino B - Costas e perna'),
                  subtitle: const Text('5 exercícios'),
                  onTap: () => _startWorkout(context, 'Treino B'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startWorkout(BuildContext context, String workoutName) {
    Navigator.pop(context);
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

              WorkoutCalendar(),
              const SizedBox(height: 35),

              const Text(
                'Meus Treinos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(child: _buildWorkoutListPlaceholder()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkoutCreatePage(),
              ),
            );
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
        const Text(
          'IronProgress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildWorkoutListPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text('Nenhum treino ativo criado ainda.')),
    );
  }
}
