import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'core_providers.dart';

// Exercises provider
final exercisesProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final db = ref.watch(databaseProvider);
  final exercises = await db.getAllExercises();
  
  if (exercises.isEmpty) {
    // Load exercises from JSON if database is empty
    await ref.read(exerciseLoaderProvider.future);
    return db.getAllExercises().then((list) => list.map((e) => ExerciseModel(
      id: e.id,
      name: e.name,
      category: e.category,
      bodyPart: e.bodyPart,
      equipment: e.equipment,
      muscleGroup: e.muscleGroup,
      target: e.target,
    )).toList());
  }
  
  return exercises.map((e) => ExerciseModel(
    id: e.id,
    name: e.name,
    category: e.category,
    bodyPart: e.bodyPart,
    equipment: e.equipment,
    muscleGroup: e.muscleGroup,
    target: e.target,
  )).toList();
});

// Load exercises from JSON file
final exerciseLoaderProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  
  // Load exercises from assets
  final String jsonString = await rootBundle.loadString('assets/exercises.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  
  // Convert to database companions and insert
  final exercises = jsonList.map((e) => ExercisesCompanion(
    id: Value(e['id']?.toString() ?? ''),
    name: Value(e['name']?.toString() ?? ''),
    category: Value(e['category']?.toString() ?? ''),
    bodyPart: Value(e['bodyPart']?.toString() ?? ''),
    equipment: Value(e['equipment']?.toString() ?? ''),
    muscleGroup: Value(e['muscleGroup']?.toString()),
    secondaryMuscles: Value(e['secondaryMuscles'] != null ? json.encode(e['secondaryMuscles']) : null),
    target: Value(e['target']?.toString()),
    instructions: Value(e['instructions'] != null ? json.encode(e['instructions']) : null),
  )).toList();
  
  await db.insertExercises(exercises);
});

// Exercise search provider
final exerciseSearchProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = Provider<AsyncValue<List<ExerciseModel>>>((ref) {
  final exercisesAsync = ref.watch(exercisesProvider);
  final searchQuery = ref.watch(exerciseSearchProvider).toLowerCase();
  
  return exercisesAsync.whenData((exercises) {
    if (searchQuery.isEmpty) return exercises;
    return exercises.where((e) =>
      e.name.toLowerCase().contains(searchQuery) ||
      e.category.toLowerCase().contains(searchQuery) ||
      e.bodyPart.toLowerCase().contains(searchQuery)
    ).toList();
  });
});

// Exercise categories provider
final exerciseCategoriesProvider = Provider<List<String>>((ref) {
  final exercisesAsync = ref.watch(exercisesProvider);
  return exercisesAsync.maybeWhen(
    data: (exercises) {
      final categories = exercises.map((e) => e.category).toSet().toList();
      categories.sort();
      return categories;
    },
    orElse: () => [],
  );
});

// Equipment types provider
final equipmentTypesProvider = Provider<List<String>>((ref) {
  final exercisesAsync = ref.watch(exercisesProvider);
  return exercisesAsync.maybeWhen(
    data: (exercises) {
      final equipment = exercises.map((e) => e.equipment).toSet().toList();
      equipment.sort();
      return equipment;
    },
    orElse: () => [],
  );
});
