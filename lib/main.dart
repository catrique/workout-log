import 'package:flutter/material.dart';
import 'package:meu_treino/core/navigation/main_screen.dart';
import 'features/workout/presentation/workout_screen.dart';
import 'package:meu_treino/core/theme/app_colors.dart';

void main(){
  runApp(const MyWorkout());
}

class MyWorkout extends StatelessWidget{
  const MyWorkout({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'IronProgress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
      home: const MainScreen(),
    );
  }
}