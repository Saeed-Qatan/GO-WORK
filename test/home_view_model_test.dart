import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/home/home_model.dart';
import 'package:gowork/model/profile_model.dart';
import 'package:gowork/repository/home_repository.dart';
import 'package:gowork/repository/profile_repository.dart';
import 'package:gowork/viewmodel/home_view_model.dart';

class _FakeHomeRepository extends HomeRepository {
  int clearCacheCount = 0;

  @override
  Future<List<StatModel>> getStats() async {
    return [StatModel(count: '3', label: 'Applications', type: StatType.sent)];
  }

  @override
  Future<List<JobModel>> getRecommendedJobs() async {
    return [
      JobModel(
        id: 'job-1',
        title: 'Flutter Developer',
        company: 'Masarak',
        companyLogoUrl: '',
        category: 'Mobile',
        location: 'Sanaa',
        country: 'Yemen',
        type: 'FullTime',
        workMode: 'Remote',
        minSalary: '100',
        maxSalary: '200',
      ),
    ];
  }

  @override
  Future<String> getUserName() async => 'Fallback Name';

  @override
  void clearCache() {
    clearCacheCount++;
  }
}

class _FakeProfileRepository extends ProfileRepository {
  @override
  Future<ProfileModel> getUserProfile() async {
    return ProfileModel(
      firstName: 'User',
      middleName: '',
      lastName: 'A',
      jobTitle: 'Developer',
      avatarUrl: 'avatar-a.png',
      email: 'a@example.com',
      phone: '123',
      cvUrl: '',
      categoryId: 'cat-a',
      skills: const ['Flutter'],
    );
  }
}

void main() {
  test('resetSessionState clears home data and repository cache', () async {
    final repository = _FakeHomeRepository();
    final viewModel = HomeViewModel(
      repository: repository,
      profileRepository: _FakeProfileRepository(),
    );

    await viewModel.fetchHomeData();
    viewModel.onSearchChanged('flutter');
    viewModel.setTabIndex(2);

    expect(viewModel.stats, isNotEmpty);
    expect(viewModel.jobs, isNotEmpty);
    expect(viewModel.userName, 'User A');
    expect(viewModel.userProfileImage, 'avatar-a.png');
    expect(viewModel.searchQuery, 'flutter');
    expect(viewModel.selectedIndex, 2);

    viewModel.resetSessionState();

    expect(viewModel.stats, isEmpty);
    expect(viewModel.jobs, isEmpty);
    expect(viewModel.userName, isEmpty);
    expect(viewModel.userProfileImage, isEmpty);
    expect(viewModel.searchQuery, isEmpty);
    expect(viewModel.selectedIndex, 0);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, isNull);
    expect(repository.clearCacheCount, 1);
  });
}
