import 'package:firebase_database/firebase_database.dart';
import '../models/v2_models.dart';

/// V2 Form Repository - reads from v2/forms/professions/ path
class V2FormRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  static const String _basePath = 'v2';

  /// Convert Firebase data to Map<String, dynamic>
  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((key, value) {
          if (value is Map) {
            return MapEntry(key.toString(), _convertToMap(value));
          } else if (value is List) {
            return MapEntry(key.toString(), _convertList(value));
          }
          return MapEntry(key.toString(), value);
        }),
      );
    }

    return {};
  }

  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToMap(item);
      }
      return item;
    }).toList();
  }

  /// Get all profession IDs
  Future<List<String>> getAllProfessionIds() async {
    try {
      final snapshot = await _db.child("$_basePath/forms/professions").get();

      if (snapshot.exists && snapshot.value != null) {
        final data = _convertToMap(snapshot.value);
        return data.keys.toList();
      }
      return [];
    } catch (e) {
      print('V2 Error getting profession IDs: $e');
      return [];
    }
  }

  /// Get profession config by ID
  Future<V2FormConfig?> getProfessionConfig(String professionId) async {
    try {
      final snapshot = await _db.child('$_basePath/forms/professions/$professionId').get();

      if (snapshot.exists && snapshot.value != null) {
        final data = _convertToMap(snapshot.value);
        return V2FormConfig.fromJson(data);
      }
      return null;
    } catch (e) {
      print('V2 Error getting profession config: $e');
      return null;
    }
  }

  /// Save profession config
  Future<bool> saveProfessionConfig(
    String professionId,
    V2FormConfig config,
  ) async {
    try {
      await _db.child('$_basePath/forms/professions/$professionId').set(config.toJson());
      return true;
    } catch (e) {
      print('V2 Error saving profession config: $e');
      return false;
    }
  }

  /// Delete profession config
  Future<bool> deleteProfessionConfig(String professionId) async {
    try {
      await _db.child('$_basePath/forms/professions/$professionId').remove();
      return true;
    } catch (e) {
      print('V2 Error deleting profession config: $e');
      return false;
    }
  }

  /// Watch profession config for real-time updates
  Stream<V2FormConfig?> watchProfessionConfig(String professionId) {
    return _db.child('$_basePath/$professionId').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = _convertToMap(event.snapshot.value);
        return V2FormConfig.fromJson(data);
      }
      return null;
    });
  }

  /// Get shared data (universities, etc.)
  Future<List<String>> getSharedData(String path) async {
    try {
      final snapshot = await _db.child('$_basePath/shared/$path').get();

      if (snapshot.exists && snapshot.value != null) {
        if (snapshot.value is List) {
          return List<String>.from(snapshot.value as List);
        } else if (snapshot.value is Map) {
          // Handle map with index keys
          final data = _convertToMap(snapshot.value);
          return data.values.map((v) => v.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('V2 Error getting shared data: $e');
      return [];
    }
  }
  /// Get shared dropdown options (countries, exams, etc.)
  Future<List<V2FieldOption>> getSharedOptions(String path) async {
    try {
      final snapshot = await _db.child('$_basePath/shared/$path').get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value;

      // ✅ CASE 1: List of strings (your universities case)
      if (data is List) {
        return data
            .whereType<String>()
            .map((e) => V2FieldOption(
          value: e.toLowerCase().toString(),
          label: e,
        ))
            .toList();
      }

      // ✅ CASE 2: Map<String, dynamic> of objects
      if (data is Map) {
        return data.values.map((e) {
          if (e is String) {
            return V2FieldOption(value: e, label: e);
          }

          if (e is Map) {
            return V2FieldOption.fromJson(
              Map<String, dynamic>.from(e),
            );
          }

          return null;
        }).whereType<V2FieldOption>().toList();
      }

      return [];
    } catch (e, stackTrace) {
      print('V2 Error getting shared options ($path): $e');
      print(stackTrace);
      return [];
    }
  }


}
