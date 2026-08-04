// Custom exceptions for the app

/// Base exception class for all app exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when database operations fail
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code = 'DATABASE_ERROR',
    super.originalError,
  });
}

/// Exception thrown when a workout is not found
class WorkoutNotFoundException extends AppException {
  const WorkoutNotFoundException({
    super.message = 'Workout not found',
    super.code = 'WORKOUT_NOT_FOUND',
  });
}

/// Exception thrown when an exercise is not found
class ExerciseNotFoundException extends AppException {
  const ExerciseNotFoundException({
    super.message = 'Exercise not found',
    super.code = 'EXERCISE_NOT_FOUND',
  });
}

/// Exception thrown when workout plan is not found
class PlanNotFoundException extends AppException {
  const PlanNotFoundException({
    super.message = 'Workout plan not found',
    super.code = 'PLAN_NOT_FOUND',
  });
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.originalError,
  });
}

/// Exception thrown when asset loading fails
class AssetLoadException extends AppException {
  const AssetLoadException({
    required super.message,
    super.code = 'ASSET_LOAD_ERROR',
    super.originalError,
  });
}

/// Result type for operations that can fail
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

/// Extension methods for Result type
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(value: final v) => v,
    Failure<T>() => null,
  };

  AppException? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final e) => e,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppException error) onFailure,
  }) {
    return switch (this) {
      Success<T>(value: final v) => onSuccess(v),
      Failure<T>(error: final e) => onFailure(e),
    };
  }
}
