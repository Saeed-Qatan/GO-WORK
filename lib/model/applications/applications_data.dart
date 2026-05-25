part of 'application_model.dart';

class ApplicationsData {
  final List<ApplicationModel> applications;
  final List<ApplicationStatusModel> statuses;

  const ApplicationsData({required this.applications, required this.statuses});
}
