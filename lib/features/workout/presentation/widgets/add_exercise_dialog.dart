import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_treino/features/workout/data/workout_repository_impl.dart';
import 'package:meu_treino/features/workout/domain/exercise.dart';
import 'package:meu_treino/features/workout/domain/temp_exercise.dart';

class AddExerciseDialog extends StatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _repository = WorkoutRepositoryImpl();
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Exercise> _catalogExercises = [];
  String? _selectedExerciseName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final list = await _repository.getExercises();
      setState(() {
        _catalogExercises = list;
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Exercício', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _catalogExercises.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Nenhum exercício no catálogo. Por favor, adicione exercícios primeiro no menu principal.',
                              style: TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedExerciseName,
                            hint: const Text('Escolha o exercício'),
                            isExpanded: true,
                            items: _catalogExercises.map((Exercise ex) {
                              return DropdownMenuItem<String>(
                                value: ex.name,
                                child: Text(ex.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedExerciseName = value;
                              });
                            },
                            validator: (value) => value == null ? 'Selecione um exercício' : null,
                          ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _setsCtrl,
                            decoration: const InputDecoration(labelText: 'Séries'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _repsCtrl,
                            decoration: const InputDecoration(labelText: 'Repetições'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _catalogExercises.isEmpty
              ? null 
              : () {
                  if (_formKey.currentState!.validate() && _selectedExerciseName != null) {
                    final newExercise = TempExercise(
                      name: _selectedExerciseName!,
                      sets: int.parse(_setsCtrl.text),
                      reps: int.parse(_repsCtrl.text),
                    );
                    Navigator.pop(context, newExercise);
                  }
                },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}