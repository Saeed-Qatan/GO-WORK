import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/interview_model.dart';
import '../repository/interviews_repository.dart';
import '../utils/app_error_parser.dart';
import '../utils/local_storage.dart';
import '../utils/status_translator.dart';
import 'session_resettable.dart';

/// Manages state and business logic for the Interviews screen.
///
/// The [IInterviewsRepository] is injected via the constructor to keep
/// this ViewModel fully testable without any framework dependency.
class InterviewsViewModel extends ChangeNotifier implements SessionResettable {
  static const String _localStatusesStorageKeyPrefix =
      'interview_local_statuses';
  static const String _deletedInterviewIdsStorageKeyPrefix =
      'deleted_interview_ids';
  static const String _archivedInterviewsStorageKeyPrefix =
      'archived_interviews';

  final IInterviewsRepository _repository;
  final LocalStorage _storage;
  int _sessionVersion = 0;

  InterviewsViewModel({
    required IInterviewsRepository repository,
    LocalStorage? storage,
  }) : _repository = repository,
       _storage = storage ?? LocalStorage();

  // ── State ───────────────────────────────────────────────────────────────

  List<InterviewModel> _interviews = [];
  final Set<String> _deletedInterviewIds = {};
  final Map<String, InterviewStatus> _localStatuses = {};
  final Map<String, InterviewModel> _archivedInterviewsById = {};
  bool _hasLoadedLocalStatuses = false;
  bool _hasLoadedDeletedInterviewIds = false;
  bool _hasLoadedArchivedInterviews = false;
  String? _loadedStorageScope;

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
      await _ensureLocalStateLoaded();
      final fetched = await _repository.getInterviews();
      if (requestVersion != _sessionVersion) return;
      bool localStatusesChanged = false;
      _interviews = fetched.map((interview) {
        if (_localStatuses.containsKey(interview.id)) {
          final localStatus = _localStatuses[interview.id]!;
          final backendStatus = interview.status;

          // If backend caught up, or progressed to a decisive terminal state,
          // we stop overriding and trust the backend.
          if (backendStatus == localStatus ||
              backendStatus == InterviewStatus.cancelled ||
              backendStatus == InterviewStatus.withdrawn ||
              backendStatus == InterviewStatus.missingInterview) {
            _localStatuses.remove(interview.id);
            localStatusesChanged = true;
            return interview;
          }

          return interview.copyWith(status: localStatus);
        }
        return interview;
      }).toList();

      if (localStatusesChanged) {
        // Run asynchronously so we don't block the mapping/rendering
        _persistLocalStatuses();
      }

      if (requestVersion != _sessionVersion) return;
      await _refreshArchivedSnapshotsFromFetchedInterviews();
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
    await _ensureLocalStateLoaded();
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
        await _persistLocalStatuses();
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


  Future<void> _ensureLocalStateLoaded() async {
    final scope = await _currentStorageScope();
    if (_loadedStorageScope != scope) {
      _resetLocalStateForScope(scope);
    }

    await _ensureLocalStatusesLoaded();
    await _ensureDeletedInterviewIdsLoaded();
    await _ensureArchivedInterviewsLoaded();
  }

  Future<void> _ensureLocalStatusesLoaded() async {
    if (_hasLoadedLocalStatuses) return;

    try {
      final raw = await _storage.getString(
        _scopedStorageKey(_localStatusesStorageKeyPrefix),
      );
      if (raw == null || raw.isEmpty) {
        _hasLoadedLocalStatuses = true;
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _localStatuses.clear();
        decoded.forEach((key, value) {
          final status = _statusFromStorageValue(value);
          if (status != null) {
            _localStatuses[key] = status;
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to load local interview statuses: $e');
    } finally {
      _hasLoadedLocalStatuses = true;
    }
  }

  Future<void> _ensureDeletedInterviewIdsLoaded() async {
    if (_hasLoadedDeletedInterviewIds) return;

    try {
      final raw = await _storage.getString(
        _scopedStorageKey(_deletedInterviewIdsStorageKeyPrefix),
      );
      if (raw == null || raw.isEmpty) {
        _hasLoadedDeletedInterviewIds = true;
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _deletedInterviewIds
          ..clear()
          ..addAll(decoded.whereType<String>());
      }
    } catch (e) {
      debugPrint('Failed to load deleted interview ids: $e');
    } finally {
      _hasLoadedDeletedInterviewIds = true;
    }
  }

  Future<void> _ensureArchivedInterviewsLoaded() async {
    if (_hasLoadedArchivedInterviews) return;

    try {
      final raw = await _storage.getString(
        _scopedStorageKey(_archivedInterviewsStorageKeyPrefix),
      );
      if (raw == null || raw.isEmpty) {
        _hasLoadedArchivedInterviews = true;
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _archivedInterviewsById.clear();
        for (final item in decoded.whereType<Map>()) {
          final interview = InterviewModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          if (interview.id.isNotEmpty) {
            _archivedInterviewsById[interview.id] = interview;
            _deletedInterviewIds.add(interview.id);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load archived interviews: $e');
    } finally {
      _hasLoadedArchivedInterviews = true;
    }
  }

  Future<void> _persistLocalStatuses() async {
    try {
      final encoded = jsonEncode(
        _localStatuses.map((key, value) => MapEntry(key, value.name)),
      );
      await _storage.saveString(
        _scopedStorageKey(_localStatusesStorageKeyPrefix),
        encoded,
      );
    } catch (e) {
      debugPrint('Failed to save local interview statuses: $e');
    }
  }

  Future<void> _persistDeletedInterviewIds() async {
    try {
      final ids = _deletedInterviewIds.toList()..sort();
      await _storage.saveString(
        _scopedStorageKey(_deletedInterviewIdsStorageKeyPrefix),
        jsonEncode(ids),
      );
    } catch (e) {
      debugPrint('Failed to save deleted interview ids: $e');
    }
  }

  Future<void> _persistArchivedInterviews() async {
    try {
      final encoded = jsonEncode(
        _archivedInterviewsById.values
            .map((interview) => interview.toJson())
            .toList(),
      );
      await _storage.saveString(
        _scopedStorageKey(_archivedInterviewsStorageKeyPrefix),
        encoded,
      );
    } catch (e) {
      debugPrint('Failed to save archived interviews: $e');
    }
  }

  Future<void> _refreshArchivedSnapshotsFromFetchedInterviews() async {
    var changed = false;

    for (final interview in _interviews) {
      if (_deletedInterviewIds.contains(interview.id)) {
        _archivedInterviewsById[interview.id] = interview;
        changed = true;
      }
    }

    if (changed) {
      await _persistArchivedInterviews();
    }
  }

  Future<String> _currentStorageScope() async {
    final userId = (await _storage.getString('userId'))?.trim();
    return userId == null || userId.isEmpty ? 'anonymous' : userId;
  }

  String _scopedStorageKey(String prefix) {
    return '${prefix}_${_loadedStorageScope ?? 'anonymous'}';
  }

  void _resetLocalStateForScope(String scope) {
    _localStatuses.clear();
    _deletedInterviewIds.clear();
    _archivedInterviewsById.clear();
    _hasLoadedLocalStatuses = false;
    _hasLoadedDeletedInterviewIds = false;
    _hasLoadedArchivedInterviews = false;
    _loadedStorageScope = scope;
  }

  InterviewStatus? _statusFromStorageValue(Object? value) {
    if (value is! String) return null;

    for (final status in InterviewStatus.values) {
      if (status.name == value) return status;
    }

    return null;
  }

  String _defaultSuccessMessage(String action) {
    return action.toLowerCase() == 'confirm'
        ? 'تم تأكيد المقابلة بنجاح'
        : 'تم إلغاء المقابلة بنجاح';
  }

  /// Dismisses an interview locally (nests it under deleted interviews).
  Future<void> dismissInterview(String interviewId) async {
    await _ensureLocalStateLoaded();
    final interview = _findInterview(interviewId);
    if (interview != null) {
      _archivedInterviewsById[interviewId] = interview;
    }
    _deletedInterviewIds.add(interviewId);
    notifyListeners();
    await _persistDeletedInterviewIds();
    await _persistArchivedInterviews();
  }

  /// Restores a locally dismissed/deleted interview.
  Future<void> restoreInterview(String interviewId) async {
    await _ensureLocalStateLoaded();
    final archivedInterview = _archivedInterviewsById[interviewId];
    _deletedInterviewIds.remove(interviewId);
    _archivedInterviewsById.remove(interviewId);
    if (archivedInterview != null &&
        !_interviews.any((interview) => interview.id == interviewId)) {
      _interviews = [archivedInterview, ..._interviews];
    }
    notifyListeners();
    await _persistDeletedInterviewIds();
    await _persistArchivedInterviews();
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
    _resetLocalStateForScope('anonymous');
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _clearSubmitting();
    if (notify) notifyListeners();
  }
}
