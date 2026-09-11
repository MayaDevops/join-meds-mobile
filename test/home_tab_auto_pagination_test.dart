import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:untitled/src/features/home/domain/repositories/home_repository.dart';
import 'package:untitled/src/features/home/presentation/providers/home_provider.dart';
import 'package:untitled/src/features/home/presentation/screens/home_tab_screen.dart';
import 'package:untitled/src/shared/models/v2/common/api_response.dart';
import 'package:untitled/src/shared/models/v2/job/job_details_dto.dart';
import 'package:untitled/src/shared/providers/user_provider.dart';
import 'package:untitled/src/shared/services/api/api_client.dart';
import 'package:untitled/src/shared/services/storage/local_storage_service.dart';
import 'package:untitled/src/shared/services/v2/repositories/interfaces/i_job_repo.dart';

/// Mimics GET /api/org-job/list: ignores limit and returns every job.
class _FakeHomeRepository implements IHomeRepository {
  _FakeHomeRepository(this.jobCount);

  final int jobCount;

  @override
  Future<ApiResponse<List<JobDetailsDTO>>> fetchRecommendedJobs({
    int? limit,
    dynamic cancelToken,
  }) async {
    return ApiResponse(
      success: true,
      message: 'ok',
      data: List.generate(
        jobCount,
        (i) => JobDetailsDTO(
          id: 'job-$i',
          hiringFor: 'Job $i',
          orgName: 'Org $i',
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeJobRepo implements IJobRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HomeProvider homeProvider;

  Future<void> pumpHome(WidgetTester tester, {required int jobCount}) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    final userProvider = UserProvider(storage, ApiClient());
    homeProvider = HomeProvider(
      _FakeHomeRepository(jobCount),
      _FakeJobRepo(),
      userProvider,
      storage,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
        ],
        child: const MaterialApp(home: HomeTabScreen()),
      ),
    );

    // The banner animates forever, so pumpAndSettle would never return.
    await _pumpFrames(tester);
  }

  testWidgets('scrolling down keeps loading until every job is shown',
      (tester) async {
    await pumpHome(tester, jobCount: 22);

    expect(homeProvider.totalJobCount, 22);
    expect(homeProvider.recommendedJobs.length, 10);

    for (var i = 0; i < 10 && homeProvider.hasMoreJobs; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await _pumpFrames(tester);
    }

    expect(homeProvider.recommendedJobs.length, 22);
    expect(homeProvider.hasMoreJobs, isFalse);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await _pumpFrames(tester);
    expect(find.text("You've seen all 22 jobs"), findsOneWidget);
    expect(find.text('Job 21'), findsOneWidget);
  });

  testWidgets('loads more on its own when the jobs do not fill the screen',
      (tester) async {
    // A very tall screen: the first 10 jobs end well inside the viewport, so
    // there is nothing to scroll. A scroll-only trigger would stall at 10.
    tester.view.physicalSize = const Size(800, 12000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpHome(tester, jobCount: 22);

    expect(homeProvider.recommendedJobs.length, 22);
    expect(homeProvider.hasMoreJobs, isFalse);
  });

  testWidgets('does not load past the first page before the user scrolls',
      (tester) async {
    await pumpHome(tester, jobCount: 22);
    await _pumpFrames(tester);

    expect(homeProvider.recommendedJobs.length, 10);
  });
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
