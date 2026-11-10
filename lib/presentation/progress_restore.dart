import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/match3.dart';

const progressSaveKey = 'cloud_kingdom_progress_v2';
const legacyProgressSaveKey = 'cloud_kingdom_save_v1';

/// A recovery result never alters the active saved progress on a decode error.
class ProgressLoadResult {
  const ProgressLoadResult({
    required this.progress,
    required this.shouldPersistMigration,
    this.needsRecovery = false,
    this.backupAvailable = false,
  });

  final ProgressState progress;
  final bool shouldPersistMigration;
  final bool needsRecovery;
  final bool backupAvailable;
}

Future<bool> _backupUnreadableSave(
    SharedPreferences prefs, String key, String raw) async {
  final backupKey = '${key}_unreadable_backup';
  try {
    if (prefs.getString(backupKey) != null) return true;
    return await prefs.setString(backupKey, raw);
  } catch (error) {
    // The original value is still stored if the backup write fails.
    debugPrint('[SAVE] Unreadable-save backup failed (${error.runtimeType}).');
    return false;
  }
}

/// Restore current/legacy progress, or return a safe new-game state while
/// retaining the original unreadable bytes (and a best-effort local backup).
///
/// The caller only persists when shouldPersistMigration is true, ensuring a
/// corrupted saved game is never silently overwritten during app startup.
Future<ProgressLoadResult> restoreSavedProgress(SharedPreferences prefs) async {
  final saved = prefs.getString(progressSaveKey);
  if (saved != null) {
    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      final progress = ProgressState.fromJson(data);
      return ProgressLoadResult(
        progress: progress,
        shouldPersistMigration: (data['schema'] as num? ?? 0) < 3,
      );
    } catch (error) {
      final backup = await _backupUnreadableSave(prefs, progressSaveKey, saved);
      debugPrint(
          '[SAVE] Saved progress cannot be read (${error.runtimeType}).');
      return ProgressLoadResult(
        progress: ProgressState(),
        shouldPersistMigration: false,
        needsRecovery: true,
        backupAvailable: backup,
      );
    }
  }

  final legacy = prefs.getString(legacyProgressSaveKey);
  if (legacy != null) {
    try {
      final old = jsonDecode(legacy) as Map<String, dynamic>;
      final completed = (old['completed'] as List? ?? []).cast<int>();
      final oldStyle = old['loungeStyle'] as String?;
      final progress = ProgressState.fromJson({
        'completed': completed,
        'stars': completed,
        'best': old['best'] ?? <String, int>{},
        'coins': old['coins'] ?? 0,
        'loungeRestored':
            (old['loungeRestored'] as bool?) ?? (oldStyle != null),
        'loungeStyleId': switch (oldStyle) {
          'Classic Cloud' => 'classic_cloud',
          'Psychedelic' => 'psychedelic',
          'Retro 70s' => 'retro_70s',
          _ => null
        },
      });
      return ProgressLoadResult(
          progress: progress, shouldPersistMigration: true);
    } catch (error) {
      final backup =
          await _backupUnreadableSave(prefs, legacyProgressSaveKey, legacy);
      debugPrint(
          '[SAVE] Legacy progress cannot be read (${error.runtimeType}).');
      return ProgressLoadResult(
        progress: ProgressState(),
        shouldPersistMigration: false,
        needsRecovery: true,
        backupAvailable: backup,
      );
    }
  }

  return ProgressLoadResult(
      progress: ProgressState(), shouldPersistMigration: true);
}
