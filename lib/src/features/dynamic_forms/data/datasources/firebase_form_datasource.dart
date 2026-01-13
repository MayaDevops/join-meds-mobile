import '../../../../shared/services/firebase/firebase_service.dart';

/// Firebase datasource for form configuration data
/// Handles reading form configs from Firebase Realtime Database
class FirebaseFormDatasource {
  final FirebaseService _firebaseService;

  FirebaseFormDatasource({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  /// Fetch form configuration from Firebase
  Future<Map<String, dynamic>?> fetchFormConfig(String professionId) async {
    return await _firebaseService.getProfessionConfig(professionId);
  }

  /// Fetch specific flow configuration
  Future<Map<String, dynamic>?> fetchFlowConfig(
    String professionId,
    String flowId,
  ) async {
    return await _firebaseService.getFlowConfig(professionId, flowId);
  }

  /// Fetch shared data (e.g., universities)
  Future<List<String>> fetchSharedData(String path) async {
    return await _firebaseService.getSharedData(path);
  }

  /// Stream form config for real-time updates
  Stream<Map<String, dynamic>?> watchFormConfig(String professionId) {
    return _firebaseService.watchProfessionConfig(professionId);
  }

  /// Get available professions list
  Future<List<String>> fetchAvailableProfessions() async {
    return await _firebaseService.getAvailableProfessions();
  }
}
