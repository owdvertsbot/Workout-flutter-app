import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Character Card
            _CharacterCard(profile: profile),
            const SizedBox(height: 24),
            
            // Stats Allocation
            _StatsAllocation(profile: profile, ref: ref),
            const SizedBox(height: 24),
            
            // Achievements (placeholder)
            _AchievementsSection(),
            const SizedBox(height: 24),
            
            // Settings
            _SettingsSection(),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final PlayerProfileModel profile;

  const _CharacterCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientPurple, AppColors.gradientViolet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                '${profile.level}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Level ${profile.level} Adventurer',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getTitle(profile.level),
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          // XP Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Experience',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${profile.currentXp} / ${profile.xpToNextLevel} XP',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: profile.levelProgress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(profile.levelProgress * 100).toInt()}% to Level ${profile.level + 1}',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle(int level) {
    if (level >= 50) return 'Legendary Champion';
    if (level >= 40) return 'Master Warrior';
    if (level >= 30) return 'Elite Fighter';
    if (level >= 20) return 'Veteran Adventurer';
    if (level >= 10) return 'Skilled Warrior';
    if (level >= 5) return 'Apprentice';
    return 'Novice Trainee';
  }
}

class _StatsAllocation extends StatelessWidget {
  final PlayerProfileModel profile;
  final WidgetRef ref;

  const _StatsAllocation({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    final pointsAvailable = _getPointsAvailable(profile.level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Character Stats',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: pointsAvailable > 0 ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pointsAvailable points',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _StatRow(
              icon: Icons.fitness_center,
              name: 'Strength',
              value: profile.stats.strength,
              color: Colors.red,
              onIncrease: pointsAvailable > 0 ? () => _allocateStat('strength') : null,
            ),
            _StatRow(
              icon: Icons.flash_on,
              name: 'Dexterity',
              value: profile.stats.dexterity,
              color: Colors.yellow[700]!,
              onIncrease: pointsAvailable > 0 ? () => _allocateStat('dexterity') : null,
            ),
            _StatRow(
              icon: Icons.favorite,
              name: 'Vitality',
              value: profile.stats.vitality,
              color: Colors.green,
              onIncrease: pointsAvailable > 0 ? () => _allocateStat('vitality') : null,
            ),
            _StatRow(
              icon: Icons.battery_charging_full,
              name: 'Endurance',
              value: profile.stats.endurance,
              color: Colors.blue,
              onIncrease: pointsAvailable > 0 ? () => _allocateStat('endurance') : null,
            ),
          ],
        ),
      ),
    );
  }

  int _getPointsAvailable(int level) {
    // 1 point per level, max 5 per stat
    final totalPoints = level;
    final usedPoints = profile.stats.strength + 
                        profile.stats.dexterity + 
                        profile.stats.vitality + 
                        profile.stats.endurance;
    return (totalPoints - usedPoints).clamp(0, 100);
  }

  void _allocateStat(String stat) {
    // Would update through provider
    // This is a simplified version
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final int value;
  final Color color;
  final VoidCallback? onIncrease;

  const _StatRow({
    required this.icon,
    required this.name,
    required this.value,
    required this.color,
    this.onIncrease,
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
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$value',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onIncrease,
            icon: Icon(Icons.add_circle, color: onIncrease != null ? Colors.green : Colors.grey),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AchievementBadge(
                  icon: Icons.local_fire_department,
                  label: 'First Workout',
                  earned: false,
                ),
                _AchievementBadge(
                  icon: Icons.bolt,
                  label: '10 PRs',
                  earned: false,
                ),
                _AchievementBadge(
                  icon: Icons.star,
                  label: '7 Day Streak',
                  earned: false,
                ),
                _AchievementBadge(
                  icon: Icons.shield,
                  label: '100 Workouts',
                  earned: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool earned;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: earned ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: earned ? Colors.amber : Colors.grey,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: earned ? Colors.amber : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: earned ? Colors.black : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Default Rest Timer'),
            subtitle: const Text('90 seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
