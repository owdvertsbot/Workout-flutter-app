import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';

// Missions Screen (FDS 3.11)
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyQuests = ref.watch(dailyQuestsProvider);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh quests',
            onPressed: () {
              // In real app, would refresh quest data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quests refreshed!')),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab bar
            Container(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: const TabBar(
                tabs: [
                  Tab(text: 'Daily'),
                  Tab(text: 'Achievements'),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Daily Quests Tab
                  _QuestList(
                    quests: dailyQuests,
                    emptyIcon: Icons.today,
                    emptyMessage: 'No daily quests available',
                  ),
                  
                  // Achievements Tab
                  _AchievementsList(profile: profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  final List<QuestModel> quests;
  final IconData emptyIcon;
  final String emptyMessage;

  const _QuestList({
    required this.quests,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        return _QuestCard(quest: quest);
      },
    );
  }
}

class _QuestCard extends StatelessWidget {
  final QuestModel quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final progress = quest.progress;
    final isCompleted = quest.isCompleted;

    return Semantics(
      label: '${quest.title}. Progress: ${quest.currentValue} of ${quest.targetValue}. ${isCompleted ? "Completed" : ""}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: isCompleted ? Colors.green.withValues(alpha: 0.1) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Quest icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getQuestColor(quest.type).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getQuestIcon(quest.type),
                      color: _getQuestColor(quest.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quest.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    Text(
                      '+${quest.xpReward} XP',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(_getQuestColor(quest.type)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quest.currentValue}/${quest.targetValue}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestIcon(QuestType type) {
    switch (type) {
      case QuestType.completeWorkout:
        return Icons.fitness_center;
      case QuestType.logSets:
        return Icons.format_list_numbered;
      case QuestType.reachVolume:
        return Icons.fitness_center;
      case QuestType.maintainStreak:
        return Icons.local_fire_department;
      case QuestType.hitPR:
        return Icons.emoji_events;
      case QuestType.useApp:
        return Icons.apps;
    }
  }

  Color _getQuestColor(QuestType type) {
    switch (type) {
      case QuestType.completeWorkout:
        return Colors.blue;
      case QuestType.logSets:
        return Colors.green;
      case QuestType.reachVolume:
        return Colors.orange;
      case QuestType.maintainStreak:
        return Colors.red;
      case QuestType.hitPR:
        return Colors.amber;
      case QuestType.useApp:
        return Colors.purple;
    }
  }
}

class _AchievementsList extends StatelessWidget {
  final PlayerProfileModel profile;

  const _AchievementsList({required this.profile});

  @override
  Widget build(BuildContext context) {
    // Sample achievements - use streakDays and level as indicators
    final achievements = [
      _Achievement(
        title: 'First Steps',
        description: 'Complete your first workout',
        icon: Icons.directions_walk,
        isUnlocked: profile.streakDays >= 1,
      ),
      _Achievement(
        title: 'Consistent',
        description: 'Complete 7 consecutive days',
        icon: Icons.calendar_month,
        isUnlocked: profile.streakDays >= 7,
      ),
      _Achievement(
        title: 'Century Club',
        description: 'Reach level 10',
        icon: Icons.military_tech,
        isUnlocked: profile.level >= 10,
      ),
      _Achievement(
        title: 'Volume King',
        description: 'Lift 10,000 kg total volume',
        icon: Icons.fitness_center,
        isUnlocked: profile.totalVolumeKg >= 10000,
      ),
      _Achievement(
        title: 'Early Bird',
        description: 'Complete a workout before 7 AM',
        icon: Icons.wb_sunny,
        isUnlocked: false, // Would check workout times
      ),
      _Achievement(
        title: 'Night Owl',
        description: 'Complete a workout after 10 PM',
        icon: Icons.nightlight_round,
        isUnlocked: false,
      ),
      _Achievement(
        title: 'PR Crusher',
        description: 'Set 10 personal records',
        icon: Icons.trending_up,
        isUnlocked: false,
      ),
      _Achievement(
        title: 'Social Butterfly',
        description: 'Share your workout results',
        icon: Icons.share,
        isUnlocked: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementCard(achievement: achievement);
      },
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${achievement.title}. ${achievement.isUnlocked ? "Unlocked" : "Locked"}. ${achievement.description}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: achievement.isUnlocked ? Colors.amber.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked ? Colors.amber : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: achievement.isUnlocked ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: achievement.isUnlocked ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                achievement.isUnlocked ? Icons.lock_open : Icons.lock,
                color: achievement.isUnlocked ? Colors.amber : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
