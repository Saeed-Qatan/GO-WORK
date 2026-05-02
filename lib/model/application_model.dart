enum ApplicationStatus { sent, inReview, accepted, rejected }

class ApplicationModel {
  final String id;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final String statusName;
  final ApplicationStatus status;

  ApplicationModel({
    required this.id,
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
    final statusStr = statusStrRaw?.toString().toLowerCase() ?? '';
    final statusNameRaw = statusStrRaw ?? 'قيد المراجعة';
    
    ApplicationStatus appStatus = ApplicationStatus.sent;
    if (statusStr.contains('review') || statusStr == '2') {
      appStatus = ApplicationStatus.inReview;
    } else if (statusStr.contains('accept') || statusStr == '3') {
      appStatus = ApplicationStatus.accepted;
    } else if (statusStr.contains('reject') || statusStr == '4') {
      appStatus = ApplicationStatus.rejected;
    }

    // Handle nested job object if present
    final jobObj = json['job'] as Map<String, dynamic>?;

    return ApplicationModel(
      id: json['applicationId']?.toString() ?? json['id']?.toString() ?? '',
      role: jobObj?['title'] ?? json['jobTitle'] ?? json['role'] ?? 'بدون مسمى',
      company: jobObj?['companyName'] ?? json['companyName'] ?? json['company'] ?? 'غير معروف',
      companyLogo: jobObj?['companyLogo'] ?? json['companyLogo'] ?? '',
      date: json['appliedDate'] ?? json['appliedAt'] ?? json['createdAt'] ?? json['date'] ?? '',
      statusName: statusNameRaw.toString(),
      status: appStatus,
    );
  }
}
