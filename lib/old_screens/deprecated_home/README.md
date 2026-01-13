# Deprecated Home Screen Files

This directory contains archived files from the old home screen implementation.

## Migration Date
January 2, 2026

## Reason for Deprecation
These files have been replaced with a new V2 home screen implementation following clean architecture principles.

## Old Files (Archived)
- `home_screen.dart` - Old home screen with bottom navigation (moved to `/home-old` route)
- `my_jobs_screen.dart` - Old jobs tab (replaced by `lib/src/features/home/presentation/screens/jobs_tab_screen.dart`)
- `user_notification.dart` - Old notifications (replaced by `lib/src/features/home/presentation/screens/notifications_tab_screen.dart`)

## New Implementation Location
New home screen implementation: `lib/src/features/home/`

### New Routes
- `/home` - Home tab with job recommendations
- `/my-jobs` - My Applications tab
- `/notifications` - Notifications tab
- `/profile` - Profile tab

## Key Improvements in V2
1. **Clean Architecture**: Separation of data/domain/presentation layers
2. **State Management**: Provider pattern with ChangeNotifier
3. **Bottom Navigation**: Persistent ShellRoute with GoRouter
4. **Modern UI**: Redesigned to match new design system
5. **Reusable Components**: Widget library for consistency
6. **API Integration**: Repository pattern with proper error handling
7. **Performance**: Caching, pull-to-refresh, optimistic updates

## Migration Notes
- Old route `/home` now redirected to V2 home screen
- Old route `/home-old` available for rollback if needed
- All functionality preserved and enhanced
- User data migration handled automatically via providers

## Rollback Instructions
If rollback is needed:
1. Update `app_router.dart` to point `/home` to old `HomeScreen`
2. Revert `AppProvider` changes to remove home providers
3. Comment out ShellRoute in router

## Contact
For questions about the migration, refer to the implementation plan at:
`~/.claude/plans/flickering-puzzling-crane.md`
