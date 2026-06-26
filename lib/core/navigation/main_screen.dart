import 'package:flutter/material.dart';
import 'package:meu_treino/features/history/presentation/history_screen.dart';
import 'package:meu_treino/features/workout/presentation/workout_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WorkoutPage(),
    const HistoryPage(),
    const Center(child: Text('Tela de Progesso (Em Breve)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
        ],
      ),
    );
  }
}
