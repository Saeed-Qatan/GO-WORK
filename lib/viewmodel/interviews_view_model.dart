import 'package:flutter/material.dart';

import '../model/interview_model.dart';
import '../repository/interviews_repository.dart';
import '../utils/app_error_parser.dart';

/// Manages state and business logic for the Interviews screen.
///
/// The [IInterviewsRepository] is injected via the constructor to keep
/// this ViewModel fully testable without any framework dependency.
class InterviewsViewModel extends ChangeNotifier {
  final IInterviewsRepository _repository;

  InterviewsViewModel({required IInterviewsRepository repository})
      : _repository = repository;

  // ── State ───────────────────────────────────────────────────────────────

  List<InterviewModel> _interviews = [];
  List<InterviewModel> get interviews => List.unmodifiable(_interviews);

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
    if (showLoading) _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _interviews = await _repository.getInterviews();
    } catch (e) {
      _errorMessage = AppErrorParser.parse(e);
    } finally {
      if (showLoading) _isLoading = false;
      notifyListeners();
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
        _successMessage = response['data']?['message']?.toString() ??
            _defaultSuccessMessage(action);
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
    final newStatus = action.toLowerCase() == 'confirm'
        ? InterviewStatus.confirmed
        : InterviewStatus.declined;

    _interviews = _interviews.map((interview) {
      return interview.id == interviewId
          ? interview.copyWith(status: newStatus)
          : interview;
    }).toList();
  }

  String _defaultSuccessMessage(String action) {
    return action.toLowerCase() == 'confirm'
        ? 'تم تأكيد المقابلة بنجاح'
        : 'تم إلغاء المقابلة بنجاح';
  }

  void _clearSubmitting() {
    _submittingInterviewId = null;
    _submittingAction = null;
  }
}
