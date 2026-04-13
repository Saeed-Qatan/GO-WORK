import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../services/job_service.dart';
import '../utils/snackbar_service.dart';

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
            company: job.company.isNotEmpty
                ? job.company
                : _jobDetails!.company,
            companyLogoUrl: job.companyLogoUrl.isNotEmpty
                ? job.companyLogoUrl
                : _jobDetails!.companyLogoUrl,
            category: job.category.isNotEmpty
                ? job.category
                : _jobDetails!.category,
            location: job.location.isNotEmpty
                ? job.location
                : _jobDetails!.location,
            country: job.country.isNotEmpty
                ? job.country
                : _jobDetails!.country,
            type: job.type.isNotEmpty ? job.type : _jobDetails!.type,
            workMode: job.workMode.isNotEmpty
                ? job.workMode
                : _jobDetails!.workMode,
            minSalary: job.minSalary.isNotEmpty
                ? job.minSalary
                : _jobDetails!.minSalary,
            maxSalary: job.maxSalary.isNotEmpty
                ? job.maxSalary
                : _jobDetails!.maxSalary,
            description: job.description ?? _jobDetails!.description,
            currency: job.currency ?? _jobDetails!.currency,
            postedDate: job.postedDate ?? _jobDetails!.postedDate,
            expirationDate: job.expirationDate ?? _jobDetails!.expirationDate,
            skills: job.skills != null && job.skills!.isNotEmpty
                ? job.skills
                : _jobDetails!.skills,
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

  Future<void> applyToJob(BuildContext context, String jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _jobService.applyToJob(jobId);

      if (response['success'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        // Assume success if no success field but status is 2xx, or success is true
        // Also update local state so the apply button turns disabled immediately
        if (_jobDetails != null) {
          _jobDetails = _jobDetails!.copyWith(canApply: false);
        }

        // Show success msg
        String msg = 'تم التقديم بنجاح';
        if (response['data'] != null && response['data']['message'] != null) {
          msg = response['data']['message'];
        }
        SnackbarService.showSuccess(msg);
      } else {
        // Extract errors
        String errorMsg = 'Failed to apply';
        if (response['errors'] is List && response['errors'].isNotEmpty) {
          errorMsg = response['errors'].join('\n');
        }
        SnackbarService.showError(errorMsg);
      }
    } catch (e) {
      String parsedError = e.toString().replaceFirst('Exception: ', '');
      if (parsedError.contains('Job is closed or expired')) {
        parsedError = 'الوظيفة مغلقة أو منتهية الصلاحية.';
      } else if (parsedError.contains('errors: [')) {
        final match = RegExp(r'errors: \[(.*?)\]').firstMatch(parsedError);
        if (match != null && match.group(1) != null) {
          parsedError = match.group(1)!;
        }
      }
      SnackbarService.showError('فشل التقديم: $parsedError');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
