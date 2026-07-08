import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../workout/domain/workout.dart';
import '../../workout/data/workout_repository_impl.dart';
import 'dart:ui' as ui;

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final _repository = WorkoutRepositoryImpl();

  int _selectedFilterTab = 0;

  String? _selectedExercise;
  String _searchQuery = "";

  Workout? _selectedWorkout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Análise de Evolução',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTabButton('Por Exercício', 0),
                const SizedBox(width: 12),
                _buildTabButton('Por Treino', 1),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _selectedFilterTab == 0
                  ? _buildExerciseProgressView()
                  : _buildWorkoutProgressView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedFilterTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySecondary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseProgressView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<String>>(
          future: _repository.getUniqueTrainedExercises(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'Finalize um treino com pesos para começar a gerar o seu progresso!',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }

            final allExercises = snapshot.data!;
            final filteredExercises = allExercises
                .where(
                  (e) => e.toLowerCase().contains(_searchQuery.toLowerCase()),
                )
                .toList();

            _selectedExercise ??= allExercises.first;

            return Column(
              children: [
                TextField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar exercício...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filteredExercises.contains(_selectedExercise)
                          ? _selectedExercise
                          : (filteredExercises.isNotEmpty
                                ? filteredExercises.first
                                : null),
                      dropdownColor: AppColors.surface,
                      isExpanded: true,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                      ),
                      items: filteredExercises
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedExercise = val),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (_selectedExercise != null)
          Expanded(
            child: ListView(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _repository.getExerciseFullProgressGraph(
                    _selectedExercise!,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return const SizedBox();
                    return _buildEvolutionGraph(snapshot.data!);
                  },
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _repository.getExerciseProgress(_selectedExercise!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return const SizedBox();

                    final allData = snapshot.data!;
                    int personalRecord = 0;
                    String lastWeight = "0";
                    int lastTrainingVolume = 0;

                    if (allData.isNotEmpty) {
                      lastWeight = allData.last['weight_used'] ?? '0';
                      String lastDate = allData.last['date_time'];
                      for (var row in allData) {
                        int w = int.tryParse(row['weight_used'] ?? '0') ?? 0;
                        if (w > personalRecord) personalRecord = w;
                        if (row['date_time'] == lastDate) {
                          lastTrainingVolume += w;
                        }
                      }
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Recorde Pessoal',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$personalRecord kg',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Card(
                                color: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.history,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Última Carga',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$lastWeight kg',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppColors.primarySecondary,
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tonelagem no Último Treino',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$lastTrainingVolume kg totais',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Carga Máxima (3 Últimos Dias)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _repository.getExerciseTopProgress(
                    _selectedExercise!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    final rows = snapshot.data ?? [];
                    if (rows.isEmpty)
                      return const Text(
                        'Sem dados suficientes.',
                        style: TextStyle(color: AppColors.textSecondary),
                      );

                    return Column(
                      children: rows.map((row) {
                        final formattedDate = DateFormat(
                          'dd/MM/yyyy',
                        ).format(DateTime.parse(row['training_date']));
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              '${row['max_weight']} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: Text(
                              formattedDate,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEvolutionGraph(List<Map<String, dynamic>> data) {
    if (data.length < 2) return const SizedBox();

    final weights = data.map((e) => e['max_weight'] as int).toList();
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final delta = (maxWeight - minWeight) == 0 ? 1 : (maxWeight - minWeight);

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight - 20;
          final stepX = width / (data.length - 1);

          List<Offset> points = [];
          for (int i = 0; i < data.length; i++) {
            final w = data[i]['max_weight'] as int;
            final x = i * stepX;
            final y = height - ((w - minWeight) / delta * height) + 10;
            points.add(Offset(x, y));
          }

          return CustomPaint(
            painter: LineChartPainter(points: points, data: data),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutProgressView() {
    return FutureBuilder<List<Workout>>(
      future: _repository.getActiveWorkouts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            'Nenhum treino ativo encontrado.',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        final workouts = snapshot.data!;
        _selectedWorkout ??= workouts.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Workout>(
                  value: workouts.any((w) => w.id == _selectedWorkout?.id)
                      ? workouts.firstWhere((w) => w.id == _selectedWorkout?.id)
                      : workouts.first,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                  items: workouts
                      .map(
                        (w) => DropdownMenuItem(value: w, child: Text(w.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWorkout = val),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedWorkout != null)
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _repository.getExercisesByWorkout(
                    _selectedWorkout!.id,
                  ),
                  builder: (context, exeSnapshot) {
                    if (!exeSnapshot.hasData || exeSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum exercício deste treino foi executado ainda.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    final exerciseNames = exeSnapshot.data!;

                    return ListView.builder(
                      itemCount: exerciseNames.length,
                      itemBuilder: (context, index) {
                        final name = exerciseNames[index];
                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: _repository.getExerciseProgress(name),
                          builder: (context, progressSnapshot) {
                            if (!progressSnapshot.hasData ||
                                progressSnapshot.data!.isEmpty)
                              return const SizedBox();

                            final progress = progressSnapshot.data!;
                            int pr = 0;
                            int lastWeight = 0;
                            int totalSets = progress.length;
                            int tonelagem = 0;
                            String lastDate = progress.last['date_time'];

                            for (var row in progress) {
                              int w =
                                  int.tryParse(row['weight_used'] ?? '0') ?? 0;
                              if (w > pr) pr = w;
                              if (row['date_time'] == lastDate) {
                                tonelagem += w;
                                lastWeight = w;
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMiniMetric('Recorde', '$pr kg'),
                                      _buildMiniMetric(
                                        'Última Carga',
                                        '$lastWeight kg',
                                      ),
                                      _buildMiniMetric(
                                        'Tonelagem',
                                        '$tonelagem kg',
                                      ),
                                      _buildMiniMetric('Séries', '$totalSets'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Offset> points;
  final List<Map<String, dynamic>> data;

  LineChartPainter({required this.points, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4.0, dotPaint);

      textPainter.text = TextSpan(
        text: '${data[i]['max_weight']}kg',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - (textPainter.width / 2), points[i].dy - 16),
      );

      if (i == 0 || i == points.length - 1 || data.length <= 4) {
        final dateStr = DateFormat(
          'dd/MM',
        ).format(DateTime.parse(data[i]['training_date']));
        textPainter.text = TextSpan(
          text: dateStr,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(points[i].dx - (textPainter.width / 2), size.height),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
