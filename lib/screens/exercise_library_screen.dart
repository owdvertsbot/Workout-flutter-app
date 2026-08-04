import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String? _selectedCategory;
  String? _selectedEquipment;
  String? _selectedBodyPart; // FDS 3.5 - Body part filter
  bool _showFavoritesOnly = false; // FDS 3.5 - Favorites toggle

  // Body parts list
  final List<String> _bodyParts = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Core',
    'Legs',
    'Glutes',
  ];

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final categories = ref.watch(exerciseCategoriesProvider);
    final equipment = ref.watch(equipmentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          // Favorites toggle (FDS 3.5)
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            tooltip: 'Show favorites only',
            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                ref.read(exerciseSearchProvider.notifier).state = value;
              },
            ),
          ),
          
          // Body Part Filter Chips (FDS 3.5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _bodyParts.map((part) {
                final isSelected = _selectedBodyPart == part || (part == 'All' && _selectedBodyPart == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(part),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBodyPart = part == 'All' ? null : part;
                      });
                    },
                    selectedColor: const Color(0xFF00E676).withValues(alpha: 0.3),
                    checkmarkColor: const Color(0xFF00E676),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          
          // Category and Equipment Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Category Filter
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(width: 16),
                // Equipment Filter
                DropdownButton<String?>(
                  value: _selectedEquipment,
                  hint: const Text('Equipment'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Equipment')),
                    ...equipment.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  ],
                  onChanged: (value) => setState(() => _selectedEquipment = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Exercise List
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (exercises) {
                var filtered = exercises;
                if (_selectedCategory != null) {
                  filtered = filtered.where((e) => e.category == _selectedCategory).toList();
                }
                if (_selectedEquipment != null) {
                  filtered = filtered.where((e) => e.equipment == _selectedEquipment).toList();
                }
                // Body part filter (FDS 3.5)
                if (_selectedBodyPart != null) {
                  filtered = filtered.where((e) => 
                    e.bodyPart.toLowerCase().contains(_selectedBodyPart!.toLowerCase()) ||
                    e.muscleGroup?.toLowerCase().contains(_selectedBodyPart!.toLowerCase()) == true
                  ).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises found',
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return _ExerciseListTile(
                      exercise: exercise,
                      onTap: () => _showExerciseDetails(context, exercise),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ExerciseDetailsSheet(exercise: exercise),
    );
  }
}

class _ExerciseListTile extends StatefulWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExerciseListTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  State<_ExerciseListTile> createState() => _ExerciseListTileState();
}

class _ExerciseListTileState extends State<_ExerciseListTile> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: widget.onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(widget.exercise.category).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(widget.exercise.category),
            color: _getCategoryColor(widget.exercise.category),
          ),
        ),
        title: Text(
          widget.exercise.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${widget.exercise.category} • ${widget.exercise.equipment}',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite toggle (FDS 3.5)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'abs': return Colors.orange;
      case 'back': return Colors.blue;
      case 'cardio': return Colors.red;
      case 'chest': return Colors.purple;
      case 'legs': return Colors.green;
      case 'shoulders': return Colors.teal;
      case 'waist': return Colors.amber;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'abs': return Icons.accessibility_new;
      case 'back': return Icons.airline_seat_flat;
      case 'cardio': return Icons.directions_run;
      case 'chest': return Icons.fitness_center;
      case 'legs': return Icons.directions_walk;
      case 'shoulders': return Icons.person;
      case 'waist': return Icons.straighten;
      default: return Icons.fitness_center;
    }
  }
}

class _ExerciseDetailsSheet extends StatelessWidget {
  final ExerciseModel exercise;

  const _ExerciseDetailsSheet({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                exercise.name,
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Info Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _InfoChip(label: 'Category', value: exercise.category.toUpperCase()),
                  _InfoChip(label: 'Body Part', value: exercise.bodyPart.toUpperCase()),
                  _InfoChip(label: 'Equipment', value: exercise.equipment),
                ],
              ),
              const SizedBox(height: 24),
              
              // Muscle Groups
              if (exercise.muscleGroup != null) ...[
                Text(
                  'Target Muscle',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(exercise.muscleGroup!),
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
              ],
              
              if (exercise.secondaryMuscles.isNotEmpty) ...[
                Text(
                  'Secondary Muscles',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: exercise.secondaryMuscles.map((m) => Chip(
                    label: Text(m),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // 1RM Calculator (FDS 3.6)
              const SizedBox(height: 16),
              _OneRMCalculatorSection(),
              
              // Instructions
              if (exercise.instructions != null && exercise.instructions!.isNotEmpty) ...[
                Text(
                  'Instructions',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...exercise.instructions!.entries.take(5).toList().asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value.value,
                            style: GoogleFonts.inter(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// 1RM Calculator Section (FDS 3.6)
class _OneRMCalculatorSection extends StatefulWidget {
  @override
  State<_OneRMCalculatorSection> createState() => _OneRMCalculatorSectionState();
}

class _OneRMCalculatorSectionState extends State<_OneRMCalculatorSection> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController(text: '5');
  double? _calculatedOneRM;

  // Brzycki formula for 1RM calculation
  double _calculateOneRM(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (36 / (37 - reps));
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    
    if (weight != null && reps != null && reps > 0 && reps <= 12) {
      setState(() {
        _calculatedOneRM = _calculateOneRM(weight, reps);
      });
    } else {
      setState(() {
        _calculatedOneRM = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF00E676).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: const Color(0xFF00E676), size: 20),
                const SizedBox(width: 8),
                Text(
                  '1RM Calculator',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _updateCalculation(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _updateCalculation(),
                  ),
                ),
              ],
            ),
            if (_calculatedOneRM != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated 1RM',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_calculatedOneRM!.toStringAsFixed(1)} kg',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E676),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on Brzycki formula',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
