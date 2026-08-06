// Adaptive Health - Main Shell
// Main navigation structure with four pillars

import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Main navigation shell for Adaptive Health
/// Implements the four-pillar navigation: Movement, Nutrition, Recovery, Education
class HealthMainShell extends StatefulWidget {
  const HealthMainShell({super.key});

  @override
  State<HealthMainShell> createState() => _HealthMainShellState();
}

class _HealthMainShellState extends State<HealthMainShell> {
  int _selectedIndex = 0;

  // Four pillars of the app
  final List<Widget> _screens = const [
    MovementScreen(),
    NutritionScreen(),
    RecoveryScreen(),
    EducationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_run_outlined),
            selectedIcon: Icon(Icons.directions_run),
            label: 'Movement',
            tooltip: 'Exercise and physical activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrition',
            tooltip: 'Diet and nutrition guidance',
          ),
          NavigationDestination(
            icon: Icon(Icons.nightlight_outlined),
            selectedIcon: Icon(Icons.nightlight),
            label: 'Recovery',
            tooltip: 'Sleep and recovery',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Learn',
            tooltip: 'Health education',
          ),
        ],
      ),
    );
  }
}

/// Movement Screen - Exercise and physical activity
class MovementScreen extends StatelessWidget {
  const MovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Movement'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(HealthSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's summary card
              _TodaySummaryCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Today's workout card
              _TodayWorkoutCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Quick stats
              _QuickStatsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nutrition Screen - Diet and nutrition guidance
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(HealthSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily targets
              _NutritionTargetsCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Meal timing
              _MealTimingCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Hydration
              _HydrationCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recovery Screen - Sleep and recovery
class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(HealthSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleep target
              _SleepTargetCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Recovery activities
              _RecoveryActivitiesCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Readiness score
              _ReadinessCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Education Screen - Health education content
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(HealthSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured content
              _FeaturedContentCard(),
              SizedBox(height: HealthSpacing.sectionGap),
              
              // Topic categories
              _TopicCategories(),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Reusable Components =====

/// Today's summary card showing daily prescription overview
class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HealthSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HealthColors.primary,
            HealthColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(HealthRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Plan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: HealthSpacing.sm,
                  vertical: HealthSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(HealthRadius.full),
                ),
                child: const Text(
                  'Personalized',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HealthSpacing.md),
          Row(
            children: [
              _SummaryItem(
                icon: Icons.timer_outlined,
                value: '30',
                label: 'minutes',
              ),
              const SizedBox(width: HealthSpacing.xl),
              _SummaryItem(
                icon: Icons.fitness_center_outlined,
                value: '5',
                label: 'exercises',
              ),
              const SizedBox(width: HealthSpacing.xl),
              _SummaryItem(
                icon: Icons.speed_outlined,
                value: 'Moderate',
                label: 'intensity',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: HealthSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Today's workout card with exercise list
class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Exercises',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        const _ExerciseListItem(
          order: 1,
          name: 'Warm-up',
          sets: '1 set',
          reps: 'Light activity',
          color: HealthColors.info,
        ),
        const _ExerciseListItem(
          order: 2,
          name: 'Bodyweight Squat',
          sets: '3 sets',
          reps: '10-15 reps',
          color: HealthColors.movement,
        ),
        const _ExerciseListItem(
          order: 3,
          name: 'Push-ups',
          sets: '3 sets',
          reps: '8-12 reps',
          color: HealthColors.movement,
        ),
        const _ExerciseListItem(
          order: 4,
          name: 'Plank',
          sets: '3 sets',
          reps: '30 seconds',
          color: HealthColors.movement,
        ),
      ],
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final int order;
  final String name;
  final String sets;
  final String reps;
  final Color color;

  const _ExerciseListItem({
    required this.order,
    required this.name,
    required this.sets,
    required this.reps,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: HealthSpacing.sm),
      padding: const EdgeInsets.all(HealthSpacing.md),
      decoration: BoxDecoration(
        color: HealthColors.surface,
        borderRadius: BorderRadius.circular(HealthRadius.md),
        border: Border.all(
          color: HealthColors.surfaceVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(HealthRadius.sm),
            ),
            child: Center(
              child: Text(
                '$order',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: HealthSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$sets • $reps',
                  style: TextStyle(
                    color: HealthColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            iconSize: 20,
            color: HealthColors.textSecondary,
            tooltip: 'Why this exercise?',
            onPressed: () {
              // Show evidence explanation
              _showWhyDialog(context, name);
            },
          ),
        ],
      ),
    );
  }
  
  void _showWhyDialog(BuildContext context, String exerciseName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(HealthSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science_outlined, color: HealthColors.primary),
                const SizedBox(width: HealthSpacing.sm),
                Text(
                  'Why this exercise?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: HealthSpacing.md),
            const Text(
              'This exercise is recommended based on:\n\n'
              '• Your fitness goal (general health)\n'
              '• Scientific evidence for effectiveness\n'
              '• Accessibility considerations\n'
              '• Progressive overload principles\n\n'
              'The sets and reps are calibrated to provide optimal '
              'stimulus while managing fatigue.',
            ),
            const SizedBox(height: HealthSpacing.lg),
            Text(
              'Evidence Source',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: HealthColors.textSecondary,
              ),
            ),
            const SizedBox(height: HealthSpacing.xs),
            const Text(
              'ACSM Guidelines for Exercise Prescription (2023)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: HealthSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

/// Quick stats row
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: '3',
            label: 'Day Streak',
            color: HealthColors.streak,
          ),
        ),
        const SizedBox(width: HealthSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            value: '+12%',
            label: 'This Week',
            color: HealthColors.success,
          ),
        ),
        const SizedBox(width: HealthSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            value: '5',
            label: 'XP Earned',
            color: HealthColors.milestone,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HealthSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(HealthRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: HealthSpacing.xs),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Nutrition screen components
class _NutritionTargetsCard extends StatelessWidget {
  const _NutritionTargetsCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Targets',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Container(
          padding: const EdgeInsets.all(HealthSpacing.cardPadding),
          decoration: BoxDecoration(
            color: HealthColors.surface,
            borderRadius: BorderRadius.circular(HealthRadius.md),
          ),
          child: Column(
            children: [
              _MacroRow(
                label: 'Calories',
                value: '2,100',
                unit: 'kcal',
                progress: 0.65,
                color: HealthColors.secondary,
              ),
              const Divider(height: HealthSpacing.lg),
              _MacroRow(
                label: 'Protein',
                value: '140',
                unit: 'g',
                progress: 0.45,
                color: HealthColors.movement,
              ),
              const Divider(height: HealthSpacing.lg),
              _MacroRow(
                label: 'Carbs',
                value: '210',
                unit: 'g',
                progress: 0.55,
                color: HealthColors.nutrition,
              ),
              const Divider(height: HealthSpacing.lg),
              _MacroRow(
                label: 'Fat',
                value: '65',
                unit: 'g',
                progress: 0.35,
                color: HealthColors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double progress;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HealthRadius.xs),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: HealthSpacing.md),
        SizedBox(
          width: 70,
          child: Text(
            '$value $unit',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _MealTimingCard extends StatelessWidget {
  const _MealTimingCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Timing',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MealChip(label: 'Breakfast', time: '7-9 AM'),
            ),
            const SizedBox(width: HealthSpacing.sm),
            Expanded(
              child: _MealChip(label: 'Lunch', time: '12-2 PM'),
            ),
            const SizedBox(width: HealthSpacing.sm),
            Expanded(
              child: _MealChip(label: 'Dinner', time: '6-8 PM'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealChip extends StatelessWidget {
  final String label;
  final String time;

  const _MealChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HealthSpacing.md),
      decoration: BoxDecoration(
        color: HealthColors.nutrition.withOpacity(0.08),
        borderRadius: BorderRadius.circular(HealthRadius.md),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant,
            color: HealthColors.nutrition,
            size: 20,
          ),
          const SizedBox(height: HealthSpacing.xs),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            time,
            style: TextStyle(
              color: HealthColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hydration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Container(
          padding: const EdgeInsets.all(HealthSpacing.cardPadding),
          decoration: BoxDecoration(
            color: HealthColors.surface,
            borderRadius: BorderRadius.circular(HealthRadius.md),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(HealthSpacing.md),
                decoration: BoxDecoration(
                  color: HealthColors.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(HealthRadius.md),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: HealthColors.info,
                ),
              ),
              const SizedBox(width: HealthSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1.8 / 2.5 L',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Target: 2.5 liters today',
                      style: TextStyle(
                        color: HealthColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('Log'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Recovery screen components
class _SleepTargetCard extends StatelessWidget {
  const _SleepTargetCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Goal',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Container(
          padding: const EdgeInsets.all(HealthSpacing.cardPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HealthColors.recovery,
                HealthColors.recovery.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(HealthRadius.lg),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bedtime,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: HealthSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '8 hours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Target bedtime: 10:30 PM',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: HealthSpacing.sm,
                  vertical: HealthSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(HealthRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Tip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecoveryActivitiesCard extends StatelessWidget {
  const _RecoveryActivitiesCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recovery Activities',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Wrap(
          spacing: HealthSpacing.sm,
          runSpacing: HealthSpacing.sm,
          children: [
            _ActivityChip(
              icon: Icons.self_improvement,
              label: 'Stretching',
              duration: '15 min',
            ),
            _ActivityChip(
              icon: Icons.spa,
              label: 'Foam Rolling',
              duration: '10 min',
            ),
            _ActivityChip(
              icon: Icons.air,
              label: 'Breathing',
              duration: '5 min',
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String duration;

  const _ActivityChip({
    required this.icon,
    required this.label,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HealthSpacing.md,
        vertical: HealthSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: HealthColors.recovery.withOpacity(0.08),
        borderRadius: BorderRadius.circular(HealthRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: HealthColors.recovery),
          const SizedBox(width: HealthSpacing.xs),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: HealthSpacing.xs),
          Text(
            duration,
            style: TextStyle(
              color: HealthColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recovery Score',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Container(
          padding: const EdgeInsets.all(HealthSpacing.cardPadding),
          decoration: BoxDecoration(
            color: HealthColors.surface,
            borderRadius: BorderRadius.circular(HealthRadius.md),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 8,
                      backgroundColor: HealthColors.success.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(HealthColors.success),
                    ),
                    Center(
                      child: Text(
                        '75',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: HealthColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: HealthSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good to go!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: HealthSpacing.xs),
                    Text(
                      'Your recovery looks great today. Feel free to do a full workout.',
                      style: TextStyle(
                        color: HealthColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Education screen components
class _FeaturedContentCard extends StatelessWidget {
  const _FeaturedContentCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Container(
          padding: const EdgeInsets.all(HealthSpacing.cardPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HealthColors.education,
                HealthColors.education.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(HealthRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(HealthSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(HealthRadius.md),
                ),
                child: const Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: HealthSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why Rest Days Matter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: HealthSpacing.xs),
                    Text(
                      'Learn how recovery drives adaptation',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: HealthSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '3 min read',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicCategories extends StatelessWidget {
  const _TopicCategories();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HealthSpacing.md),
        Wrap(
          spacing: HealthSpacing.sm,
          runSpacing: HealthSpacing.sm,
          children: [
            _TopicChip(
              label: 'Exercise Science',
              icon: Icons.fitness_center,
              color: HealthColors.movement,
            ),
            _TopicChip(
              label: 'Nutrition',
              icon: Icons.restaurant,
              color: HealthColors.nutrition,
            ),
            _TopicChip(
              label: 'Sleep',
              icon: Icons.bedtime,
              color: HealthColors.recovery,
            ),
            _TopicChip(
              label: 'Habit Formation',
              icon: Icons.repeat,
              color: HealthColors.education,
            ),
          ],
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TopicChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HealthSpacing.md,
        vertical: HealthSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(HealthRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: HealthSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
