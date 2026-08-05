import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Exercise table
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get bodyPart => text()();
  TextColumn get equipment => text()();
  TextColumn get muscleGroup => text().nullable()();
  TextColumn get secondaryMuscles => text().nullable()(); // JSON array
  TextColumn get target => text().nullable()();
  TextColumn get instructions => text().nullable()(); // JSON object
  
  @override
  Set<Column> get primaryKey => {id};
}

// Workout session table
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get status => text()(); // IN_PROGRESS, COMPLETED, ABANDONED
  TextColumn get templateId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Set entries table
class SetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(WorkoutSessions, #id)();
  TextColumn get exerciseId => text()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get rpe => integer().nullable()(); // Rate of Perceived Exertion 1-10
  TextColumn get setType => text()(); // WARMUP, WORKING, DROP_SET, FAILURE
  TextColumn get notes => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Player profile table
class PlayerProfiles extends Table {
  TextColumn get id => text()();
  IntColumn get currentLevel => integer().withDefault(const Constant(1))();
  IntColumn get currentXp => integer().withDefault(const Constant(0))();
  RealColumn get totalVolumeKg => real().withDefault(const Constant(0))();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWorkoutDate => dateTime().nullable()();
  TextColumn get allocatedStats => text().nullable()(); // JSON {str, dex, vit, end}
  
  @override
  Set<Column> get primaryKey => {id};
}

// Personal records table
class PersonalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseId => text()();
  TextColumn get recordType => text()(); // ALL_TIME_WEIGHT, ROLLING_2MONTH_WEIGHT, VOLUME_PR
  RealColumn get value => real()();
  DateTimeColumn get achievedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Sync queue table
class SyncQueueEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payload => text()(); // JSON
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // PENDING, FAILED
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Exercises, WorkoutSessions, SetEntries, PlayerProfiles, PersonalRecords, SyncQueueEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Incremented for migration support

  // Migration strategy for future schema changes
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will be handled here
        // Example:
        // if (from < 2) {
        //   await m.addColumn(exercises, exercises.newColumn);
        // }
        if (from < 2) {
          // Migration from v1 to v2 would go here
          // Currently no changes needed, but framework is in place
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Exercise queries
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  
  Future<Exercise?> getExerciseById(String id) =>
      (select(exercises)..where((e) => e.id.equals(id))).getSingleOrNull();
  
  Future<List<Exercise>> searchExercises(String query) =>
      (select(exercises)..where((e) => e.name.like('%$query%'))).get();
  
  Future<void> insertExercise(ExercisesCompanion exercise) =>
      into(exercises).insert(exercise, mode: InsertMode.insertOrReplace);
  
  Future<void> insertExercises(List<ExercisesCompanion> exerciseList) async {
    await batch((batch) {
      batch.insertAll(exercises, exerciseList, mode: InsertMode.insertOrReplace);
    });
  }

  // Workout session queries
  Future<List<WorkoutSession>> getAllWorkouts() =>
      (select(workoutSessions)..orderBy([(s) => OrderingTerm.desc(s.startTime)])).get();
  
  Future<WorkoutSession?> getActiveWorkout() =>
      (select(workoutSessions)..where((s) => s.status.equals('IN_PROGRESS'))).getSingleOrNull();
  
  Future<void> insertWorkoutSession(WorkoutSessionsCompanion session) =>
      into(workoutSessions).insert(session);
  
  Future<void> updateWorkoutSession(WorkoutSessionsCompanion session) =>
      (update(workoutSessions)..where((s) => s.id.equals(session.id.value)))
          .write(session);

  // Set entry queries
  Future<List<SetEntry>> getSetsForSession(String sessionId) =>
      (select(setEntries)..where((s) => s.sessionId.equals(sessionId))).get();
  
  Future<List<SetEntry>> getPreviousSetsForExercise(String exerciseId, {int limit = 10}) =>
      (select(setEntries)
        ..where((s) => s.exerciseId.equals(exerciseId) & s.isCompleted.equals(true))
        ..orderBy([(s) => OrderingTerm.desc(s.completedAt)])
        ..limit(limit))
      .get();
  
  Future<void> insertSetEntry(SetEntriesCompanion entry) =>
      into(setEntries).insert(entry);
  
  Future<void> updateSetEntry(SetEntriesCompanion entry) =>
      (update(setEntries)..where((s) => s.id.equals(entry.id.value))).write(entry);

  // Player profile queries
  Future<PlayerProfile?> getPlayerProfile() =>
      select(playerProfiles).getSingleOrNull();
  
  Future<void> upsertPlayerProfile(PlayerProfilesCompanion profile) =>
      into(playerProfiles).insertOnConflictUpdate(profile);

  // Personal records queries
  Future<List<PersonalRecord>> getPRsForExercise(String exerciseId) =>
      (select(personalRecords)..where((r) => r.exerciseId.equals(exerciseId))).get();
  
  Future<void> upsertPersonalRecord(PersonalRecordsCompanion record) =>
      into(personalRecords).insertOnConflictUpdate(record);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rpg_workout.db'));
    return NativeDatabase.createInBackground(file);
  });
}
