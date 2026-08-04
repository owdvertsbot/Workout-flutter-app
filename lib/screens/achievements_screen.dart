import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _AchievementCard(achievement: achievement);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      // First Workout
      {'id': 'first_workout', 'name': 'First Steps', 'desc': 'Complete your first workout', 'icon': Icons.fitness_center, 'unlocked': true, 'progress': 1.0, 'tier': 'bronze'},
      {'id': '10_workouts', 'name': 'Dedicated', 'desc': 'Complete 10 workouts', 'icon': Icons.repeat, 'unlocked': false, 'progress': 0.5, 'tier': 'silver'},
      {'id': '100_workouts', 'name': 'Committed', 'desc': 'Complete 100 workouts', 'icon': Icons.emoji_events, 'unlocked': false, 'progress': 0.1, 'tier': 'gold'},
      // PRs
      {'id': 'first_pr', 'name': 'Record Breaker', 'desc': 'Hit your first PR', 'icon': Icons.trending_up, 'unlocked': true, 'progress': 1.0, 'tier': 'bronze'},
      {'id': '10_prs', 'name': 'PR Machine', 'desc': 'Hit 10 PRs', 'icon': Icons.bolt, 'unlocked': false, 'progress': 0.3, 'tier': 'silver'},
      {'id': '50_prs', 'name': 'Legendary', 'desc': 'Hit 50 PRs', 'icon': Icons.star, 'unlocked': false, 'progress': 0.0, 'tier': 'gold'},
      // Streaks
      {'id': '7_day_streak', 'name': 'Week Warrior', 'desc': 'Maintain a 7-day streak', 'icon': Icons.local_fire_department, 'unlocked': true, 'progress': 1.0, 'tier': 'bronze'},
      {'id': '30_day_streak', 'name': 'Month Master', 'desc': 'Maintain a 30-day streak', 'icon': Icons.whatshot, 'unlocked': false, 'progress': 0.23, 'tier': 'silver'},
      {'id': '100_day_streak', 'name': 'Unstoppable', 'desc': 'Maintain a 100-day streak', 'icon': Icons.military_tech, 'unlocked': false, 'progress': 0.0, 'tier': 'gold'},
      // Volume
      {'id': 'volume_1t', 'name': 'Tonelifter', 'desc': 'Lift 1 ton total volume', 'icon': Icons.fitness_center, 'unlocked': true, 'progress': 1.0, 'tier': 'bronze'},
      {'id': 'volume_10t', 'name': 'Iron Will', 'desc': 'Lift 10 tons total volume', 'icon': Icons.sports_gymnastics, 'unlocked': false, 'progress': 0.45, 'tier': 'silver'},
      {'id': 'volume_100t', 'name': 'Titan', 'desc': 'Lift 100 tons total volume', 'icon': Icons.psychology, 'unlocked': false, 'progress': 0.0, 'tier': 'gold'},
      // Levels
      {'id': 'level_5', 'name': 'Apprentice', 'desc': 'Reach level 5', 'icon': Icons.trending_up, 'unlocked': true, 'progress': 1.0, 'tier': 'bronze'},
      {'id': 'level_10', 'name': 'Journeyman', 'desc': 'Reach level 10', 'icon': Icons.trending_up, 'unlocked': false, 'progress': 0.5, 'tier': 'silver'},
      {'id': 'level_25', 'name': 'Master', 'desc': 'Reach level 25', 'icon': Icons.trending_up, 'unlocked': false, 'progress': 0.2, 'tier': 'gold'},
      // Exercises
      {'id': '50_exercises', 'name': 'Variety', 'desc': 'Try 50 different exercises', 'icon': Icons.list, 'unlocked': false, 'progress': 0.3, 'tier': 'bronze'},
      {'id': '200_exercises', 'name': 'Explorer', 'desc': 'Try 200 different exercises', 'icon': Icons.explore, 'unlocked': false, 'progress': 0.1, 'tier': 'silver'},
      {'id': 'all_exercises', 'name': 'Completionist', 'desc': 'Try all exercises', 'icon': Icons.check_circle, 'unlocked': false, 'progress': 0.0, 'tier': 'gold'},
    ];
  }
}

class _AchievementCard extends StatelessWidget {
  final Map<String, dynamic> achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement['unlocked'] as bool;
    final tier = achievement['tier'] as String;
    final progress = achievement['progress'] as double;

    final tierColor = switch (tier) {
      'gold' => const Color(0xFFFFD700),
      'silver' => const Color(0xFFC0C0C0),
      'bronze' => const Color(0xFFCD7F32),
      _ => Colors.grey,
    };

    return GestureDetector(
      onTap: () => _showAchievementDetail(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked ? tierColor.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? tierColor.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked ? tierColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement['icon'] as IconData,
                color: isUnlocked ? tierColor : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['name'] as String,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (!isUnlocked && progress > 0)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(tierColor.withValues(alpha: 0.5)),
                minHeight: 4,
              ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(BuildContext context) {
    final isUnlocked = achievement['unlocked'] as bool;
    final tier = achievement['tier'] as String;
    final tierColor = switch (tier) {
      'gold' => const Color(0xFFFFD700),
      'silver' => const Color(0xFFC0C0C0),
      'bronze' => const Color(0xFFCD7F32),
      _ => Colors.grey,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isUnlocked ? tierColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: tierColor, width: 3),
              ),
              child: Icon(
                achievement['icon'] as IconData,
                color: isUnlocked ? tierColor : Colors.grey,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement['name'] as String,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['desc'] as String,
              style: GoogleFonts.inter(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tierColor),
              ),
              child: Text(
                '${tier.toUpperCase()} ACHIEVEMENT',
                style: GoogleFonts.inter(
                  color: tierColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isUnlocked)
              const Text('🏆 Achievement Unlocked!', style: TextStyle(fontSize: 18))
            else
              Text(
                'Keep training to unlock!',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
