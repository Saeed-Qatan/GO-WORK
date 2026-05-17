import '../utils/status_translator.dart';

enum ApplicationStatus { sent, inReview, accepted, rejected, withdrawn }

class ApplicationModel {
  final String id;
  final String jobId;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final String statusName;
  final ApplicationStatus status;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.role,
    required this.company,
    required this.companyLogo,
    required this.date,
    required this.statusName,
    required this.status,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final statusStrRaw =
        json['applicationStatus'] ?? json['status'] ?? json['statusName'];
    final appStatus = StatusTranslator.getEnum(statusStrRaw?.toString());
    final jobObj = json['job'] as Map<String, dynamic>?;

    return ApplicationModel(
      id: json['applicationId']?.toString() ?? json['id']?.toString() ?? '',
      jobId: jobObj?['id']?.toString() ?? json['jobId']?.toString() ?? '',
      role:
          jobObj?['title']?.toString() ??
          json['jobTitle']?.toString() ??
          json['role']?.toString() ??
          'بدون مسمى',
      company:
          jobObj?['companyName']?.toString() ??
          json['companyName']?.toString() ??
          json['company']?.toString() ??
          'غير معروف',
      companyLogo:
          jobObj?['companyLogo']?.toString() ??
          json['companyLogo']?.toString() ??
          '',
      date:
          json['appliedDate']?.toString() ??
          json['appliedAt']?.toString() ??
          json['createdAt']?.toString() ??
          json['date']?.toString() ??
          '',
      statusName: appStatus.arabicLabel,
      status: appStatus,
    );
  }
}
