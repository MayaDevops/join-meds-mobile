import '../models/form_config.dart';

/// Abstract repository interface for form configuration data
abstract class FormRepository {
  /// Get profession configuration by ID
  /// Returns FormConfig if found, null otherwise
  Future<FormConfig?> getProfessionConfig(String professionId);

  /// Get profession configuration with cache-first strategy
  /// [forceRefresh] bypasses cache and fetches fresh data
  /// [cacheMaxAgeHours] determines cache validity period
  Future<FormConfig?> getProfessionConfigWithCache(
    String professionId, {
    bool forceRefresh = false,
    int cacheMaxAgeHours = 24,
  });

  /// Get shared data (e.g., universities list) by path
  /// Example: getSharedData('universities/india')
  Future<List<String>> getSharedData(String path);

  /// Get shared data with cache-first strategy
  Future<List<String>> getSharedDataWithCache(
    String path, {
    bool forceRefresh = false,
    int cacheMaxAgeHours = 168,
  });

  /// Stream profession config for real-time updates
  Stream<FormConfig?> watchProfessionConfig(String professionId);

  /// Clear cache for a specific profession
  Future<void> clearCache(String professionId);

  /// Clear all cached data
  Future<void> clearAllCaches();

  /// Get list of available professions
  Future<List<String>> getAvailableProfessions();

  /// Check if cached config is valid
  Future<bool> isCacheValid(String professionId, {int maxAgeHours = 24});
}
