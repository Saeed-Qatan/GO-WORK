import 'package:flutter/foundation.dart';
import '../model/applications/application_model.dart';
import '../services/applications_service.dart';
import '../utils/status_translator.dart';

abstract class IApplicationsRepository {
  Future<ApplicationsData> getApplicationsData();

  Future<List<ApplicationStatusModel>> getApplicationStatuses();

  Future<List<ApplicationModel>> getApplications({
    List<ApplicationStatusModel>? statuses,
  });

  Future<void> withdrawApplication(String applicationId);
}

class ApplicationsRepository implements IApplicationsRepository {
  final ApplicationsService _service;

  ApplicationsRepository({ApplicationsService? service})
    : _service = service ?? ApplicationsService();

  @override
  Future<ApplicationsData> getApplicationsData() async {
    final statuses = await getApplicationStatuses();
    final applications = await getApplications(statuses: statuses);

    return ApplicationsData(applications: applications, statuses: statuses);
  }

  @override
  Future<List<ApplicationStatusModel>> getApplicationStatuses() async {
    final response = await _service.getApplicationStatuses();
    final rawStatuses = _extractList(response);

    return rawStatuses
        .map(_parseStatus)
        .where((status) => status.value.isNotEmpty || status.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<ApplicationModel>> getApplications({
    List<ApplicationStatusModel>? statuses,
  }) async {
    debugPrint('=== APPLICATIONS: Fetching applications ===');
    final response = await _service.getApplications();
    final rawApplications = _extractList(response);

    final applications = <ApplicationModel>[];

    for (final rawApplication in rawApplications) {
      try {
        final application = _parseApplication(rawApplication);
        if (application.id.isNotEmpty) {
          applications.add(_attachBackendStatus(application, statuses ?? []));
        }
      } catch (error) {
        debugPrint('=== APPLICATIONS: Skipping invalid item: $error ===');
      }
    }

    return applications;
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    final response = await _service.withdrawApplication(applicationId);

    if (response['success'] == false) {
      throw Exception(
        StatusTranslator.backendMessage(
          _extractBackendMessage(response),
          fallbackMessage: 'لا يمكن سحب هذا الطلب في وضعه الحالي',
        ),
      );
    }
  }

  ApplicationStatusModel _parseStatus(dynamic status) {
    if (status is Map<String, dynamic>) {
      return ApplicationStatusModel.fromJson(status);
    }
    if (status is Map) {
      return ApplicationStatusModel.fromJson(Map<String, dynamic>.from(status));
    }
    return ApplicationStatusModel.fromValue(status);
  }

  ApplicationModel _parseApplication(dynamic application) {
    if (application is Map<String, dynamic>) {
      return ApplicationModel.fromJson(application);
    }
    if (application is Map) {
      return ApplicationModel.fromJson(Map<String, dynamic>.from(application));
    }

    throw const FormatException('Invalid application item');
  }

  ApplicationModel _attachBackendStatus(
    ApplicationModel application,
    List<ApplicationStatusModel> statuses,
  ) {
    for (final status in statuses) {
      if (status.matches(application)) {
        return application.attachStatus(status);
      }
    }

    return application;
  }

  List<dynamic> _extractList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) return data;

    if (data is Map) {
      for (final key in const [
        'items',
        'applications',
        'statuses',
        'applicationStatuses',
        'applicationStatus',
      ]) {
        final value = data[key];
        if (value is List) return value;
      }
    }

    for (final key in const [
      'items',
      'applications',
      'statuses',
      'applicationStatuses',
      'applicationStatus',
    ]) {
      final value = response[key];
      if (value is List) return value;
    }

    return const [];
  }

  String? _extractBackendMessage(Map<String, dynamic> response) {
    final errors = response['errors'];
    if (errors is List && errors.isNotEmpty) return errors.join('\n');
    if (errors is String && errors.trim().isNotEmpty) return errors;

    final message = response['message'];
    if (message != null) return message.toString();

    final data = response['data'];
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return null;
  }
}
