/// Feature flags for gradual rollout and A/B testing
///
/// This system allows controlled rollout of new features per profession
class FeatureFlags {
  /// Master switch for dynamic forms system
  static const bool enableDynamicForms = true;

  /// Enable dynamic forms for specific professions
  /// Set to true to use V2 dynamic forms, false to use old static screens
  static const Map<String, bool> dynamicFormsByProfession = {
    'doctor': false, // Keep old flow for now
    'nurse': false,
    'pharmacist': true, // Pilot with pharmacist first
    'lab_technician': false,
    'anesthesia_technician': false,
    'dentist': false,
    'physiotherapy': false,
    'audiologist': false,
    'dietitian': false,
    'clinical_psychologist': false,
    'social_worker': false,
    'hospital_administrator': false,
  };

  /// Percentage rollout (0-100) for A/B testing
  /// If user hash % 100 < rolloutPercentage, use dynamic forms
  static const int rolloutPercentage = 0; // 0% = disabled, 100% = all users

  /// Force dynamic forms for testing (overrides all other flags)
  /// Only use during development/testing
  static const bool forceEnableDynamicForms = false;

  /// Check if dynamic forms should be used for a specific profession
  static bool useDynamicForms(String professionId, {String? userId}) {
    // Force enable for testing
    if (forceEnableDynamicForms) return true;

    // Master switch check
    if (!enableDynamicForms) return false;

    // Check profession-specific flag
    final professionEnabled = dynamicFormsByProfession[professionId] ?? false;
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
  static List<String> getEnabledProfessions() {
    if (forceEnableDynamicForms) {
      return dynamicFormsByProfession.keys.toList();
    }

    return dynamicFormsByProfession.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if any profession has dynamic forms enabled
  static bool hasAnyEnabled() {
    return forceEnableDynamicForms ||
        (enableDynamicForms && dynamicFormsByProfession.values.any((v) => v));
  }
}
