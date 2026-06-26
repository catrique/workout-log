import 'package:flutter/material.dart';

class WorkoutCalendar extends StatefulWidget {
  const WorkoutCalendar({super.key});

  @override
  State<WorkoutCalendar> createState() => _WorkoutCalendarState();
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  bool _isExpanded = false;
  final List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  List<DateTime> _getDaysOfCurrentWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  List<DateTime> _getDaysOfCurrentMonth() {
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    return List.generate(
      totalDays,
      (index) => DateTime(now.year, now.month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: _isExpanded ? 240 : 120,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            _buildMonthHeader(),
            const SizedBox(height: 12),
            _buildWeekDaysHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: _isExpanded ? _buildMonthlyView() : _buildWeeklyView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final now = DateTime.now();
    final monthName = _months[now.month - 1];
    final year = now.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$monthName $year',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 18,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildWeeklyView() {
    final weekDays = _getDaysOfCurrentWeek();
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((date) {
        final isToday =
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        return Expanded(
          child: Center(
            child: SizedBox(
              width: 35,
              height: 35,
              child: _buildDayCell(
                dayNumber: date.day,
                hasWorkout: isToday,
                isToday: isToday,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekDaysHeader() {
    final List<String> weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors
                    .grey[500], 
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyView() {
    final monthDays = _getDaysOfCurrentMonth();
    final today = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: monthDays.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 0,
        crossAxisSpacing: 6,
        childAspectRatio: 1.7,
      ),

      itemBuilder: (context, index) {
        final date = monthDays[index];
        final isToday =
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        return _buildDayCell(
          dayNumber: index + 1,
          hasWorkout: isToday,
          isToday: isToday,
        );
      },
    );
  }

  Widget _buildDayCell({
    required int dayNumber,
    required bool hasWorkout,
    required bool isToday,
  }) {
    final backgroundColor = hasWorkout ? Colors.green[100] : Colors.transparent;
    final textColor = hasWorkout ? Colors.green[800] : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: Colors.green[600]!, width: 1.5)
            : null,
      ),

      child: Center(
        child: Text(
          '$dayNumber',
          style: TextStyle(
            color: textColor,
            fontWeight: (hasWorkout || isToday)
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
