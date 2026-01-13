import 'package:flutter/material.dart';
import '../../core/constants/storage_keys.dart';
import '../services/storage/local_storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final LocalStorageService _storageService;

  Locale _locale = const Locale('en');

  LocaleProvider(this._storageService) {
    _loadLocale();
  }

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isHindi => _locale.languageCode == 'hi';
  bool get isArabic => _locale.languageCode == 'ar';

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('ar'), // Arabic
  ];

  /// Load saved locale from storage
  Future<void> _loadLocale() async {
    final savedLocale = _storageService.getString(StorageKeys.languageCode);
    if (savedLocale != null && savedLocale.isNotEmpty) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  /// Set locale and persist
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    // Verify it's a supported locale
    if (!supportedLocales.contains(locale)) {
      return;
    }

    _locale = locale;
    await _storageService.setString(StorageKeys.languageCode, locale.languageCode);
    notifyListeners();
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Get locale name for display
  String getLocaleName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  /// Get current locale name
  String get currentLocaleName => getLocaleName(_locale.languageCode);

  /// Check if current locale is RTL
  bool get isRTL => _locale.languageCode == 'ar';
}
