import 'package:flutter/foundation.dart';
import '../model/home_model.dart';
import '../services/job_service.dart';

class JobDetailsViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  JobModel? _jobDetails;
  JobModel? get jobDetails => _jobDetails;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchJobDetails(String jobId) async {
    _isLoading = true;
    _errorMessage = null;
    // We notify listeners so the view can show a loading state
    notifyListeners();

    try {
      final job = await _jobService.getJobById(jobId);
      if (job != null) {
        _jobDetails = job;
      } else {
        _errorMessage = 'Failed to load details.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Allow passing the initial job model so we don't start from null
  void setInitialJob(JobModel job) {
    if (_jobDetails == null || _jobDetails!.id != job.id) {
      _jobDetails = job;
    }
  }
}
