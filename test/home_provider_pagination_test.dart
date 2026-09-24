import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:untitled/src/features/home/domain/repositories/home_repository.dart';
import 'package:untitled/src/features/home/presentation/providers/home_provider.dart';
import 'package:untitled/src/shared/models/v2/common/api_response.dart';
import 'package:untitled/src/shared/models/v2/job/job_details_dto.dart';
import 'package:untitled/src/shared/providers/user_provider.dart';
import 'package:untitled/src/shared/services/api/api_client.dart';
import 'package:untitled/src/shared/services/storage/local_storage_service.dart';
import 'package:untitled/src/shared/services/v2/repositories/interfaces/i_job_repo.dart';

/// Mimics GET /api/org-job/list: ignores limit and returns every job.
class _FakeHomeRepository implements IHomeRepository {
  _FakeHomeRepository(this.jobCount);

  int jobCount;
  int? lastLimit;
  int calls = 0;

  @override
  Future<ApiResponse<List<JobDetailsDTO>>> fetchRecommendedJobs({
    int? limit,
    dynamic cancelToken,
  }) async {
    calls++;
    lastLimit = limit;
    return ApiResponse(
      success: true,
      message: 'ok',
      data: List.generate(jobCount, (i) => JobDetailsDTO(id: 'job-$i')),
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
  late _FakeHomeRepository repo;
  late HomeProvider provider;

  Future<HomeProvider> build(int jobCount) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    repo = _FakeHomeRepository(jobCount);
    return HomeProvider(
      repo,
      _FakeJobRepo(),
      UserProvider(storage, ApiClient()),
      storage,
    );
  }

  test('does not truncate the job list to 20', () async {
    provider = await build(22);
    await provider.fetchRecommendedJobs();

    expect(repo.lastLimit, isNull);
    expect(provider.totalJobCount, 22);
  });

  test('reveals jobs one page at a time until all are shown', () async {
    provider = await build(22);
    await provider.fetchRecommendedJobs();

    expect(provider.recommendedJobs.length, 10);
    expect(provider.hasMoreJobs, isTrue);

    await provider.loadMoreJobs();
    expect(provider.recommendedJobs.length, 20);
    expect(provider.hasMoreJobs, isTrue);

    await provider.loadMoreJobs();
    expect(provider.recommendedJobs.length, 22);
    expect(provider.hasMoreJobs, isFalse);
    expect(provider.recommendedJobs.last.id, 'job-21');

    // Extra calls from the scroll listener must be harmless.
    await provider.loadMoreJobs();
    expect(provider.recommendedJobs.length, 22);
  });

  test('fewer jobs than one page shows them all with nothing more', () async {
    provider = await build(4);
    await provider.fetchRecommendedJobs();

    expect(provider.recommendedJobs.length, 4);
    expect(provider.hasMoreJobs, isFalse);
  });

  test('pull-to-refresh bypasses the cache and resets to page one', () async {
    provider = await build(22);
    await provider.fetchRecommendedJobs();
    await provider.loadMoreJobs();
    expect(provider.recommendedJobs.length, 20);

    repo.jobCount = 25; // admin posted three more jobs
    await provider.refreshHome();

    expect(repo.calls, 2);
    expect(provider.totalJobCount, 25);
    expect(provider.recommendedJobs.length, 10);
  });
}
