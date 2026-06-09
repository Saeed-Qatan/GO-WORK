import 'package:flutter/foundation.dart';

import '../model/home/home_model.dart';
import 'session_resettable.dart';

class JobApplicationStateViewModel extends ChangeNotifier
    implements SessionResettable {
  final Map<String, bool> _canApplyByJobId = {};

  bool canApplyFor(JobModel job) {
    final localState = _canApplyByJobId[job.id];
    return localState ?? job.canApply ?? true;
  }

  JobModel resolveJob(JobModel job) {
    return job.copyWith(canApply: canApplyFor(job));
  }

  void markApplied(String jobId) {
    _setCanApply(jobId, false);
  }

  void markWithdrawn(String jobId) {
    _setCanApply(jobId, true);
  }

  void _setCanApply(String jobId, bool canApply) {
    final normalizedJobId = jobId.trim();
    if (normalizedJobId.isEmpty) return;
    if (_canApplyByJobId[normalizedJobId] == canApply) return;

    _canApplyByJobId[normalizedJobId] = canApply;
    notifyListeners();
  }

  @override
  void resetSessionState({bool notify = true}) {
    _canApplyByJobId.clear();
    if (notify) notifyListeners();
  }
}
