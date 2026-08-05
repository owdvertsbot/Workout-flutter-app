import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'models/models.dart';

void main() {
  runApp(const ProviderScope(child: RPGWorkoutApp()));
}

class RPGWorkoutApp extends ConsumerWidget {
  const RPGWorkoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'RPG Workout',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // FDS 11.1 Navigation Matrix:
  // Tab 0: Dashboard, Tab 1: Exercise Library, Tab 2: Workout Hub, Tab 3: Analytics, Tab 4: Profile
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExerciseLibraryScreen(),
    const _WorkoutHubScreen(), // Tab 2: Active Workout / Routine Hub
    const ProgressAnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Home Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
            tooltip: 'Exercise Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Workouts',
            tooltip: 'Active Workout / Routine Hub',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Progress',
            tooltip: 'Hypertrophy Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
            tooltip: 'RPG Character Profile Hub',
          ),
        ],
      ),
    );
  }
}

// FDS 11.1 Tab 2: Workout Hub - Active Workout / Routine Hub
class _WorkoutHubScreen extends ConsumerWidget {
  const _WorkoutHubScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final featuredPlans = ref.watch(featuredPlansProvider);

    if (activeWorkout != null) {
      // If there's an active workout, show it
      return const ActiveWorkoutScreen();
    }

    // Otherwise show the routine hub
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ Quest Missions'),
        backgroundColor: AppColors.backgroundDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'All Plans',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlansScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured Quest Plans
          _SectionHeader(title: 'Available Quests'),
          const SizedBox(height: 12),
          if (featuredPlans.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    'All quests completed!',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check back tomorrow for new quests',
                    style: GoogleFonts.inter(
                      color: AppColors.textMutedDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ...featuredPlans.take(3).map((plan) => _PlanQuickCard(plan: plan)),
          
          const SizedBox(height: 24),
          
          // Quick Start
          _HubCard(
            title: 'Quick Start',
            subtitle: 'Start an empty workout',
            icon: Icons.play_arrow,
            color: AppColors.primary,
            onTap: () {
              ref.read(activeWorkoutProvider.notifier).startWorkout();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()));
            },
          ),
          const SizedBox(height: 16),
          
          // Active workout detection
          _HubCard(
            title: 'Active Workout',
            subtitle: activeWorkout != null ? 'Workout in progress' : 'No active workout',
            icon: Icons.fitness_center,
            color: activeWorkout != null ? AppColors.xpGold : Colors.grey,
            onTap: () {
              if (activeWorkout != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()));
              }
            },
          ),
          const SizedBox(height: 16),
          
          // View All Plans Button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlansScreen()));
            },
            icon: const Icon(Icons.map),
            label: const Text('View All Quest Plans'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.secondary),
              foregroundColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Quick card for displaying a workout plan as a quest
class _PlanQuickCard extends StatelessWidget {
  final WorkoutPlanModel plan;

  const _PlanQuickCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = AppColors.getDifficultyColor(plan.difficulty);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: difficultyColor.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlansScreen()));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [difficultyColor, difficultyColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    plan.imageIcon ?? '🏋️',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 12, color: AppColors.textMutedDark),
                        const SizedBox(width: 4),
                        Text(
                          '${plan.estimatedMinutes} min',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star, size: 12, color: AppColors.secondary.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          '+${plan.xpReward} XP',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.secondary.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Start',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryDark)),
                  Text(subtitle, style: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMutedDark),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
    );
  }
}
