import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local datasource for caching form configuration data
/// Uses SharedPreferences for persistent local storage
class LocalFormDatasource {
  final SharedPreferences _prefs;

  LocalFormDatasource(this._prefs);

  /// Cache form configuration locally
  Future<void> cacheFormConfig(
    String professionId,
    Map<String, dynamic> config,
  ) async {
    try {
      final key = _getCacheKey(professionId);
      final jsonString = jsonEncode(config);
      await _prefs.setString(key, jsonString);

      // Save timestamp
      final timestampKey = _getTimestampKey(professionId);
      await _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching form config for $professionId: $e');
      rethrow;
    }
  }

  /// Get cached form configuration
  Future<Map<String, dynamic>?> getCachedFormConfig(String professionId) async {
    try {
      final key = _getCacheKey(professionId);
      final jsonString = _prefs.getString(key);

      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting cached form config for $professionId: $e');
      return null;
    }
  }

  /// Check if cached config is valid
  Future<bool> isCacheValid(String professionId, {int maxAgeHours = 24}) async {
    try {
      final timestampKey = _getTimestampKey(professionId);
      final timestamp = _prefs.getInt(timestampKey);

      if (timestamp == null) return false;

      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = maxAgeHours * 60 * 60 * 1000;

      return cacheAge < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// Cache shared data
  Future<void> cacheSharedData(String path, List<String> data) async {
    try {
      final key = _getSharedDataKey(path);
      await _prefs.setStringList(key, data);

      // Save timestamp
      final timestampKey = _getSharedDataTimestampKey(path);
      await _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching shared data for $path: $e');
      rethrow;
    }
  }

  /// Get cached shared data
  Future<List<String>?> getCachedSharedData(String path) async {
    try {
      final key = _getSharedDataKey(path);
      return _prefs.getStringList(key);
    } catch (e) {
      print('Error getting cached shared data for $path: $e');
      return null;
    }
  }

  /// Check if shared data cache is valid
  Future<bool> isSharedDataCacheValid(String path, {int maxAgeHours = 168}) async {
    try {
      final timestampKey = _getSharedDataTimestampKey(path);
      final timestamp = _prefs.getInt(timestampKey);

      if (timestamp == null) return false;

      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = maxAgeHours * 60 * 60 * 1000;

      return cacheAge < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// Clear cache for specific profession
  Future<void> clearCache(String professionId) async {
    try {
      await _prefs.remove(_getCacheKey(professionId));
      await _prefs.remove(_getTimestampKey(professionId));
    } catch (e) {
      print('Error clearing cache for $professionId: $e');
    }
  }

  /// Clear all form config caches
  Future<void> clearAllCaches() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('form_config_') || key.startsWith('shared_data_')) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing all caches: $e');
    }
  }

  /// Cache form submission data (for offline support)
  Future<void> cacheFormSubmission(
    String userId,
    String professionId,
    Map<String, dynamic> formData,
  ) async {
    try {
      final key = 'form_submission_${userId}_$professionId';
      final jsonString = jsonEncode(formData);
      await _prefs.setString(key, jsonString);

      // Track pending submissions
      final pendingKey = 'pending_submissions';
      final pending = _prefs.getStringList(pendingKey) ?? [];
      if (!pending.contains(key)) {
        pending.add(key);
        await _prefs.setStringList(pendingKey, pending);
      }
    } catch (e) {
      print('Error caching form submission: $e');
    }
  }

  /// Get pending form submissions
  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    try {
      final pendingKey = 'pending_submissions';
      final pending = _prefs.getStringList(pendingKey) ?? [];

      final submissions = <Map<String, dynamic>>[];
      for (final key in pending) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          submissions.add(jsonDecode(jsonString) as Map<String, dynamic>);
        }
      }

      return submissions;
    } catch (e) {
      print('Error getting pending submissions: $e');
      return [];
    }
  }

  /// Remove a pending submission after successful upload
  Future<void> removePendingSubmission(String userId, String professionId) async {
    try {
      final key = 'form_submission_${userId}_$professionId';
      await _prefs.remove(key);

      final pendingKey = 'pending_submissions';
      final pending = _prefs.getStringList(pendingKey) ?? [];
      pending.remove(key);
      await _prefs.setStringList(pendingKey, pending);
    } catch (e) {
      print('Error removing pending submission: $e');
    }
  }

  // Helper methods for generating cache keys
  String _getCacheKey(String professionId) => 'form_config_$professionId';
  String _getTimestampKey(String professionId) => 'form_config_${professionId}_timestamp';
  String _getSharedDataKey(String path) => 'shared_data_${path.replaceAll('/', '_')}';
  String _getSharedDataTimestampKey(String path) =>
      'shared_data_${path.replaceAll('/', '_')}_timestamp';
}
