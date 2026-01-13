import 'package:firebase_database/firebase_database.dart';
import '../models/form_config.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Helper method to convert Firebase data to Map<String, dynamic>
  /// Handles both regular Map and LinkedMap from Firebase web
  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) {
      return data;
    }

    // Handle LinkedMap or other Map types
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((key, value) {
          // Recursively convert nested maps
          if (value is Map) {
            return MapEntry(key.toString(), _convertToMap(value));
          } else if (value is List) {
            return MapEntry(key.toString(), _convertList(value));
          }
          return MapEntry(key.toString(), value);
        })
      );
    }

    return {};
  }

  /// Helper method to convert lists
  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToMap(item);
      }
      return item;
    }).toList();
  }

  /// Get all profession IDs from Firebase
  Future<List<String>> getAllProfessionIds() async {
    try {
      final snapshot = await _db.child('join_meds_JSON/professions').get();

      print('Snapshot exists: ${snapshot.exists}');
      print('Snapshot value type: ${snapshot.value.runtimeType}');

      if (snapshot.exists && snapshot.value != null) {
        // Handle both Map and LinkedMap from Firebase web
        final data = _convertToMap(snapshot.value);
        print('Profession IDs found: ${data.keys.toList()}');
        return data.keys.toList();
      }
      return [];
    } catch (e) {
      print('Error getting profession IDs: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Get a profession config by ID
  Future<FormConfig?> getProfessionConfig(String professionId) async {
    try {
      final snapshot =
          await _db.child('join_meds_JSON/professions/$professionId').get();

      print('Getting config for: $professionId');
      print('Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists && snapshot.value != null) {
        print('Snapshot value type: ${snapshot.value.runtimeType}');
        // Handle both Map and LinkedMap from Firebase web
        final data = _convertToMap(snapshot.value);
        print('Converted data keys: ${data.keys.toList()}');
        return FormConfig.fromJson(data);
      }
      return null;
    } catch (e, stackTrace) {
      print('Error getting profession config for $professionId: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Save/update a profession config
  Future<bool> saveProfessionConfig(
      String professionId, FormConfig config) async {
    try {
      await _db
          .child('join_meds_JSON/professions/$professionId')
          .set(config.toJson());
      return true;
    } catch (e) {
      print('Error saving profession config: $e');
      return false;
    }
  }

  /// Delete a profession config
  Future<bool> deleteProfessionConfig(String professionId) async {
    try {
      await _db.child('join_meds_JSON/professions/$professionId').remove();
      return true;
    } catch (e) {
      print('Error deleting profession config: $e');
      return false;
    }
  }

  /// Watch a profession config for real-time updates
  Stream<FormConfig?> watchProfessionConfig(String professionId) {
    return _db
        .child('join_meds_JSON/professions/$professionId')
        .onValue
        .map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = _convertToMap(event.snapshot.value);
        return FormConfig.fromJson(data);
      }
      return null;
    });
  }

  /// Check if a profession exists
  Future<bool> professionExists(String professionId) async {
    try {
      final snapshot =
          await _db.child('join_meds_JSON/professions/$professionId').get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking profession existence: $e');
      return false;
    }
  }
}
