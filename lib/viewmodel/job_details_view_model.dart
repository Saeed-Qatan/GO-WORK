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
        if (_jobDetails != null) {
          _jobDetails = JobModel(
            id: job.id,
            title: job.title.isNotEmpty ? job.title : _jobDetails!.title,
            company: job.company.isNotEmpty ? job.company : _jobDetails!.company,
            companyLogoUrl: job.companyLogoUrl.isNotEmpty ? job.companyLogoUrl : _jobDetails!.companyLogoUrl,
            category: job.category.isNotEmpty ? job.category : _jobDetails!.category,
            location: job.location.isNotEmpty ? job.location : _jobDetails!.location,
            country: job.country.isNotEmpty ? job.country : _jobDetails!.country,
            type: job.type.isNotEmpty ? job.type : _jobDetails!.type,
            workMode: job.workMode.isNotEmpty ? job.workMode : _jobDetails!.workMode,
            minSalary: job.minSalary.isNotEmpty ? job.minSalary : _jobDetails!.minSalary,
            maxSalary: job.maxSalary.isNotEmpty ? job.maxSalary : _jobDetails!.maxSalary,
            description: job.description ?? _jobDetails!.description,
            currency: job.currency ?? _jobDetails!.currency,
            postedDate: job.postedDate ?? _jobDetails!.postedDate,
            expirationDate: job.expirationDate ?? _jobDetails!.expirationDate,
            skills: job.skills != null && job.skills!.isNotEmpty ? job.skills : _jobDetails!.skills,
            canApply: job.canApply ?? _jobDetails!.canApply,
            contactNumber: job.contactNumber ?? _jobDetails!.contactNumber,
          );
        } else {
          _jobDetails = job;
        }
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
