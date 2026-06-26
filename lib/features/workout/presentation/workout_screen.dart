import 'package:flutter/material.dart';
import 'package:meu_treino/features/workout/presentation/widgets/workout_calendar.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

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

              _buildCalendarPlaceholder(),
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
          onPressed: () {},
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
        ),
        const SizedBox(width: 40,)
      ],
    );
  }

  Widget _buildCalendarPlaceholder() {
    return const WorkoutCalendar();
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
