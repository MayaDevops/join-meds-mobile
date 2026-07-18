import 'package:flutter/foundation.dart';
import '../services/storage/local_storage_service.dart';
import '../services/api/api_client.dart';
import '../../core/constants/storage_keys.dart';
import 'auth_provider.dart';
import '../../../api/personal_data_service.dart';

class UserProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final ApiClient _apiClient;

  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // User data
  String? _userId;
  String? _fullName;
  String? _email;
  String? _phone;
  String? _profession;
  String? _profileImageUrl;
  String? _resumeUrl;
  String? _dob;
  String? _address;
  String? _aadhaarNo;
  String? _academicStatus;
  String? _workExperience;
  Map<String, dynamic>? _personalData;

  UserProvider(this._storageService, this._apiClient) {
    _loadUserFromStorage();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  String? get userId => _userId;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get phone => _phone;
  String? get profession => _profession;
  String? get profileImageUrl => _profileImageUrl;
  String? get resumeUrl => _resumeUrl;
  Map<String, dynamic>? get personalData => _personalData;

  String? get dob => _dob;
  String? get address => _address;
  String? get aadhaarNo => _aadhaarNo;
  String? get academicStatus => _academicStatus;
  String? get workExperience => _workExperience;

  bool get hasProfile => _fullName != null && _fullName!.isNotEmpty;
  bool get hasProfileImage =>
      _profileImageUrl != null && _profileImageUrl!.isNotEmpty;
  bool get hasResume => _resumeUrl != null && _resumeUrl!.isNotEmpty;

  bool get isProfileComplete {
    // NOTE: workExperience is intentionally NOT checked here. It is stored on a
    // separate resource (POST /api/work-experience/save) and is never returned
    // by the user-details response, so _workExperience is always null. Including
    // it kept the "Complete Your Profile" FAB visible even for users whose
    // profile was fully filled. All other required fields (name, dob, email,
    // phone, address, aadhaarNo, resume, profession, academicStatus) are
    // present in the user-details payload and are validated below.
    bool filled(String? v) => v != null && v.trim().isNotEmpty;
    return filled(_fullName) &&
        filled(_dob) &&
        filled(_email) &&
        filled(_phone) &&
        filled(_address) &&
        filled(_aadhaarNo) &&
        filled(_resumeUrl) &&
        filled(_profession) &&
        filled(_academicStatus);
  }

  bool get canApplyForJob {
    bool filled(String? v) => v != null && v.trim().isNotEmpty;
    return filled(_fullName) &&
        filled(_dob) &&
        filled(_email) &&
        filled(_phone) &&
        filled(_resumeUrl);
  }

  /// Ensures user name & profile image are available
  Future<void> ensureUserLoadedForHome() async {
    debugPrint('UserProvider: ensureUserLoadedForHome called');

    // Wait for constructor async init to finish
    if (!_isInitialized) {
      while (!_isInitialized) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    if (_fullName == null || _profileImageUrl == null) {
      debugPrint('UserProvider: Missing data, refreshing');
      await refreshUserData();
    }
  }

  Future<void> _loadUserFromStorage() async {
    _userId = _storageService.getString(StorageKeys.userId);
    _personalData = _storageService.getObject(StorageKeys.userProfile);

    debugPrint(
      'UserProvider: Loading user data - userId=$_userId, hasPersonalData=${_personalData != null}',
    );

    // Re-fetch if cache is missing or was saved in the old 6-field format
    // (i.e., newer required fields like dob/address/aadhaarNo are absent)
    // workExperience is excluded here on purpose: it lives on a separate
    // resource and never appears in the user-details payload, so treating its
    // absence as a stale cache would force a re-fetch on every load.
    final cacheMissingNewFields = _personalData != null &&
        (_personalData!['dob'] == null ||
            _personalData!['address'] == null ||
            _personalData!['aadhaarNo'] == null ||
            _personalData!['academicStatus'] == null);

    if ((_personalData == null || cacheMissingNewFields) &&
        _userId != null &&
        _userId!.isNotEmpty) {
      try {
        final apiData =
        await PersonalDataService.getPersonalData(_userId!);

        if (apiData != null) {
          _personalData = {
            'fullName': apiData.fullname,
            'email': apiData.email,
            'phone': apiData.emailOrPhone,
            'profession': apiData.profession,
            'profileImageUrl': apiData.photoId,
            'resumeUrl': apiData.resumeId,
            'dob': apiData.dob,
            'address': apiData.address,
            'aadhaarNo': apiData.aadhaarNo,
            'academicStatus': apiData.academicStatus,
            'workExperience': apiData.workExperience,
          };

          await _storageService.setObject(
              StorageKeys.userProfile, _personalData!);
        }
      } catch (e) {
        debugPrint('UserProvider: Error fetching profile - $e');
      }
    }

    if (_personalData != null) {
      _fullName = _personalData!['fullName'] as String?;
      _email = _personalData!['email'] as String?;
      _phone = _personalData!['phone'] as String?;
      _profession = _personalData!['profession'] as String?;
      _profileImageUrl = _personalData!['profileImageUrl'] as String?;
      _resumeUrl = _personalData!['resumeUrl'] as String?;
      _dob = _personalData!['dob'] as String?;
      _address = _personalData!['address'] as String?;
      _aadhaarNo = _personalData!['aadhaarNo'] as String?;
      _academicStatus = _personalData!['academicStatus'] as String?;
      _workExperience = _personalData!['workExperience'] as String?;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    debugPrint('UserProvider: Refreshing user data...');
    await _loadUserFromStorage();
  }

  void updateAuth(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      _clearUserData();
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? profession,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (fullName != null) _fullName = fullName;
      if (email != null) _email = email;
      if (phone != null) _phone = phone;
      if (profession != null) _profession = profession;

      await _saveToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateResume(String resumePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveToStorage() async {
    final userData = {
      'fullName': _fullName,
      'email': _email,
      'phone': _phone,
      'profession': _profession,
      'profileImageUrl': _profileImageUrl,
      'resumeUrl': _resumeUrl,
      'dob': _dob,
      'address': _address,
      'aadhaarNo': _aadhaarNo,
      'academicStatus': _academicStatus,
      'workExperience': _workExperience,
    };

    await _storageService.setObject(StorageKeys.userProfile, userData);
  }

  void _clearUserData() {
    _userId = null;
    _fullName = null;
    _email = null;
    _phone = null;
    _profession = null;
    _profileImageUrl = null;
    _resumeUrl = null;
    _dob = null;
    _address = null;
    _aadhaarNo = null;
    _academicStatus = null;
    _workExperience = null;
    _personalData = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isPersonalDataComplete =>
      _storageService.getBoolOrDefault(
          StorageKeys.personalDataComplete);

  bool get isAcademicStatusComplete =>
      _storageService.getBoolOrDefault(
          StorageKeys.academicStatusComplete);

  bool get isWorkExperienceComplete =>
      _storageService.getBoolOrDefault(
          StorageKeys.workExperienceComplete);

  bool get isProfessionSelected =>
      _storageService.getBoolOrDefault(
          StorageKeys.professionSelected);

  double get profileCompletionPercentage {
    int completed = 0;
    const total = 4;

    if (isPersonalDataComplete) completed++;
    if (isAcademicStatusComplete) completed++;
    if (isWorkExperienceComplete) completed++;
    if (isProfessionSelected) completed++;

    return completed / total;
  }

  Future<void> setPersonalDataComplete() async {
    await _storageService.setBool(
        StorageKeys.personalDataComplete, true);
    notifyListeners();
  }

  Future<void> setAcademicStatusComplete() async {
    await _storageService.setBool(
        StorageKeys.academicStatusComplete, true);
    notifyListeners();
  }

  Future<void> setWorkExperienceComplete() async {
    await _storageService.setBool(
        StorageKeys.workExperienceComplete, true);
    notifyListeners();
  }

  Future<void> setProfessionSelected(String profession) async {
    _profession = profession;
    await _storageService.setBool(
        StorageKeys.professionSelected, true);
    await _saveToStorage();
    notifyListeners();
  }
}
