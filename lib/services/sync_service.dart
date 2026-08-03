import 'dart:async';
import 'package:flutter/foundation.dart';

/// Sync service for background synchronization (FDS Section 9)
/// Implements local-first operations with background sync queue
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool _isInitialized = false;
  Timer? _syncTimer;
  final List<_SyncOperation> _pendingOperations = [];
  
  // Retry intervals as per FDS: 5s, 15s, 45s, 2m, 5m, 15m
  final List<Duration> _retryIntervals = const [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 45),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  /// Initialize the sync service
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startBackgroundSync();
  }

  /// Start background sync polling
  void _startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _processSyncQueue();
    });
  }

  /// Add operation to sync queue (FDS 9.1 step 4)
  Future<void> queueOperation({
    required String entityType,
    required String operation,
    required String payload,
  }) async {
    _pendingOperations.add(_SyncOperation(
      entityType: entityType,
      operation: operation,
      payload: payload,
      retryCount: 0,
      status: _SyncStatus.pending,
    ));
    
    // Process immediately if online
    _processSyncQueue();
  }

  /// Process sync queue (FDS 9.1 steps 5-6)
  Future<void> _processSyncQueue() async {
    if (_pendingOperations.isEmpty) return;
    
    final pendingOps = _pendingOperations.where((op) => op.status == _SyncStatus.pending).toList();
    
    for (final op in pendingOps) {
      try {
        // Simulate API call
        await _transmitToServer(op);
        
        // Success - mark as completed
        op.status = _SyncStatus.completed;
        _pendingOperations.remove(op);
        
        debugPrint('SyncService: Successfully synced ${op.entityType}');
      } catch (e) {
        // Failure - implement exponential backoff (FDS 9.2)
        op.retryCount++;
        
        if (op.retryCount >= _retryIntervals.length) {
          op.status = _SyncStatus.failed;
          debugPrint('SyncService: Max retries reached for ${op.entityType}');
        } else {
          // Schedule retry with exponential backoff
          _scheduleRetry(op);
        }
      }
    }
  }

  Future<void> _transmitToServer(_SyncOperation op) async {
    // In production, this would make HTTPS POST to cloud API
    // Using encrypted JSON payloads per FDS 9.1
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simulate occasional failures for testing
    // throw Exception('Network error');
  }

  void _scheduleRetry(_SyncOperation op) {
    final delay = _retryIntervals[op.retryCount.clamp(0, _retryIntervals.length - 1)];
    Timer(delay, () => _processSyncQueue());
  }

  /// Conflict resolution using Last-Write-Wins (FDS 9.2)
  String resolveConflict(String localValue, String remoteValue, DateTime localTime, DateTime remoteTime) {
    // Deterministic LWW - higher timestamp wins
    return localTime.isAfter(remoteTime) ? localValue : remoteValue;
  }

  /// Dispose sync service
  void dispose() {
    _syncTimer?.cancel();
    _isInitialized = false;
  }
}

enum _SyncStatus { pending, completed, failed }

class _SyncOperation {
  final String entityType;
  final String operation;
  final String payload;
  int retryCount;
  _SyncStatus status;

  _SyncOperation({
    required this.entityType,
    required this.operation,
    required this.payload,
    this.retryCount = 0,
    this.status = _SyncStatus.pending,
  });
}

// Helper for debug printing
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
