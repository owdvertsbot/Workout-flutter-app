import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class ProgressAnalyticsScreen extends ConsumerStatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  ConsumerState<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends ConsumerState<ProgressAnalyticsScreen> {
  String _selectedPeriod = '7d';
  String _selectedMuscleView = 'front';

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onChanged: (p) => setState(() => _selectedPeriod = p),
            ),
            const SizedBox(height: 24),

            // Weekly summary
            _WeeklySummaryCard(profile: profile),
            const SizedBox(height: 24),

            // Muscle heatmap
            _SectionHeader(title: 'Muscle Balance'),
            const SizedBox(height: 12),
            _MuscleHeatmap(
              selectedView: _selectedMuscleView,
              onViewChanged: (v) => setState(() => _selectedMuscleView = v),
            ),
            const SizedBox(height: 24),

            // Volume trends
            _SectionHeader(title: 'Volume Trends'),
            const SizedBox(height: 12),
            _VolumeTrendsChart(),
            const SizedBox(height: 24),

            // PRs this month
            _SectionHeader(title: 'Personal Records'),
            const SizedBox(height: 12),
            _PRSummaryCard(),
            const SizedBox(height: 24),

            // Body measurements
            _SectionHeader(title: 'Body Measurements'),
            const SizedBox(height: 12),
            _BodyMeasurementsCard(),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(label: '7D', value: '7d', selected: selectedPeriod, onTap: onChanged),
          _PeriodChip(label: '30D', value: '30d', selected: selectedPeriod, onTap: onChanged),
          _PeriodChip(label: '90D', value: '90d', selected: selectedPeriod, onTap: onChanged),
          _PeriodChip(label: '1Y', value: '1y', selected: selectedPeriod, onTap: onChanged),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

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

class _WeeklySummaryCard extends StatelessWidget {
  final PlayerProfileModel profile;

  const _WeeklySummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.levelPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeeklyStat(value: '${profile.streakDays}', label: 'Streak', icon: Icons.local_fire_department),
              _WeeklyStat(value: '${(profile.totalVolumeKg / 1000).toStringAsFixed(1)}t', label: 'Volume', icon: Icons.fitness_center),
              _WeeklyStat(value: '4', label: 'Workouts', icon: Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _WeeklyStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MuscleHeatmap extends StatelessWidget {
  final String selectedView;
  final ValueChanged<String> onViewChanged;

  const _MuscleHeatmap({
    required this.selectedView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // View toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ViewToggle(
                  label: 'Front',
                  isSelected: selectedView == 'front',
                  onTap: () => onViewChanged('front'),
                ),
                const SizedBox(width: 16),
                _ViewToggle(
                  label: 'Back',
                  isSelected: selectedView == 'back',
                  onTap: () => onViewChanged('back'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Muscle groups heatmap
            SizedBox(
              height: 280,
              child: CustomPaint(
                size: const Size(double.infinity, 280),
                painter: _MusclePainter(isFront: selectedView == 'front'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.grey.shade800, label: 'Not trained'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orange.shade300, label: 'Light'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orange.shade600, label: 'Moderate'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orange.shade900, label: 'Heavy'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

class _MusclePainter extends CustomPainter {
  final bool isFront;

  _MusclePainter({required this.isFront});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Simplified muscle positions
    final muscleData = isFront ? _frontMuscles : _backMuscles;
    
    for (final muscle in muscleData) {
      paint.color = _getMuscleColor(muscle['intensity'] as double);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            (muscle['x'] as double) * size.width,
            (muscle['y'] as double) * size.height,
          ),
          width: (muscle['w'] as double) * size.width,
          height: (muscle['h'] as double) * size.height,
        ),
        paint,
      );
    }
  }

  Color _getMuscleColor(double intensity) {
    if (intensity == 0) return Colors.grey.shade800;
    if (intensity < 0.3) return Colors.orange.shade300;
    if (intensity < 0.7) return Colors.orange.shade600;
    return Colors.orange.shade900;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Muscle data for front view
final _frontMuscles = [
  // Chest
  {'x': 0.35, 'y': 0.22, 'w': 0.12, 'h': 0.08, 'intensity': 0.8},
  {'x': 0.55, 'y': 0.22, 'w': 0.12, 'h': 0.08, 'intensity': 0.8},
  // Shoulders
  {'x': 0.28, 'y': 0.18, 'w': 0.08, 'h': 0.06, 'intensity': 0.6},
  {'x': 0.64, 'y': 0.18, 'w': 0.08, 'h': 0.06, 'intensity': 0.6},
  // Biceps
  {'x': 0.22, 'y': 0.32, 'w': 0.06, 'h': 0.12, 'intensity': 0.5},
  {'x': 0.72, 'y': 0.32, 'w': 0.06, 'h': 0.12, 'intensity': 0.5},
  // Abs
  {'x': 0.45, 'y': 0.35, 'w': 0.1, 'h': 0.15, 'intensity': 0.3},
  // Quads
  {'x': 0.38, 'y': 0.6, 'w': 0.1, 'h': 0.18, 'intensity': 0.9},
  {'x': 0.52, 'y': 0.6, 'w': 0.1, 'h': 0.18, 'intensity': 0.9},
];

// Muscle data for back view
final _backMuscles = [
  // Upper back
  {'x': 0.45, 'y': 0.2, 'w': 0.1, 'h': 0.1, 'intensity': 0.7},
  // Lats
  {'x': 0.35, 'y': 0.28, 'w': 0.1, 'h': 0.12, 'intensity': 0.6},
  {'x': 0.55, 'y': 0.28, 'w': 0.1, 'h': 0.12, 'intensity': 0.6},
  // Traps
  {'x': 0.45, 'y': 0.15, 'w': 0.1, 'h': 0.06, 'intensity': 0.4},
  // Triceps
  {'x': 0.22, 'y': 0.32, 'w': 0.06, 'h': 0.1, 'intensity': 0.5},
  {'x': 0.72, 'y': 0.32, 'w': 0.06, 'h': 0.1, 'intensity': 0.5},
  // Lower back
  {'x': 0.45, 'y': 0.4, 'w': 0.1, 'h': 0.08, 'intensity': 0.3},
  // Glutes
  {'x': 0.42, 'y': 0.52, 'w': 0.08, 'h': 0.08, 'intensity': 0.8},
  {'x': 0.52, 'y': 0.52, 'w': 0.08, 'h': 0.08, 'intensity': 0.8},
  // Hamstrings
  {'x': 0.38, 'y': 0.68, 'w': 0.1, 'h': 0.15, 'intensity': 0.7},
  {'x': 0.52, 'y': 0.68, 'w': 0.1, 'h': 0.15, 'intensity': 0.7},
];

class _VolumeTrendsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Volume (kg)',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: const Size(double.infinity, 150),
                painter: _BarChartPainter(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Text(d, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 9;
    final heights = [0.4, 0.7, 0.3, 0.9, 0.5, 0.2, 0.6]; // Sample data

    for (var i = 0; i < heights.length; i++) {
      final height = heights[i] * size.height * 0.9;
      final x = (i + 0.5) * barWidth;
      final y = size.height - height;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth * 0.6, height),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PRSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PRRow(icon: Icons.emoji_events, label: 'All-Time PRs', value: '12'),
            const Divider(),
            _PRRow(icon: Icons.trending_up, label: '2-Month PRs', value: '5'),
            const Divider(),
            _PRRow(icon: Icons.local_fire_department, label: 'Volume PRs', value: '8'),
          ],
        ),
      ),
    );
  }
}

class _PRRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PRRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.xpGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.xpGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.inter()),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppColors.xpGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMeasurementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MeasurementRow(label: 'Body Weight', value: '80.5 kg', trend: '+0.5'),
            const Divider(),
            _MeasurementRow(label: 'Chest', value: '102 cm', trend: '+1'),
            const Divider(),
            _MeasurementRow(label: 'Waist', value: '82 cm', trend: '-1'),
            const Divider(),
            _MeasurementRow(label: 'Arms', value: '36 cm', trend: '+0.5'),
          ],
        ),
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  final String label;
  final String value;
  final String trend;

  const _MeasurementRow({
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = !trend.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter())),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trend,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
