import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Instructions'),
            Tab(text: 'Analytics'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InstructionsTab(exercise: widget.exercise),
          _AnalyticsTab(exercise: widget.exercise),
          _HistoryTab(exercise: widget.exercise),
        ],
      ),
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  final ExerciseModel exercise;

  const _InstructionsTab({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise preview placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Muscle groups
          _SectionTitle(title: 'Target Muscles'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(exercise.muscleGroup ?? exercise.bodyPart),
                backgroundColor: const Color(0xFF00E676).withOpacity(0.2),
                labelStyle: const TextStyle(color: Color(0xFF00E676)),
              ),
              ...exercise.secondaryMuscles.map(
                (m) => Chip(
                  label: Text(m),
                  backgroundColor: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Equipment
          _SectionTitle(title: 'Equipment'),
          Chip(
            avatar: const Icon(Icons.fitness_center, size: 16),
            label: Text(exercise.equipment),
          ),
          const SizedBox(height: 24),

          // Setup steps
          _SectionTitle(title: 'Setup Instructions'),
          _InstructionStep(
            number: 1,
            text: 'Position yourself in the starting position for ${exercise.name}.',
          ),
          _InstructionStep(
            number: 2,
            text: 'Ensure proper form and grip width.',
          ),
          _InstructionStep(
            number: 3,
            text: 'Engage your core and prepare for the movement.',
          ),
          _InstructionStep(
            number: 4,
            text: 'Execute the movement through the full range of motion.',
          ),
          const SizedBox(height: 24),

          // Common mistakes
          _SectionTitle(title: 'Common Mistakes'),
          _MistakeItem(text: 'Using momentum instead of controlled movement'),
          _MistakeItem(text: 'Not achieving full range of motion'),
          _MistakeItem(text: 'Incorrect breathing pattern'),
          _MistakeItem(text: 'Rounding the back during lifts'),
          const SizedBox(height: 24),

          // Tips
          _SectionTitle(title: 'Pro Tips'),
          _TipItem(text: 'Focus on mind-muscle connection'),
          _TipItem(text: 'Keep constant tension on the target muscle'),
          _TipItem(text: 'Progressively overload for continued gains'),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final ExerciseModel exercise;

  const _AnalyticsTab({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1RM Chart
          _SectionTitle(title: 'Estimated 1RM Progression'),
          const SizedBox(height: 8),
          _PeriodSelector(),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: _ProgressChartPainter(),
            ),
          ),
          const SizedBox(height: 24),

          // PRs summary
          _SectionTitle(title: 'Personal Records'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PRCard(
                  title: 'All-Time Best',
                  value: '100 kg',
                  date: 'Jan 15',
                  icon: Icons.emoji_events,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PRCard(
                  title: '2-Month Best',
                  value: '95 kg',
                  date: 'Feb 10',
                  icon: Icons.trending_up,
                  color: const Color(0xFF00E676),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PRCard(
            title: 'Best Volume (1RM est)',
            value: '1600 kg',
            date: 'Feb 8',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            fullWidth: true,
          ),
          const SizedBox(height: 24),

          // Plateau status
          _SectionTitle(title: 'Performance Status'),
          const SizedBox(height: 12),
          _PlateauCard(status: 'getting_stronger'),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatefulWidget {
  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  String _selected = '3M';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['1M', '3M', '6M', '1Y', 'All'].map((period) {
        final isSelected = _selected == period;
        return GestureDetector(
          onTap: () => setState(() => _selected = period),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00E676) : Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              period,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [
      const Offset(0.1, 0.7),
      const Offset(0.2, 0.65),
      const Offset(0.3, 0.6),
      const Offset(0.4, 0.55),
      const Offset(0.5, 0.5),
      const Offset(0.6, 0.45),
      const Offset(0.7, 0.4),
      const Offset(0.8, 0.35),
      const Offset(0.9, 0.3),
    ];

    final path = Path();
    path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    canvas.drawPath(path, paint);

    // Draw dots
    paint.style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PRCard extends StatelessWidget {
  final String title;
  final String value;
  final String date;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _PRCard({
    required this.title,
    required this.value,
    required this.date,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlateauCard extends StatelessWidget {
  final String status;

  const _PlateauCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final data = _getStatusData(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data['icon'] as IconData,
              color: data['color'] as Color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: data['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['description'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData(String status) {
    switch (status) {
      case 'getting_stronger':
        return {
          'color': const Color(0xFF00E676),
          'icon': Icons.trending_up,
          'title': 'Getting Stronger',
          'description': 'Your recent performance shows consistent progress',
        };
      case 'plateauing':
        return {
          'color': Colors.orange,
          'icon': Icons.trending_flat,
          'title': 'Plateauing',
          'description': 'Consider increasing volume or changing exercises',
        };
      case 'taking_dip':
        return {
          'color': Colors.red,
          'icon': Icons.trending_down,
          'title': 'Taking a Dip',
          'description': 'Ensure proper recovery and nutrition',
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.help_outline,
          'title': 'Not Enough Data',
          'description': 'Keep training to see trends',
        };
    }
  }
}

class _HistoryTab extends StatelessWidget {
  final ExerciseModel exercise;

  const _HistoryTab({required this.exercise});

  @override
  Widget build(BuildContext context) {
    // Sample history data
    final history = [
      _HistoryEntry(date: 'Feb 15', sets: '3×8 @ 80kg'),
      _HistoryEntry(date: 'Feb 12', sets: '3×6 @ 85kg'),
      _HistoryEntry(date: 'Feb 9', sets: '3×8 @ 75kg'),
      _HistoryEntry(date: 'Feb 5', sets: '4×6 @ 70kg'),
      _HistoryEntry(date: 'Feb 1', sets: '3×10 @ 65kg'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(entry.date),
            subtitle: Text(entry.sets),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _HistoryEntry {
  final String date;
  final String sets;

  _HistoryEntry({required this.date, required this.sets});
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeItem extends StatelessWidget {
  final String text;

  const _MistakeItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFFFD700), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
