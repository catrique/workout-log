import 'package:flutter/material.dart';

class WorkoutCreatePage extends StatefulWidget {
  const WorkoutCreatePage({super.key});

  @override
  State<WorkoutCreatePage> createState() => _WorkoutCreatePageState();
}

class _WorkoutCreatePageState extends State<WorkoutCreatePage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Novo Treino', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome do Treino',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ex: Treino A - Superior',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercícios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Center(
                  child: Text(
                    'Nenhum exercício adicionado a este treino.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}