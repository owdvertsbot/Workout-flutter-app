import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../core/errors.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// UUID generator
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// Error state provider for UI feedback
final appErrorProvider = StateProvider<AppException?>((ref) => null);

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => false);
