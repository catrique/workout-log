import 'package:flutter/material.dart';
import 'features/workout/presentation/workout_screen.dart';

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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WorkoutPage(),
    );
  }
}