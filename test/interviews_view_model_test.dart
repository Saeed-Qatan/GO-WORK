import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/interview_model.dart';
import 'package:gowork/repository/interviews_repository.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:gowork/viewmodel/interviews_view_model.dart';
import 'package:gowork/widget/interviews/interview_status_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeInterviewsRepository implements IInterviewsRepository {
  final List<InterviewModel> interviews;
  int submitCount = 0;
  final List<String> submittedActions = [];
  final List<String> submittedIds = [];

  String? get submittedAction =>
      submittedActions.isEmpty ? null : submittedActions.last;

  _FakeInterviewsRepository(this.interviews);

  @override
  Future<List<InterviewModel>> getInterviews() async {
    return interviews;
  }

  @override
  Future<Map<String, dynamic>> submitInterviewAction(
    String id,
    String action, {
    String? notes,
  }) async {
    submitCount++;
    submittedActions.add(action);
    submittedIds.add(id);
    return {
      'success': true,
      'data': {'message': 'ok'},
    };
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'cancel action persists withdrawn status across view model recreation',
    () async {
      final scheduledInterview = _interview(status: InterviewStatus.scheduled);
      final firstRepository = _FakeInterviewsRepository([scheduledInterview]);
      final firstViewModel = InterviewsViewModel(repository: firstRepository);

      await firstViewModel.fetchInterviews();
      expect(
        firstViewModel.interviews.single.status,
        InterviewStatus.scheduled,
      );

      final success = await firstViewModel.submitAction(
        'interview-1',
        'cancel',
      );

      expect(success, isTrue);
      expect(firstRepository.submitCount, 1);
      expect(firstRepository.submittedAction, 'cancel');
      expect(firstViewModel.interviews.single.status, InterviewStatus.withdrawn);

      final reopenedRepository = _FakeInterviewsRepository([
        scheduledInterview,
      ]);
      final reopenedViewModel = InterviewsViewModel(
        repository: reopenedRepository,
      );

      await reopenedViewModel.fetchInterviews();

      expect(
        reopenedViewModel.interviews.single.status,
        InterviewStatus.withdrawn,
      );
    },
  );

  test('withdraw interview status parses and displays as Arabic label', () {
    final interview = InterviewModel.fromJson({
      'id': 'interview-1',
      'status': 'withdraw',
    });

    expect(interview.status, InterviewStatus.withdrawn);
    expect(InterviewStatusMapper.forStatus(interview.status).label, 'منسحب');
    expect(interview.toJson()['status'], 'withdraw');
  });



  test('missed interview status parses and displays as Arabic label', () {
    final interview = InterviewModel.fromJson({
      'id': 'interview-1',
      'status': 'MissedInterview',
    });

    expect(interview.status, InterviewStatus.missingInterview);
    expect(InterviewStatusMapper.forStatus(interview.status).label, 'فائتة');
  });

  test(
    'archived interviews stay archived across view model recreation',
    () async {
      final firstInterview = _interview(id: 'interview-1');
      final secondInterview = _interview(id: 'interview-2');
      final firstViewModel = InterviewsViewModel(
        repository: _FakeInterviewsRepository([
          firstInterview,
          secondInterview,
        ]),
      );

      await firstViewModel.fetchInterviews();
      await firstViewModel.dismissInterview('interview-1');
      await LocalStorage().clear();

      expect(firstViewModel.interviews.map((item) => item.id), ['interview-2']);
      expect(firstViewModel.deletedInterviews.single.id, 'interview-1');

      final reopenedViewModel = InterviewsViewModel(
        repository: _FakeInterviewsRepository([
          firstInterview,
          secondInterview,
        ]),
      );

      await reopenedViewModel.fetchInterviews();

      expect(reopenedViewModel.interviews.map((item) => item.id), [
        'interview-2',
      ]);
      expect(reopenedViewModel.deletedInterviews.single.id, 'interview-1');
    },
  );

  test('archived interviews remain visible when backend omits them', () async {
    final firstInterview = _interview(id: 'interview-1');
    final secondInterview = _interview(id: 'interview-2');
    final firstViewModel = InterviewsViewModel(
      repository: _FakeInterviewsRepository([firstInterview, secondInterview]),
    );

    await firstViewModel.fetchInterviews();
    await firstViewModel.dismissInterview('interview-1');

    final reopenedViewModel = InterviewsViewModel(
      repository: _FakeInterviewsRepository([secondInterview]),
    );

    await reopenedViewModel.fetchInterviews();

    expect(reopenedViewModel.interviews.map((item) => item.id), [
      'interview-2',
    ]);
    expect(reopenedViewModel.deletedInterviews.single.id, 'interview-1');
    expect(
      reopenedViewModel.deletedInterviews.single.role,
      firstInterview.role,
    );

    await reopenedViewModel.restoreInterview('interview-1');

    expect(reopenedViewModel.interviews.map((item) => item.id), [
      'interview-1',
      'interview-2',
    ]);
    expect(reopenedViewModel.deletedInterviews, isEmpty);
  });

  test('stored interview actions are scoped to the current user', () async {
    final storage = LocalStorage();
    final interview = _interview(id: 'shared-interview-id');

    await storage.saveString('userId', 'user-a');
    final userAViewModel = InterviewsViewModel(
      repository: _FakeInterviewsRepository([interview]),
    );
    await userAViewModel.fetchInterviews();
    await userAViewModel.dismissInterview('shared-interview-id');

    await storage.clear();
    await storage.saveString('userId', 'user-b');
    final userBViewModel = InterviewsViewModel(
      repository: _FakeInterviewsRepository([interview]),
    );
    await userBViewModel.fetchInterviews();

    expect(userBViewModel.interviews.single.id, 'shared-interview-id');
    expect(userBViewModel.deletedInterviews, isEmpty);

    await storage.clear();
    await storage.saveString('userId', 'user-a');
    final reopenedUserAViewModel = InterviewsViewModel(
      repository: _FakeInterviewsRepository(<InterviewModel>[]),
    );
    await reopenedUserAViewModel.fetchInterviews();

    expect(reopenedUserAViewModel.interviews, isEmpty);
    expect(
      reopenedUserAViewModel.deletedInterviews.single.id,
      'shared-interview-id',
    );
  });

  test(
    'session reset clears memory without deleting scoped local state',
    () async {
      final storage = LocalStorage();
      final interview = _interview(id: 'interview-to-archive');

      await storage.saveString('userId', 'user-a');
      final viewModel = InterviewsViewModel(
        repository: _FakeInterviewsRepository([interview]),
      );

      await viewModel.fetchInterviews();
      await viewModel.dismissInterview('interview-to-archive');

      expect(viewModel.interviews, isEmpty);
      expect(viewModel.deletedInterviews.single.id, 'interview-to-archive');

      viewModel.resetSessionState();

      expect(viewModel.interviews, isEmpty);
      expect(viewModel.deletedInterviews, isEmpty);
      expect(
        await storage.getString('deleted_interview_ids_user-a'),
        isNotNull,
      );

      final reopenedViewModel = InterviewsViewModel(
        repository: _FakeInterviewsRepository(<InterviewModel>[]),
      );
      await reopenedViewModel.fetchInterviews();

      expect(
        reopenedViewModel.deletedInterviews.single.id,
        'interview-to-archive',
      );
    },
  );

  test(
    'restored interviews stay restored across view model recreation',
    () async {
      final firstInterview = _interview(id: 'interview-1');
      final secondInterview = _interview(id: 'interview-2');
      final firstViewModel = InterviewsViewModel(
        repository: _FakeInterviewsRepository([
          firstInterview,
          secondInterview,
        ]),
      );

      await firstViewModel.fetchInterviews();
      await firstViewModel.dismissInterview('interview-1');
      await firstViewModel.restoreInterview('interview-1');

      final reopenedViewModel = InterviewsViewModel(
        repository: _FakeInterviewsRepository([
          firstInterview,
          secondInterview,
        ]),
      );

      await reopenedViewModel.fetchInterviews();

      expect(reopenedViewModel.interviews, hasLength(2));
      expect(reopenedViewModel.deletedInterviews, isEmpty);
    },
  );
}

InterviewModel _interview({
  String id = 'interview-1',
  InterviewStatus status = InterviewStatus.scheduled,
  DateTime? scheduledAt,
}) {
  final interviewDate = scheduledAt ?? DateTime(2099);

  return InterviewModel(
    id: id,
    role: 'Flutter Developer',
    company: 'Masarak',
    date:
        '${interviewDate.year}-${_twoDigits(interviewDate.month)}-${_twoDigits(interviewDate.day)}',
    time:
        '${_twoDigits(interviewDate.hour)}:${_twoDigits(interviewDate.minute)}',
    scheduledAt: interviewDate,
    location: 'Online',
    status: status,
  );
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
