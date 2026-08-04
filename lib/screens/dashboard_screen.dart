import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import 'active_workout_screen.dart';
import 'history_screen.dart';

// Connectivity state provider
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hasNotification = true;
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications.addAll([
      {'title': 'Quest Complete!', 'body': 'You earned +100 XP', 'time': DateTime.now(), 'icon': Icons.emoji_events, 'color': const Color(0xFFFFD700)},
      {'title': 'New PR!', 'body': 'Hit a new bench press record', 'time': DateTime.now().subtract(const Duration(hours: 2)), 'icon': Icons.trending_up, 'color': const Color(0xFF00E676)},
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final quests = ref.watch(dailyQuestsProvider);
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final connectivity = ref.watch(connectivityProvider);

    // Check if offline
    final isOffline = connectivity.whenOrNull(
      data: (results) => results.isEmpty || results.contains(ConnectivityResult.none),
    ) ?? false;

    return Scaffold(
      body: Column(
        children: [
          // Offline banner
          if (isOffline) const OfflineBanner(),
          Expanded(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar with Avatar and Notifications (FDS 3.3)
                  SliverAppBar(
                    floating: true,
                    backgroundColor: const Color(0xFF121212),
                    toolbarHeight: 70,
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showProfileSheet(context, profile),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF7C4DFF), width: 2.5),
                              gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)]),
                            ),
                            child: Center(child: Text('${profile.level}', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(profile.characterTitle, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Level ${profile.level}', style: GoogleFonts.inter(color: const Color(0xFF7C4DFF), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Stack(
                        children: [
                          IconButton(icon: const Icon(Icons.notifications_outlined, size: 28), onPressed: () => _showNotificationsSheet(context)),
                          if (_hasNotification)
                            Positioned(right: 10, top: 10, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle))),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HeroBannerCard(profile: profile),
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Quick Start', action: TextButton(onPressed: () {}, child: const Text('Routines'))),
                        const SizedBox(height: 12),
                        _StartWorkoutCard(activeWorkout: activeWorkout),
                        const SizedBox(height: 12),
                        _RoutineCards(),
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Daily Missions', action: TextButton(onPressed: () {}, child: const Text('All Quests'))),
                        const SizedBox(height: 12),
                        ...quests.take(3).map((quest) => _QuestCard(quest: quest)),
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Weekly Summary'),
                        const SizedBox(height: 12),
                        _WeeklyHypertrophySummary(profile: profile),
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Recent Workouts', action: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())), child: const Text('See All'))),
                        const SizedBox(height: 12),
                        _RecentWorkoutsSection(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (context, scrollController) => Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Notifications', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () { setState(() => _hasNotification = false); Navigator.pop(context); }, child: const Text('Clear All')),
          ])),
          Expanded(child: _notifications.isEmpty ? Center(child: Text('No notifications', style: GoogleFonts.inter(color: Colors.grey))) : ListView.builder(
            controller: scrollController, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notif = _notifications[index];
              return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: (notif['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: (notif['color'] as Color).withValues(alpha: 0.3))),
                child: Row(children: [
                  Icon(notif['icon'] as IconData, color: notif['color'] as Color),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(notif['title'], style: GoogleFonts.inter(fontWeight: FontWeight.bold)), Text(notif['body'], style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))])),
                  Text(_formatTime(notif['time'] as DateTime), style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                ]));
            },
          )),
        ]),
      ),
    );
  }

  void _showProfileSheet(BuildContext context, PlayerProfileModel profile) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1E1E1E), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)]), boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.5), blurRadius: 20)]), child: Center(child: Text('${profile.level}', style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 16),
        Text(profile.characterTitle, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _ProfileStatRow('Total XP', '${profile.currentXp}'),
        _ProfileStatRow('XP to Next Level', '${profile.xpToNextLevel}'),
        _ProfileStatRow('Total Volume', '${(profile.totalVolumeKg / 1000).toStringAsFixed(1)}t'),
        _ProfileStatRow('Streak', '${profile.streakDays} days'),
        const SizedBox(height: 24),
      ]),
    ));
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _ProfileStatRow extends StatelessWidget {
  final String label; final String value;
  const _ProfileStatRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.inter(color: Colors.grey)), Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold))]));
}

class _HeroBannerCard extends StatelessWidget {
  final PlayerProfileModel profile;
  const _HeroBannerCard({required this.profile});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 10))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Level ${profile.level}', style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text(profile.characterTitle, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [const Icon(Icons.local_fire_department, color: Colors.orange, size: 24), const SizedBox(width: 4), Text('${profile.streakDays}', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
        ),
      ]),
      const SizedBox(height: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('XP Progress', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          Text('${profile.currentXp} / ${profile.xpToNextLevel}', style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: profile.levelProgress, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)), minHeight: 12)),
      ]),
    ]),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title; final Widget? action;
  const _SectionHeader({required this.title, this.action});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)), if (action != null) action!]);
}

class _StartWorkoutCard extends StatelessWidget {
  final WorkoutSessionModel? activeWorkout;
  const _StartWorkoutCard({this.activeWorkout});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen())),
      icon: const Icon(Icons.play_arrow_rounded, size: 28),
      label: Text(activeWorkout != null ? 'Resume Workout' : 'Start Empty Workout', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4),
    ),
  );
}

class _RoutineCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routines = [
      {'name': 'Push Day', 'exercises': 6, 'color': Colors.red},
      {'name': 'Pull Day', 'exercises': 5, 'color': Colors.blue},
      {'name': 'Leg Day', 'exercises': 7, 'color': Colors.green},
    ];
    return SizedBox(height: 100, child: ListView.builder(
      scrollDirection: Axis.horizontal, itemCount: routines.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return Container(width: 120, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add, color: Colors.grey, size: 32), const SizedBox(height: 4), Text('Create', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12))]));
        final routine = routines[index - 1];
        return Container(width: 140, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: (routine['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: (routine['color'] as Color).withValues(alpha: 0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(routine['name'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)), Text('${routine['exercises']} exercises', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12))]));
      },
    ));
  }
}

class _QuestCard extends ConsumerWidget {
  final QuestModel quest;
  const _QuestCard({required this.quest});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: quest.canClaim && !quest.isCompleted ? () => ref.read(dailyQuestsProvider.notifier).claimQuest(quest.id) : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(quest.isCompleted ? Icons.check_circle : Icons.emoji_events, color: const Color(0xFFFFD700))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(quest.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold))), if (quest.isCompleted) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text('✓', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 4),
          Row(children: [Expanded(child: LinearProgressIndicator(value: quest.progress, backgroundColor: Colors.grey[800], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)), minHeight: 6)), const SizedBox(width: 12), Text('${quest.currentValue}/${quest.targetValue}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))]),
        ])),
        const SizedBox(width: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(quest.isCompleted ? 'Claimed' : '+${quest.xpReward} XP', style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12))),
      ])),
    ),
  );
}

class _WeeklyHypertrophySummary extends ConsumerWidget {
  final PlayerProfileModel profile;
  const _WeeklyHypertrophySummary({required this.profile});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    
    return historyAsync.when(
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e'))),
      data: (workouts) {
        // Calculate last 7 days workout data
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekWorkouts = workouts.where((w) {
          return w.startTime.isAfter(weekStart) && w.status == WorkoutStatus.completed;
        }).toList();
        
        // Build week data (Mon-Sun)
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final weekData = List.generate(7, (index) {
          final dayDate = weekStart.add(Duration(days: index));
          return weekWorkouts.any((w) =>
            w.startTime.year == dayDate.year &&
            w.startTime.month == dayDate.month &&
            w.startTime.day == dayDate.day
          );
        });
        
        final workoutCount = weekWorkouts.length;
        
        return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(7, (index) {
            final hasWorkout = weekData[index];
            return Column(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: hasWorkout ? const Color(0xFF00E676).withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: hasWorkout ? Border.all(color: const Color(0xFF00E676), width: 2) : null), child: Icon(hasWorkout ? Icons.check : Icons.close, color: hasWorkout ? const Color(0xFF00E676) : Colors.grey, size: 20)),
              const SizedBox(height: 4),
              Text(days[index], style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
            ]);
          })),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _SummaryStatItem(value: '$workoutCount', label: 'Workouts', color: const Color(0xFF00E676)),
            _SummaryStatItem(value: '${(profile.totalVolumeKg / 1000).toStringAsFixed(1)}t', label: 'Total Volume', color: Colors.orange),
            _SummaryStatItem(value: '${profile.streakDays}', label: 'Day Streak', color: Colors.blue),
          ]),
        ])));
      },
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String value; final String label; final Color color;
  const _SummaryStatItem({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey))]);
}

class _RecentWorkoutsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (workouts) {
        if (workouts.isEmpty) return Card(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [Icon(Icons.fitness_center, size: 48, color: Colors.grey[600]), const SizedBox(height: 16), Text('No workouts yet', style: GoogleFonts.inter(color: Colors.grey[600])), const SizedBox(height: 8), Text('Start your first workout!', style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 12))])));
        return Column(children: workouts.take(3).map((workout) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.fitness_center, color: Color(0xFF00E676))),
          title: Text(workout.title ?? 'Workout', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          subtitle: Text(_formatDate(workout.startTime), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          trailing: Text(_formatDuration(workout.duration), style: GoogleFonts.inter(color: const Color(0xFF00E676), fontWeight: FontWeight.bold)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen())),
        ))).toList());
      },
    );
  }
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _formatDuration(Duration duration) { final hours = duration.inHours; final minutes = duration.inMinutes % 60; return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m'; }
}

// Shimmer loading placeholder widget (FDS 3.3)
class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF1E1E1E),
                Color(0xFF2A2A2A),
                Color(0xFF1E1E1E),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

// Offline state banner (FDS 3.3)
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            'Offline - Changes will sync when connected',
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

// Shimmer loading card for dashboard content
class ShimmerLoadingCard extends StatelessWidget {
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerPlaceholder(height: 20, width: 120),
            const SizedBox(height: 12),
            Row(
              children: [
                const ShimmerPlaceholder(width: 60, height: 14),
                const SizedBox(width: 8),
                const ShimmerPlaceholder(width: 40, height: 14),
                const Spacer(),
                ShimmerPlaceholder(
                  width: 60,
                  height: 32,
                  borderRadius: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
