# Home Feature - V2 Architecture

Modern home screen implementation with bottom navigation, job recommendations, and user profile management.

## 📁 Structure

```
home/
├── data/                           # Data layer
│   └── repositories/
│       └── home_repository_impl.dart
├── domain/                         # Business logic layer
│   ├── models/
│   │   ├── promotional_banner.dart
│   │   └── home_stats.dart
│   └── repositories/
│       └── home_repository.dart
└── presentation/                   # UI layer
    ├── providers/
    │   ├── home_provider.dart           # Home tab state
    │   ├── navigation_provider.dart     # Bottom nav state
    │   ├── jobs_tab_provider.dart       # Jobs tab state
    │   └── notifications_provider.dart  # Notifications state
    ├── screens/
    │   ├── home_shell_screen.dart       # Main shell with bottom nav
    │   ├── home_tab_screen.dart         # Home tab content
    │   ├── jobs_tab_screen.dart         # My Jobs tab
    │   ├── notifications_tab_screen.dart # Notifications tab
    │   ├── profile_tab_screen.dart      # Profile tab
    │   ├── job_search_screen.dart       # Search functionality
    │   └── job_filters_screen.dart      # Filter UI
    └── widgets/
        ├── job_card_widget.dart         # Reusable job card
        ├── promotional_banner_widget.dart # Banner display
        ├── search_bar_with_filter.dart  # Search widget
        ├── user_profile_header.dart     # Profile header
        ├── complete_profile_fab.dart    # FAB for profile completion
        └── home_app_bar.dart            # Custom app bar
```

## 🚀 Features

### Home Tab
- ✅ Promotional banner with dynamic content from API
- ✅ Job recommendations based on user profile
- ✅ Search bar with filter integration
- ✅ Job bookmarking functionality
- ✅ Pull-to-refresh
- ✅ Shimmer loading states
- ✅ Error handling with retry

### My Jobs Tab
- ✅ List of applied jobs
- ✅ Status filtering (All, Pending, Accepted, Rejected)
- ✅ Application status badges
- ✅ Pull-to-refresh
- ✅ Empty states

### Notifications Tab
- ✅ Real-time notifications
- ✅ Unread count badges
- ✅ Mark as read/Mark all as read
- ✅ Swipe to delete
- ✅ Time ago formatting
- ✅ Type-based icons

### Profile Tab
- ✅ User profile display
- ✅ Profile completion tracking
- ✅ Edit profile navigation
- ✅ Resume upload status
- ✅ Settings and logout

### Bottom Navigation
- ✅ Persistent across tabs
- ✅ State preservation
- ✅ Deep linking support
- ✅ Notification badges

## 📡 API Endpoints

All endpoints are defined in `lib/src/core/constants/v2_api_constants.dart`:

```dart
// Job endpoints
fetchRecommendedJobs: '/org-job/recommended'
bookmarkJob(jobId): '/job-bookmarks/save/{jobId}'
removeBookmark(jobId): '/job-bookmarks/remove/{jobId}'
fetchBookmarkedJobs: '/job-bookmarks/list'

// Home endpoints
fetchHomeStats: '/home/stats'
fetchActiveBanner: '/home/banner/active'

// Notifications
fetchNotifications: '/notifications/list'
markNotificationRead(id): '/notifications/{id}/read'
markAllNotificationsRead: '/notifications/mark-all-read'
```

## 🎨 Design System

### Colors
- Primary Blue: `#00A4E1`
- Success: `#4CAF50`
- Error: `#E53935`
- Warning: `#FFC107`

### Typography
- Headings: Bold, 18-24sp
- Body: Regular, 14-16sp
- Captions: Regular, 12-14sp

### Spacing
- Standard padding: 16px
- Card border radius: 12px
- Button border radius: 20-28px

## 🔄 State Management

Uses **Provider** pattern with `ChangeNotifier`:

### HomeProvider
```dart
// Access in widgets
final homeProvider = context.read<HomeProvider>();
await homeProvider.initialize();

// Listen to changes
Consumer<HomeProvider>(
  builder: (context, provider, child) {
    return Text('${provider.recommendedJobs.length} jobs');
  },
)
```

### Key Methods
- `fetchRecommendedJobs()` - Load job recommendations
- `fetchBanner()` - Get promotional banner
- `toggleBookmark(jobId)` - Bookmark/unbookmark job
- `refreshHome()` - Refresh all data

## 🧭 Navigation

Routes are defined using **GoRouter** with **ShellRoute**:

```dart
// Navigate to tabs
context.go('/home');           // Home tab
context.go('/my-jobs');        // Jobs tab
context.go('/notifications');  // Notifications tab
context.go('/profile');        // Profile tab

// Navigate to nested screens
context.push('/home/search');  // Job search
context.push('/home/filters'); // Job filters
```

## 📦 Dependencies

Required packages (in `pubspec.yaml`):
```yaml
dependencies:
  provider: ^6.1.2
  go_router: ^14.6.2
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  timeago: ^3.6.1
```

## 🎯 Usage Example

### Accessing Home Provider
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Read once (doesn't rebuild on changes)
    final homeProvider = context.read<HomeProvider>();

    // Watch (rebuilds on changes)
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: provider.recommendedJobs.length,
          itemBuilder: (context, index) {
            return JobCardWidget(job: provider.recommendedJobs[index]);
          },
        );
      },
    );
  }
}
```

### Navigating Between Tabs
```dart
// From anywhere in the app
context.go('/home');        // Navigate to home tab
context.go('/notifications'); // Navigate to notifications
```

### Bookmarking a Job
```dart
IconButton(
  icon: Icon(
    homeProvider.isJobBookmarked(jobId)
      ? Icons.bookmark
      : Icons.bookmark_border
  ),
  onPressed: () {
    homeProvider.toggleBookmark(jobId);
  },
)
```

## 🧪 Testing

### Unit Tests
```bash
flutter test test/features/home/providers/home_provider_test.dart
```

### Widget Tests
```bash
flutter test test/features/home/widgets/job_card_widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/home_flow_test.dart
```

## 🚀 Getting Started

1. **Ensure providers are registered** in `AppProvider`:
   ```dart
   await AppProvider.initializeServices();
   ```

2. **Navigate to home** after login:
   ```dart
   context.go('/home');
   ```

3. **Providers auto-initialize** when screens mount

## 🐛 Troubleshooting

### Jobs not loading?
- Check API endpoint configuration
- Verify user authentication token
- Check network connectivity
- Review console for error messages

### Bottom nav not working?
- Ensure ShellRoute is configured in router
- Check route paths match RouteNames constants
- Verify HomeShellScreen is properly wrapping child

### State not updating?
- Ensure using Consumer or context.watch()
- Check notifyListeners() is called in provider
- Verify provider is registered in AppProvider

## 📝 Best Practices

1. **Always use providers** - Don't make direct API calls from widgets
2. **Handle all states** - Loading, error, empty, success
3. **Use pull-to-refresh** - Let users manually refresh data
4. **Cache data** - Avoid excessive API calls
5. **Show loading indicators** - Keep users informed
6. **Handle errors gracefully** - Show retry buttons
7. **Use const constructors** - Improve performance
8. **Dispose resources** - Clean up in dispose()

## 📚 Related Documentation

- [Plan File](~/.claude/plans/flickering-puzzling-crane.md)
- [API Documentation](../../../../core/constants/v2_api_constants.dart)
- [Theme Guide](../../../../core/theme/app_colors.dart)
- [Router Setup](../../../../core/router/app_router.dart)

## 🤝 Contributing

When adding new features:
1. Follow clean architecture pattern
2. Create provider for state management
3. Add reusable widgets to widgets/
4. Document API endpoints
5. Add error handling
6. Write tests

## 📄 License

Part of JoinMeds Mobile Application
