import 'package:flutter/material.dart';

import '../model/interview_model.dart';
import '../repository/interviews_repository.dart';
import '../utils/app_error_parser.dart';
import '../utils/status_translator.dart';
import 'session_resettable.dart';

/// Manages state and business logic for the Interviews screen.
///
/// The [IInterviewsRepository] is injected via the constructor to keep
/// this ViewModel fully testable without any framework dependency.
class InterviewsViewModel extends ChangeNotifier implements SessionResettable {
  final IInterviewsRepository _repository;
  int _sessionVersion = 0;

  InterviewsViewModel({required IInterviewsRepository repository})
    : _repository = repository;

  // ── State ───────────────────────────────────────────────────────────────

  List<InterviewModel> _interviews = [];
  final Set<String> _deletedInterviewIds = {};
  final Map<String, InterviewStatus> _localStatuses = {};
  final Map<String, InterviewModel> _archivedInterviewsById = {};

  /// Returns interviews that have NOT been locally deleted.
  List<InterviewModel> get interviews => List.unmodifiable(
    _interviews.where((i) => !_deletedInterviewIds.contains(i.id)),
  );

  /// Returns interviews that have been locally deleted.
  List<InterviewModel> get deletedInterviews {
    final byId = <String, InterviewModel>{
      for (final interview in _archivedInterviewsById.values)
        interview.id: interview,
      for (final interview in _interviews) interview.id: interview,
    };

    return List.unmodifiable(
      _deletedInterviewIds.map((id) => byId[id]).whereType<InterviewModel>(),
    );
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _submittingInterviewId;
  String? _submittingAction;

  // ── Derived state ────────────────────────────────────────────────────────

  int get confirmedCount =>
      _interviews.where((i) => i.status == InterviewStatus.confirmed).length;

  int get scheduledCount =>
      _interviews.where((i) => i.status == InterviewStatus.scheduled).length;

  /// True if ANY action for [interviewId] is in-flight.
  bool isSubmitting(String interviewId) =>
      _submittingInterviewId == interviewId;

  /// True if the specific [action] for [interviewId] is in-flight.
  bool isSubmittingAction(String interviewId, String action) =>
      _submittingInterviewId == interviewId && _submittingAction == action;

  // ── Commands ─────────────────────────────────────────────────────────────

  /// Loads (or reloads) the interview list.
  ///
  /// Pass [showLoading] = false for silent background refreshes.
  Future<void> fetchInterviews({bool showLoading = true}) async {
    final requestVersion = _sessionVersion;
    if (showLoading) _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.getInterviews();
      if (requestVersion != _sessionVersion) return;
      _interviews = fetched.map((interview) {
        final localStatus = _localStatuses[interview.id];
        if (localStatus == null) return interview;

        final backendStatus = interview.status;
        if (backendStatus == localStatus ||
            backendStatus == InterviewStatus.cancelled ||
            backendStatus == InterviewStatus.withdrawn ||
            backendStatus == InterviewStatus.missingInterview) {
          _localStatuses.remove(interview.id);
          return interview;
        }

        return interview.copyWith(status: localStatus);
      }).toList();
      _refreshArchivedSnapshotsFromFetchedInterviews();
    } catch (e) {
      if (requestVersion != _sessionVersion) return;
      _errorMessage = AppErrorParser.parse(e);
    } finally {
      if (requestVersion == _sessionVersion) {
        if (showLoading) _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Submits a confirm/cancel [action] for the given [interviewId].
  ///
  /// Returns true on success, false otherwise.
  /// Callers should read [successMessage] / [errorMessage] after the call.
  Future<bool> submitAction(
    String interviewId,
    String action, {
    String? notes,
  }) async {
    _submittingInterviewId = interviewId;
    _submittingAction = action;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.submitInterviewAction(
        interviewId,
        action,
        notes: notes,
      );

      if (response['success'] == true) {
        _applyStatusChange(interviewId, action);
        _successMessage = StatusTranslator.backendMessage(
          response['data']?['message']?.toString(),
          fallbackMessage: _defaultSuccessMessage(action),
        );
        _clearSubmitting();
        notifyListeners();
        await fetchInterviews(showLoading: false);
        return true;
      }

      _errorMessage = AppErrorParser.parseResponseData(
        response,
        fallbackMessage: 'تعذر تحديث حالة المقابلة، يرجى المحاولة مرة أخرى',
      );
      _clearSubmitting();
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = AppErrorParser.parse(e);
      _clearSubmitting();
      notifyListeners();
      return false;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  void _applyStatusChange(String interviewId, String action) {
    final newStatus = _statusForAction(action);

    _setInterviewStatus(interviewId, newStatus);
  }

  void _setInterviewStatus(String interviewId, InterviewStatus newStatus) {
    _localStatuses[interviewId] = newStatus;

    _interviews = _interviews.map((interview) {
      return interview.id == interviewId
          ? interview.copyWith(status: newStatus)
          : interview;
    }).toList();
  }

  InterviewStatus _statusForAction(String action) {
    final normalized = action.trim().toLowerCase();
    if (normalized == 'confirm') return InterviewStatus.confirmed;
    if (normalized == 'missinterview' ||
        normalized == 'missinginterview' ||
        normalized == 'missedinterview') {
      return InterviewStatus.missingInterview;
    }
    if (normalized == 'withdraw' ||
        normalized == 'withdrawn' ||
        normalized == 'cancel') {
      return InterviewStatus.withdrawn;
    }
    return InterviewStatus.cancelled;
  }

  void _refreshArchivedSnapshotsFromFetchedInterviews() {
    for (final interview in _interviews) {
      if (_deletedInterviewIds.contains(interview.id)) {
        _archivedInterviewsById[interview.id] = interview;
      }
    }
  }

  String _defaultSuccessMessage(String action) {
    return action.toLowerCase() == 'confirm'
        ? 'تم تأكيد المقابلة بنجاح'
        : 'تم إلغاء المقابلة بنجاح';
  }

  /// Dismisses an interview locally (nests it under deleted interviews).
  Future<void> dismissInterview(String interviewId) async {
    final interview = _findInterview(interviewId);
    if (interview != null) {
      _archivedInterviewsById[interviewId] = interview;
    }
    _deletedInterviewIds.add(interviewId);
    notifyListeners();
  }

  /// Restores a locally dismissed/deleted interview.
  Future<void> restoreInterview(String interviewId) async {
    final archivedInterview = _archivedInterviewsById[interviewId];
    _deletedInterviewIds.remove(interviewId);
    _archivedInterviewsById.remove(interviewId);
    if (archivedInterview != null &&
        !_interviews.any((interview) => interview.id == interviewId)) {
      _interviews = [archivedInterview, ..._interviews];
    }
    notifyListeners();
  }

  InterviewModel? _findInterview(String interviewId) {
    for (final interview in _interviews) {
      if (interview.id == interviewId) return interview;
    }

    return _archivedInterviewsById[interviewId];
  }

  void _clearSubmitting() {
    _submittingInterviewId = null;
    _submittingAction = null;
  }

  @override
  void resetSessionState({bool notify = true}) {
    _sessionVersion++;
    _interviews = [];
    _deletedInterviewIds.clear();
    _localStatuses.clear();
    _archivedInterviewsById.clear();
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _clearSubmitting();
    if (notify) notifyListeners();
  }
}
