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

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final categories = ref.watch(exerciseCategoriesProvider);
    final equipment = ref.watch(equipmentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
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
          
          // Filters
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

class _ExerciseListTile extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExerciseListTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(exercise.category).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(exercise.category),
            color: _getCategoryColor(exercise.category),
          ),
        ),
        title: Text(
          exercise.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${exercise.category} • ${exercise.equipment}',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right),
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
                  backgroundColor: Colors.red.withOpacity(0.2),
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
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
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
        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
