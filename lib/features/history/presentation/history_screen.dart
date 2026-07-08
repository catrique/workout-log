import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_treino/features/workout/data/workout_repository_impl.dart';
import 'package:meu_treino/features/history/domain/workout_history.dart';
import 'package:meu_treino/core/theme/app_colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> { 
  final _repository = WorkoutRepositoryImpl();
  String _searchQuery = "";
  String? _expandedDate;

  void clearSearch() {
    setState(() {
      _searchQuery = "";
      _expandedDate = null;
    });
  }

  void filterAndExpandDate(String dateIso) {
    setState(() {
      final parsed = DateTime.parse(dateIso);
      _searchQuery = DateFormat('dd/MM/yyyy').format(parsed);
      _expandedDate = dateIso;
    });
  }

  Map<String, List<HistoryExerciseSet>> _groupByExercise(
    List<HistoryExerciseSet> sets,
  ) {
    final Map<String, List<HistoryExerciseSet>> grouped = {};
    for (final set in sets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Histórico de Treinos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: TextField(
              style: const TextStyle(color: AppColors.textSecondary),
              decoration: InputDecoration(
                hintText: 'Buscar por data (Ex: 30/06/2026)...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              controller: TextEditingController(text: _searchQuery)
                ..selection = TextSelection.fromPosition(TextPosition(offset: _searchQuery.length)),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _expandedDate = null; 
                });
              },
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<WorkoutHistory>>(
              future: _repository.getWorkoutHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allHistory = snapshot.data ?? [];
                
                final history = allHistory.where((item) {
                  final formattedDate = DateFormat('dd/MM/yyyy').format(item.dateTime);
                  return formattedDate.contains(_searchQuery);
                }).toList();

                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum treino realizado ainda.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final formattedDate = DateFormat(
                      'dd/MM/yyyy - HH:mm',
                    ).format(item.dateTime);
                    final groupedExercises = _groupByExercise(item.sets);

                    final itemDateIso = DateFormat('yyyy-MM-dd').format(item.dateTime);
                    final shouldExpand = _expandedDate != null && itemDateIso == _expandedDate;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        key: Key('${item.dateTime.toIso8601String()}_$shouldExpand'),
                        initiallyExpanded: shouldExpand,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[50],
                          child: Icon(
                            Icons.check,
                            color: Colors.green[700],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.workoutName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                ...groupedExercises.entries.map((entry) {
                                  final exerciseName = entry.key;
                                  final exerciseSets = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exerciseName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: exerciseSets.map((set) {
                                            return Chip(
                                              labelPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              backgroundColor: Colors.grey[100],
                                              side: BorderSide.none,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  6,
                                                ),
                                              ),
                                              label: Text(
                                                'S${set.setNumber}: ${set.weightUsed}kg',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}