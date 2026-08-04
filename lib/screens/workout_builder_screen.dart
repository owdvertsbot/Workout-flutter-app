import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import 'exercise_picker_screen.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  ConsumerState<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  final _titleController = TextEditingController();
  String _selectedFolder = 'General';
  final List<_BuilderExercise> _exercises = [];
  bool _isDragging = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Builder'),
        actions: [
          TextButton.icon(
            onPressed: _saveRoutine,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Routine Name',
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                // Folder selector
                Row(
                  children: [
                    Text('Folder: ', style: GoogleFonts.inter(color: Colors.grey)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedFolder,
                      items: ['General', 'Push', 'Pull', 'Legs', 'Upper', 'Lower']
                          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedFolder = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Exercise List
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text('No exercises added', style: GoogleFonts.inter(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addExercise,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    onReorderStart: (_) => setState(() => _isDragging = true),
                    onReorderEnd: (_) => setState(() => _isDragging = false),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _exercises.removeAt(oldIndex);
                        _exercises.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _ExerciseBuilderCard(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        index: index,
                        onRemove: () => setState(() => _exercises.removeAt(index)),
                        onUpdate: (updated) => setState(() => _exercises[index] = updated),
                        isDragging: _isDragging,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercise,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
        backgroundColor: const Color(0xFF00E676),
      ),
    );
  }

  void _addExercise() async {
    final result = await Navigator.push<ExerciseModel>(
      context,
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );
    if (result != null) {
      setState(() {
        _exercises.add(_BuilderExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exercise: result,
          targetSets: 3,
          targetReps: 10,
          targetRpe: 8,
          restSeconds: 90,
          setType: SetType.working,
        ));
      });
    }
  }

  void _saveRoutine() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine name')),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }
    // Save logic here
    Navigator.pop(context);
  }
}

class _BuilderExercise {
  final String id;
  final ExerciseModel exercise;
  int targetSets;
  int targetReps;
  int targetRpe;
  int restSeconds;
  SetType setType;
  bool isSuperset;

  _BuilderExercise({
    required this.id,
    required this.exercise,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetRpe = 8,
    this.restSeconds = 90,
    this.setType = SetType.working,
    this.isSuperset = false,
  });
}

class _ExerciseBuilderCard extends StatelessWidget {
  final _BuilderExercise exercise;
  final int index;
  final VoidCallback onRemove;
  final Function(_BuilderExercise) onUpdate;
  final bool isDragging;

  const _ExerciseBuilderCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
    required this.isDragging,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text('${index + 1}', style: GoogleFonts.inter(color: const Color(0xFF00E676), fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.exercise.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      Text(exercise.exercise.muscleGroup ?? exercise.exercise.bodyPart, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (exercise.isSuperset)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Superset', style: TextStyle(fontSize: 10, color: Color(0xFF7C4DFF))),
                  ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'remove') onRemove();
                    if (v == 'superset') onUpdate(_BuilderExercise(
                      id: exercise.id, exercise: exercise.exercise,
                      targetSets: exercise.targetSets, targetReps: exercise.targetReps,
                      targetRpe: exercise.targetRpe, restSeconds: exercise.restSeconds,
                      setType: exercise.setType, isSuperset: !exercise.isSuperset,
                    ));
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'superset', child: Row(children: [Icon(Icons.link), SizedBox(width: 8), Text('Create Superset')])),
                    const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Remove', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TargetField(label: 'Sets', value: exercise.targetSets, onChanged: (v) => onUpdate(_BuilderExercise(id: exercise.id, exercise: exercise.exercise, targetSets: v, targetReps: exercise.targetReps, targetRpe: exercise.targetRpe, restSeconds: exercise.restSeconds, setType: exercise.setType, isSuperset: exercise.isSuperset))),
                const SizedBox(width: 12),
                _TargetField(label: 'Reps', value: exercise.targetReps, onChanged: (v) => onUpdate(_BuilderExercise(id: exercise.id, exercise: exercise.exercise, targetSets: exercise.targetSets, targetReps: v, targetRpe: exercise.targetRpe, restSeconds: exercise.restSeconds, setType: exercise.setType, isSuperset: exercise.isSuperset))),
                const SizedBox(width: 12),
                _TargetField(label: 'RPE', value: exercise.targetRpe, suffix: '/10', onChanged: (v) => onUpdate(_BuilderExercise(id: exercise.id, exercise: exercise.exercise, targetSets: exercise.targetSets, targetReps: exercise.targetReps, targetRpe: v, restSeconds: exercise.restSeconds, setType: exercise.setType, isSuperset: exercise.isSuperset))),
                const SizedBox(width: 12),
                _TargetField(label: 'Rest', value: exercise.restSeconds, suffix: 's', onChanged: (v) => onUpdate(_BuilderExercise(id: exercise.id, exercise: exercise.exercise, targetSets: exercise.targetSets, targetReps: exercise.targetReps, targetRpe: exercise.targetRpe, restSeconds: v, setType: exercise.setType, isSuperset: exercise.isSuperset))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetField extends StatelessWidget {
  final String label;
  final int value;
  final String? suffix;
  final Function(int) onChanged;

  const _TargetField({required this.label, required this.value, this.suffix, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: value > 1 ? () => onChanged(value - 1) : null, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                Expanded(child: Text('$value${suffix ?? ''}', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => onChanged(value + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
