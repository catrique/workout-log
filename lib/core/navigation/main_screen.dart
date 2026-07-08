import 'package:flutter/material.dart';
import 'package:meu_treino/core/theme/app_colors.dart';
import 'package:meu_treino/features/history/presentation/history_screen.dart';
import 'package:meu_treino/features/progress/presentation/progress_screen.dart';
import 'package:meu_treino/features/workout/presentation/workout_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];
  final GlobalKey<HistoryPageState> _historyKey = GlobalKey<HistoryPageState>();

  @override
  void initState() {
    super.initState();
    _screens.clear();
    _screens.addAll([
      WorkoutPage(
        onGoToHistory: _handleGoToHistory,
      ),
      HistoryPage(key: _historyKey),
      const ProgressPage(),
    ]);
  }

  void _handleGoToHistory(String dateIso) {
    setState(() {
      _currentIndex = 1;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _historyKey.currentState?.filterAndExpandDate(dateIso);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.surface,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          if (index == 1) {
            _historyKey.currentState?.clearSearch();
          }
        },

        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
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