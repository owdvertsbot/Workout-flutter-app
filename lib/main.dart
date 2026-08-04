import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

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
        seedColor: const Color(0xFF00E676),
        brightness: brightness,
        primary: const Color(0xFF00E676),
        secondary: const Color(0xFF7C4DFF),
        tertiary: const Color(0xFFFFD700),
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      cardTheme: CardThemeDataData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
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

    if (activeWorkout != null) {
      // If there's an active workout, show it
      return const ActiveWorkoutScreen();
    }

    // Otherwise show the routine hub
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Start (FDS 3.3)
          _HubCard(
            title: 'Quick Start',
            subtitle: 'Start an empty workout',
            icon: Icons.play_arrow,
            color: const Color(0xFF00E676),
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
            color: activeWorkout != null ? const Color(0xFFFFD700) : Colors.grey,
            onTap: () {
              if (activeWorkout != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()));
              }
            },
          ),
          const SizedBox(height: 16),
          // Routines section (FDS 3.3)
          _SectionHeader(title: 'Saved Routines'),
          const SizedBox(height: 8),
          // Placeholder for routines
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.bookmark_outline, size: 48, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text('No saved routines', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Create Routine'),
                ),
              ],
            ),
          ),
        ],
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
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
      child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
