import 'package:firebase_database/firebase_database.dart';
import 'feature_flags.dart';

/// Remote feature flags service using Firebase Realtime Database
///
/// Allows runtime configuration without app releases
/// Falls back to local FeatureFlags if remote config unavailable
class RemoteFeatureFlags {
  static final RemoteFeatureFlags _instance = RemoteFeatureFlags._internal();
  factory RemoteFeatureFlags() => _instance;
  RemoteFeatureFlags._internal();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Cache for remote flags
  bool? _masterSwitch;
  Map<String, bool>? _professionFlags;
  int? _rolloutPercentage;
  DateTime? _lastFetch;

  // Cache duration: 1 hour
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Initialize and fetch remote flags
  Future<void> initialize() async {
    try {
      await _fetchRemoteFlags();
    } catch (e) {
      print('⚠️ Failed to fetch remote feature flags: $e');
      print('📍 Using local feature flags as fallback');
    }
  }

  /// Fetch flags from Firebase Realtime Database
  Future<void> _fetchRemoteFlags() async {
    try {
      final snapshot = await _db.child('feature_flags').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        _masterSwitch = data['enableDynamicForms'] as bool?;
        _rolloutPercentage = data['rolloutPercentage'] as int?;

        if (data['professions'] != null) {
          final professionsMap = data['professions'] as Map<dynamic, dynamic>;
          _professionFlags = professionsMap.map(
            (key, value) => MapEntry(key.toString(), value as bool),
          );
        }

        _lastFetch = DateTime.now();
        print('✅ Remote feature flags fetched successfully');
      } else {
        print('📍 No remote feature flags found, using local defaults');
      }
    } catch (e) {
      print('❌ Error fetching remote flags: $e');
      rethrow;
    }
  }

  /// Check if cache is stale and needs refresh
  bool get _isCacheStale {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > _cacheDuration;
  }

  /// Refresh cache if stale
  Future<void> _refreshIfNeeded() async {
    if (_isCacheStale) {
      try {
        await _fetchRemoteFlags();
      } catch (e) {
        // Ignore errors, use cached values
      }
    }
  }

  /// Check if dynamic forms should be used for a profession
  Future<bool> useDynamicForms(String professionId, {String? userId}) async {
    await _refreshIfNeeded();

    // Use remote flags if available, otherwise fall back to local
    final masterSwitch = _masterSwitch ?? FeatureFlags.enableDynamicForms;
    final rolloutPercentage =
        _rolloutPercentage ?? FeatureFlags.rolloutPercentage;
    final professionFlags =
        _professionFlags ?? FeatureFlags.dynamicFormsByProfession;

    // Force enable check (local only)
    if (FeatureFlags.forceEnableDynamicForms) return true;

    // Master switch check
    if (!masterSwitch) return false;

    // Check profession-specific flag
    final professionEnabled = professionFlags[professionId] ?? false;
    if (!professionEnabled) return false;

    // A/B testing based on user ID hash
    if (rolloutPercentage > 0 && rolloutPercentage < 100 && userId != null) {
      final userHash = userId.hashCode.abs() % 100;
      return userHash < rolloutPercentage;
    }

    // If rollout is 100% or no A/B testing, use profession flag
    return rolloutPercentage == 100 ? true : professionEnabled;
  }

  /// Get list of professions with dynamic forms enabled
  Future<List<String>> getEnabledProfessions() async {
    await _refreshIfNeeded();

    if (FeatureFlags.forceEnableDynamicForms) {
      return FeatureFlags.dynamicFormsByProfession.keys.toList();
    }

    final professionFlags =
        _professionFlags ?? FeatureFlags.dynamicFormsByProfession;

    return professionFlags.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get current flag status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'masterSwitch': _masterSwitch ?? FeatureFlags.enableDynamicForms,
      'rolloutPercentage': _rolloutPercentage ?? FeatureFlags.rolloutPercentage,
      'professionFlags': _professionFlags ?? FeatureFlags.dynamicFormsByProfession,
      'lastFetch': _lastFetch?.toIso8601String() ?? 'never',
      'cacheStale': _isCacheStale,
      'forceEnabled': FeatureFlags.forceEnableDynamicForms,
    };
  }

  /// Clear cache and force refetch
  Future<void> refresh() async {
    _lastFetch = null;
    await _fetchRemoteFlags();
  }
}
