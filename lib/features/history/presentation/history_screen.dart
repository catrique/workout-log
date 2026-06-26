import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Treinos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildEmptyHistory(),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Seus treinos finalizados aparecerão aqui',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
