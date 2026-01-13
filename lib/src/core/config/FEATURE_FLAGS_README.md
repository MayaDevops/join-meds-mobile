# Feature Flags System

## Overview

The feature flags system enables controlled rollout of the dynamic forms feature per profession, A/B testing, and easy rollback without app releases.

## Files

- `feature_flags.dart` - Local feature flag configuration
- `remote_feature_flags.dart` - Remote flags from Firebase Realtime Database
- `../../features/debug/feature_flags_debug_screen.dart` - Debug UI for testing

## How It Works

### 1. Local Flags (feature_flags.dart)

Static configuration in code:

```dart
class FeatureFlags {
  // Master switch for entire system
  static const bool enableDynamicForms = true;

  // Per-profession flags
  static const Map<String, bool> dynamicFormsByProfession = {
    'doctor': false,
    'nurse': false,
    'pharmacist': true,  // Pilot with pharmacist
    // ... other professions
  };

  // A/B testing percentage (0-100)
  static const int rolloutPercentage = 0;

  // Force enable for testing
  static const bool forceEnableDynamicForms = false;
}
```

### 2. Remote Flags (Firebase)

Dynamic configuration from Firebase Realtime Database at path `feature_flags/`:

```json
{
  "enableDynamicForms": true,
  "rolloutPercentage": 50,
  "professions": {
    "pharmacist": true,
    "nurse": true,
    "doctor": false
  }
}
```

Remote flags override local flags and allow updates without app releases.

### 3. Flag Resolution Priority

1. **Force Enable** (local only) - `forceEnableDynamicForms = true`
2. **Master Switch** (remote or local) - `enableDynamicForms`
3. **Profession Flag** (remote or local) - `professions[professionId]`
4. **A/B Testing** (remote or local) - `rolloutPercentage`

## Usage

### Check if dynamic forms should be used

```dart
// Simple check
final useDynamic = FeatureFlags.useDynamicForms('pharmacist');

// With user ID for A/B testing
final useDynamic = FeatureFlags.useDynamicForms(
  'pharmacist',
  userId: user.id,
);

// Using remote flags (with caching)
final remoteFlags = RemoteFeatureFlags();
final useDynamic = await remoteFlags.useDynamicForms(
  'pharmacist',
  userId: user.id,
);
```

### Get enabled professions

```dart
// Local flags
final enabled = FeatureFlags.getEnabledProfessions();
// Returns: ['pharmacist']

// Remote flags
final enabled = await RemoteFeatureFlags().getEnabledProfessions();
```

### Check if any profession is enabled

```dart
if (FeatureFlags.hasAnyEnabled()) {
  // Show option to access dynamic forms
}
```

## Integration Points

### Profession Selection Screen

The old profession selection screen checks feature flags before navigation:

```dart
void _navigateToNextScreen() {
  final professionId = _getProfessionId(profession!);
  final useDynamicForms = FeatureFlags.useDynamicForms(
    professionId,
    userId: userId,
  );

  if (useDynamicForms) {
    // New dynamic forms
    context.push('/dynamic-form/$professionId');
  } else {
    // Old static screens
    Navigator.pushNamed(context, '/old_screen');
  }
}
```

Location: `lib/widgets/selection_of_professions.dart:110-180`

## Rollout Strategies

### 1. Single Profession Pilot

Test with one profession first:

```dart
static const Map<String, bool> dynamicFormsByProfession = {
  'pharmacist': true,  // Only pharmacist enabled
  'doctor': false,
  'nurse': false,
  // ... all others false
};
```

### 2. Gradual Rollout

Enable professions incrementally:

**Week 1:** Pharmacist
**Week 2:** Nurse, Lab Technician
**Week 3:** All remaining professions

Update `feature_flags.dart` or Firebase each week.

### 3. A/B Testing

Test with percentage of users:

```dart
static const int rolloutPercentage = 50;  // 50% of users
```

Users are bucketed based on userId hash, ensuring consistent experience.

### 4. Emergency Rollback

Disable immediately if issues found:

**Option A: Update Firebase** (instant, no release)
```json
{
  "enableDynamicForms": false
}
```

**Option B: Update local code** (requires release)
```dart
static const bool enableDynamicForms = false;
```

## Remote Configuration (Firebase)

### Setup

1. Upload feature flags to Firebase:
```bash
# Use Firebase Console
# Path: feature_flags/
# Import: assets/configs/feature_flags_firebase.json
```

2. Initialize in app:
```dart
// In main.dart or app initialization
await RemoteFeatureFlags().initialize();
```

### Update Flags Remotely

1. Go to Firebase Console → Realtime Database
2. Navigate to `feature_flags/`
3. Edit values:
   - `enableDynamicForms`: true/false
   - `rolloutPercentage`: 0-100
   - `professions/{professionId}`: true/false
4. Save - changes apply immediately (respects 1-hour cache)

### Cache Behavior

- **Cache Duration:** 1 hour
- **Stale Cache:** Automatically refreshed on next check
- **Manual Refresh:** Use debug screen or `RemoteFeatureFlags().refresh()`
- **Offline:** Falls back to local flags

## Debug Screen

Access the debug screen to view and test flags:

### Navigation

Add route to your app:
```dart
GoRoute(
  path: '/debug/feature-flags',
  name: 'feature_flags_debug',
  builder: (context, state) => const FeatureFlagsDebugScreen(),
),
```

### Features

- ✅ View all flag values (local + remote)
- ✅ See cache status
- ✅ Refresh from Firebase
- ✅ View profession-specific flags
- ✅ Check A/B testing percentage
- ✅ See last fetch time

### Access in Development

```dart
// Add debug button in settings
ElevatedButton(
  onPressed: () => context.push('/debug/feature-flags'),
  child: Text('Feature Flags Debug'),
),
```

## Testing

### Test Force Enable

```dart
// In feature_flags.dart
static const bool forceEnableDynamicForms = true;

// All professions will use dynamic forms
// Ignores all other flags
```

### Test A/B Bucketing

```dart
// Set rolloutPercentage to 50
static const int rolloutPercentage = 50;

// Test with different user IDs
final user1 = FeatureFlags.useDynamicForms('pharmacist', userId: 'user1');
final user2 = FeatureFlags.useDynamicForms('pharmacist', userId: 'user2');
// user1 and user2 will consistently get same or different experiences
```

### Test Remote Flags

```dart
// 1. Update flags in Firebase Console
// 2. In app, go to debug screen
// 3. Tap refresh icon
// 4. Verify flags updated
```

## Best Practices

### 1. Start Small
- Enable one profession first (pharmacist recommended)
- Monitor for issues
- Gradually expand

### 2. Monitor Metrics
- Track completion rates
- Monitor error rates
- Compare old vs new flow

### 3. Use Remote Flags
- Update Firebase for instant changes
- No app release needed
- Easy rollback

### 4. Communicate Changes
- Inform team when enabling new professions
- Document any issues
- Share learnings

### 5. Clean Up
After 100% rollout, remove old code:
- Delete old static screens
- Remove feature flag checks
- Update to use dynamic forms directly

## Profession ID Mapping

| Display Name | Profession ID |
|-------------|---------------|
| Doctor | doctor |
| Nurse | nurse |
| Pharmacist | pharmacist |
| Lab Technician | lab_technician |
| Anesthesia Technician | anesthesia_technician |
| Dentist | dentist |
| Physiotherapy | physiotherapy |
| Audiologist | audiologist |
| Dietitian | dietitian |
| Clinical Psychologist | clinical_psychologist |
| Social Worker | social_worker |
| Hospital Administrator | hospital_administrator |

## Troubleshooting

### Flags not updating
- Check Firebase connection
- Verify cache isn't stale (>1 hour)
- Use debug screen to force refresh

### Wrong profession routing
- Verify profession ID mapping
- Check `_getProfessionId()` in selection screen
- Ensure exact match (case-sensitive)

### A/B testing not working
- Verify rolloutPercentage is 0-100
- Check user ID is provided
- Test with different user IDs

### Remote flags not loading
- Check Firebase database rules allow read
- Verify path is `feature_flags/`
- Check network connectivity
- Falls back to local flags on error

## Migration Plan

### Phase 1: Pilot (Week 1)
- Enable pharmacist only
- Monitor closely
- Fix any issues

### Phase 2: Expand (Week 2-3)
- Enable 3-4 more professions
- Continue monitoring
- Gather feedback

### Phase 3: Full Rollout (Week 4)
- Enable all professions
- Set rolloutPercentage to 100

### Phase 4: Cleanup (Week 5+)
- Remove old screens
- Remove feature flag code
- Update to dynamic forms only

## Support

For issues or questions:
- Check debug screen for flag status
- Verify Firebase configuration
- Review integration points
- Test with force enable flag
