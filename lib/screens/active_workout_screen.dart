import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import 'exercise_picker_screen.dart';
import 'workout_summary_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Map<String, bool> _expandedExercises = {};
  
  // Rest timer state for floating overlay (FDS 3.4)
  bool _isRestTimerVisible = false;
  int _restTimeRemaining = 0;
  bool _isRestPaused = false;

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeWorkoutProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No active workout',
                style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(activeWorkoutProvider.notifier).startWorkout();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Workout'),
              ),
            ],
          ),
        ),
      );
    }

    // Group sets by exercise
    final exerciseIds = workout.exerciseIds;
    final exerciseSets = <String, List<SetEntryModel>>{};
    for (final set in workout.sets) {
      exerciseSets.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.minimize),
          tooltip: 'Minimize to mini player',
          onPressed: () => _showMiniPlayer(context),
        ),
        title: Text(workout.title ?? 'Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => _showRestTimerDialog(context),
            tooltip: 'Rest Timer',
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => _showPlateCalculator(context),
            tooltip: 'Plate Calculator',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'add_exercise', child: Text('Add Exercise')),
              const PopupMenuItem(value: 'superset', child: Text('Create Superset')),
              const PopupMenuItem(value: 'finish', child: Text('Finish Workout')),
              const PopupMenuItem(value: 'abandon', child: Text('Abandon Workout', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Floating Rest Timer Overlay (FDS 3.4)
          if (_isRestTimerVisible)
            _FloatingRestTimerOverlay(
              timeRemaining: _restTimeRemaining,
              isPaused: _isRestPaused,
              onAddTime: () => setState(() => _restTimeRemaining += 30),
              onSubtractTime: () => setState(() => _restTimeRemaining = (_restTimeRemaining - 15).clamp(0, 999)),
              onSkip: () => setState(() => _isRestTimerVisible = false),
              onTogglePause: () => setState(() => _isRestPaused = !_isRestPaused),
            ),
          
          // Workout Stats Bar
          _WorkoutStatsBar(workout: workout),
          
          // Exercise List
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (exercises) {
                if (exerciseIds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Add exercises to start',
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToExercisePicker(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exerciseIds.length,
                  itemBuilder: (context, index) {
                    final exerciseId = exerciseIds[index];
                    final sets = exerciseSets[exerciseId] ?? [];
                    final exercise = exercises.firstWhere(
                      (e) => e.id == exerciseId,
                      orElse: () => ExerciseModel(id: exerciseId, name: 'Unknown', category: '', bodyPart: '', equipment: ''),
                    );
                    
                    _expandedExercises.putIfAbsent(exerciseId, () => true);

                    return _ExerciseCard(
                      exercise: exercise,
                      sets: sets,
                      isExpanded: _expandedExercises[exerciseId] ?? true,
                      onToggleExpand: () {
                        setState(() {
                          _expandedExercises[exerciseId] = !(_expandedExercises[exerciseId] ?? true);
                        });
                      },
                      onAddSet: () => ref.read(activeWorkoutProvider.notifier).addSetToExercise(exerciseId),
                      onCompleteSet: (setId) async {
                        HapticFeedback.mediumImpact();
                        await ref.read(activeWorkoutProvider.notifier).completeSet(setId);
                      },
                      onUpdateSet: (set) => ref.read(activeWorkoutProvider.notifier).updateSet(set),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToExercisePicker(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToExercisePicker(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );
    if (result != null && mounted) {
      await ref.read(activeWorkoutProvider.notifier).addExercise(result);
    }
  }

  void _handleMenuAction(String action, BuildContext context) async {
    switch (action) {
      case 'add_exercise':
        _navigateToExercisePicker(context);
        break;
      case 'superset':
        _showSupersetDialog(context);
        break;
      case 'finish':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Finish Workout?'),
            content: const Text('Great job! Save this workout and earn XP.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finish')),
            ],
          ),
        );
        if (confirm == true) {
          // Finish workout - notifier returns completion result with calculated XP
          final result = await ref.read(activeWorkoutProvider.notifier).finishWorkout();
          
          if (result != null && context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutSummaryScreen(
                  workout: result.workout,
                  totalXpEarned: result.xpEarned,
                  xpFromSets: (result.workout.totalVolume / 100).round(),
                  prBonusXp: 0,
                  leveledUp: result.leveledUp,
                  newLevel: result.levelAfter,
                ),
              ),
            );
          }
        }
        break;
      case 'abandon':
        final confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // FDS: Non-dismissible by background tap
          builder: (context) => AlertDialog(
            title: const Text('Abandon Workout?'),
            content: const Text('This workout will not be saved.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Abandon'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(activeWorkoutProvider.notifier).abandonWorkout();
          if (context.mounted) Navigator.pop(context);
        }
        break;
    }
  }

  void _showMiniPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Workout in Progress', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  Text('Tap to resume', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSupersetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Superset'),
        content: const Text('Select exercises to combine into a superset. They will alternate during your workout.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Create')),
        ],
      ),
    );
  }

  void _showRestTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RestTimerDialog(
        onStartFloating: (seconds) {
          setState(() {
            _restTimeRemaining = seconds;
            _isRestTimerVisible = true;
            _isRestPaused = false;
          });
          Navigator.pop(context); // Close dialog
          _startFloatingTimer();
        },
      ),
    );
  }

  void _startFloatingTimer() async {
    while (_restTimeRemaining > 0 && _isRestTimerVisible) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRestPaused && mounted) {
        setState(() {
          _restTimeRemaining--;
          if (_restTimeRemaining <= 0) {
            _isRestTimerVisible = false;
          }
        });
      }
    }
  }

  void _showPlateCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _PlateCalculatorSheet(),
    );
  }
}

class _WorkoutStatsBar extends StatelessWidget {
  final WorkoutSessionModel workout;

  const _WorkoutStatsBar({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.timer_outlined,
            value: _formatDuration(workout.duration),
            label: 'Duration',
          ),
          _StatItem(
            icon: Icons.check_circle_outline,
            value: '${workout.completedSets}',
            label: 'Sets',
          ),
          _StatItem(
            icon: Icons.bolt,
            value: '${workout.totalXp}',
            label: 'XP',
          ),
          _StatItem(
            icon: Icons.fitness_center,
            value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}t',
            label: 'Volume',
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final List<SetEntryModel> sets;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddSet;
  final Function(String) onCompleteSet;
  final Function(SetEntryModel) onUpdateSet;

  const _ExerciseCard({
    required this.exercise,
    required this.sets,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onAddSet,
    required this.onCompleteSet,
    required this.onUpdateSet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Exercise Header
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sets.where((s) => s.isCompleted).length}/${sets.length} sets',
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Options menu (FDS 3.4)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    tooltip: 'Options',
                    onSelected: (value) {
                      // Handle options - would call back to parent
                      debugPrint('Selected: $value');
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'replace',
                        child: Row(children: [
                          Icon(Icons.swap_horiz, size: 20),
                          SizedBox(width: 8),
                          Text('Replace'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'reorder',
                        child: Row(children: [
                          Icon(Icons.reorder, size: 20),
                          SizedBox(width: 8),
                          Text('Reorder'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'note',
                        child: Row(children: [
                          Icon(Icons.note_add, size: 20),
                          SizedBox(width: 8),
                          Text('Add Note'),
                        ]),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          
          // Sets Table
          if (isExpanded) ...[
            const Divider(height: 1),
            // Historical Baseline Header (FDS 3.4)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.amber.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.history, size: 14, color: Colors.amber[700]),
                  const SizedBox(width: 6),
                  Text(
                    'Last Session: 80 kg × 8 reps',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.amber[700]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header Row with Previous column (FDS 3.4)
                  Row(
                    children: [
                      const SizedBox(width: 40, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 60, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 45, child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 45, child: Text('RPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 55, child: Text('Prev', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.xpGold))),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Set Rows
                  ...sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    return _SetRow(
                      setNumber: index + 1,
                      set: set,
                      onComplete: () => onCompleteSet(set.id),
                      onUpdate: onUpdateSet,
                    );
                  }),
                  
                  // Add Set Button
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onAddSet,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Set'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final int setNumber;
  final SetEntryModel set;
  final VoidCallback onComplete;
  final Function(SetEntryModel) onUpdate;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.onComplete,
    required this.onUpdate,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> with SingleTickerProviderStateMixin {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late AnimationController _prShimmerController;
  late Animation<double> _prShimmerAnimation;
  
  // Sample previous value (would come from database in real implementation)
  final String _previousValue = '80×8';

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weightKg?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
    
    // PR shimmer animation (FDS 3.4, 10.3)
    _prShimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _prShimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_prShimmerController);
    
    // Auto-play shimmer when set is completed (simulating PR detection)
    if (widget.set.isCompleted) {
      _prShimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start shimmer when completed
    if (widget.set.isCompleted && !oldWidget.set.isCompleted) {
      _prShimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _prShimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPR = widget.set.isCompleted; // In real app, check against PR database
    
    return AnimatedBuilder(
      animation: _prShimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: isPR
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.amber.withOpacity(0.3 * _prShimmerAnimation.value),
                      Colors.transparent,
                    ],
                    stops: [
                      (_prShimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _prShimmerAnimation.value,
                      (_prShimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Semantics(
            label: 'Set ${widget.setNumber}, ${widget.set.weightKg ?? 'unspecified'} kilograms, ${widget.set.reps ?? 'unspecified'} reps. Double-tap to mark completed.',
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${widget.setNumber}${_getSetSuffix(widget.setNumber)}',
                    style: TextStyle(
                      color: widget.set.setType == SetType.warmup ? Colors.orange :
                             widget.set.setType == SetType.dropSet ? Colors.purple :
                             widget.set.setType == SetType.failure ? Colors.red : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      hintText: 'kg',
                    ),
                    onChanged: (value) {
                      final weight = double.tryParse(value);
                      widget.onUpdate(widget.set.copyWith(weightKg: weight));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    onChanged: (value) {
                      final reps = int.tryParse(value);
                      widget.onUpdate(widget.set.copyWith(reps: reps));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 45,
                  child: DropdownButton<int?>(
                    value: widget.set.rpe,
                    isDense: true,
                    hint: const Text('-', style: TextStyle(fontSize: 12)),
                    items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((rpe) => DropdownMenuItem(
                      value: rpe,
                      child: Text('$rpe', style: const TextStyle(fontSize: 12)),
                    )).toList(),
                    onChanged: (value) {
                      widget.onUpdate(widget.set.copyWith(rpe: value));
                    },
                  ),
                ),
                // Previous Value Column (FDS 3.4)
                SizedBox(
                  width: 55,
                  child: Text(
                    _previousValue,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.amber[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.set.isCompleted ? null : widget.onComplete,
                  icon: Icon(
                    widget.set.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    color: widget.set.isCompleted ? Colors.green : Colors.grey,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSetSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}

class _RestTimerDialog extends StatefulWidget {
  final Function(int)? onStartFloating;
  
  const _RestTimerDialog({this.onStartFloating});
  
  @override
  State<_RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<_RestTimerDialog> {
  int _selectedSeconds = 90;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rest Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_selectedSeconds ~/ 60}:${(_selectedSeconds % 60).toString().padLeft(2, '0')}',
            style: GoogleFonts.jetBrainsMono(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [60, 90, 120, 180, 300].map((seconds) => ChoiceChip(
              label: Text('${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'),
              selected: _selectedSeconds == seconds,
              onSelected: (selected) {
                if (selected) setState(() => _selectedSeconds = seconds);
              },
            )).toList(),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              if (widget.onStartFloating != null) {
                widget.onStartFloating!(_selectedSeconds);
              }
            },
            icon: const Icon(Icons.picture_in_picture_alt),
            label: const Text('Show as Floating Timer'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _startTimer(context);
          },
          child: const Text('Start'),
        ),
      ],
    );
  }

  void _startTimer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RunningTimerDialog(seconds: _selectedSeconds),
    );
  }
}

class _RunningTimerDialog extends StatefulWidget {
  final int seconds;
  
  const _RunningTimerDialog({required this.seconds});

  @override
  State<_RunningTimerDialog> createState() => _RunningTimerDialogState();
}

class _RunningTimerDialogState extends State<_RunningTimerDialog> {
  late int _remaining;
  late int _initialSeconds;
  
  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _initialSeconds = widget.seconds;
    _tick();
  }

  void _tick() async {
    while (_remaining > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _remaining--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rest Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer display
          Text(
            '${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: _remaining <= 10 ? Colors.red : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          // +30s / -15s adjustment buttons (FDS 3.4)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _remaining += 30),
                child: const Text('+30s'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _remaining > 15 ? () => setState(() => _remaining -= 15) : null,
                child: const Text('-15s'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Time elapsed / total
          Text(
            'of ${_initialSeconds}s',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          if (_remaining == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.xpGold),
                  SizedBox(width: 8),
                  Text("Time's up!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Skip Rest button (FDS 3.4)
        if (_remaining > 0)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip Rest'),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

// Floating Rest Timer Overlay (FDS 3.4)
class _FloatingRestTimerOverlay extends StatelessWidget {
  final int timeRemaining;
  final bool isPaused;
  final VoidCallback onAddTime;
  final VoidCallback onSubtractTime;
  final VoidCallback onSkip;
  final VoidCallback onTogglePause;

  const _FloatingRestTimerOverlay({
    required this.timeRemaining,
    required this.isPaused,
    required this.onAddTime,
    required this.onSubtractTime,
    required this.onSkip,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaused
              ? [Colors.grey[800]!, Colors.grey[900]!]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REST',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Time display
                Text(
                  '${timeRemaining ~/ 60}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // +30s button
                _TimerButton(
                  icon: Icons.add,
                  label: '30s',
                  onPressed: onAddTime,
                  isSmall: true,
                ),
                const SizedBox(width: 8),
                // -15s button
                _TimerButton(
                  icon: Icons.remove,
                  label: '15s',
                  onPressed: onSubtractTime,
                  isSmall: true,
                ),
                const SizedBox(width: 16),
                // Pause/Play button
                IconButton(
                  onPressed: onTogglePause,
                  icon: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(width: 16),
                // Skip button
                _TimerButton(
                  icon: Icons.skip_next,
                  label: 'Skip',
                  onPressed: onSkip,
                  isSmall: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSmall;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 6 : 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: isSmall ? 16 : 20, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlateCalculatorSheet extends StatefulWidget {
  const _PlateCalculatorSheet();

  @override
  State<_PlateCalculatorSheet> createState() => _PlateCalculatorSheetState();
}

class _PlateCalculatorSheetState extends State<_PlateCalculatorSheet> {
  double _barWeight = 20;
  double _targetWeight = 60;
  
  final List<double> _availablePlates = [25, 20, 15, 10, 5, 2.5, 1.25];

  @override
  Widget build(BuildContext context) {
    final plateWeight = (_targetWeight - _barWeight) / 2;
    final plates = <double>[];
    var remaining = plateWeight;
    
    for (final plate in _availablePlates) {
      while (remaining >= plate) {
        plates.add(plate);
        remaining -= plate;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Plate Calculator', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bar Weight'),
                    Slider(
                      value: _barWeight,
                      min: 0,
                      max: 25,
                      divisions: 5,
                      label: '${_barWeight}kg',
                      onChanged: (v) => setState(() => _barWeight = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Weight'),
                    Slider(
                      value: _targetWeight,
                      min: _barWeight,
                      max: 300,
                      divisions: 56,
                      label: '${_targetWeight.toInt()}kg',
                      onChanged: (v) => setState(() => _targetWeight = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Visual Barbell (FDS Plate Calculator)
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left collar
                Container(width: 8, height: 16, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                // Left plates (mirrored)
                ...plates.reversed.map((plate) => _PlateWidget(weight: plate)),
                // Bar
                Container(width: 60, height: 12, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(6))),
                // Right plates
                ...plates.map((plate) => _PlateWidget(weight: plate)),
                const SizedBox(width: 4),
                // Right collar
                Container(width: 8, height: 16, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Per Side: ${plates.isEmpty ? "Bar only" : plates.join(" + ")}',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${_barWeight + plateWeight * 2}kg',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plates.map((p) => Chip(
              label: Text('${p}kg'),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PlateWidget extends StatelessWidget {
  final double weight;
  const _PlateWidget({required this.weight});

  @override
  Widget build(BuildContext context) {
    final height = _getPlateHeight(weight);
    final color = _getPlateColor(weight);
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(2), right: Radius.circular(2)),
      ),
    );
  }

  double _getPlateHeight(double weight) {
    if (weight >= 25) return 70;
    if (weight >= 20) return 65;
    if (weight >= 15) return 55;
    if (weight >= 10) return 50;
    if (weight >= 5) return 40;
    if (weight >= 2.5) return 30;
    return 25;
  }

  Color _getPlateColor(double weight) {
    if (weight >= 25) return Colors.red;
    if (weight >= 20) return Colors.blue;
    if (weight >= 15) return Colors.yellow;
    if (weight >= 10) return Colors.green;
    if (weight >= 5) return Colors.white;
    if (weight >= 2.5) return Colors.red[300]!;
    return Colors.grey;
  }
}
