import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';
import '../models/models.dart';

// Workout Plans Screen - Browse and select pre-built workout plans
class WorkoutPlansScreen extends ConsumerStatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  ConsumerState<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends ConsumerState<WorkoutPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDifficulty = 'ALL';

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
    final allPlans = ref.watch(workoutPlansProvider);
    final planProgress = ref.watch(planProgressProvider);
    final profile = ref.watch(playerProfileProvider);

    // Group plans by difficulty
    final beginnerPlans = allPlans.where((p) => p.difficulty == 'BEGINNER').toList();
    final intermediatePlans = allPlans.where((p) => p.difficulty == 'INTERMEDIATE').toList();
    final advancedPlans = allPlans.where((p) => p.difficulty == 'ADVANCED').toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.surfaceDark, AppColors.cardDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚔️ Quest Missions',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete workout quests to earn XP and level up!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.secondary,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Beginner'),
                  Tab(text: 'Intermediate'),
                  Tab(text: 'Advanced'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PlanList(plans: beginnerPlans, planProgress: planProgress, profile: profile),
            _PlanList(plans: intermediatePlans, planProgress: planProgress, profile: profile),
            _PlanList(plans: advancedPlans, planProgress: planProgress, profile: profile),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundDark,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _PlanList extends ConsumerWidget {
  final List<WorkoutPlanModel> plans;
  final Map<String, PlanProgressModel> planProgress;
  final PlayerProfileModel profile;

  const _PlanList({
    required this.plans,
    required this.planProgress,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No plans available',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final progress = planProgress[plan.id];
        final isCompleted = progress?.status == PlanStatus.completed;
        final isInProgress = progress?.status == PlanStatus.inProgress;
        
        return _PlanCard(
          plan: plan,
          isCompleted: isCompleted,
          isInProgress: isInProgress,
          timesCompleted: progress?.timesCompleted ?? 0,
          profileLevel: profile.level,
        );
      },
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final WorkoutPlanModel plan;
  final bool isCompleted;
  final bool isInProgress;
  final int timesCompleted;
  final int profileLevel;

  const _PlanCard({
    required this.plan,
    required this.isCompleted,
    required this.isInProgress,
    required this.timesCompleted,
    required this.profileLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficultyColor = _getDifficultyColor(plan.difficulty);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted 
            ? AppColors.primary.withOpacity(0.5)
            : difficultyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showPlanDetails(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon and difficulty
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [difficultyColor, difficultyColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        plan.imageIcon ?? '🏋️',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Complete',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _DifficultyBadge(difficulty: plan.difficulty),
                            const SizedBox(width: 8),
                            _CategoryBadge(category: plan.category),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                plan.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: '${plan.estimatedMinutes} min',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.fitness_center,
                    label: '${plan.totalSets} sets',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.star,
                    label: '+${plan.xpReward} XP',
                    color: AppColors.secondary,
                  ),
                  if (timesCompleted > 0) ...[
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.replay,
                      label: 'x$timesCompleted',
                      color: Colors.grey,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              
              // Muscle groups
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.muscleGroups.map((muscle) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    muscle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showPlanDetails(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted 
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCompleted 
                          ? Icons.replay
                          : isInProgress 
                            ? Icons.play_arrow 
                            : Icons.play_circle_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCompleted 
                          ? 'Do Again'
                          : isInProgress 
                            ? 'Continue Quest'
                            : 'Start Quest',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'BEGINNER':
        return AppColors.primary;
      case 'INTERMEDIATE':
        return AppColors.xpGold;
      case 'ADVANCED':
        return AppColors.difficultyAdvanced;
      default:
        return Colors.grey;
    }
  }

  void _showPlanDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlanDetailsSheet(
        plan: plan,
        isCompleted: isCompleted,
        timesCompleted: timesCompleted,
        ref: ref,
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  
  const _DifficultyBadge({required this.difficulty});
  
  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        difficulty,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  Color _getColor() {
    switch (difficulty) {
      case 'BEGINNER':
        return AppColors.primary;
      case 'INTERMEDIATE':
        return AppColors.xpGold;
      case 'ADVANCED':
        return AppColors.difficultyAdvanced;
      default:
        return Colors.grey;
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  
  const _CategoryBadge({required this.category});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetailsSheet extends ConsumerWidget {
  final WorkoutPlanModel plan;
  final bool isCompleted;
  final int timesCompleted;
  final WidgetRef ref;

  const _PlanDetailsSheet({
    required this.plan,
    required this.isCompleted,
    required this.timesCompleted,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.levelPurple],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              plan.imageIcon ?? '🏋️',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _DifficultyBadge(difficulty: plan.difficulty),
                                  const SizedBox(width: 8),
                                  _CategoryBadge(category: plan.category),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      plan.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats grid
                    Row(
                      children: [
                        Expanded(child: _StatCard(
                          icon: Icons.timer,
                          value: '${plan.estimatedMinutes}',
                          label: 'Minutes',
                          color: Colors.blue,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          icon: Icons.fitness_center,
                          value: '${plan.exercises.length}',
                          label: 'Exercises',
                          color: Colors.orange,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          icon: Icons.format_list_numbered,
                          value: '${plan.totalSets}',
                          label: 'Total Sets',
                          color: Colors.green,
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Rewards
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withOpacity(0.2),
                            AppColors.xpGold.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.star, color: AppColors.secondary, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                '+${plan.xpReward} XP',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                'Experience',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey[700],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.military_tech, color: AppColors.xpGold, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                '+${plan.goldReward}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.xpGold,
                                ),
                              ),
                              Text(
                                'Gold',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Exercises list
                    Text(
                      'Exercises',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...plan.exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: exercise.isWarmup 
                            ? Border.all(color: Colors.orange.withOpacity(0.3))
                            : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: exercise.isWarmup 
                                  ? Colors.orange.withOpacity(0.2)
                                  : AppColors.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: exercise.isWarmup ? Colors.orange : AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exercise.exerciseId.replaceAll('_', ' ').toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (exercise.isWarmup)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Warmup',
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exercise.targetSets} sets × ${exercise.targetReps} reps • ${exercise.restSeconds}s rest',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    
                    // Muscle groups
                    Text(
                      'Target Muscles',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: plan.muscleGroups.map((muscle) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          muscle.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 32),
                    
                    // Start button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _startPlan(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCompleted ? Icons.replay : Icons.play_arrow,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCompleted 
                                ? 'Do Quest Again (+${plan.xpReward} XP)'
                                : 'Begin Quest (+${plan.xpReward} XP)',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startPlan(BuildContext context) {
    // Mark plan as started
    ref.read(planProgressProvider.notifier).startPlan(plan.id);
    
    // Show confirmation and navigate
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.play_circle, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('Quest "${plan.title}" started! Complete it to earn ${plan.xpReward} XP'),
          ],
        ),
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
