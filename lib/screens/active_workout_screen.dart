import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import 'exercise_picker_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Map<String, bool> _expandedExercises = {};

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
          await ref.read(activeWorkoutProvider.notifier).finishWorkout();
          if (context.mounted) Navigator.pop(context);
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
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center, color: Color(0xFF00E676)),
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
      builder: (context) => _RestTimerDialog(),
    );
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    children: [
                      const SizedBox(width: 40, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 70, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 50, child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 50, child: Text('RPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weightKg?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            width: 70,
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
            width: 50,
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
            width: 50,
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
            style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold),
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
              color: _remaining <= 10 ? Colors.red : const Color(0xFF00E676),
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
                color: const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFFFFD700)),
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
