import 'package:flutter/material.dart';
import 'package:meu_treino/core/theme/app_colors.dart';
import 'package:meu_treino/features/workout/data/workout_repository_impl.dart';
import 'package:meu_treino/features/workout/domain/exercise.dart';

class ExercisesManageScreen extends StatefulWidget {
  const ExercisesManageScreen({super.key});

  @override
  State<ExercisesManageScreen> createState() => _ExercisesManageScreenState();
}

class _ExercisesManageScreenState extends State<ExercisesManageScreen> {
  final _repository = WorkoutRepositoryImpl();
  final _searchController = TextEditingController();
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repository.getExercises();
      setState(() {
        _allExercises = list;
        _filterExercises(_searchController.text);
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises = _allExercises
            .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Novo Exercício',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por favor, confira a grafia antes de salvar. Não será possível alterar ou excluir depois.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ex: Supino Reto',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final text = nameController.text.trim();
                if (text.isNotEmpty) {
                  await _repository.insertExercise(Exercise(name: text));
                  if (mounted) Navigator.pop(context);
                  _loadExercises();
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Catálogo de Exercícios',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterExercises,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Pesquisar no catálogo...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum exercício encontrado.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredExercises.length,
                        separatorBuilder: (_, __) => const Divider(color: AppColors.surface, height: 1),
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            title: Text(
                              exercise.name,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            ),
                            trailing: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddExerciseDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}