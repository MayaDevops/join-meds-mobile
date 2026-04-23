import '../../domain/models/form_config.dart';
import '../../domain/repositories/form_repository.dart';
import '../datasources/firebase_form_datasource.dart';
import '../datasources/local_form_datasource.dart';

/// Implementation of FormRepository
/// Combines Firebase and local datasources with cache-first strategy
class FormRepositoryImpl implements FormRepository {
  final FirebaseFormDatasource _firebaseDatasource;
  final LocalFormDatasource _localDatasource;

  FormRepositoryImpl({
    required FirebaseFormDatasource firebaseDatasource,
    required LocalFormDatasource localDatasource,
  })  : _firebaseDatasource = firebaseDatasource,
        _localDatasource = localDatasource;

  @override
  Future<FormConfig?> getProfessionConfig(String professionId) async {
    try {
      final configJson = await _firebaseDatasource.fetchFormConfig(professionId);
      if (configJson == null) return null;

      return FormConfig.fromJson(configJson);
    } catch (e) {
      print('Error getting profession config: $e');
      rethrow;
    }
  }

  @override
  Future<FormConfig?> getProfessionConfigWithCache(
    String professionId, {
    bool forceRefresh = false,
    int cacheMaxAgeHours = 24,
  }) async {
    try {
      // Try cache first if not forcing refresh
      if (!forceRefresh) {
        final isValid = await _localDatasource.isCacheValid(
          professionId,
          maxAgeHours: cacheMaxAgeHours,
        );

        if (isValid) {
          final cachedJson = await _localDatasource.getCachedFormConfig(professionId);
          if (cachedJson != null) {
            print('Using cached config for $professionId');
            return FormConfig.fromJson(cachedJson);
          }
        }
      }

      // Fetch from Firebase
      print('Fetching fresh config for $professionId from Firebase');
      final configJson = await _firebaseDatasource.fetchFormConfig(professionId);

      if (configJson != null) {
        // Cache it
        await _localDatasource.cacheFormConfig(professionId, configJson);
        return FormConfig.fromJson(configJson);
      }

      return null;
    } catch (e) {
      print('Error getting profession config with cache: $e');

      // Try to return cached data as fallback
      try {
        final cachedJson = await _localDatasource.getCachedFormConfig(professionId);
        if (cachedJson != null) {
          print('Returning stale cached config as fallback');
          return FormConfig.fromJson(cachedJson);
        }
      } catch (cacheError) {
        print('Failed to get cached fallback: $cacheError');
      }

      rethrow;
    }
  }

  @override
  Future<List<String>> getSharedData(String path) async {
    try {
      return await _firebaseDatasource.fetchSharedData(path);
    } catch (e) {
      print('Error getting shared data: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getSharedDataWithCache(
    String path, {
    bool forceRefresh = false,
    int cacheMaxAgeHours = 168,
  }) async {
    try {
      // Try cache first if not forcing refresh
      if (!forceRefresh) {
        final isValid = await _localDatasource.isSharedDataCacheValid(
          path,
          maxAgeHours: cacheMaxAgeHours,
        );

        if (isValid) {
          final cached = await _localDatasource.getCachedSharedData(path);
          if (cached != null && cached.isNotEmpty) {
            print('Using cached shared data for $path');
            return cached;
          }
        }
      }

      // Fetch from Firebase
      print('Fetching fresh shared data for $path from Firebase');
      final data = await _firebaseDatasource.fetchSharedData(path);

      if (data.isNotEmpty) {
        // Cache it
        await _localDatasource.cacheSharedData(path, data);
      }

      return data;
    } catch (e) {
      print('Error getting shared data with cache: $e');

      // Try to return cached data as fallback
      try {
        final cached = await _localDatasource.getCachedSharedData(path);
        if (cached != null && cached.isNotEmpty) {
          print('Returning stale cached shared data as fallback');
          return cached;
        }
      } catch (cacheError) {
        print('Failed to get cached shared data fallback: $cacheError');
      }

      rethrow;
    }
  }

  @override
  Stream<FormConfig?> watchProfessionConfig(String professionId) {
    return _firebaseDatasource.watchFormConfig(professionId).map((configJson) {
      if (configJson == null) return null;
      return FormConfig.fromJson(configJson);
    });
  }

  @override
  Future<void> clearCache(String professionId) async {
    await _localDatasource.clearCache(professionId);
  }

  @override
  Future<void> clearAllCaches() async {
    await _localDatasource.clearAllCaches();
  }

  @override
  Future<List<String>> getAvailableProfessions() async {
    try {
      return await _firebaseDatasource.fetchAvailableProfessions();
    } catch (e) {
      print('Error getting available professions: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isCacheValid(String professionId, {int maxAgeHours = 24}) async {
    return await _localDatasource.isCacheValid(professionId, maxAgeHours: maxAgeHours);
  }
}
