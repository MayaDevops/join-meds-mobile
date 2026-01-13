import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for interacting with Firebase Realtime Database
/// Database is read-only, no authentication required
class FirebaseService {
  final FirebaseDatabase _database;
  final String _basePath = 'join_meds_JSON';

  FirebaseService({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  /// Helper method to recursively convert Firebase Map<Object?, Object?> to Map<String, dynamic>
  /// This handles nested maps and lists properly
  Map<String, dynamic> _convertFirebaseMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.fromEntries(
        data.entries.map((entry) {
          return MapEntry<String, dynamic>(
            entry.key.toString(),
            _convertFirebaseValue(entry.value),
          );
        }),
      );
    }
    return {};
  }

  /// Helper method to recursively convert Firebase values
  dynamic _convertFirebaseValue(dynamic value) {
    if (value is Map) {
      return _convertFirebaseMap(value);
    } else if (value is List) {
      return value.map((item) => _convertFirebaseValue(item)).toList();
    }
    return value;
  }

  /// Get profession configuration from Firebase
  /// Path: join_meds_JSON/professions/{professionId}
  Future<Map<String, dynamic>?> getProfessionConfig(String professionId) async {
    try {
      // Debug: Log Firebase fetch attempt
      print('🔍 DEBUG: Fetching profession config from Firebase: $professionId');
      print('🔍 DEBUG: Firebase path: $_basePath/professions/$professionId');

      final ref = _database.ref('$_basePath/professions/$professionId');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          final converted = _convertFirebaseMap(data);

          // Debug: Log loaded data structure
          print('✅ DEBUG: Firebase config fetched for $professionId');

          // Print profession metadata
          if (converted['profession'] != null) {
            final profession = converted['profession'] as Map;
            print('   📋 Profession displayName: ${profession['displayName']}');
          }

          // Print flows
          if (converted['flows'] != null) {
            final flows = converted['flows'] as Map;
            print('   📋 Available flows: ${flows.keys.toList()}');
            flows.forEach((flowId, flowData) {
              if (flowData is Map && flowData['displayName'] != null) {
                print('     * $flowId: ${flowData['displayName']}');

                // Print first 3 steps of each flow to verify step titles
                if (flowData['steps'] is List) {
                  final steps = flowData['steps'] as List;
                  print('       Steps (${steps.length} total):');
                  for (var i = 0; i < steps.length && i < 3; i++) {
                    if (steps[i] is Map) {
                      final step = steps[i] as Map;
                      print('         ${i + 1}. ${step['stepId']}: "${step['title']}"');
                    }
                  }
                  if (steps.length > 3) {
                    print('         ... and ${steps.length - 3} more steps');
                  }
                }
              }
            });
          }

          return converted;
        }
      }

      print('❌ DEBUG: No data found for profession: $professionId');
      return null;
    } catch (e) {
      print('❌ DEBUG: Error fetching profession config for $professionId: $e');
      rethrow;
    }
  }

  /// Get a specific flow configuration for a profession
  /// Path: join_meds_JSON/professions/{professionId}/flows/{flowId}
  Future<Map<String, dynamic>?> getFlowConfig(
    String professionId,
    String flowId,
  ) async {
    try {
      final ref = _database.ref('$_basePath/professions/$professionId/flows/$flowId');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          return _convertFirebaseMap(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching flow config for $professionId/$flowId: $e');
      rethrow;
    }
  }

  /// Get shared data from Firebase
  /// Path: join_meds_JSON/{path}/{path}
  /// Example: getSharedData('universities/india') → join_meds_JSON/universities/india/universities/india
  Future<List<String>> getSharedData(String path) async {
    try {
      // Firebase path is nested: join_meds_JSON/{path}/{path}
      // Example: join_meds_JSON/universities/india/universities/india
      final ref = _database.ref('$_basePath/$path/$path');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        } else if (data is Map) {
          // Convert map values to list
          return data.values.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching shared data from $path: $e');
      rethrow;
    }
  }

  /// Stream profession config for real-time updates
  /// Useful for syncing config changes without app restart
  Stream<Map<String, dynamic>?> watchProfessionConfig(String professionId) {
    final ref = _database.ref('$_basePath/professions/$professionId');

    return ref.onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    });
  }

  /// Cache profession config to local storage
  Future<void> cacheConfig(
    String professionId,
    Map<String, dynamic> config,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'profession_config_$professionId';
      final jsonString = jsonEncode(config);
      await prefs.setString(key, jsonString);

      // Also save timestamp
      final timestampKey = 'profession_config_${professionId}_timestamp';
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching config for $professionId: $e');
    }
  }

  /// Get cached profession config from local storage
  Future<Map<String, dynamic>?> getCachedConfig(String professionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'profession_config_$professionId';
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting cached config for $professionId: $e');
      return null;
    }
  }

  /// Check if cached config is still valid
  /// Returns true if cache is less than [maxAgeHours] old
  Future<bool> isCacheValid(String professionId, {int maxAgeHours = 24}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = 'profession_config_${professionId}_timestamp';
      final timestamp = prefs.getInt(timestampKey);

      if (timestamp == null) return false;

      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = maxAgeHours * 60 * 60 * 1000; // Convert hours to milliseconds

      return cacheAge < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// Get config with cache-first strategy
  /// 1. Check local cache
  /// 2. If valid, return cached
  /// 3. If invalid or missing, fetch from Firebase
  /// 4. Cache the new data
  Future<Map<String, dynamic>?> getConfigWithCache(
    String professionId, {
    int cacheMaxAgeHours = 24,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      // Try cache first
      final isValid = await isCacheValid(professionId, maxAgeHours: cacheMaxAgeHours);
      if (isValid) {
        final cached = await getCachedConfig(professionId);
        if (cached != null) {
          print('Using cached config for $professionId');
          return cached;
        }
      }
    }

    // Fetch from Firebase
    print('Fetching fresh config for $professionId from Firebase');
    final config = await getProfessionConfig(professionId);

    if (config != null) {
      // Cache it
      await cacheConfig(professionId, config);
    }

    return config;
  }

  /// Clear cached config for a profession
  Future<void> clearCache(String professionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profession_config_$professionId');
      await prefs.remove('profession_config_${professionId}_timestamp');
    } catch (e) {
      print('Error clearing cache for $professionId: $e');
    }
  }

  /// Clear all cached configs
  Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('profession_config_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing all caches: $e');
    }
  }

  /// Cache shared data (e.g., universities list)
  Future<void> cacheSharedData(String path, List<String> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'shared_data_$path';
      await prefs.setStringList(key, data);

      // Save timestamp
      final timestampKey = 'shared_data_${path}_timestamp';
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching shared data for $path: $e');
    }
  }

  /// Get cached shared data
  Future<List<String>?> getCachedSharedData(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'shared_data_$path';
      return prefs.getStringList(key);
    } catch (e) {
      print('Error getting cached shared data for $path: $e');
      return null;
    }
  }

  /// Get shared data with cache-first strategy
  Future<List<String>> getSharedDataWithCache(
    String path, {
    int cacheMaxAgeHours = 168, // 1 week default for shared data
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      // Try cache first
      final cached = await getCachedSharedData(path);
      if (cached != null && cached.isNotEmpty) {
        print('Using cached shared data for $path');
        return cached;
      }
    }

    // Fetch from Firebase
    print('Fetching fresh shared data for $path from Firebase');
    final data = await getSharedData(path);

    if (data.isNotEmpty) {
      // Cache it
      await cacheSharedData(path, data);
    }

    return data;
  }

  /// Get all available professions
  /// Path: join_meds_JSON/professions
  Future<List<String>> getAvailableProfessions() async {
    try {
      final ref = _database.ref('$_basePath/professions');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          return data.keys.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching available professions: $e');
      rethrow;
    }
  }
}
