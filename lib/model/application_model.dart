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
    // Determine status
    final statusStrRaw = json['applicationStatus'] ?? json['status'] ?? json['statusName'];
    final statusStr = statusStrRaw?.toString() ?? '';
    
    ApplicationStatus appStatus = StatusTranslator.getEnum(statusStr);
    
    // Handle nested job object if present
    final jobObj = json['job'] as Map<String, dynamic>?;

    return ApplicationModel(
      id: json['applicationId']?.toString() ?? json['id']?.toString() ?? '',
      jobId: jobObj?['id']?.toString() ?? json['jobId']?.toString() ?? '',
      role: jobObj?['title'] ?? json['jobTitle'] ?? json['role'] ?? 'بدون مسمى',
      company: jobObj?['companyName'] ?? json['companyName'] ?? json['company'] ?? 'غير معروف',
      companyLogo: jobObj?['companyLogo'] ?? json['companyLogo'] ?? '',
      date: json['appliedDate'] ?? json['appliedAt'] ?? json['createdAt'] ?? json['date'] ?? '',
      statusName: appStatus.arabicLabel,
      status: appStatus,
    );
  }
}

